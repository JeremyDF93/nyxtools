# NyxTools
A collection of plugins to help make development easier and reduce repetitiveness.
## Documentation
Work in progress.
## Stocks
```c
stock bool IsClientPlaying(int client);
stock int GetPlayerCount(bool playing = false);
stock void TF2_ChangeClientTeamEx(int client, int team, bool respawn = true);
stock void TF2_RemoveAllWearables(int client);
stock void TF2_RemoveWearables(int client, const int[] items, int len);
stock void TF2_SwitchToSlot(int client, int slot);
stock int TF2_StringToSlot(char[] str);
stock int TF2_StringToTeam(char[] str);
stock void TF2_TeamToString(int team, char[] str, int maxlength);
stock void TF2_ClassToString(TFClassType class, char[] str, int maxlength);
stock TFClassType TF2_StringToClass(char[] str);
stock bool IsValidClient(int client, bool filterBots = false, bool filterReplay = true, bool filterSourceTV = true);
stock bool IsClientAdmin(int client, int flags = ADMFLAG_GENERIC);
stock void NyxMsg(char[] format, any ...);
stock void NyxMsgReply(int client, char[] format, any ...);
stock void NyxMsgConsole(int client, char[] format, any ...);
stock void NyxMsgClient(int client, char[] format, any ...);
stock void NyxMsgAll(char[] format, any ...);
stock void NyxMsgTeam(int team, char[] format, any ...);
stock void NyxMsgAdmin(char[] format, any ...);
stock void NyxMsgDebug(char[] format, any ...);
stock void NyxAct(int client, char[] format, any ...);
stock void SayText2(int client, int from, char[] msg);
stock int GetCmdTarget(int argnum, int client, bool nobots = false, bool immunity = true);
stock bool GetCmdBool(int argnum, bool def = false);
stock int GetCmdInt(int argnum, int def = 0);
stock int GetCmdIntEx(int argnum, int min = INT_MIN, int max = INT_MAX, int def = 0);
stock float GetCmdFloat(int argnum, float def = 0.0);
stock float GetCmdFloatEx(int argnum, float min, float max, float def = 0.0);
stock void GetCmdVector(int argnum, float vec[3], float def[3]={ 0.0, 0.0, 0.0 });
stock bool GetClientAimPos(int client, float vec[3], int mask = MASK_ALL);
stock bool GetClientAimPosEx(int client, float vec[3], float normal[3], int mask = MASK_ALL);
stock int GetClientAimTargetEx(int client, bool only_clients=true, int mask = MASK_ALL);
stock int FindClosestPlayer(int client, bool filterTeam=true, float distMin=0.0, float distMax=0.0);
stock int FindEntityByClassnameSafe(int startEnt, const char[] classname);
stock any MathMin(any x, any y);
stock any MathMax(any x, any y);
stock void CopyVectors(const float vector[3], float copy[3]);
stock bool StringToVector(const char[] str, float vector[3]);
stock void MatrixToAngles(const float fwd[3], const float left[3], const float up[3], float angles[3]);
stock void ShowURLPanel(int client, const char[] title, const char[] url, bool show = true);
stock bool IsPlayerSurvivor(int client);
stock bool IsPlayerInfected(int client);
stock bool IsPlayerGhost(int client);
stock bool IsPlayerTank(int client);
stock bool IsPlayerGrabbed(int client);
stock bool IsPlayerIncapacitated(int client);
stock bool IsClientPlaying(int client);
stock int GetPlayerCount(bool playing = false);
stock L4D2ClassType L4D2_StringToClass(const char[] classname);
stock L4D2ClassType L4D2_GetClientClass(int client);
stock L4D2ClassType L4D2_GetClassFromInt(int class);
stock L4D2Team L4D2_GetTeamFromInt(int team);
stock L4D2Team L4D2_GetClientTeam(int client);
stock L4D2Team L4D2_StringToTeam(char[] str);
stock void L4D2_TeamToString(L4D2Team team, char[] str, int maxlength);
```
## Forwards
```c
forward Action L4D2_OnReplaceTank(int client_1, int client_2);
forward Action L4D2_OnTakeOverBot(int bot, bool flag);
forward Action L4D2_OnTakeOverZombieBot(int client, int bot);
forward Action L4D2_OnReplaceWithBot(int client, bool flag);
forward Action L4D2_OnSetHumanSpectator(int bot, int client);
forward Action L4D2_OnFirstSurvivorLeftSafeArea(int client);
forward Action L4D2_OnEndVersusModeRound(bool flag);
forward Action L4D2_OnSwapTeams();
```
## Natives
```c
native void TF2_RemoveAllObjects(int client, bool flag=true);
native int TF2_GetObjectCount(int client);
native bool TF2_SetUpgradesMode(bool enabled, bool reviveEnabled);
native bool TF2_IsUpgradesEnabled();
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
native bool ExecuteCheatCommand(int client, const char[] fmt, any ...);
native bool HasCheatPermissions(int client);
```
## Misc
```c
public bool TraceEntityFilter_PlayersOnly(int entity, int contentsMask);
public bool TraceEntityFilter_Players(int entity, int contentsMask);
public bool TraceEntityFilter_PlayersOnlyEx(int entity, int contentsMask, any self);
public bool TraceEntityFilter_PlayersEx(int entity, int contentsMask, any self);
public bool TraceEntityFilter_Self(int entity, int contentsMask, any self);
```
## Commands
### NyxTools
```
[Name]             [Type]       [Help]
nyx_connectmethod  admin        Usage: nyx_connectmethod
nyx_fakecmd        admin        Usage: nyx_fakecmd <#userid|name> <cmd>
nyx_querycvar      admin        Usage: nyx_querycvar <#userid|name> <convar>
nyx_sendcvar       admin        Usage: nyx_sendcvar <#userid|name> <convar> <value>
nyx_showurl        admin        Usage: nyx_showurl <#userid|name> <url> [show]
nyx_tele           admin        Usage: nyx_tele <#userid|name> [stack]
```
### NyxTools - Cheats
```
[Name]              [Type]       [Help]
nyx_fakecmdc        admin        Usage: nyx_fakecmdc <#userid|name> <cmd>
```
### NyxTools - Entities
These commands are super useful for viewing or setting prop data.
```
[Name]                [Type]       [Help]
nyx_entfire_aim       admin        Usage: nyx_entfire_aim <input> [value]
nyx_entfire_class     admin        Usage: nyx_entfire_class <classname> <input> [value]
nyx_entfire_player    admin        Usage: nyx_entprop_player <#userid|name> <input> [value]
nyx_entprop_aim       admin        Usage: nyx_entprop_aim <prop> [value]
nyx_entprop_class     admin        Usage: nyx_entprop_class <classname> <prop> [value]
nyx_entprop_player    admin        Usage: nyx_entprop_player <#userid|name> <prop> [value]
nyx_entprop_weapon    admin        Usage: nyx_entprop_weapon <#userid|name> <slot> <prop> [value]
```
### NyxTools - Events
This plugin is super small, but usefull for testing events for data without compiling code to view them.
```
[Name]            [Type]       [Help]
nyx_hookevent     admin        Usage: nyx_hookevent <event> <key> [mode]
nyx_unhookevent   admin        Usage: nyx_unhookevent <event> [mode]
```
### NyxTools - L4D2 (Linux Support Only);
```
[Name]            [Type]       [Help]
nyx_changeclass   admin        Usage: nyx_changeclass <#userid|name> <class>
nyx_changeteam    admin        Usage: nyx_changeteam <#userid|name> <team>
nyx_respawn       admin        Usage: nyx_respawn <#userid|name>
nyx_takeoverbot   admin        Usage: nyx_takeoverbot <#userid|name>
```
### NyxTools - TF2 (Linux Support Only);
```
[Name]                  [Type]       [Help]
nyx_addcond             admin        Usage: nyx_addcond <#userid|name> <cond>
nyx_changeclass         admin        Usage: nyx_changeclass <#userid|name> <class>
nyx_changeteam          admin        Usage: nyx_changeteam <#userid|name> <team>
nyx_regen               admin        Usage: nyx_regen <#userid|name>
nyx_removecond          admin        Usage: nyx_removecond <#userid|name> <cond>
nyx_removeobjects       admin        Usage: nyx_removeobjects <#userid|name>
nyx_respawn             admin        Usage: nyx_respawn <#userid|name>
```
## ConVars
### NyxTools - Cheats
```
[Name]                           [Default]        [Help]
nyx_cheats_override              n                Override flag required to execute cheat commands
nyx_cheats_notify                0                Notify admins when a cheat command is ran?
```