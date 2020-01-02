#include "detours.h"

CDetour *Detour_ReplaceTank = NULL;
CDetour *Detour_TakeOverBot = NULL;
CDetour *Detour_TakeOverZombieBot = NULL;
CDetour *Detour_ReplaceWithBot = NULL;
CDetour *Detour_SetHumanSpectator = NULL;
CDetour *Detour_IsWeaponAllowedToExist = NULL;
CDetour *Detour_IsMeleeWeaponAllowedToExist = NULL;

IForward *g_pFwdReplaceTank = NULL;
IForward *g_pFwdReplaceWithBot = NULL;
IForward *g_pFwdIsWeaponAllowedToExist = NULL;
IForward *g_pFwdIsMeleeWeaponAllowedToExist  = NULL;

DETOUR_DECL_MEMBER2(ReplaceTank, void, CTerrorPlayer *, param_1, CTerrorPlayer *, param_2) {
	DETOUR_MEMBER_CALL(ReplaceTank)(param_1, param_2);
  if (!g_pFwdReplaceTank) {
    g_pSM->LogMessage(myself, "OnReplaceTank forward is invalid");
    return;
  }
  g_pSM->LogMessage(myself, "ReplaceTank(%d, %d)", param_1, param_2);
/*
  int client_1 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));
	int client_2 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_2));
  g_pFwdReplaceTank->PushCell(client_1);
  g_pFwdReplaceTank->PushCell(client_2);
  g_pFwdReplaceTank->Execute();
*/
}

DETOUR_DECL_MEMBER1(TakeOverBot, void, bool, param_1) {
	DETOUR_MEMBER_CALL(TakeOverBot)(param_1);
  CBaseEntity *pEntity = reinterpret_cast<CBaseEntity *>(this);
  int client = gamehelpers->EntityToBCompatRef(pEntity);

  g_pSM->LogMessage(myself, "%d::TakeOverBot(%d)", client, param_1);
}

DETOUR_DECL_MEMBER1(TakeOverZombieBot, void, CTerrorPlayer *, param_1) {
	DETOUR_MEMBER_CALL(TakeOverZombieBot)(param_1);
  CBaseEntity *pEntity = reinterpret_cast<CBaseEntity *>(this);
  int client = gamehelpers->EntityToBCompatRef(pEntity);
  int target = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));

  g_pSM->LogMessage(myself, "%d::TakeOverZombieBot(%d)", client, target);
}

DETOUR_DECL_MEMBER1(ReplaceWithBot, void, bool, param_1) {
	DETOUR_MEMBER_CALL(ReplaceWithBot)(param_1);
  CBaseEntity *pEntity = reinterpret_cast<CBaseEntity *>(this);
  int client = gamehelpers->EntityToBCompatRef(pEntity);
  
  if (!g_pFwdReplaceWithBot) {
    g_pSM->LogMessage(myself, "ReplaceWithBot forward is invalid");
    return;
  }
  g_pSM->LogMessage(myself, "%d::ReplaceWithBot(%d)", client, param_1);

/*
  g_pFwdReplaceWithBot->PushCell(param_1);
  g_pFwdReplaceWithBot->Execute();
*/
}

DETOUR_DECL_MEMBER1(SetHumanSpectator, void, CTerrorPlayer *, param_1) {
	DETOUR_MEMBER_CALL(SetHumanSpectator)(param_1);
  CBaseEntity *pEntity = reinterpret_cast<CBaseEntity *>(this);
  int client = gamehelpers->EntityToBCompatRef(pEntity);
  int target = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));

  g_pSM->LogMessage(myself, "%d::SetHumanSpectator(%d)", client, target);
}

