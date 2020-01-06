#pragma semicolon 1
#include <sourcemod>

#define NYX_DEBUG 2
#include <nyxtools>
#include <nyxtools_l4d2>

#pragma newdecls required

public Plugin myinfo = {
  name = "NyxTools - L4D2",
  author = NYXTOOLS_AUTHOR,
  description = "General set of L4D2 tools",
  version = NYXTOOLS_VERSION,
  url = NYXTOOLS_WEBSITE
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
  Handle:SDK_TakeOverZombieBot,
  Handle:SDK_ReplaceWithBot,
  Handle:SDK_SetHumanSpectator,
  Handle:SDK_ChangeTeam,
  Handle:SDK_SetClass,
  Handle:SDK_CreateAbility,
  Handle:SDK_WarpGhostToInitialPosition,
  Handle:SDK_BecomeGhost,
  Handle:SDK_CanBecomeGhost,
  Handle:SDK_IsMissionFinalMap,
  Handle:SDK_GetRandomPZSpawnPosition,
  Handle:SDK_IsMissionStartMap,
  Handle:SDK_IsClassAllowed,
  Handle:SDK_FindNearbySpawnSpot,
  Handle:SDK_WarpToValidPositionIfStuck,
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

Address g_pZombieManager;
Address g_pTheDirector;

/***
 *        ____  __            _          ____      __            ____              
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________ 
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/ 
 *                  /____/                                                         
 */

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  EngineVersion engine = GetEngineVersion();
  if (engine != Engine_Left4Dead2) {
    strcopy(error, err_max, "nyxtools_l4d2 is incompatible with this game");
    return APLRes_SilentFailure;
  }
  RegPluginLibrary("nyxtools_l4d2");

  CreateNative("L4D2_RespawnPlayer", Native_RespawnPlayer);
  CreateNative("L4D2_WarpGhostToInitialPosition", Native_WarpGhostToInitialPosition);
  CreateNative("L4D2_BecomeGhost", Native_BecomeGhost);
  CreateNative("L4D2_CanBecomeGhost", Native_CanBecomeGhost);
  CreateNative("L4D2_TakeOverBot", Native_TakeOverBot);
  CreateNative("L4D2_TakeOverZombieBot", Native_TakeOverZombieBot);
  CreateNative("L4D2_ReplaceWithBot", Native_ReplaceWithBot);
  CreateNative("L4D2_SetHumanSpectator", Native_SetHumanSpectator);
  CreateNative("L4D2_ChangeTeam", Native_ChangeTeam);
  CreateNative("L4D2_SetInfectedClass", Native_SetInfectedClass);
  CreateNative("L4D2_IsMissionFinalMap", Native_IsMissionFinalMap);
  CreateNative("L4D2_IsClassAllowed", Native_IsClassAllowed);
  CreateNative("L4D2_GetRandomPZSpawnPosition", Native_GetRandomPZSpawnPosition);
  CreateNative("L4D2_FindNearbySpawnSpot", Native_FindNearbySpawnSpot);
  CreateNative("L4D2_WarpToValidPositionIfStuck", Native_WarpToValidPositionIfStuck);

  return APLRes_Success;
}

