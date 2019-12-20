#pragma semicolon 1
#include <sourcemod>
#include <nyxtools>
#include <nyxtools_l4d2>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - L4D2",
  author = "JeremyDF93",
  description = "General set of L4D2 tools",
  version = "1.0",
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
  Handle:SDK_SetHumanSpectator,
  Handle:SDK_ChangeTeam
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
  CreateNative("L4D2_SetHumanSpectator", Native_SetHumanSpectator);
  CreateNative("L4D2_ChangeTeam", Native_ChangeTeam);

  return APLRes_Success;
}

public void OnPluginStart() {
  LoadTranslations("common.phrases");

  RegAdminCmd("nyx_respawn", ConCmd_Respawn, ADMFLAG_SLAY, "Usage: nyx_respawn <#userid|name>");
  RegAdminCmd("nyx_takeoverbot", ConCmd_TakeOverBot, ADMFLAG_SLAY, "Usage: nyx_takeoverbot <#userid|name>");
  RegAdminCmd("nyx_changeteam", ConCmd_ChangeTeam, ADMFLAG_SLAY, "Usage: nyx_changeteam <#userid|name> <team>");

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
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "SurvivorBot::SetHumanSpectator");
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  g_hSDKCall[SDK_SetHumanSpectator] = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::ChangeTeam");
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  g_hSDKCall[SDK_ChangeTeam] = EndPrepSDKCall();
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

  SDKCall(g_hSDKCall[SDK_RoundRespawn], client);
  return 0;
}

public int Native_TakeOverBot(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  SDKCall(g_hSDKCall[SDK_TakeOverBot], client, flag);
  return 0;
}

public int Native_SetHumanSpectator(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  int target = GetNativeCell(2);
  if (!IsValidClient(client)) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  if (!IsValidClient(target)) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid target index (%d)", target);

  int survivorCharacter = GetEntProp(target, Prop_Send, "m_survivorCharacter");
  int modelIndex = GetEntProp(target, Prop_Data, "m_nModelIndex");
  SetEntProp(client, Prop_Send, "m_survivorCharacter", survivorCharacter);
  SetEntProp(client, Prop_Data, "m_nModelIndex", modelIndex);

  SDKCall(g_hSDKCall[SDK_RoundRespawn], target, client);
  return 0;
}

public int Native_ChangeTeam(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  int team = GetNativeCell(2);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  SDKCall(g_hSDKCall[SDK_ChangeTeam], client, team);
  return 0;
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

  L4D2_SetHumanSpectator(target, client);
  L4D2_TakeOverBot(client, true);

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
