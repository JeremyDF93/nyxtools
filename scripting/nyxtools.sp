#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define NYX_DEBUG 1
#include <nyxtools>

public Plugin myinfo = {
  name = "NyxTools",
  author = NYXTOOLS_AUTHOR,
  description = "General set of source engine tools",
  version = NYXTOOLS_VERSION,
  url = NYXTOOLS_WEBSITE
};

/***
 *        ____  __            _          ____      __            ____
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/
 *                  /____/
 */

public void OnPluginStart() {
  LoadTranslations("common.phrases");

  RegAdminCmd("nyx_sendcvar", ConCmd_SendConVar, ADMFLAG_ROOT, "nyx_sendcvar <#userid|name> <convar> <value>");
  RegAdminCmd("nyx_querycvar", ConCmd_QueryConVar, ADMFLAG_ROOT, "nyx_querycvar <#userid|name> <convar>");
  RegAdminCmd("nyx_connectmethod", ConCmd_ConnectMethod, ADMFLAG_ROOT, "nyx_connectmethod");
  RegAdminCmd("nyx_fakecmd", ConCmd_FakeCmd, ADMFLAG_ROOT, "nyx_fakecmd <#userid|name> <cmd>");
  RegAdminCmd("nyx_showurl", ConCmd_ShowURL, ADMFLAG_ROOT, "nyx_showurl <#userid|name> <url> [show]");
  RegAdminCmd("nyx_tele", ConCmd_Teleport, ADMFLAG_SLAY, "nyx_tele <#userid|name> [stack]");
}

/***
 *       ______      ______               __
 *      / ____/___ _/ / / /_  ____ ______/ /_______
 *     / /   / __ `/ / / __ \/ __ `/ ___/ //_/ ___/
 *    / /___/ /_/ / / / /_/ / /_/ / /__/ ,< (__  )
 *    \____/\__,_/_/_/_.___/\__,_/\___/_/|_/____/
 *
 */

public void OnConVarQuery(QueryCookie cookie, int target, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value) {
  int client = GetClientOfUserId(value);
  if (IsValidClient(client) && IsValidClient(target)) {
    NyxMsgReply(client, "Query of '%s' returned '%s' for %N", cvarName, cvarValue, target);
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

public Action ConCmd_SendConVar(int client, int args) {
  if (args < 3) {
    NyxMsgReply(client, "Usage: nyx_sendcvar <#userid|name> <convar> <value>");
    return Plugin_Handled;
  }

  char arg1[32];
  GetCmdArg(1, arg1, sizeof(arg1));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  char cvar[64], value[64];
  GetCmdArg(2, cvar, sizeof(cvar));
  GetCmdArg(3, value, sizeof(value));

  ConVar convar = FindConVar(cvar);
  if (convar == null) {
    NyxMsgReply(client, "Unable to find cvar '%s'", cvar);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    SendConVarValue(target_list[i], convar, value);
    LogAction(client, target_list[i], "\"%L\" changed cvar \"%s\" to \"%s\" on \"%L\"", client, cvar, value, target_list[i]);
  }
  NyxAct(client, "Changed cvar '%s' to '%s' on %s", cvar, value, target_name);

  return Plugin_Handled;
}

public Action ConCmd_QueryConVar(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_querycvar <#userid|name> <convar>");
    return Plugin_Handled;
  }

  char arg1[32];
  GetCmdArg(1, arg1, sizeof(arg1));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  char arg2[64];
  GetCmdArg(2, arg2, sizeof(arg2));

  for (int i = 0; i < target_count; i++) {
    QueryClientConVar(target_list[i], arg2, OnConVarQuery, GetClientUserId(client));
    LogAction(client, target_list[i], "\"%L\" queried cvar \"%s\" on \"%L\"", client, arg2, target_list[i]);
  }
  NyxAct(client, "Queried cvar '%s' on %s", arg2, target_name);

  return Plugin_Handled;
}

public Action ConCmd_ConnectMethod(int client, int args) {
  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i, true)) continue;

    char value[64];
    bool ret = GetClientInfo(i, "cl_connectmethod", value, sizeof(value));
    NyxMsgReply(client, "<%i> \"%N\" -- %s", GetClientUserId(i), i, ret ? value : "QUERY FAILED");
  }

  return Plugin_Handled;
}

public Action ConCmd_FakeCmd(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_fakecmd <#userid|name> <cmd>");
    return Plugin_Handled;
  }

  char arg1[32];
  GetCmdArg(1, arg1, sizeof(arg1));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  char cmd[256];
  GetCmdArg(2, cmd, sizeof(cmd));

  for (int i = 0; i < target_count; i++) {
    if (IsValidClient(target_list[i])) {
      FakeClientCommandEx(target_list[i], cmd);
      LogAction(client, target_list[i], "\"%L\" ran fake command \"%s\" on \"%L\"", client, cmd, target_list[i]);
    }
  }
  NyxAct(client, "Ran fake command '%s' on %s", cmd, target_name);

  return Plugin_Handled;
}

public Action ConCmd_ShowURL(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_showurl <#userid|name> <url> [show]");
    return Plugin_Handled;
  }

  char arg1[32];
  GetCmdArg(1, arg1, sizeof(arg1));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  char url[256];
  GetCmdArg(2, url, sizeof(url));

  for (int i = 0; i < target_count; i++) {
    if (IsValidClient(target_list[i])) {
      ShowURLPanel(target_list[i], "", url, GetCmdBool(3, true));
      LogAction(client, target_list[i], "\"%L\" showed \"%s\" to \"%L\"", client, url, target_list[i]);
    }
  }
  NyxAct(client, "Showed '%s' to %s", url, target_name);

  return Plugin_Handled;
}

public Action ConCmd_Teleport(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_tele <#userid|name> [stack]");
    return Plugin_Handled;
  }

  char arg1[32];
  GetCmdArg(1, arg1, sizeof(arg1));

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;

  if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS,
      COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
  {
    ReplyToTargetError(client, target_count);
    return Plugin_Handled;
  }

  float pos[3];
  if (!GetClientAimPos(client, pos)) {
    NyxMsgReply(client, "Could not get teleport end point");
    return Plugin_Handled;
  }

  float angles[3], fwd[3];
  GetClientEyeAngles(client, angles);
  GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
  pos[0] = pos[0] + (fwd[0] * -35.0);
  pos[1] = pos[1] + (fwd[1] * -35.0);
  pos[2] = pos[2] + (fwd[2] * -35.0);

  bool stack = GetCmdBool(2);

  for (int i = 0; i < target_count; i++) {
    TeleportEntity(target_list[i], pos, NULL_VECTOR, NULL_VECTOR);

    if (stack) {
      pos[2] += 40.0;
    }

    LogAction(client, target_list[i], "\"%L\" teleported \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Teleported %s", target_name);

  return Plugin_Handled;
}