public void OnPluginStart() {
  LoadTranslations("common.phrases");
  LoadTranslations("nyxtools.phrases");

  AddMultiTargetFilter("@survivors", MultiTargetFilter_Survivors, "survivors", true);  
  AddMultiTargetFilter("@infected", MultiTargetFilter_Infected, "infected", true);  

  RegAdminCmd("nyx_respawn", ConCmd_Respawn, ADMFLAG_SLAY, "Usage: nyx_respawn <#userid|name>");
  RegAdminCmd("nyx_takeoverbot", ConCmd_TakeOverBot, ADMFLAG_SLAY, "Usage: nyx_takeoverbot <#userid|name>");
  RegAdminCmd("nyx_changeteam", ConCmd_ChangeTeam, ADMFLAG_SLAY, "Usage: nyx_changeteam <#userid|name> <team>");
  RegAdminCmd("nyx_changeclass", ConCmd_ChangeClass, ADMFLAG_SLAY, "Usage: nyx_changeclass <#userid|name> <class>");
  RegAdminCmd("nyx_debug", ConCmd_Debug, ADMFLAG_ROOT);

  // game config
  g_hGameConf = LoadGameConfigFile("nyxtools.l4d2");

 /***
  *     _____                   __    _      __  ___                                 
  *    /__  /  ____  ____ ___  / /_  (_)__  /  |/  /___ _____  ____ _____ ____  _____
  *      / /  / __ \/ __ `__ \/ __ \/ / _ \/ /|_/ / __ `/ __ \/ __ `/ __ `/ _ \/ ___/
  *     / /__/ /_/ / / / / / / /_/ / /  __/ /  / / /_/ / / / / /_/ / /_/ /  __/ /    
  *    /____/\____/_/ /_/ /_/_.___/_/\___/_/  /_/\__,_/_/ /_/\__,_/\__, /\___/_/     
  *                                                               /____/             
  */

  g_pZombieManager = GameConfGetAddress(g_hGameConf, "TheZombieManager");
  if (g_pZombieManager == Address_Null) SetFailState("Failed to get address of TheZombieManager");

  StartPrepSDKCall(SDKCall_Raw);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "ZombieManager::GetRandomPZSpawnPosition");
  PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer, _, VENCODE_FLAG_COPYBACK);
  g_hSDKCall[SDK_GetRandomPZSpawnPosition] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_GetRandomPZSpawnPosition] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for ZombieManager::GetRandomPZSpawnPosition");

 /***
  *       __________  _                __            
  *      / ____/ __ \(_)_______  _____/ /_____  _____
  *     / /   / / / / / ___/ _ \/ ___/ __/ __ \/ ___/
  *    / /___/ /_/ / / /  /  __/ /__/ /_/ /_/ / /    
  *    \____/_____/_/_/   \___/\___/\__/\____/_/     
  *                                                  
  */

  g_pTheDirector = GameConfGetAddress(g_hGameConf, "TheDirector");
  if (g_pTheDirector == Address_Null) SetFailState("Failed to get address of TheDirector");
  
  StartPrepSDKCall(SDKCall_Raw);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CDirector::IsMissionStartMap");
  PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
  g_hSDKCall[SDK_IsMissionStartMap] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_IsMissionStartMap] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CDirector::IsMissionStartMap");
  
  StartPrepSDKCall(SDKCall_Raw);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CDirector::IsClassAllowed");
  PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  g_hSDKCall[SDK_IsClassAllowed] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_IsClassAllowed] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CDirector::IsClassAllowed");

 /***
  *       ____________                          ____  __                     
  *      / ____/_  __/__  ______________  _____/ __ \/ /___ ___  _____  _____
  *     / /     / / / _ \/ ___/ ___/ __ \/ ___/ /_/ / / __ `/ / / / _ \/ ___/
  *    / /___  / / /  __/ /  / /  / /_/ / /  / ____/ / /_/ / /_/ /  __/ /    
  *    \____/ /_/  \___/_/  /_/   \____/_/  /_/   /_/\__,_/\__, /\___/_/     
  *                                                       /____/             
  */

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::RoundRespawn");
  g_hSDKCall[SDK_RoundRespawn] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_RoundRespawn] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::RoundRespawn");
  
  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::WarpGhostToInitialPosition");
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_WarpGhostToInitialPosition] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_WarpGhostToInitialPosition] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::WarpGhostToInitialPosition");
  
  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::BecomeGhost");
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_BecomeGhost] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_BecomeGhost] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::BecomeGhost");
  
  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::CanBecomeGhost");
  PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_CanBecomeGhost] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_CanBecomeGhost] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::CanBecomeGhost");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::TakeOverBot");
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_TakeOverBot] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_TakeOverBot] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::TakeOverBot");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::TakeOverZombieBot");
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  g_hSDKCall[SDK_TakeOverZombieBot] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_TakeOverZombieBot] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::TakeOverZombieBot");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::ReplaceWithBot");
  PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
  g_hSDKCall[SDK_ReplaceWithBot] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_ReplaceWithBot] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::ReplaceWithBot");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::ChangeTeam");
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  g_hSDKCall[SDK_ChangeTeam] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_ChangeTeam] == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CTerrorPlayer::ChangeTeam");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::SetClass");
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  g_hSDKCall[SDK_SetClass] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_SetClass] == INVALID_HANDLE)
      SetFailState("Failed to create SDKCall for CTerrorPlayer::SetClass");
      
  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer::WarpToValidPositionIfStuck");
  g_hSDKCall[SDK_WarpToValidPositionIfStuck] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_WarpToValidPositionIfStuck] == INVALID_HANDLE)
      SetFailState("Failed to create SDKCall for CTerrorPlayer::WarpToValidPositionIfStuck");

 /***
  *        __  ____          
  *       /  |/  (_)_________
  *      / /|_/ / / ___/ ___/
  *     / /  / / (__  ) /__  
  *    /_/  /_/_/____/\___/  
  *                          
  */

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "SurvivorBot::SetHumanSpectator");
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  g_hSDKCall[SDK_SetHumanSpectator] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_SetHumanSpectator] == INVALID_HANDLE)
      SetFailState("Failed to create SDKCall for SurvivorBot::SetHumanSpectator");

  StartPrepSDKCall(SDKCall_Static);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CBaseAbility::CreateForPlayer");
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
  g_hSDKCall[SDK_CreateAbility] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_CreateAbility] == INVALID_HANDLE)
      SetFailState("Failed to create SDKCall for CBaseAbility::CreateForPlayer");

  StartPrepSDKCall(SDKCall_Static);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorGameRules::IsMissionFinalMap");
  PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
  g_hSDKCall[SDK_IsMissionFinalMap] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_IsMissionFinalMap] == INVALID_HANDLE)
      SetFailState("Failed to create SDKCall for CTerrorGameRules::IsMissionFinalMap");
  StartPrepSDKCall(SDKCall_Static);

  /* FindNearbySpawnSpot(CTerrorPlayer*, Vector*, int, bool, float) */
  StartPrepSDKCall(SDKCall_Static);
  PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "FindNearbySpawnSpot");
  PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
  PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
  PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer, _, VENCODE_FLAG_COPYBACK);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
  g_hSDKCall[SDK_FindNearbySpawnSpot] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_FindNearbySpawnSpot] == INVALID_HANDLE)
      SetFailState("Failed to create SDKCall for FindNearbySpawnSpot");
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

