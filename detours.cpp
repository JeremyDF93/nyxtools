#include "detours.h"

CDetour *Detour_ReplaceTank= NULL;
CDetour *Detour_IsWeaponAllowedToExist = NULL;
CDetour *Detour_IsMeleeWeaponAllowedToExist = NULL;

IForward *g_replaceTank = NULL;
IForward *g_isWeaponAllowedToExistForward = NULL;
IForward *g_isMeleeWeaponAllowedToExistForward  = NULL;

DETOUR_DECL_MEMBER2(ReplaceTank, bool, CTerrorPlayer *, param_1, CTerrorPlayer *, param_2) {
	bool origVal = DETOUR_MEMBER_CALL(ReplaceTank)(param_1, param_2);
  if (!g_replaceTank) {
    g_pSM->LogMessage(myself, "OnReplaceTank forward is invalid");
    return origVal;
  }

  cell_t newVal = origVal ? 1 : 0;
  int client_1 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));
	int client_2 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_2));
  g_replaceTank->PushCell(client_1);
  g_replaceTank->PushCell(client_2);
  g_replaceTank->PushCellByRef(&newVal); // return value

  cell_t result = 0;
  g_replaceTank->Execute(&result);

  if (result > Pl_Continue) {
    return newVal == 1;
  } else {
    return origVal;
  }
}

DETOUR_DECL_MEMBER1(IsWeaponAllowedToExist, bool, int, param_1) {
	bool origVal = DETOUR_MEMBER_CALL(IsWeaponAllowedToExist)(param_1);
  if (!g_isWeaponAllowedToExistForward) {
    g_pSM->LogMessage(myself, "IsWeaponAllowedToExist forward is invalid");
    return origVal;
  }

  cell_t newVal = origVal ? 1 : 0;
  g_isWeaponAllowedToExistForward->PushCell(param_1);
  g_isWeaponAllowedToExistForward->PushCellByRef(&newVal); // return value

  cell_t result = 0;
  g_isWeaponAllowedToExistForward->Execute(&result);

  if (result > Pl_Continue) {
    return newVal == 1;
  } else {
    return origVal;
  }
}

DETOUR_DECL_MEMBER1(IsMeleeWeaponAllowedToExist, bool, const char*, param_1) {
	bool origVal = DETOUR_MEMBER_CALL(IsMeleeWeaponAllowedToExist)(param_1);
  if (!g_isMeleeWeaponAllowedToExistForward) {
    g_pSM->LogMessage(myself, "IsMeleeWeaponAllowedToExist forward is invalid");
    return origVal;
  }

  cell_t newVal = origVal ? 1 : 0;
  g_isMeleeWeaponAllowedToExistForward->PushString(param_1);
  g_isMeleeWeaponAllowedToExistForward->PushCellByRef(&newVal); // return value

  cell_t result = 0;
  g_isMeleeWeaponAllowedToExistForward->Execute(&result);

  if (result > Pl_Continue) {
    return newVal == 1;
  } else {
    return origVal;
  }
}

bool InitialiseDetours() {
  Detour_ReplaceTank = DETOUR_CREATE_MEMBER(ReplaceTank, "ZombieManager::ReplaceTank");
	if (Detour_ReplaceTank != NULL) {
		Detour_ReplaceTank->EnableDetour();
		return true;
	} else {
    g_pSM->LogError(myself, "Failed to get signature for ZombieManager::ReplaceTank");
	  return false;
  }

	Detour_IsWeaponAllowedToExist = DETOUR_CREATE_MEMBER(IsWeaponAllowedToExist, 
      "CDirectorItemManager::IsWeaponAllowedToExist");
	if (Detour_IsWeaponAllowedToExist != NULL) {
		Detour_IsWeaponAllowedToExist->EnableDetour();
		return true;
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CDirectorItemManager::IsWeaponAllowedToExist");
	  return false;
  }

  Detour_IsMeleeWeaponAllowedToExist = DETOUR_CREATE_MEMBER(IsMeleeWeaponAllowedToExist, 
      "CDirectorItemManager::IsWeaponAllowedToExist");
	if (Detour_IsMeleeWeaponAllowedToExist != NULL) {
		Detour_IsMeleeWeaponAllowedToExist->EnableDetour();
		return true;
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CDirectorItemManager::IsMeleeWeaponAllowedToExist");
	  return false;
  }
}

void RemoveDetours() {
  Detour_ReplaceTank->Destroy();
	Detour_IsWeaponAllowedToExist->Destroy();
	Detour_IsMeleeWeaponAllowedToExist->Destroy();
}