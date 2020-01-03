#if defined _nyxtools_tf2_included
  #endinput
#endif
#define _nyxtools_tf2_included

#include <tf2>
#include <tf2_stocks>

#define TF_TEAM_UNASSIGNED  0
#define TF_TEAM_SPECTATOR   1
#define TF_TEAM_RED         2
#define TF_TEAM_BLUE        3

/***
 *        _   __      __  _                
 *       / | / /___ _/ /_(_)   _____  _____
 *      /  |/ / __ `/ __/ / | / / _ \/ ___/
 *     / /|  / /_/ / /_/ /| |/ /  __(__  ) 
 *    /_/ |_/\__,_/\__/_/ |___/\___/____/  
 *                                         
 */

native void TF2_RemoveAllObjects(int client, bool flag=true);
native int TF2_GetObjectCount(int client);
native bool TF2_SetUpgradesMode(bool enabled);

public SharedPlugin:__pl_nyxtools_tf2 = {
  name = "nyxtools_tf2",
  file = "nyxtools_tf2.smx",
#if defined REQUIRE_PLUGIN
  required = 1,
#else
  required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_nyxtools_tf2_SetNTVOptional() {
  MarkNativeAsOptional("TF2_RemoveAllObjects");
  MarkNativeAsOptional("TF2_GetObjectCount");
}
#endif

/***
 *        ______                 __  _                 
 *       / ____/_  ______  _____/ /_(_)___  ____  _____
 *      / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
 *     / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
 *    /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/  
 *                                                     
 */

 stock bool IsClientPlaying(int client) {
  if (!IsValidClient(client)) return false;

  int team = GetClientTeam(client);
  if (team == TF_TEAM_RED) return true;
  if (team == TF_TEAM_BLUE) return true;

  return false;
}

stock int GetPlayerCount(bool playing = false) {
  int playerCount = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i, true)) continue;
    if (playing) {
      int team = GetClientTeam(i);
      if (team != TF_TEAM_RED && team != TF_TEAM_BLUE) {
        continue;
      }
    }

    playerCount++;
  }

  return playerCount;
}

/***
 *      _______________ 
 *     /_  __/ ____/__ \
 *      / / / /_   __/ /
 *     / / / __/  / __/ 
 *    /_/ /_/    /____/ 
 *                      
 */

stock void TF2_ChangeClientTeamEx(int client, int team, bool respawn = true) {
  int lifeState = GetEntProp(client, Prop_Send, "m_lifeState");
  SetEntProp(client, Prop_Send, "m_lifeState", 2);
  ChangeClientTeam(client, team);
  SetEntProp(client, Prop_Send, "m_lifeState", lifeState);

  if (respawn) {
    TF2_RespawnPlayer(client);
  }
}

public bool TF2_IsMvM() {
  char map[PLATFORM_MAX_PATH];
  GetCurrentMap(map, sizeof(map));
  if (strncmp(map, "mvm_", 4) == 0) return true;

  return false;
}

stock void TF2_RemoveAllWearables(int client) {
  if (!IsValidClient(client)) return;
  if (!IsPlayerAlive(client)) return;

  int  wearable = -1;
  while ((wearable = FindEntityByClassname(wearable, "tf_wearable")) != -1) {
    if (!IsValidEdict(wearable)) continue;

    if (client == GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity")) {
      TF2_RemoveWearable(client, wearable);
    }
  }
}

stock void TF2_RemoveWearables(int client, const int[] items, int len) {
  if (!IsValidClient(client)) return;
  if (!IsPlayerAlive(client)) return;

  int  wearable = -1;
  while ((wearable = FindEntityByClassname(wearable, "tf_wearable")) != -1) {
    if (!IsValidEdict(wearable)) continue;

    if (client == GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity")) {
      for (int i = 0; i < len; i++) {
        if (GetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex") == items[i]) {
          TF2_RemoveWearable(client, wearable);
        }
      }
    }
  }
}

stock void TF2_SwitchToSlot(int client, int slot) {
  if (!IsValidClient(client)) return;
  if (!IsPlayerAlive(client)) return;

  char classname[64];
  if (slot >= 0 && slot <= 5) {
    int weapon = GetPlayerWeaponSlot(client, slot);
    if (weapon > MaxClients) {
      if (!IsValidEdict(weapon)) return;
      if (!GetEdictClassname(weapon, classname, sizeof(classname))) return;

      FakeClientCommandEx(client, "use %s", classname);
      SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
    }
  }
}

