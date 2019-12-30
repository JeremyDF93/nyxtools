# NyxTools
A collection of plugins to help make development easier and reduce repetitiveness.
## Documentation
Work in progress.
## Natives
### NyxTools - Cheats
```c
void FakeClientCommandCheat(int client, const char[] fmt, any ...);
bool HasCheatPermissions(int client);
```
### NyxTools - L4D2 (Linux Support Only)
```c
void L4D2_RespawnPlayer(int client);
void L4D2_TakeOverBot(int client, bool flag=true);
void L4D2_TakeOverZombieBot(int bot, int client);
void L4D2_ReplaceWithBot(int client, bool flag=true);
void L4D2_SetHumanSpectator(int bot, int client);
void L4D2_ChangeTeam(int client, int team);
void L4D2_SetInfectedClass(int client, L4D2ClassType class);
```
### NyxTools - TF2 (Linux Support Only)
```c
void TF2_RemoveAllObjects(int client, bool flag=true);
int TF2_GetObjectCount(int client);
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
```
[Name]            [Type]       [Help]
nyx_hookevent     admin        Usage: nyx_hookevent <event> <key> [mode]
nyx_unhookevent   admin        Usage: nyx_unhookevent <event> [mode]
```
### NyxTools - L4D2 (Linux Support Only)
```
[Name]            [Type]       [Help]
nyx_changeclass   admin        Usage: nyx_changeclass <#userid|name> <class>
nyx_changeteam    admin        Usage: nyx_changeteam <#userid|name> <team>
nyx_respawn       admin        Usage: nyx_respawn <#userid|name>
nyx_takeoverbot   admin        Usage: nyx_takeoverbot <#userid|name>
```
### NyxTools - TF2 (Linux Support Only)
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