public int Native_WarpGhostToInitialPosition(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_WarpGhostToInitialPosition], client, flag);
}

public int Native_BecomeGhost(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_BecomeGhost], client, flag);
}

public int Native_CanBecomeGhost(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_CanBecomeGhost], client, flag);
}

public int Native_TakeOverBot(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  bool flag = GetNativeCell(2);

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_TakeOverBot], client, flag);
}

public int Native_TakeOverZombieBot(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  int bot = GetNativeCell(2);

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  } else if (!IsValidClient(bot) || !IsFakeClient(bot)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid bot index (%d)", bot);
  }

  return SDKCall(g_hSDKCall[SDK_TakeOverZombieBot], client, bot);
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

  if (!IsValidClient(bot) || !IsFakeClient(bot)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid bot index (%d)", bot);
  } else if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_SetHumanSpectator], bot, client);
}

public int Native_ChangeTeam(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  L4D2Team team = L4D2_GetTeamFromInt(GetNativeCell(2));

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  } else if (team == L4D2Team_Unknown) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid team index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_ChangeTeam], client, team);
}

public int Native_SetInfectedClass(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  L4D2ClassType class = L4D2_GetClassFromInt(GetNativeCell(2));

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

  return 0;
}

public int Native_IsMissionFinalMap(Handle plugin, int numArgs) {
  return SDKCall(g_hSDKCall[SDK_IsMissionFinalMap]);
}

public int Native_GetRandomPZSpawnPosition(Handle plugin, int numArgs) {
  L4D2ClassType class = L4D2_GetClassFromInt(GetNativeCell(1));
  int tries = GetNativeCell(2);
  int client = GetNativeCell(3);
  float vector[3]; GetNativeArray(4, vector, sizeof(vector));

  if (class == L4D2Class_Unknown) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid or class index (%d)", class);
  } else if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  bool retVal = SDKCall(g_hSDKCall[SDK_GetRandomPZSpawnPosition], g_pZombieManager, class, tries, client, vector);
  SetNativeArray(4, vector, sizeof(vector));
  return retVal;
}

public int Native_FindNearbySpawnSpot(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);
  float vector[3]; GetNativeArray(2, vector, sizeof(vector));
  L4D2Team team = L4D2_GetTeamFromInt(GetNativeCell(3));
  bool flag = GetNativeCell(4);
  float radius = GetNativeCell(5);

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  } else if (team == L4D2Team_Unknown) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid team index (%d)", client);
  }

  bool retVal = SDKCall(g_hSDKCall[SDK_FindNearbySpawnSpot], client, vector, team, flag, radius);
  SetNativeArray(2, vector, sizeof(vector));
  return retVal;
}

public int Native_IsMissionStartMap(Handle plugin, int numArgs) {
  return SDKCall(g_hSDKCall[SDK_IsMissionStartMap], g_pTheDirector);
}