stock int TF2_StringToSlot(char[] str) {
  if (strcmp(str, "primary", false) == 0) return 0;
  if (strcmp(str, "secondary", false) == 0) return 1;
  if (strcmp(str, "sapper", false) == 0) return 1;
  if (strcmp(str, "melee", false) == 0) return 2;
  if (strcmp(str, "pda", false) == 0) return 3;
  if (strcmp(str, "pdaq", false) == 0) return 3;
  if (strcmp(str, "pda2", false) == 0) return 4;
  if (strcmp(str, "building", false) == 0) return 5;
  if (strcmp(str, "hat", false) == 0) return 5;
  if (strcmp(str, "head", false) == 0) return 5;
  if (strcmp(str, "misc", false) == 0) return 6;
  if (strcmp(str, "action", false) == 0) return 7;

  return -1;
}

stock int TF2_StringToTeam(char[] str) {
  if (strcmp(str, "unassigned", false) == 0) return TF_TEAM_UNASSIGNED;
  if (strncmp(str, "spectate", 4, false) == 0) return TF_TEAM_SPECTATOR;
  if (strcmp(str, "red", false) == 0) return TF_TEAM_RED;
  if (strcmp(str, "blue", false) == 0) return TF_TEAM_BLUE;

  return -1;
}

stock void TF2_TeamToString(int team, char[] str, int maxlength) {
  strcopy(str, maxlength, "unknown");

  if (team == TF_TEAM_UNASSIGNED) strcopy(str, maxlength, "unassigned");
  if (team == TF_TEAM_SPECTATOR) strcopy(str, maxlength, "spectate");
  if (team == TF_TEAM_RED) strcopy(str, maxlength, "red");
  if (team == TF_TEAM_BLUE) strcopy(str, maxlength, "blue");
}

stock void TF2_ClassToString(TFClassType class, char[] str, int maxlength) {
  strcopy(str, maxlength, "unknown");

  if (class == TFClass_Scout) strcopy(str, maxlength, "scout");
  if (class == TFClass_Sniper) strcopy(str, maxlength, "sniper");
  if (class == TFClass_DemoMan) strcopy(str, maxlength, "demoman");
  if (class == TFClass_Medic) strcopy(str, maxlength, "medic");
  if (class == TFClass_Heavy) strcopy(str, maxlength, "heavyweapons");
  if (class == TFClass_Pyro) strcopy(str, maxlength, "pyro");
  if (class == TFClass_Spy) strcopy(str, maxlength, "spy");
  if (class == TFClass_Soldier) strcopy(str, maxlength, "soldier");
  if (class == TFClass_Engineer) strcopy(str, maxlength, "engineer");
}

stock TFClassType TF2_StringToClass(char[] str) {
  if (strcmp(str, "scout", false) == 0) return TFClass_Scout;
  if (strcmp(str, "sniper", false) == 0) return TFClass_Sniper;
  if (strncmp(str, "demoman", 4, false) == 0) return TFClass_DemoMan;
  if (strcmp(str, "medic", false) == 0) return TFClass_Medic;
  if (strncmp(str, "heavyweapons", 5, false) == 0) return TFClass_Heavy;
  if (strcmp(str, "pyro", false) == 0) return TFClass_Pyro;
  if (strcmp(str, "spy", false) == 0) return TFClass_Spy;
  if (strcmp(str, "soldier", false) == 0) return TFClass_Soldier;
  if (strncmp(str, "engineer", 4, false) == 0) return TFClass_Engineer;

  return TFClass_Unknown;
}

/***
 *        __    _ __                         
 *       / /   (_) /_  _________ ________  __
 *      / /   / / __ \/ ___/ __ `/ ___/ / / /
 *     / /___/ / /_/ / /  / /_/ / /  / /_/ / 
 *    /_____/_/_.___/_/   \__,_/_/   \__, /  
 *                                  /____/   
 */

public SharedPlugin:__pl_nyxtools_tf2 = {
  name = "nyxtools_tf2",
  file = "nyxtools_tf2.smx",
#if defined REQUIRE_PLUGIN
  required = 1,
#else
  required = 0,
#endif
};

public Extension __ext_nyxtools_tf2 = {
  name = "NyxTools",
  file = "nyxtools.ext",
#if defined AUTOLOAD_EXTENSIONS
  autoload = 1,
#else
  autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
  required = 1,
#else
  required = 0,
#endif
};
