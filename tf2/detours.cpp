#include "detours.h"
#include "tf2/tf2.h"

CDetour *Detour_EventKilled = NULL;
CDetour *Detour_CycleMission = NULL;
CDetour *Detour_GameModeUsesUpgrades = NULL;

IForward *g_pFwdEventKilled = NULL;

class CTakeDamageInfo;

DETOUR_DECL_MEMBER1(EventKilled, void, CTakeDamageInfo const&, param_1) {
  if (!g_bUpgradesEnabled) {
    DETOUR_MEMBER_CALL(EventKilled)(param_1);
    return;
  }

  bool &m_bPlayingMannVsMachine = *(bool *)((intptr_t)gamerules + g_iPlayingMannVsMachineOffs);
  bool orig = m_bPlayingMannVsMachine;
  m_bPlayingMannVsMachine = 1;
  DETOUR_MEMBER_CALL(EventKilled)(param_1);
  m_bPlayingMannVsMachine = orig;

  return;
}

DETOUR_DECL_MEMBER0(CycleMission, void) {
  if (!g_bUpgradesEnabled) {
    DETOUR_MEMBER_CALL(CycleMission)();
    return;
  }

  g_pSM->LogMessage(myself, "Blocking CPopulationManager::CycleMission");
  return; // DETOUR_MEMBER_CALL(CycleMission)();
}

DETOUR_DECL_MEMBER0(GameModeUsesUpgrades, bool) {
  if (!g_bUpgradesEnabled) {
    return DETOUR_MEMBER_CALL(GameModeUsesUpgrades)();
  }
  
  //g_pSM->LogMessage(myself, "Blocking CTFGameRules::GameModeUsesUpgrades");
  return true; // DETOUR_MEMBER_CALL(GameModeUsesUpgrades)();
}

void CreateDetours() {
  Detour_EventKilled = DETOUR_CREATE_MEMBER(EventKilled, "CTFPlayer::Event_Killed");
	if (Detour_EventKilled != NULL) {
		Detour_EventKilled->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTFPlayer::Event_Killed");
  }

  Detour_CycleMission = DETOUR_CREATE_MEMBER(CycleMission, "CPopulationManager::CycleMission");
	if (Detour_CycleMission != NULL) {
		Detour_CycleMission->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CPopulationManager::CycleMission");
  }
  
  Detour_GameModeUsesUpgrades = DETOUR_CREATE_MEMBER(GameModeUsesUpgrades, "CTFGameRules::GameModeUsesUpgrades");
	if (Detour_GameModeUsesUpgrades != NULL) {
		Detour_GameModeUsesUpgrades->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTFGameRules::GameModeUsesUpgrades");
  }
}

void DestroyDetours() {
  Detour_EventKilled->Destroy();
}
