#include "detours.h"

CDetour *Detour_ReplaceTank = nullptr;
CDetour *Detour_TakeOverBot = nullptr;
CDetour *Detour_TakeOverZombieBot = nullptr;
CDetour *Detour_ReplaceWithBot = nullptr;
CDetour *Detour_SetHumanSpectator = nullptr;
CDetour *Detour_OnFirstSurvivorLeftSafeArea = nullptr;
CDetour *Detour_EndVersusModeRound = nullptr;

IForward *g_pFwdReplaceTank = nullptr;
IForward *g_pFwdTakeOverBot = nullptr;
IForward *g_pFwdTakeOverZombieBot = nullptr;
IForward *g_pFwdReplaceWithBot = nullptr;
IForward *g_pFwdSetHumanSpectator = nullptr;
IForward *g_pFwdOnFirstSurvivorLeftSafeArea = nullptr;
IForward *g_pFwdEndVersusModeRound = nullptr;

// Is return void?
DETOUR_DECL_MEMBER2(ReplaceTank, bool, CTerrorPlayer *, param_1, CTerrorPlayer *, param_2) {
  if (!g_pFwdReplaceTank) {
    g_pSM->LogMessage(myself, "OnReplaceTank forward is invalid");
    return DETOUR_MEMBER_CALL(ReplaceTank)(param_1, param_2);
  }

  int client_1 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));
	int client_2 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_2));
  //g_pSM->LogMessage(myself, "ReplaceTank(%d, %d)", client_1, client_2);

  cell_t result = Pl_Continue;
  g_pFwdReplaceTank->PushCell(client_1);
  g_pFwdReplaceTank->PushCell(client_2);
  g_pFwdReplaceTank->Execute(&result);

  if (result == Pl_Continue) {
    return DETOUR_MEMBER_CALL(ReplaceTank)(param_1, param_2);
  }

  return false;
}

DETOUR_DECL_MEMBER1(TakeOverBot, bool, bool, param_1) {
  if (!g_pFwdTakeOverBot) {
    g_pSM->LogMessage(myself, "OnTakeOverBot forward is invalid");
    return DETOUR_MEMBER_CALL(TakeOverBot)(param_1);
  }

  int client = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(this));
  //g_pSM->LogMessage(myself, "CTerrorPlayer(%d)::TakeOverBot(%d)", client, param_1);

  cell_t result = Pl_Continue;
  g_pFwdTakeOverBot->PushCell(client);
  g_pFwdTakeOverBot->PushCell(param_1);
  g_pFwdTakeOverBot->Execute(&result);

  if (result == Pl_Continue) {
    return DETOUR_MEMBER_CALL(TakeOverBot)(param_1);
  }

  return false;
}

DETOUR_DECL_MEMBER1(TakeOverZombieBot, void, CTerrorPlayer *, param_1) {
  if (!g_pFwdTakeOverBot) {
    g_pSM->LogMessage(myself, "OnTakeOverZombieBot forward is invalid");
    DETOUR_MEMBER_CALL(TakeOverZombieBot)(param_1);
    return;
  }

  int client = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(this));
  int bot = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));
  //g_pSM->LogMessage(myself, "CTerrorPlayer(%d)::TakeOverZombieBot(%d)", bot, client);

  cell_t result = Pl_Continue;
  g_pFwdTakeOverZombieBot->PushCell(client);
  g_pFwdTakeOverZombieBot->PushCell(bot);
  g_pFwdTakeOverZombieBot->Execute(&result);

  if (result == Pl_Continue) {
    DETOUR_MEMBER_CALL(TakeOverZombieBot)(param_1);
  }

  }

// Not a void
DETOUR_DECL_MEMBER1(ReplaceWithBot, bool, bool, param_1) {
  if (!g_pFwdTakeOverBot) {
    g_pSM->LogMessage(myself, "OnReplaceWithBot forward is invalid");
    return DETOUR_MEMBER_CALL(ReplaceWithBot)(param_1);
  }

  int client = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(this));
  //g_pSM->LogMessage(myself, "CTerrorPlayer(%d)::ReplaceWithBot(%d)", client, param_1);

  cell_t result = Pl_Continue;
  g_pFwdReplaceWithBot->PushCell(client);
  g_pFwdReplaceWithBot->PushCell(param_1);
  g_pFwdReplaceWithBot->Execute(&result);

  if (result == Pl_Continue) {
    return DETOUR_MEMBER_CALL(ReplaceWithBot)(param_1);
  }

  return false;
}

DETOUR_DECL_MEMBER1(SetHumanSpectator, bool, CTerrorPlayer *, param_1) {
  if (!g_pFwdTakeOverBot) {
    g_pSM->LogMessage(myself, "OnSetHumanSpectator forward is invalid");
    return DETOUR_MEMBER_CALL(SetHumanSpectator)(param_1);
  }

  int bot = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(this));
  int client = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));
  //g_pSM->LogMessage(myself, "SurvivorBot(%d)::SetHumanSpectator(%d)", bot, client);

  cell_t result = Pl_Continue;
  g_pFwdSetHumanSpectator->PushCell(bot);
  g_pFwdSetHumanSpectator->PushCell(client);
  g_pFwdSetHumanSpectator->Execute(&result);

  if (result == Pl_Continue) {
    return DETOUR_MEMBER_CALL(SetHumanSpectator)(param_1);
  }

  return false;
}

