#pragma semicolon 1
#include <sourcemod>
#include <nyxtools>
#include <nyxtools_tf2>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - TF2",
  author = "JeremyDF93",
  description = "",
  version = "1.0",
  url = "https://praisethemoon.com/"
};

///
/// enums
///

enum NyxSDK {
  Handle:SDK_RemoveAllObjects
}

///
/// Globals
///

Handle g_hGameConf;
Handle g_hSDKCall[NyxSDK];

///
/// Plugin Interface
///

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  RegPluginLibrary("nyxtools_tf2");

  CreateNative("TF2_RemoveAllObjects", Native_RemoveAllObjects);

  return APLRes_Success;
}

public void OnPluginStart() {
  RegAdminCmd("nyx_respawn", ConCmd_Respawn, ADMFLAG_SLAY, "Usage: nyx_respawn <#userid|name>");
  RegAdminCmd("nyx_changeteam", ConCmd_ChangeTeam, ADMFLAG_SLAY, "Usage: nyx_changeteam <#userid|name> <team>");
  RegAdminCmd("nyx_changeclass", ConCmd_ChangeClass, ADMFLAG_SLAY, "Usage: nyx_changeclass <#userid|name> <class>");
  RegAdminCmd("nyx_removeobjects", ConCmd_RemoveObjects, ADMFLAG_SLAY, "nyx_removeobjects <#userid|name>");
  RegAdminCmd("nyx_regen", ConCmd_Regenerate, ADMFLAG_SLAY, "nyx_regen <#userid|name>");
  RegAdminCmd("nyx_addcond", ConCmd_AddCond, ADMFLAG_SLAY, "nyx_addcond <#userid|name> <cond>");
  RegAdminCmd("nyx_removecond", ConCmd_RemoveCond, ADMFLAG_SLAY, "nyx_removecond <#userid|name> <cond>");

  // game config
  g_hGameConf = LoadGameConfigFile("tf2.nyxtools");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTFPlayer::RemoveAllObjects");
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_RemoveAllObjects] = EndPrepSDKCall();
}

///
/// Natives
///

public int Native_RemoveAllObjects(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);
  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  SDKCall(g_hSDKCall[SDK_RemoveAllObjects], client, flag);
  return 0;
}

///
/// Commands
///

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
    TF2_RespawnPlayer(target_list[i]);
    LogAction(client, target_list[i], "\"%L\" respawned \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Respawned %s", target_name);

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
    team = TF2_StringToTeam(teamStr);
  }

  if (team < 0 || team > 3) {
    NyxMsgReply(client, "No team matchs '%s'", teamStr);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    ChangeClientTeam(target_list[i], team);
    LogAction(client, target_list[i], "\"%L\" changed \"%L\" to team \"%s\"", client, target_list[i], teamStr);
  }
  NyxAct(client, "Changed %s to team %s", target_name, teamStr);

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
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  char classStr[32];
  GetCmdArg(2, classStr, sizeof(classStr));

  int class;
  if (StringToIntEx(classStr, class) == 0) {
    class = view_as<int>(TF2_StringToClass(classStr));
  }

  if (class < 0 || class > 9) {
    NyxMsgReply(client, "No class matchs '%s'", classStr);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    TF2_RemoveAllWearables(target_list[i]); // fixes multi-class cosmetics staying on as the previous class
    TF2_SetPlayerClass(target_list[i], view_as<TFClassType>(class));

    // we have to regenerate health because manually changing classes keeps the old health for some reason
    if (IsPlayerAlive(target_list[i])) {
      SetEntityHealth(target_list[i], 25);
      TF2_RegeneratePlayer(target_list[i]);
    }
    
    LogAction(client, target_list[i], "\"%L\" changed \"%L\" to class \"%s\"", client, target_list[i], classStr);
  }
  NyxAct(client, "Changed %s to class %s", target_name, classStr);

  return Plugin_Handled;
}

public Action ConCmd_RemoveObjects(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_removeobjects <#userid|name>");
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
    TF2_RemoveAllObjects(target_list[i]);
    LogAction(client, target_list[i], "\"%L\" removed all objects for \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Removed all objects for %s", target_name);

  return Plugin_Handled;
}

public Action ConCmd_Regenerate(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_regen <#userid|name>");
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
    TF2_RegeneratePlayer(target_list[i]);
    LogAction(client, target_list[i], "\"%L\" regenerated \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Regenerated %s", target_name);

  return Plugin_Handled;
}

public Action ConCmd_AddCond(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_addcond <#userid|name> <cond>");
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

  int cond = GetCmdInt(2);
  for (int i = 0; i < target_count; i++) {
    TF2_AddCondition(target_list[i], view_as<TFCond>(cond));
    LogAction(client, target_list[i], "\"%L\" regenerated \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Regenerated %s", target_name);

  return Plugin_Handled;
}

public Action ConCmd_RemoveCond(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_removecond <#userid|name> <cond>");
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

  int cond = GetCmdInt(2);
  for (int i = 0; i < target_count; i++) {
    TF2_RemoveCondition(target_list[i], view_as<TFCond>(cond));
    LogAction(client, target_list[i], "\"%L\" regenerated \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Regenerated %s", target_name);

  return Plugin_Handled;
}
