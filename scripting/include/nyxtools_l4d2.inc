#if defined _nyxtools_l4d2_included
  #endinput
#endif
#define _nyxtools_l4d2_included

#define L4D2_TEAM_UNASSIGNED  0
#define L4D2_TEAM_SPECTATOR   1
#define L4D2_TEAM_SURVIVOR    2
#define L4D2_TEAM_INFECTED    3

/***
 *        ______                          
 *       / ____/___  __  ______ ___  _____
 *      / __/ / __ \/ / / / __ `__ \/ ___/
 *     / /___/ / / / /_/ / / / / / (__  ) 
 *    /_____/_/ /_/\__,_/_/ /_/ /_/____/  
 *                                        
 */

// Smoker = 1, Boomer = 2, Hunter = 3, Spitter = 4, Jockey = 5, 
// Charger = 6, Witch = 7, Tank = 8, Survivor = 9
enum L4D2ClassType {
  L4D2Class_Unknown = 0,
  L4D2Class_Smoker,
  L4D2Class_Boomer,
  L4D2Class_Hunter,
  L4D2Class_Spitter,
  L4D2Class_Jockey,
  L4D2Class_Charger,
  L4D2Class_Witch,
  L4D2Class_Tank,
  L4D2Class_Survivor
};

enum L4D2Team {
  L4D2Team_Unassigned = L4D2_TEAM_UNASSIGNED,
  L4D2Team_Spectator = L4D2_TEAM_SPECTATOR,
  L4D2Team_Survivor = L4D2_TEAM_SURVIVOR,
  L4D2Team_Infected = L4D2_TEAM_INFECTED
}

/***
 *        _   __      __  _                
 *       / | / /___ _/ /_(_)   _____  _____
 *      /  |/ / __ `/ __/ / | / / _ \/ ___/
 *     / /|  / /_/ / /_/ /| |/ /  __(__  ) 
 *    /_/ |_/\__,_/\__/_/ |___/\___/____/  
 *                                         
 */

native void L4D2_RespawnPlayer(int client);
native void L4D2_WarpGhostToInitialPosition(int client, bool flag=true);
native void L4D2_BecomeGhost(int client, bool flag=true);
native void L4D2_TakeOverBot(int client, bool flag=true);
native void L4D2_TakeOverZombieBot(int bot, int client);
native void L4D2_ReplaceWithBot(int client, bool flag=true);
native void L4D2_SetHumanSpectator(int bot, int client);
native void L4D2_ChangeTeam(int client, int team);
native void L4D2_SetInfectedClass(int client, L4D2ClassType class);
forward Action L4D2_OnReplaceTank(int client_1, int client_2);
forward Action L4D2_OnTakeOverBot(int bot, bool flag);
forward Action L4D2_OnTakeOverZombieBot(int client, int bot);
forward Action L4D2_OnReplaceWithBot(int client, bool flag);
forward Action L4D2_OnSetHumanSpectator(int bot, int client);

#if !defined REQUIRE_PLUGIN
public __pl_nyxtools_l4d2_SetNTVOptional() {
  MarkNativeAsOptional("L4D2_RespawnPlayer");
  MarkNativeAsOptional("L4D2_TakeOverBot");
  MarkNativeAsOptional("L4D2_TakeOverZombieBot");
  MarkNativeAsOptional("L4D2_ReplaceWithBot");
  MarkNativeAsOptional("L4D2_SetHumanSpectator");
  MarkNativeAsOptional("L4D2_ChangeTeam");
  MarkNativeAsOptional("L4D2_SetInfectedClass");
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

stock bool IsPlayerSurvivor(int client) {
  if (!IsValidClient(client)) return false;
  if (GetClientTeam(client) == L4D2_TEAM_INFECTED) return false;

  return true;
}

stock bool IsPlayerInfected(int client) {
  if (!IsValidClient(client)) return false;
  if (GetClientTeam(client) == L4D2_TEAM_SURVIVOR) return false;

  return true;
}

stock bool IsPlayerGhost(int client) {
  if (!IsValidClient(client)) return false;
  if (!GetEntProp(client, Prop_Send, "m_isGhost")) return false;

  return true;
}

stock bool IsPlayerTank(int client) {
  if (!IsValidClient(client)) return false;
  if (IsPlayerSurvivor(client)) return false;
  if (GetEntProp(client, Prop_Send, "m_zombieClass") != 8) return false;
  
  return true;
}

stock bool IsPlayerGrabbed(int client) {
  if (GetEntProp(client, Prop_Send, "m_pummelAttacker") > 0) return true;
  if (GetEntProp(client, Prop_Send, "m_carryAttacker") > 0) return true;
  if (GetEntProp(client, Prop_Send, "m_pounceAttacker") > 0) return true;
  if (GetEntProp(client, Prop_Send, "m_jockeyAttacker") > 0) return true;
  if (GetEntProp(client, Prop_Send, "m_tongueOwner") > 0) return true;

  return false;
}

stock bool IsPlayerIncapacitated(int client) {
  if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return true;
  
  return false;
}

stock bool IsClientPlaying(int client) {
  if (!IsValidClient(client)) return false;

  int team = GetClientTeam(client);
  if (team == L4D2_TEAM_SURVIVOR) return true;
  if (team == L4D2_TEAM_INFECTED) return true;

  return false;
}

stock int GetPlayerCount(bool playing = false) {
  int playerCount = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i, true)) continue;
    if (playing) {
      int team = GetClientTeam(i);
      if (team != L4D2_TEAM_SURVIVOR && team != L4D2_TEAM_INFECTED) {
        continue;
      }
    }

    playerCount++;
  }

  return playerCount;
}

