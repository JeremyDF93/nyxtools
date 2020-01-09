#pragma semicolon 1
#include <sourcemod>
#include <nyxtools>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - Event",
  author = NYXTOOLS_AUTHOR,
  description = "Tool for viewing event values",
  version = NYXTOOLS_VERSION,
  url = NYXTOOLS_WEBSITE
};

/***
 *       ________      __          __
 *      / ____/ /___  / /_  ____ _/ /____
 *     / / __/ / __ \/ __ \/ __ `/ / ___/
 *    / /_/ / / /_/ / /_/ / /_/ / (__  )
 *    \____/_/\____/_.___/\__,_/_/____/
 *
 */

StringMap g_hStringMap;

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

  g_hStringMap = new StringMap();

  RegAdminCmd("nyx_hookevent", ConCmd_HookEvent, ADMFLAG_ROOT, "nyx_hookevent <event> <key> [mode]");
  RegAdminCmd("nyx_unhookevent", ConCmd_UnHookEvent, ADMFLAG_ROOT, "nyx_unhookevent <event> [mode]");
}

/***
 *        ______                 __
 *       / ____/   _____  ____  / /______
 *      / __/ | | / / _ \/ __ \/ __/ ___/
 *     / /___ | |/ /  __/ / / / /_(__  )
 *    /_____/ |___/\___/_/ /_/\__/____/
 *
 */

public Action Event_Generic(Event event, const char[] name, bool dontBroadcast) {
  char key[256], value[256];
  if (g_hStringMap.GetString(name, key, sizeof(key))) {
    event.GetString(key, value, sizeof(value));
    NyxMsgAdmin("[%s:%s]=%s", name, key, value);
  }

  return Plugin_Continue;
}

/***
 *       ______                                          __
 *      / ____/___  ____ ___  ____ ___  ____ _____  ____/ /____
 *     / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
 *    / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  )
 *    \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/
 *
 */

public Action ConCmd_HookEvent(int client, int args) {
  if (args < 2) {
    NyxMsgReply(client, "Usage: nyx_hookevent <event> <key> [mode]");
    return Plugin_Handled;
  }

  char arg1[256], arg2[256];
  GetCmdArg(1, arg1, sizeof(arg1));
  GetCmdArg(2, arg2, sizeof(arg2));
  int mode = GetCmdInt(2, view_as<int>(EventHookMode_Post));

  if (!g_hStringMap.Remove(arg1)) {
    HookEvent(arg1, Event_Generic, view_as<EventHookMode>(mode));
  }
  g_hStringMap.SetString(arg1, arg2);

  LogAction(client, -1, "\"%L\" hooked event [\"%s:%s\"]", client, arg1, arg2);
  NyxAct(client, "Hooked event [%s:%s]", arg1, arg2);

  return Plugin_Handled;
}

public Action ConCmd_UnHookEvent(int client, int args) {
  if (args < 1) {
    NyxMsgReply(client, "Usage: nyx_unhookevent <event> [mode]");
    return Plugin_Handled;
  }

  char arg1[256];
  GetCmdArg(1, arg1, sizeof(arg1));
  int mode = GetCmdInt(2, view_as<int>(EventHookMode_Post));

  if (g_hStringMap.Remove(arg1)) {
    UnhookEvent(arg1, Event_Generic, view_as<EventHookMode>(mode));
  }

  LogAction(client, -1, "\"%L\" unhooked event \"%s\"", client, arg1);
  NyxAct(client, "Unhooked event '%s'", arg1);

  return Plugin_Handled;
}
