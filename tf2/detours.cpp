#include "detours.h"
#include "tf2/tf2.h"

CDetour *Detour_EventKilled = nullptr;
CDetour *Detour_CycleMission = nullptr;
CDetour *Detour_GameModeUsesUpgrades = nullptr;
CDetour *Detour_ClientCommandKeyValues = nullptr;

IForward *g_pFwdEventKilled = nullptr;

class CTakeDamageInfo;

DETOUR_DECL_MEMBER1(EventKilled, void, CTakeDamageInfo const&, info) {
  if (!g_bUpgradesEnabled || !g_bReviveEnabled) {
    DETOUR_MEMBER_CALL(EventKilled)(info);
    return;
  }

  bool &m_bPlayingMannVsMachine = *(bool *)((intptr_t)gamerules + g_iPlayingMannVsMachineOffs);
  bool orig = m_bPlayingMannVsMachine;
  m_bPlayingMannVsMachine = true;
  DETOUR_MEMBER_CALL(EventKilled)(info);
  m_bPlayingMannVsMachine = orig;
}

DETOUR_DECL_MEMBER0(CycleMission, void) {
  if (!g_bUpgradesEnabled) {
    DETOUR_MEMBER_CALL(CycleMission)();
    return;
  }

  g_pSM->LogMessage(myself, "Blocking CPopulationManager::CycleMission");
}

DETOUR_DECL_MEMBER0(GameModeUsesUpgrades, bool) {
  if (!g_bUpgradesEnabled) {
    return DETOUR_MEMBER_CALL(GameModeUsesUpgrades)();
  }

  //g_pSM->LogMessage(myself, "Blocking CTFGameRules::GameModeUsesUpgrades");
  return true;
}

DETOUR_DECL_MEMBER2(ClientCommandKeyValues, void, edict_t *, pEntity, KeyValues *, pCommand) {
  if (!g_bUpgradesEnabled) {
    DETOUR_MEMBER_CALL(ClientCommandKeyValues)(pEntity, pCommand);
    return;
  }

  bool &m_bPlayingMannVsMachine = *(bool *)((intptr_t)gamerules + g_iPlayingMannVsMachineOffs);
  bool orig = m_bPlayingMannVsMachine;
  m_bPlayingMannVsMachine = true;
  DETOUR_MEMBER_CALL(ClientCommandKeyValues)(pEntity, pCommand);
  m_bPlayingMannVsMachine = orig;
}

void CreateDetours() {
  Detour_EventKilled = DETOUR_CREATE_MEMBER(EventKilled, "CTFPlayer::Event_Killed");
    if (Detour_EventKilled != nullptr) {
      Detour_EventKilled->EnableDetour();
    } else {
    g_pSM->LogError(myself, "Failed to get signature for CTFPlayer::Event_Killed");
  }

  Detour_CycleMission = DETOUR_CREATE_MEMBER(CycleMission, "CPopulationManager::CycleMission");
    if (Detour_CycleMission != nullptr) {
      Detour_CycleMission->EnableDetour();
    } else {
    g_pSM->LogError(myself, "Failed to get signature for CPopulationManager::CycleMission");
  }

  Detour_GameModeUsesUpgrades = DETOUR_CREATE_MEMBER(GameModeUsesUpgrades, "CTFGameRules::GameModeUsesUpgrades");
    if (Detour_GameModeUsesUpgrades != nullptr) {
      Detour_GameModeUsesUpgrades->EnableDetour();
    } else {
    g_pSM->LogError(myself, "Failed to get signature for CTFGameRules::GameModeUsesUpgrades");
  }

  Detour_ClientCommandKeyValues = DETOUR_CREATE_MEMBER(ClientCommandKeyValues, "CServerGameClients::ClientCommandKeyValues");
    if (Detour_ClientCommandKeyValues != nullptr) {
      Detour_ClientCommandKeyValues->EnableDetour();
    } else {
    g_pSM->LogError(myself, "Failed to get signature for CServerGameClients::ClientCommandKeyValues");
  }
}

void DestroyDetours() {
  if (Detour_EventKilled) Detour_EventKilled->Destroy();
  if (Detour_CycleMission) Detour_CycleMission->Destroy();
  if (Detour_GameModeUsesUpgrades) Detour_GameModeUsesUpgrades->Destroy();
  if (Detour_ClientCommandKeyValues) Detour_ClientCommandKeyValues->Destroy();
}
