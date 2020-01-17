#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define NYXTOOLS_DEBUG 1
#include <nyxtools>
#include <nyxtools_cheats>

public Plugin myinfo = {
  name = "NyxTools - Cheats",
  author = NYXTOOLS_AUTHOR,
  description = "Allows admins to run cheat commands without setting sv_cheats",
  version = NYXTOOLS_VERSION,
  url = NYXTOOLS_WEBSITE
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
ConVar nyx_cheats_notify;
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

int g_iHookedCount = 0;
char g_sHookedCmd[MAX_COMMANDS][128];
bool g_bAllowOnce[MAXPLAYERS + 1];

/***
 *        ____  __            _          ____      __            ____
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/
 *                  /____/
 */

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  RegPluginLibrary("nyxtools_cheats");

  CreateNative("ExecuteCheatCommand", Native_ExecuteCheatCommand);
  CreateNative("HasCheatPermissions", Native_HasCheatPermissions);

  return APLRes_Success;
}

public void OnPluginStart() {
  nyx_cheats_override = CreateConVar("nyx_cheats_override", "n",
      "Override flag required to execute cheat commands");
  nyx_cheats_notify = CreateConVar("nyx_cheats_notify", "0",
      "Notify admins when a cheat command is ran?", _, true, 0.0, true, 1.0);

  sv_cheats = FindConVar("sv_cheats");
  host_timescale = FindConVar("host_timescale");
  if (host_timescale != null) { // not all source games have this apparently...
    HookConVarChange(host_timescale, ConVarChanged_HostTimescale);
  }

  RegAdminCmd("nyx_cheatcmd", ConCmd_CheatCmd, ADMFLAG_CHEATS, "nyx_cheatcmd <#userid|name> <cmd> [args]");

  HookCheatCommands();
}

public void OnPluginEnd() {
  for (int i = 0; i < g_iHookedCount; i++) {
    SetCommandFlags(g_sHookedCmd[i], GetCommandFlags(g_sHookedCmd[i]) | FCVAR_CHEAT);
  }
  LogAction(-1, -1, "Restored %i commands", g_iHookedCount);
}

public void OnClientPostAdminCheck(int client) {
  if (!IsValidClient(client, true)) return;

  if (HasCheatPermissions(client)) {
    // disabling autokick allows us to use ent_fire so lets do that
    ServerCommand("mp_disable_autokick %i", GetClientUserId(client));
  }

  // we have to trick the client into thinking sv_cheats is enabled so host_timescale works...
  if (host_timescale != null) {
    if (host_timescale.FloatValue != 1.0) {
      SendConVarValue(client, sv_cheats, "1");
    }
  }
}

/***
 *        _   __      __  _
 *       / | / /___ _/ /_(_)   _____  _____
 *      /  |/ / __ `/ __/ / | / / _ \/ ___/
 *     / /|  / /_/ / /_/ /| |/ /  __(__  )
 *    /_/ |_/\__,_/\__/_/ |___/\___/____/
 *
 */

public int Native_ExecuteCheatCommand(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  char buffer[256];
  int error = FormatNativeString(0, 2, 3, sizeof(buffer), _, buffer);
  if (error != SP_ERROR_NONE) {
    return ThrowNativeError(error, "Failed to format native string");
  }
  TrimString(buffer);

  char cmd[128], args[256];
  int len = BreakString(buffer, cmd, sizeof(cmd));
  strcopy(args, sizeof(args), buffer[len]);

  for (int i = 0; i < g_iHookedCount; i++) {
    if (strcmp(g_sHookedCmd[i], cmd) == 0) {
      g_bAllowOnce[client] = true;
      FakeClientCommandEx(client, "%s %s", cmd, args);
      return true;
    }
  }

  return false;
}

public int Native_HasCheatPermissions(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  if (client == 0) return true;
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  char flags[8]; nyx_cheats_override.GetString(flags, sizeof(flags));
  if (strlen(flags) == 0) return true;
  if (IsClientAdmin(client, ReadFlagString(flags))) return true;

  return false;
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

public Action ConCmd_CheatCmd(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_cheatcmd <#userid|name> <cmd> [args]");
    return Plugin_Handled;
  }

  char buffer[256], target[MAX_TARGET_LENGTH], cmd[128], cmdArgs[256];
  GetCmdArgString(buffer, sizeof(buffer));
  TrimString(buffer);

  int len1 = BreakString(buffer, target, sizeof(target));
  int len2 = BreakString(buffer[len1], cmd, sizeof(cmd));
  strcopy(cmdArgs, sizeof(cmdArgs), buffer[len1 + len2]);
  StripQuotes(cmdArgs);

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    if (IsValidClient(target_list[i])) {
      ExecuteCheatCommand(target_list[i], "%s %s", cmd, cmdArgs);
      LogAction(client, target_list[i], "\"%L\" ran cheat command \"%s\" [%s] on \"%L\"", client, cmd, cmdArgs, target_list[i]);
    }
  }
  NyxAct(client, "Ran cheat command '%s' [%s] on %s", cmd, cmdArgs, target_name);

  return Plugin_Handled;
}

public Action ConCmd_Cheat(int client, int args) {
  char cmd[256], cmdArgs[256];
  GetCmdArg(0, cmd, 256);
  GetCmdArgString(cmdArgs, sizeof(cmdArgs));
  TrimString(cmdArgs);

  if (!HasCheatPermissions(client) && !g_bAllowOnce[client]) {
    LogAction(client, -1, "\"%L\" was prevented from running cheat command \"%s\" [%s]", client, cmd, cmdArgs);
    return Plugin_Handled;
  }

  g_bAllowOnce[client] = false;

  LogAction(client, -1, "\"%L\" ran cheat command \"%s\" [%s]", client, cmd, cmdArgs);
  if (nyx_cheats_notify.BoolValue) {
    NyxAct(client, "Ran cheat command \"%s\" [%s]", cmd, cmdArgs);
  }

  return Plugin_Continue;
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
    if (isCommand && flags & FCVAR_CHEAT && g_iHookedCount < MAX_COMMANDS) {
      RegConsoleCmd(cmd, ConCmd_Cheat);
      SetCommandFlags(cmd, GetCommandFlags(cmd) ^ FCVAR_CHEAT);
      strcopy(g_sHookedCmd[g_iHookedCount++], 128, cmd);
    }

    if (g_iHookedCount >= MAX_COMMANDS) {
      LogError("Failed to hook all cheat commands: MAX_COMMANDS reached");
      return;
    }
  } while (FindNextConCommand(hCommand, cmd, sizeof(cmd), isCommand, flags));

  LogAction(-1, -1, "Hooked %i commands", g_iHookedCount);
}