DETOUR_DECL_MEMBER1(OnFirstSurvivorLeftSafeArea, void, CTerrorPlayer *, param_1) {
  if (!g_pFwdOnFirstSurvivorLeftSafeArea) {
    g_pSM->LogMessage(myself, "OnFirstSurvivorLeftSafeArea forward is invalid");
    DETOUR_MEMBER_CALL(OnFirstSurvivorLeftSafeArea)(param_1);
    return;
  }

  int client = 0;
  if (param_1) client = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));
  g_pSM->LogMessage(myself, "OnFirstSurvivorLeftSafeArea(%d)", client);


  cell_t result = Pl_Continue;
  g_pFwdOnFirstSurvivorLeftSafeArea->PushCell(client);
  g_pFwdOnFirstSurvivorLeftSafeArea->Execute(&result);

  if (result == Pl_Continue) {
    DETOUR_MEMBER_CALL(OnFirstSurvivorLeftSafeArea)(param_1);
    return;
  }

  }

DETOUR_DECL_MEMBER1(EndVersusModeRound, void, bool, param_1) {
  if (!g_pFwdEndVersusModeRound) {
    g_pSM->LogMessage(myself, "EndVersusModeRound forward is invalid");
    DETOUR_MEMBER_CALL(EndVersusModeRound)(param_1);
    return;
  }
  g_pSM->LogMessage(myself, "EndVersusModeRound(%d)", param_1);

  cell_t result = Pl_Continue;
  g_pFwdEndVersusModeRound->PushCell(param_1);
  g_pFwdEndVersusModeRound->Execute(&result);

  if (result == Pl_Continue) {
    DETOUR_MEMBER_CALL(EndVersusModeRound)(param_1);
    return;
  }

  }

void CreateDetours() {
  Detour_ReplaceTank = DETOUR_CREATE_MEMBER(ReplaceTank, "ZombieManager::ReplaceTank");
	if (Detour_ReplaceTank != nullptr) {
		Detour_ReplaceTank->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for ZombieManager::ReplaceTank");
  }

  Detour_TakeOverBot = DETOUR_CREATE_MEMBER(TakeOverBot, "CTerrorPlayer::TakeOverBot");
	if (Detour_TakeOverBot != nullptr) {
		Detour_TakeOverBot->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::TakeOverBot");
  }
  
  Detour_TakeOverZombieBot = DETOUR_CREATE_MEMBER(TakeOverZombieBot, "CTerrorPlayer::TakeOverZombieBot");
	if (Detour_TakeOverZombieBot != nullptr) {
		Detour_TakeOverZombieBot->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::TakeOverZombieBot");
  }
  
  Detour_ReplaceWithBot = DETOUR_CREATE_MEMBER(ReplaceWithBot, "CTerrorPlayer::ReplaceWithBot");
	if (Detour_ReplaceWithBot != nullptr) {
		Detour_ReplaceWithBot->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::ReplaceWithBot");
  }
  
  Detour_SetHumanSpectator = DETOUR_CREATE_MEMBER(SetHumanSpectator, "SurvivorBot::SetHumanSpectator");
	if (Detour_SetHumanSpectator != nullptr) {
		Detour_SetHumanSpectator->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CTerrorPlayer::SetHumanSpectator");
  }
  
  Detour_OnFirstSurvivorLeftSafeArea = DETOUR_CREATE_MEMBER(OnFirstSurvivorLeftSafeArea, "CDirector::OnFirstSurvivorLeftSafeArea");
	if (Detour_OnFirstSurvivorLeftSafeArea != nullptr) {
		Detour_OnFirstSurvivorLeftSafeArea->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CDirector::OnFirstSurvivorLeftSafeArea");
  }
  
  Detour_EndVersusModeRound = DETOUR_CREATE_MEMBER(EndVersusModeRound, "CDirectorVersusMode::EndVersusModeRound");
	if (Detour_EndVersusModeRound != nullptr) {
		Detour_EndVersusModeRound->EnableDetour();
	} else {
    g_pSM->LogError(myself, "Failed to get signature for CDirectorVersusMode::EndVersusModeRound");
  }
}

void DestroyDetours() {
  Detour_ReplaceTank->Destroy();
  Detour_TakeOverBot->Destroy();
  Detour_TakeOverZombieBot->Destroy();
  Detour_ReplaceWithBot->Destroy();
  Detour_SetHumanSpectator->Destroy();
  Detour_OnFirstSurvivorLeftSafeArea->Destroy();
  Detour_EndVersusModeRound->Destroy();
}