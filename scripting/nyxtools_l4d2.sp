#pragma semicolon 1
#include <sourcemod>
#include <nyxtools>
#include <nyxtools_l4d2>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - L4D2",
  author = "JeremyDF93",
  description = "General set of L4D2 tools",
  version = NYX_PLUGIN_VERSION,
  url = "https://praisethemoon.com/"
};

/***
 *        ______                          
 *       / ____/___  __  ______ ___  _____
 *      / __/ / __ \/ / / / __ `__ \/ ___/
 *     / /___/ / / / /_/ / / / / / (__  ) 
 *    /_____/_/ /_/\__,_/_/ /_/ /_/____/  
 *                                        
 */

enum NyxSDK {
  Handle:SDK_RoundRespawn,
  Handle:SDK_TakeOverBot,
  Handle:SDK_ReplaceWithBot,
  Handle:SDK_SetHumanSpectator,
  Handle:SDK_ChangeTeam,
  Handle:SDK_SetClass,
  Handle:SDK_CreateAbility
}

/***
 *       ________      __          __    
 *      / ____/ /___  / /_  ____ _/ /____
 *     / / __/ / __ \/ __ \/ __ `/ / ___/
 *    / /_/ / / /_/ / /_/ / /_/ / (__  ) 
 *    \____/_/\____/_.___/\__,_/_/____/  
 *                                       
 */

Handle g_hGameConf;
Handle g_hSDKCall[NyxSDK];

/***
 *        ____  __            _          ____      __            ____              
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________ 
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/ 
 *                  /____/                                                         
 */

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  RegPluginLibrary("nyxtools_l4d2");

  CreateNative("L4D2_RespawnPlayer", Native_RespawnPlayer);
  CreateNative("L4D2_TakeOverBot", Native_TakeOverBot);
  CreateNative("L4D2_ReplaceWithBot", Native_ReplaceWithBot);
  CreateNative("L4D2_SetHumanSpectator", Native_SetHumanSpectator);
  CreateNative("L4D2_ChangeTeam", Native_ChangeTeam);
  CreateNative("L4D2_SetInfectedClass", Native_SetInfectedClass);

  return APLRes_Success;
}

public void OnPluginStart() {
  LoadTranslations("common.phrases");

  RegAdminCmd("nyx_respawn", ConCmd_Respawn, ADMFLAG_SLAY, "Usage: nyx_respawn <#userid|name>");
  RegAdminCmd("nyx_takeoverbot", ConCmd_TakeOverBot, ADMFLAG_SLAY, "Usage: nyx_takeoverbot <#userid|name>");
  RegAdminCmd("nyx_changeteam", ConCmd_ChangeTeam, ADMFLAG_SLAY, "Usage: nyx_changeteam <#userid|name> <team>");
  RegAdminCmd("nyx_changeclass", ConCmd_ChangeClass, ADMFLAG_SLAY, "Usage: nyx_changeclass <#userid|name> <class>");

  // game config
  g_hGameConf = LoadGameConfigFile("l4d2.nyxtools");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CCSPlayer::RoundRespawn");
  g_hSDKCall[SDK_RoundRespawn] = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::TakeOverBot");
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_TakeOverBot] = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::ReplaceWithBot");
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_ReplaceWithBot] = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "SurvivorBot::SetHumanSpectator");
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  g_hSDKCall[SDK_SetHumanSpectator] = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::ChangeTeam");
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  g_hSDKCall[SDK_ChangeTeam] = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::SetClass");
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  g_hSDKCall[SDK_SetClass] = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Static);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CBaseAbility::CreateForPlayer");
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
  g_hSDKCall[SDK_CreateAbility] = EndPrepSDKCall();
}

/***
 *        _   __      __  _                
 *       / | / /___ _/ /_(_)   _____  _____
 *      /  |/ / __ `/ __/ / | / / _ \/ ___/
 *     / /|  / /_/ / /_/ /| |/ /  __(__  ) 
 *    /_/ |_/\__,_/\__/_/ |___/\___/____/  
 *                                         
 */

public int Native_RespawnPlayer(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_RoundRespawn], client);
}

public int Native_TakeOverBot(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_TakeOverBot], client, flag);
}

public int Native_ReplaceWithBot(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_ReplaceWithBot], client, flag);
}

public int Native_SetHumanSpectator(Handle plugin, int numArgs) {
  int bot = GetNativeCell(1);
  int client = GetNativeCell(2);
  if (!IsValidClient(bot) && !IsFakeClient(bot)) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid bot index (%d)", bot);
  if (!IsValidClient(client)) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);

  return SDKCall(g_hSDKCall[SDK_SetHumanSpectator], bot, client);
}

public int Native_ChangeTeam(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  int team = GetNativeCell(2);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_ChangeTeam], client, team);
}

