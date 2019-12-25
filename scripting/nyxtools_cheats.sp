#pragma semicolon 1
#include <sourcemod>
#include <nyxtools>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - Cheats",
  author = "JeremyDF93",
  description = "Allows admins to run cheat commands without setting sv_cheats",
  version = NYX_PLUGIN_VERSION,
  url = "https://praisethemoon.com/"
};

#define MAX_COMMANDS 512

/***
 *       ______          _    __               
 *      / ____/___  ____| |  / /___ ___________
 *     / /   / __ \/ __ \ | / / __ `/ ___/ ___/
 *    / /___/ /_/ / / / / |/ / /_/ / /  (__  ) 
 *    \____/\____/_/ /_/|___/\__,_/_/  /____/  
 *                                             
 */

ConVar nyx_cheats_override;
ConVar nyx_cheats_silent;
ConVar sv_cheats;
ConVar host_timescale;

/***
 *       ________      __          __    
 *      / ____/ /___  / /_  ____ _/ /____
 *     / / __/ / __ \/ __ \/ __ `/ / ___/
 *    / /_/ / / /_/ / /_/ / /_/ / (__  ) 
 *    \____/_/\____/_.___/\__,_/_/____/  
 *                                       
 */

char g_HookedCmd[MAX_COMMANDS][128];
int g_HookedCount = 0;

/***
 *        ____  __            _          ____      __            ____              
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________ 
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/ 
 *                  /____/                                                         
 */

public void OnPluginStart() {
  nyx_cheats_override = CreateConVar("nyx_cheats_override", "z", "Override flag required to execute cheat commands");
  nyx_cheats_silent = CreateConVar("nyx_cheats_silent", "1", "Hide activity");

  sv_cheats = FindConVar("sv_cheats");
  host_timescale = FindConVar("host_timescale");
  if (host_timescale != null) { // not all source games have this apparently...
    HookConVarChange(host_timescale, ConVarChanged_HostTimescale);
  }

  HookCheatCommands();
}

public void OnPluginEnd() {
  for (int i = 0; i < g_HookedCount; i++) {
    SetCommandFlags(g_HookedCmd[i], GetCommandFlags(g_HookedCmd[i]) | FCVAR_CHEAT);
  }
  LogAction(-1, -1, "Restored %i commands", g_HookedCount);
}

public void OnClientPostAdminCheck(int client) {
  if (IsValidClient(client, true)) {
    char flags[8];
    nyx_cheats_override.GetString(flags, sizeof(flags));

    if (strlen(flags) == 0 || IsClientAdmin(client, ReadFlagString(flags))) {
      ServerCommand("mp_disable_autokick %i", GetClientUserId(client)); // disabling autokick allows us to use ent_fire so lets do that
    }

    // we have to trick the client into thinking sv_cheats is enabled so host_timescale works...
    if (host_timescale != null) {
      if (host_timescale.FloatValue != 1.0) {
        SendConVarValue(client, sv_cheats, "1");
      }
    }
  }
}

/***
 *       ______      ______               __       
 *      / ____/___ _/ / / /_  ____ ______/ /_______
 *     / /   / __ `/ / / __ \/ __ `/ ___/ //_/ ___/
 *    / /___/ /_/ / / / /_/ / /_/ / /__/ ,< (__  ) 
 *    \____/\__,_/_/_/_.___/\__,_/\___/_/|_/____/  
 *                                                 
 */

// if host_timescale is not its default value fake sv_cheats for all clients
public void ConVarChanged_HostTimescale(ConVar convar, const char[] oldValue, const char[] newValue) {
  for (int i = 1; i <= MaxClients; i++) {
    if (IsValidClient(i, true)) {
      SendConVarValue(i, sv_cheats, StringToFloat(newValue) == 1.0 ? "0" : "1");
    }
  }
}

/***
 *       ______                                          __    
 *      / ____/___  ____ ___  ____ ___  ____ _____  ____/ /____
 *     / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
 *    / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  ) 
 *    \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/  
 *                                                             
 */

public Action ConCmd_Cheat(int client, int args) {
  char cmd[256], cmdArgs[256];
  GetCmdArg(0, cmd, 256);
  GetCmdArgString(cmdArgs, sizeof(cmdArgs));
  TrimString(cmdArgs);

  char flags[8];
  nyx_cheats_override.GetString(flags, sizeof(flags));

  if (client == 0 || strlen(flags) == 0 || IsClientAdmin(client, ReadFlagString(flags))) {
    LogAction(client, -1, "\"%L\" ran cheat command \"%s\" [%s]", client, cmd, cmdArgs);
    if (!nyx_cheats_silent.BoolValue) {
      NyxAct(client, "Ran cheat command \"%s\" [%s]", cmd, cmdArgs);
    }

    return Plugin_Continue;
  }

  LogAction(client, -1, "\"%L\" was prevented from running cheat command \"%s\" [%s]", client, cmd, cmdArgs);
  return Plugin_Handled;
}

/***
 *        ______                 __  _                 
 *       / ____/_  ______  _____/ /_(_)___  ____  _____
 *      / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
 *     / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
 *    /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/  
 *                                                     
 */

void HookCheatCommands() {
  char cmd[128];
  bool isCommand;
  int flags;
  Handle hCommand = FindFirstConCommand(cmd, sizeof(cmd), isCommand, flags);
  do {
    if (isCommand && flags & FCVAR_CHEAT && g_HookedCount < MAX_COMMANDS) {
      RegConsoleCmd(cmd, ConCmd_Cheat);
      SetCommandFlags(cmd, GetCommandFlags(cmd) ^ FCVAR_CHEAT);
      strcopy(g_HookedCmd[g_HookedCount++], 128, cmd);
    }

    if (g_HookedCount >= MAX_COMMANDS) {
      LogError("Failed to hook all cheat commands: MAX_COMMANDS reached");
      return;
    }
  } while (FindNextConCommand(hCommand, cmd, sizeof(cmd), isCommand, flags));

  LogAction(-1, -1, "Hooked %i commands", g_HookedCount);
}