/***
 *        __   __ __  ____ ___ 
 *       / /  / // / / __ \__ \
 *      / /  / // /_/ / / /_/ /
 *     / /__/__  __/ /_/ / __/ 
 *    /_____/ /_/ /_____/____/ 
 *                             
 */

stock L4D2ClassType L4D2_StringToClass(const char[] classname) {
  if (strcmp(classname, "boomer", false) == 0) return L4D2Class_Boomer;
  if (strcmp(classname, "smoker", false) == 0) return L4D2Class_Smoker;
  if (strcmp(classname, "hunter", false) == 0) return L4D2Class_Hunter;
  if (strcmp(classname, "spitter", false) == 0) return L4D2Class_Spitter;
  if (strcmp(classname, "jockey", false) == 0) return L4D2Class_Jockey;
  if (strcmp(classname, "charger", false) == 0) return L4D2Class_Charger;
  if (strcmp(classname, "witch", false) == 0) return L4D2Class_Witch;
  if (strcmp(classname, "tank", false) == 0) return L4D2Class_Tank;
  if (strcmp(classname, "survivor", false) == 0) return L4D2Class_Survivor;

  return L4D2Class_Unknown;
}

stock L4D2ClassType L4D2_GetClientClass(int client) {
  return view_as<L4D2ClassType>(GetEntProp(client, Prop_Send, "m_zombieClass"));
}

stock L4D2Team L4D2_GetClientTeam(int client) {
  return view_as<L4D2Team>(GetClientTeam(client));
}

stock int L4D2_StringToTeam(char[] str) {
  if (strcmp(str, "unassigned", false) == 0) return L4D2_TEAM_UNASSIGNED;
  if (strcmp(str, "spectate", false) == 0) return L4D2_TEAM_SPECTATOR;
  if (strcmp(str, "survivor", false) == 0) return L4D2_TEAM_SURVIVOR;
  if (strcmp(str, "infected", false) == 0) return L4D2_TEAM_INFECTED;

  return -1;
}

stock void L4D2_TeamToString(int team, char[] str, int maxlength) {
  strcopy(str, maxlength, "unknown");

  if (team == L4D2_TEAM_UNASSIGNED) strcopy(str, maxlength, "unassigned");
  if (team == L4D2_TEAM_SPECTATOR) strcopy(str, maxlength, "spectate");
  if (team == L4D2_TEAM_SURVIVOR) strcopy(str, maxlength, "survivor");
  if (team == L4D2_TEAM_INFECTED) strcopy(str, maxlength, "infected");
}

/***
 *        __    _ __                         
 *       / /   (_) /_  _________ ________  __
 *      / /   / / __ \/ ___/ __ `/ ___/ / / /
 *     / /___/ / /_/ / /  / /_/ / /  / /_/ / 
 *    /_____/_/_.___/_/   \__,_/_/   \__, /  
 *                                  /____/   
 */

public SharedPlugin:__pl_nyxtools_l4d2 = {
  name = "nyxtools_l4d2",
  file = "nyxtools_l4d2.smx",
#if defined REQUIRE_PLUGIN
  required = 1,
#else
  required = 0,
#endif
};

public Extension __ext_nyxtools_l4d2 = {
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