public int Native_IsClassAllowed(Handle plugin, int numArgs) {
  L4D2ClassType class = L4D2_GetClassFromInt(GetNativeCell(1));

  if (class == L4D2Class_Unknown) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid or class index (%d)", class);
  }

  return SDKCall(g_hSDKCall[SDK_IsClassAllowed], g_pTheDirector, class);
}

public int Native_WarpToValidPositionIfStuck(Handle plugin, int numArgs) {
  int client = GetNativeCell(1);

  if (!IsValidClient(client)) {
    return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
  }

  return SDKCall(g_hSDKCall[SDK_WarpToValidPositionIfStuck], client);
}

/***
 *        __  ___      ____  _ ______                      __  _______ ____           
 *       /  |/  /_  __/ / /_(_)_  __/___ __________ ____  / /_/ ____(_) / /____  _____
 *      / /|_/ / / / / / __/ / / / / __ `/ ___/ __ `/ _ \/ __/ /_  / / / __/ _ \/ ___/
 *     / /  / / /_/ / / /_/ / / / / /_/ / /  / /_/ /  __/ /_/ __/ / / / /_/  __/ /    
 *    /_/  /_/\__,_/_/\__/_/ /_/  \__,_/_/   \__, /\___/\__/_/   /_/_/\__/\___/_/     
 *                                          /____/                                    
 */

public bool MultiTargetFilter_Survivors(const char[] pattern, Handle clients) {
  for (int i = 1; i <= MaxClients; i++) {
    if (!IsPlayerSurvivor(i)) continue;
    PushArrayCell(clients, i);
  }

  return true;
}

public bool MultiTargetFilter_Infected(const char[] pattern, Handle clients) {
  for (int i = 1; i <= MaxClients; i++) {
    if (!IsPlayerInfected(i)) continue;
    PushArrayCell(clients, i);
  }

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
    if (IsPlayerSurvivor(target_list[i])) {
      L4D2_RespawnPlayer(target_list[i]);
      int player = FindClosestPlayer(target_list[i]);
      if (IsValidClient(player)) {
        float pos[3]; GetClientEyePosition(player, pos);
        bool found = L4D2_FindNearbySpawnSpot(player, pos, L4D2Team_Unassigned, true, 250.0);
        if (found) {
          TeleportEntity(target_list[i], pos, NULL_VECTOR, NULL_VECTOR);
        }
      }
    } else if (IsPlayerInfected(target_list[i])) {
      if (IsPlayerGhost(target_list[i])) {
        L4D2_RespawnPlayer(target_list[i]);
        SetEntProp(client, Prop_Send, "m_lifeState", 2);
      }
      SetEntProp(target_list[i], Prop_Send, "m_iPlayerState", 6);
      L4D2_BecomeGhost(target_list[i]);
    }
    L4D2_WarpToValidPositionIfStuck(target_list[i]);

    LogAction(client, target_list[i], "\"%L\" respawned \"%L\"", client, target_list[i]);
  }
  NyxAct(client, "Respawned %s", target_name);

  return Plugin_Handled;

/*
  float vector[3]; GetClientEyePosition(client, vector);
  bool retVal = L4D2_FindNearbySpawnSpot(client, vector, L4D2Team_Unassigned, true, 100.0);
  if (retVal) {
    TeleportEntity(client, vector, NULL_VECTOR, NULL_VECTOR);
  }
  */
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

  L4D2_ChangeTeam(client, L4D2Team_Spectator);
  if (IsPlayerInfected(target)) {
    L4D2_TakeOverZombieBot(client, target);
  } else {
    L4D2_SetHumanSpectator(target, client);
    L4D2_TakeOverBot(client);
  }

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
    team = view_as<int>(L4D2_StringToTeam(teamStr));
  }

  if (team < 0 || team > 3) {
    NyxMsgReply(client, "No team matchs '%s'", teamStr);
    return Plugin_Handled;
  }

  for (int i = 0; i < target_count; i++) {
    L4D2_ChangeTeam(target_list[i], view_as<L4D2Team>(team));
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

public Action ConCmd_Debug(int client, int args) {
  float vector[3]; GetClientEyePosition(client, vector);
  bool retVal = L4D2_FindNearbySpawnSpot(client, vector, L4D2Team_Unassigned, true, 100.0);
  if (retVal) {
    TeleportEntity(client, vector, NULL_VECTOR, NULL_VECTOR);
  }
  L4D2_WarpToValidPositionIfStuck(client);
  NyxMsgDebug("retVal: %d", retVal);

  return Plugin_Handled;
}
