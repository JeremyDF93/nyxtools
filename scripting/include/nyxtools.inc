#if defined _nyxtools_included
  #endinput
#endif
#define _nyxtools_included

/*
                                              .,
                                             / :
                                            / :---..
                                     .^.,-`/  :     `.
                                 .-``| 'j./  :''-.   )
                              ..`-'`(..-./  :'    \  |
                             ( ,\'``        '-  .  | `._   _.---.
                             |(  '`-..__      `.   (    ```_._   \
                            (( `.(.---. ``\    )    `-..-'`   \   )
                            |(```:``'-.\  /   .'            .  : (
 .-..-.                     |(`. (  ((WW)''--'  *       x      (  `..,__
(   \  \          _.._.--.  ( \|  '. \`,|  `.                   `-_     `-
 '   '._`-._..-'``__  `-. '. \ |    `'--'  ..7               .     ``-..  \
  '.    ```   /```  `'.  \  \ \|   `-.-~-.`-/      *          ___       )  |   .
 .-.:>.       \__.     '. \  \ '      (`'.`' `-..        .-'`..--._-._.'   `--'|
(               (   .    . \  \)       \  `'._   `--..-'_.-'`      `'-.____..-'
 `'-._           `'(__.   : \ /''-.     \     ```''''```
     .7               (_. (  \'``\ `'---'\
   .'     ,                \  '-  \ ._)`. )
   \__--':     .     .      `'     \ -..'/
        /    ,:    ,/\   /\__.   . .`'--`
        '--'`  `--'   `'  /      |  : /|.-'```''.
                         /       |  |` |.-'``-.  `-.
                        /        |  :  (   .  x`-   )
                      .'_  ()  .'|  '.  '        ) (  ..--.
                     ( `.`L_  / \|   :   '.      `-.`'  .-.`.__
                     (( C`  )\   (    \    \  .   * `--' ,.)   ``.
                      \`'` )o )./-\    \.-.(\ .-.      .'. .-'``/
                      (`--',./.-''-:. -( \)  `.-._'---'  .'
                       `-._        _(`.:  \-...)  ``'''``
                           `''''=:_`   |---'
                                   ````
*/

#tryinclude <nyxtools_version_auto>
#include <nyxtools_version>
#include <sdktools>

#if !defined NYXTOOLS_TAG
  #define NYXTOOLS_TAG "Nyx"
#endif
#define NYXTOOLS_AUTHOR "Kiwi, JeremyDF93"
#define NYXTOOLS_WEBSITE "https://praisethemoon.com/"

#define INT_MAX 2147483647
#define INT_MIN -2147483648

#define SOLID_NONE     0 // no solid model
#define SOLID_BSP      1 // a BSP tree
#define SOLID_BBOX     2 // an AABB
#define SOLID_OBB      3 // an OBB (not implemented yet)
#define SOLID_OBB_YAW  4 // an OBBconstrained so that it can only yaw
#define SOLID_CUSTOM   5 // Always call into the entity for tests
#define SOLID_VPHYSICS 6 // solid vphysics object, get vcollide from the model and collide with that

/***
 *       _________            __     ________              __       
 *      / ____/ (_)__  ____  / /_   / ____/ /_  ___  _____/ /_______
 *     / /   / / / _ \/ __ \/ __/  / /   / __ \/ _ \/ ___/ //_/ ___/
 *    / /___/ / /  __/ / / / /_   / /___/ / / /  __/ /__/ ,< (__  ) 
 *    \____/_/_/\___/_/ /_/\__/   \____/_/ /_/\___/\___/_/|_/____/  
 *                                                                  
 */

stock bool IsValidClient(int client, bool filterBots = false, bool filterReplay = true, bool filterSourceTV = true) {
  if (client <= 0 || client > MaxClients) return false;
  if (!IsClientInGame(client)) return false;
  if (IsClientReplay(client) && filterReplay) return false;
  if (IsClientSourceTV(client) && filterSourceTV) return false;
  if (IsFakeClient(client) && filterBots) return false;

  return true;
}

stock bool IsClientAdmin(int client, int flags = ADMFLAG_GENERIC) {
  return (GetUserFlagBits(client) & flags) > 0 || (GetUserFlagBits(client) & ADMFLAG_ROOT) > 0;
}

/***
 *        __  ___                                    
 *       /  |/  /__  ______________ _____ ____  _____
 *      / /|_/ / _ \/ ___/ ___/ __ `/ __ `/ _ \/ ___/
 *     / /  / /  __(__  |__  ) /_/ / /_/ /  __(__  ) 
 *    /_/  /_/\___/____/____/\__,_/\__, /\___/____/  
 *                                /____/             
 */

