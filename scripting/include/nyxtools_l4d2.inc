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
  L4D2Team_Unknown = -1,
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
native bool L4D2_CanBecomeGhost(int client, bool flag=true);
native void L4D2_TakeOverBot(int client, bool flag=true);
native void L4D2_TakeOverZombieBot(int client, int bot);
native void L4D2_ReplaceWithBot(int client, bool flag=true);
native void L4D2_SetHumanSpectator(int bot, int client);
native void L4D2_ChangeTeam(int client, L4D2Team team);
native void L4D2_SetInfectedClass(int client, L4D2ClassType class);
native bool L4D2_IsMissionFinalMap();
native bool L4D2_IsMissionStartMap();
native bool L4D2_IsClassAllowed(L4D2ClassType class);
native bool L4D2_GetRandomPZSpawnPosition(L4D2ClassType class, int tries=5, int client, float[3] vector);
native bool L4D2_FindNearbySpawnSpot(int client, float[3] vector, L4D2Team team, bool flag, float radius);
native void L4D2_WarpToValidPositionIfStuck(int client);
native void L4D2_ScriptStaggerPlayer(int client, float[3] vector);
forward Action L4D2_OnReplaceTank(int client_1, int client_2);
forward Action L4D2_OnTakeOverBot(int bot, bool flag);
forward Action L4D2_OnTakeOverZombieBot(int client, int bot);
forward Action L4D2_OnReplaceWithBot(int client, bool flag);
forward Action L4D2_OnSetHumanSpectator(int bot, int client);
forward Action L4D2_OnFirstSurvivorLeftSafeArea(int client);
forward Action L4D2_OnEndVersusModeRound(bool flag);
forward Action L4D2_OnSwapTeams();

#if !defined REQUIRE_PLUGIN
public __pl_nyxtools_l4d2_SetNTVOptional() {
  MarkNativeAsOptional("L4D2_RespawnPlayer");
  MarkNativeAsOptional("L4D2_WarpGhostToInitialPosition");
  MarkNativeAsOptional("L4D2_BecomeGhost");
  MarkNativeAsOptional("L4D2_CanBecomeGhost");
  MarkNativeAsOptional("L4D2_TakeOverBot");
  MarkNativeAsOptional("L4D2_TakeOverZombieBot");
  MarkNativeAsOptional("L4D2_ReplaceWithBot");
  MarkNativeAsOptional("L4D2_SetHumanSpectator");
  MarkNativeAsOptional("L4D2_ChangeTeam");
  MarkNativeAsOptional("L4D2_SetInfectedClass");
  MarkNativeAsOptional("L4D2_IsMissionFinalMap");
  MarkNativeAsOptional("L4D2_IsMissionStartMap");
  MarkNativeAsOptional("L4D2_IsClassAllowed");
  MarkNativeAsOptional("L4D2_GetRandomPZSpawnPosition");
  MarkNativeAsOptional("L4D2_FindNearbySpawnSpot");
  MarkNativeAsOptional("L4D2_WarpToValidPositionIfStuck");
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

stock void RunScriptCode(const char[] fmt, any ...) {
  char buffer[512];
  VFormat(buffer, sizeof(buffer), fmt, 2);

  int ent = CreateEntityByName("logic_script");
  DispatchSpawn(ent);

  SetVariantString(buffer);
  AcceptEntityInput(ent, "RunScriptCode");

  RemoveEntity(ent);
}

stock void DisplayInstructorHint(
    int client,
    const char[] caption="",
    const char[] icon_onscreen="icon_alert",
    const char[] icon_offscreen="icon_alert",
    float timeout=5.0,
    const int color[3]={255,255,255},
    float offset=0.0,
    float range=0.0,
    int flags=0,
    const char[] binding="",
    bool allow_nodraw_target=true,
    bool nooffscreen=false,
    bool forcecaption=false
) {
  char hintName[32];
  Format(hintName, sizeof(hintName), "hint_%d", GetClientUserId(client));

  char hintColor[32];
  Format(hintColor, sizeof(hintColor), "%d,%d,%d", color[0], color[1], color[2]);

  Event event = CreateEvent("instructor_server_hint_create", true);
  event.SetString("hint_name", hintName);
  event.SetInt("hint_target", client);
  event.SetFloat("hint_timeout", timeout);
  event.SetString("hint_icon_onscreen", icon_onscreen);
  event.SetString("hint_icon_offscreen", icon_offscreen);
  event.SetString("hint_caption", caption);
  event.SetString("hint_color", hintColor);
  event.SetFloat("hint_icon_offset", offset);
  event.SetFloat("hint_range", range);
  event.SetInt("hint_flags", flags);
  event.SetString("hint_binding", binding);
  event.SetBool("hint_allow_nodraw_target", allow_nodraw_target);
  event.SetBool("hint_nooffscreen", nooffscreen);
  event.SetBool("hint_forcecaption", forcecaption);
  event.FireToClient(client);
  event.Cancel();
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

stock L4D2ClassType L4D2_GetClassFromInt(int class) {
  if (class < 1 || class > 9) return L4D2Class_Unknown;
  return view_as<L4D2ClassType>(class);
}

stock L4D2Team L4D2_GetTeamFromInt(int team) {
  if (team < 0 || team > 3) return L4D2Team_Unknown;
  return view_as<L4D2Team>(team);
}

stock L4D2Team L4D2_GetClientTeam(int client) {
  return view_as<L4D2Team>(GetClientTeam(client));
}

stock L4D2Team L4D2_StringToTeam(const char[] str) {
  if (strcmp(str, "unassigned", false) == 0) return L4D2Team_Unassigned;
  if (strncmp(str, "spectator", 4, false) == 0) return L4D2Team_Spectator;
  if (strcmp(str, "survivor", false) == 0) return L4D2Team_Survivor;
  if (strcmp(str, "infected", false) == 0) return L4D2Team_Infected;

  return L4D2Team_Unknown;
}

stock void L4D2_TeamToString(L4D2Team team, char[] str, int maxlength) {
  strcopy(str, maxlength, "unknown");

  if (team == L4D2Team_Unassigned) strcopy(str, maxlength, "unassigned");
  if (team == L4D2Team_Spectator) strcopy(str, maxlength, "spectator");
  if (team == L4D2Team_Survivor) strcopy(str, maxlength, "survivor");
  if (team == L4D2Team_Infected) strcopy(str, maxlength, "infected");
}

/***
 *        __    _ __
 *       / /   (_) /_  _________ ________  __
 *      / /   / / __ \/ ___/ __ `/ ___/ / / /
 *     / /___/ / /_/ / /  / /_/ / /  / /_/ /
 *    /_____/_/_.___/_/   \__,_/_/   \__, /
 *                                  /____/
 */

public SharedPlugin __pl_nyxtools_l4d2 = {
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