DETOUR_DECL_MEMBER1(IsWeaponAllowedToExist, bool, int, param_1) {
	bool origVal = DETOUR_MEMBER_CALL(IsWeaponAllowedToExist)(param_1);
  if (!g_pFwdIsWeaponAllowedToExist) {
    g_pSM->LogMessage(myself, "IsWeaponAllowedToExist forward is invalid");
    return origVal;
  }
  //g_pSM->LogMessage(myself, "%d IsWeaponAllowedToExist(%d)", origVal, param_1);

/*
  cell_t newVal = origVal ? 1 : 0;
  g_pFwdIsWeaponAllowedToExist->PushCell(param_1);
  g_pFwdIsWeaponAllowedToExist->PushCellByRef(&newVal); // return value

  cell_t result = 0;
  g_pFwdIsWeaponAllowedToExist->Execute(&result);

  if (result > Pl_Continue) {
    return newVal == 1;
  } else {
    return origVal;
  }
*/
  return origVal;
}

DETOUR_DECL_MEMBER1(IsMeleeWeaponAllowedToExist, bool, int, param_1) {
	bool origVal = DETOUR_MEMBER_CALL(IsMeleeWeaponAllowedToExist)(param_1);
  if (!g_pFwdIsMeleeWeaponAllowedToExist) {
    g_pSM->LogMessage(myself, "IsMeleeWeaponAllowedToExist forward is invalid");
    return origVal;
  }
  //g_pSM->LogMessage(myself, "%d IsMeleeWeaponAllowedToExist(%d)", origVal, param_1);

/*
  cell_t newVal = origVal ? 1 : 0;
  g_pFwdIsMeleeWeaponAllowedToExist->PushString(param_1);
  g_pFwdIsMeleeWeaponAllowedToExist->PushCellByRef(&newVal); // return value

  cell_t result = 0;
  g_pFwdIsMeleeWeaponAllowedToExist->Execute(&result);

  if (result > Pl_Continue) {
    return newVal == 1;
  } else {
    return origVal;
  }
*/
  return origVal;
}

void InitialiseDetours() {
  Detour_ReplaceTank = DETOUR_CREATE_MEMBER(ReplaceTank, "ZombieManager::ReplaceTank");
	if (Detour_ReplaceTank != NULL) {
		Detour_ReplaceTank->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for ZombieManager::ReplaceTank");
  }

  Detour_TakeOverBot = DETOUR_CREATE_MEMBER(TakeOverBot, "CTerrorPlayer::TakeOverBot");
	if (Detour_TakeOverBot != NULL) {
		Detour_TakeOverBot->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::TakeOverBot");
  }
  
  Detour_TakeOverZombieBot = DETOUR_CREATE_MEMBER(TakeOverZombieBot, "CTerrorPlayer::TakeOverZombieBot");
	if (Detour_TakeOverZombieBot != NULL) {
		Detour_TakeOverZombieBot->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::TakeOverZombieBot");
  }
  
  Detour_ReplaceWithBot = DETOUR_CREATE_MEMBER(ReplaceWithBot, "CTerrorPlayer::ReplaceWithBot");
	if (Detour_ReplaceWithBot != NULL) {
		Detour_ReplaceWithBot->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::ReplaceWithBot");
  }
  
  Detour_SetHumanSpectator = DETOUR_CREATE_MEMBER(SetHumanSpectator, "SurvivorBot::SetHumanSpectator");
	if (Detour_SetHumanSpectator != NULL) {
		Detour_SetHumanSpectator->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::SetHumanSpectator");
  }

	Detour_IsWeaponAllowedToExist = DETOUR_CREATE_MEMBER(IsWeaponAllowedToExist, 
      "CDirectorItemManager::IsWeaponAllowedToExist");
	if (Detour_IsWeaponAllowedToExist != NULL) {
		Detour_IsWeaponAllowedToExist->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CDirectorItemManager::IsWeaponAllowedToExist");
  }

  Detour_IsMeleeWeaponAllowedToExist = DETOUR_CREATE_MEMBER(IsMeleeWeaponAllowedToExist, 
      "CDirectorItemManager::IsWeaponAllowedToExist");
	if (Detour_IsMeleeWeaponAllowedToExist != NULL) {
		Detour_IsMeleeWeaponAllowedToExist->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CDirectorItemManager::IsMeleeWeaponAllowedToExist");
  }
}

void RemoveDetours() {
  Detour_ReplaceTank->Destroy();
	Detour_IsWeaponAllowedToExist->Destroy();
	Detour_IsMeleeWeaponAllowedToExist->Destroy();
}