stock void NyxMsg(char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  PrintToServer("[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgReply(int client, char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  ReplySource rs = GetCmdReplySource();
  if (rs == SM_REPLY_TO_CONSOLE) {
    NyxMsgConsole(client, buffer);
  } else {
    NyxMsgClient(client, buffer);
  }
}

stock void NyxMsgConsole(int client, char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  PrintToConsole(client, "[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgClient(int client, char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  PrintToChat(client, "[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgAll(char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  PrintToChatAll("[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgTeam(int team, char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i, true)) continue;
    if (GetClientTeam(i) != team) continue;

    PrintToChat(i, "[%s] %s", NYXTOOLS_TAG, buffer);
    PrintToConsole(i, "[%s] %s", NYXTOOLS_TAG, buffer);
  }
}

stock void NyxMsgAdmin(char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i, true)) continue;
    if (!IsClientAdmin(i)) continue;

    PrintToChat(i, "[%s] %s", NYXTOOLS_TAG, buffer);
    PrintToConsole(i, "[%s] %s", NYXTOOLS_TAG, buffer);
  }

  PrintToServer("[%s] %s", NYXTOOLS_TAG, buffer);
}

stock void NyxMsgDebug(char[] format, any ...) {
#if defined NYX_DEBUG
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 2);

  // use a switch statement because you'll 'redundant code' warnings in the compiler
  switch (NYX_DEBUG) {
    case 1: NyxMsg(buffer);
    case 2: NyxMsgAdmin(buffer);
  }
#endif
}

stock void NyxAct(int client, char[] format, any ...) {
  char buffer[256];
  VFormat(buffer, sizeof(buffer), format, 3);

  char prefix[64];
  FormatEx(prefix, sizeof(prefix), "[%s] ", NYXTOOLS_TAG);

  ShowActivity2(client, prefix, "%s", buffer);
}

stock void SayText2(int client, int from, char[] msg) {
  char buffer[256];
  Format(buffer, sizeof(buffer), "\x01%s", msg);

  Handle hBf;
  hBf = StartMessageOne("SayText2", client);
  if (hBf != null) {
    BfWriteByte(hBf, from); 
    BfWriteByte(hBf, 0); 
    BfWriteString(hBf, msg);
    EndMessage();
  }
}

/***
 *       ______                                          __   __  __     __                    
 *      / ____/___  ____ ___  ____ ___  ____ _____  ____/ /  / / / /__  / /___  ___  __________
 *     / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  /  / /_/ / _ \/ / __ \/ _ \/ ___/ ___/
 *    / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ /  / __  /  __/ / /_/ /  __/ /  (__  ) 
 *    \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/  /_/ /_/\___/_/ .___/\___/_/  /____/  
 *                                                                    /_/                      
 */

stock int GetCmdTarget(int argnum, int client, bool nobots = false, bool immunity = true) {
  char target[MAX_TARGET_LENGTH];
  GetCmdArg(argnum, target, sizeof(target));

  return FindTarget(client, target, nobots, immunity);
}

stock bool GetCmdBool(int argnum, bool def = false) {
  char arg[32];
  GetCmdArg(argnum, arg, sizeof(arg));

  if (strcmp(arg, "true", false) == 0) return true;
  if (strcmp(arg, "false", false) == 0) return false;
  if (strcmp(arg, "on", false) == 0) return true;
  if (strcmp(arg, "off", false) == 0) return false;

  return GetCmdIntEx(argnum, 0, 1, def) > 0;
}

stock int GetCmdInt(int argnum, int def = 0) {
  return RoundFloat(GetCmdFloat(argnum, float(def)));
}

stock int GetCmdIntEx(int argnum, int min = INT_MIN, int max = INT_MAX, int def = 0) {
  return RoundFloat(GetCmdFloatEx(argnum, float(min), float(max), float(def)));
}

stock float GetCmdFloat(int argnum, float def = 0.0) {
  char arg[32];
  GetCmdArg(argnum, arg, sizeof(arg));

  float result;
  if (StringToFloatEx(arg, result) == 0) {
    return def;
  }

  return result;
}

stock float GetCmdFloatEx(int argnum, float min, float max, float def = 0.0) {
  char arg[32];
  GetCmdArg(argnum, arg, sizeof(arg));

  float result;
  if (StringToFloatEx(arg, result) == 0) {
    return def;
  }

  if (result < min) result = min;
  if (result > max) result = max;

  return result;
}

stock void GetCmdVector(int argnum, float vec[3], float def[3]={ 0.0, 0.0, 0.0 }) {
  char arg[64];
  GetCmdArg(argnum, arg, sizeof(arg));

  bool success = StringToVector(arg, vec);
  if (!success) {
    CopyVectors(def, vec);
  }
}

/***
 *        ____                 ______                _            
 *       / __ \____ ___  __   /_  __/________ ______(_)___  ____ _
 *      / /_/ / __ `/ / / /    / / / ___/ __ `/ ___/ / __ \/ __ `/
 *     / _, _/ /_/ / /_/ /    / / / /  / /_/ / /__/ / / / / /_/ / 
 *    /_/ |_|\__,_/\__, /    /_/ /_/   \__,_/\___/_/_/ /_/\__, /  
 *                /____/                                 /____/   
 */