public int Native_SetInfectedClass(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  L4D2ClassType class = view_as<L4D2ClassType>(GetNativeCell(2));

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  } else if (!IsPlayerAlive(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Can only be used on alive players");
  } else if (!IsPlayerInfected(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client team");
  } else if (class == L4D2Class_Unknown || class == L4D2Class_Witch || class == L4D2Class_Survivor) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid or blocked class index (%d)", class);
  }

  int weapon = GetPlayerWeaponSlot(client, 0);
  if (IsValidEdict(weapon)) {
    RemovePlayerItem(client, weapon);
    RemoveEdict(weapon);
  }

  SDKCall(g_hSDKCall[SDK_SetClass], client, class);

  int customAbility = GetEntProp(client, Prop_Send, "m_customAbility");
  if (customAbility != -1) {
    AcceptEntityInput(MakeCompatEntRef(customAbility), "Kill");
  }

  int ent = SDKCall(g_hSDKCall[SDK_CreateAbility], client);
  int offs = FindDataMapInfo(ent, "m_angRotation") + 12; // the offset we want is 12 bytes after 'm_angRotation'
  SetEntProp(client, Prop_Send, "m_customAbility", GetEntData(ent, offs));

  return true;
}

/***
 *       ______                                          __    
 *      / ____/___  ____ ___  ____ ___  ____ _____  ____/ /____
 *     / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
 *    / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  ) 
 *    \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/  
 *                                                             
 */

public Action ConCmd_Respawn(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_respawn <#userid|name>");
    return Plugin_Handled;
  }

  char target[MAX_NAME_LENGTH];
  GetCmdArg(1, target, sizeof(target));

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
    L4D2_RespawnPlayer(target_list[i]);
    LogAction(client, target_list[i], "\"%L\" respawned \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Respawned %s", target_name);

  return Plugin_Handled;
}

public Action ConCmd_TakeOverBot(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_takeoverbot <#userid|name>");
    return Plugin_Handled;
  }

  int target = GetCmdTarget(1, client);
  if (!IsValidClient(target)) {
    return Plugin_Handled;
  }

  if (!IsFakeClient(target)) {
    NyxMsgReply(client, "%N is not a bot", target);
    return Plugin_Handled;
  }

  if (IsPlayerInfected(target)) {
    NyxMsgReply(client, "Can't target the infected team", target);
    return Plugin_Handled;
  }

  L4D2_ChangeTeam(client, L4D2_TEAM_SPECTATOR);
  L4D2_SetHumanSpectator(target, client);
  L4D2_TakeOverBot(client);

  LogAction(client, target, "\"%L\" took over \"%L\"", client, target);
  NyxAct(client, "Taking over %N", target);

  return Plugin_Handled;
}

public Action ConCmd_ChangeTeam(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_changeteam <#userid|name> <team>");
    return Plugin_Handled;
  }

  char target[MAX_NAME_LENGTH];
  GetCmdArg(1, target, sizeof(target));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  char teamStr[32];
  GetCmdArg(2, teamStr, sizeof(teamStr));

  int team;
  if (StringToIntEx(teamStr, team) == 0) {
    team = L4D2_StringToTeam(teamStr);
  }

  if (team < 0 || team > 3) {
    NyxMsgReply(client, "No team matchs '%s'", teamStr);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    L4D2_ChangeTeam(target_list[i], team);
    LogAction(client, target_list[i], "\"%L\" changed \"%L\" to team \"%d\"", client, target_list[i], team);
  }
  NyxAct(client, "Changed %s to team %d", target_name, team);

  return Plugin_Handled;
}

public Action ConCmd_ChangeClass(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_changeclass <#userid|name> <class>");
    return Plugin_Handled;
  }

  char target[MAX_NAME_LENGTH];
  GetCmdArg(1, target, sizeof(target));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  char classStr[32];
  GetCmdArg(2, classStr, sizeof(classStr));

  int class;
  if (StringToIntEx(classStr, class) == 0) {
    class = view_as<int>(L4D2_StringToClass(classStr));
  }

  if (class < 0 || class > 6 && class != 8) {
    NyxMsgReply(client, "No valid class matchs '%s'", classStr);
    return Plugin_Handled;
  }

  bool success;
  for (int i = 0; i < target_count; i++) {
    if (IsPlayerInfected(target_list[i])) {
      success = true;
      L4D2_SetInfectedClass(target_list[i], view_as<L4D2ClassType>(class));
      LogAction(client, target_list[i], "\"%L\" changed \"%L\" to class \"%s\"", client, target_list[i], classStr);
    }
  }

  if (success) {
    NyxAct(client, "Changed %s to class %s", target_name, classStr);
  } else {
    NyxMsgReply(client, "Failed to find a valid target");
  }

  return Plugin_Handled;
}