stock bool GetClientAimPos(int client, float vec[3], int mask = MASK_ALL) {
  float origin[3], angles[3];
  GetClientEyePosition(client, origin);
  GetClientEyeAngles(client, angles);

  Handle trace = TR_TraceRayFilterEx(origin, angles, mask, RayType_Infinite, TraceEntityFilter_Self, client);
  if (TR_DidHit(trace)) {
    TR_GetEndPosition(vec, trace);
    CloseHandle(trace);
    return true;
  }

  CloseHandle(trace);
  return false;
}

stock int GetClientAimTargetEx(int client, bool only_clients, int mask = MASK_ALL) {
  float origin[3], angles[3];
  GetClientEyePosition(client, origin);
  GetClientEyeAngles(client, angles);

  Handle trace;
  if (only_clients) {
    trace = TR_TraceRayFilterEx(origin, angles, mask, RayType_Infinite, TraceEntityFilter_Self);
  } else {
    trace = TR_TraceRayEx(origin, angles, mask, RayType_Infinite);
  }

  if (TR_DidHit(trace)) {
    int ent = TR_GetEntityIndex(trace);
    CloseHandle(trace);
    return ent;
  }

  CloseHandle(trace);
  return -1;
}

stock int FindClosestPlayer(int client, bool filterTeam=true, float distMin=0.0, float distMax=0.0) {
  int team = GetClientTeam(client);
  float pos[3]; GetClientEyePosition(client, pos);

  int target;
  for (int i = 1; i <= MaxClients; i++) {
    if (!IsValidClient(i)) continue;
    if (!IsPlayerAlive(i)) continue;
    if (filterTeam) {
      if (GetClientTeam(i) != team) continue;
    }

    float targetPos[3]; GetClientEyePosition(i, targetPos);
    float targetDist = GetVectorDistance(pos, targetPos);

    if (targetDist > distMin && (targetDist < distMax || distMax == 0.0)) {
      distMax = targetDist;
      target = i;
    }
  }

  return target;
}

public bool TraceEntityFilter_Players(int entity, int contentsMask) {
  return entity > MaxClients || !entity;
}

public bool TraceEntityFilter_SelfPlayers(int entity, int contentsMask, any data) {
  if (entity == data) {
    return false;
  }

  return entity > MaxClients || !entity;
}

public bool TraceEntityFilter_Self(int entity, int contentsMask, any data) {
  if (entity == data) {
    return false;
  }

  return true;
}

/***
 *        ______      __  _ __  _          
 *       / ____/___  / /_(_) /_(_)__  _____
 *      / __/ / __ \/ __/ / __/ / _ \/ ___/
 *     / /___/ / / / /_/ / /_/ /  __(__  ) 
 *    /_____/_/ /_/\__/_/\__/_/\___/____/  
 *                                         
 */

stock int FindEntityByClassnameSafe(int startEnt, const char[] classname) {
  while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
  return FindEntityByClassname(startEnt, classname);
}

/***
 *        __  ___      __  __  
 *       /  |/  /___ _/ /_/ /_ 
 *      / /|_/ / __ `/ __/ __ \
 *     / /  / / /_/ / /_/ / / /
 *    /_/  /_/\__,_/\__/_/ /_/ 
 *                             
 */

stock any MathMin(any x, any y) {
  if (x < y) return x;

  return y;
}

stock any MathMax(any x, any y) {
  if (x > y) return x;

  return y;
}

/***
 *     _    __          __                 
 *    | |  / /__  _____/ /_____  __________
 *    | | / / _ \/ ___/ __/ __ \/ ___/ ___/
 *    | |/ /  __/ /__/ /_/ /_/ / /  (__  ) 
 *    |___/\___/\___/\__/\____/_/  /____/  
 *                                         
 */

stock void CopyVectors(float vector[3], float copy[3]) {
  copy[0] = vector[0];
  copy[1] = vector[1];
  copy[2] = vector[2];
}

stock bool StringToVector(const char[] str, float vector[3]) {
  char num[64][3];
  int found = ExplodeString(str, " ", num, 3, sizeof(num), false);
  if (found == 3) {
    vector[0] = StringToFloat(num[0]);
    vector[1] = StringToFloat(num[1]);
    vector[2] = StringToFloat(num[2]);

    return true;
  }

  return false;
}

/***
 *        __  ____          
 *       /  |/  (_)_________
 *      / /|_/ / / ___/ ___/
 *     / /  / / (__  ) /__  
 *    /_/  /_/_/____/\___/  
 *                          
 */

stock void ShowURLPanel(int client, const char[] title, const char[] url, bool show = true) {
  Handle kv = CreateKeyValues("data");
  KvSetString(kv, "title", title);
  KvSetNum(kv, "type", MOTDPANEL_TYPE_URL);
  KvSetString(kv, "msg", url);
  KvSetNum(kv, "customsvr", 1);

  ShowVGUIPanel(client, "info", kv, show);
  CloseHandle(kv);
}
