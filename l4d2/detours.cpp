#include "detours.h"

CDetour *Detour_ReplaceTank = nullptr;
CDetour *Detour_TakeOverBot = nullptr;
CDetour *Detour_TakeOverZombieBot = nullptr;
CDetour *Detour_ReplaceWithBot = nullptr;
CDetour *Detour_SetHumanSpectator = nullptr;
CDetour *Detour_OnFirstSurvivorLeftSafeArea = nullptr;
CDetour *Detour_EndVersusModeRound = nullptr;
CDetour *Detour_SwapTeams = nullptr;
CDetour *Detour_GetRandomPZSpawnPosition = nullptr;
CDetour *Detour_StackTrace = nullptr;

IForward *g_pFwdReplaceTank = nullptr;
IForward *g_pFwdTakeOverBot = nullptr;
IForward *g_pFwdTakeOverZombieBot = nullptr;
IForward *g_pFwdReplaceWithBot = nullptr;
IForward *g_pFwdSetHumanSpectator = nullptr;
IForward *g_pFwdOnFirstSurvivorLeftSafeArea = nullptr;
IForward *g_pFwdEndVersusModeRound = nullptr;
IForward *g_pFwdOnSwapTeams = nullptr;

// Is return void?
DETOUR_DECL_MEMBER2(ReplaceTank, bool, CTerrorPlayer *, param_1, CTerrorPlayer *, param_2) {
  if (!g_pFwdReplaceTank) {
    g_pSM->LogMessage(myself, "OnReplaceTank forward is invalid");
    return DETOUR_MEMBER_CALL(ReplaceTank)(param_1, param_2);
  }

  int client_1 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_1));
  int client_2 = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_2));

#ifdef _DEBUG
  g_pSM->LogMessage(myself, "ReplaceTank(%d, %d)", client_1, client_2);
#endif

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

#ifdef _DEBUG
  g_pSM->LogMessage(myself, "CTerrorPlayer(%d)::TakeOverBot(%d)", client, param_1);
#endif

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

#ifdef _DEBUG
  g_pSM->LogMessage(myself, "CTerrorPlayer(%d)::TakeOverZombieBot(%d)", bot, client);
#endif

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

#ifdef _DEBUG
  g_pSM->LogMessage(myself, "CTerrorPlayer(%d)::ReplaceWithBot(%d)", client, param_1);
#endif

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

#ifdef _DEBUG
  g_pSM->LogMessage(myself, "SurvivorBot(%d)::SetHumanSpectator(%d)", bot, client);
#endif

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

#ifdef _DEBUG
  g_pSM->LogMessage(myself, "OnFirstSurvivorLeftSafeArea(%d)", client);
#endif

  cell_t result = Pl_Continue;
  g_pFwdOnFirstSurvivorLeftSafeArea->PushCell(client);
  g_pFwdOnFirstSurvivorLeftSafeArea->Execute(&result);

  if (result == Pl_Continue) {
    DETOUR_MEMBER_CALL(OnFirstSurvivorLeftSafeArea)(param_1);
    return;
  }
}

DETOUR_DECL_MEMBER0(SwapTeams, void) {
#ifdef _DEBUG
  g_pSM->LogMessage(myself, "SwapTeams()");
#endif

  cell_t result = Pl_Continue;
  g_pFwdOnSwapTeams->Execute(&result);

  if (result == Pl_Continue) {
    DETOUR_MEMBER_CALL(SwapTeams)();
    return;
  }
}

DETOUR_DECL_MEMBER1(EndVersusModeRound, void, bool, param_1) {
  if (!g_pFwdEndVersusModeRound) {
    g_pSM->LogMessage(myself, "EndVersusModeRound forward is invalid");
    DETOUR_MEMBER_CALL(EndVersusModeRound)(param_1);
    return;
  }

#ifdef _DEBUG
  g_pSM->LogMessage(myself, "EndVersusModeRound(%d)", param_1);
#endif

  cell_t result = Pl_Continue;
  g_pFwdEndVersusModeRound->PushCell(param_1);
  g_pFwdEndVersusModeRound->Execute(&result);

  if (result == Pl_Continue) {
    DETOUR_MEMBER_CALL(EndVersusModeRound)(param_1);
    return;
  }
}

DETOUR_DECL_MEMBER4(GetRandomPZSpawnPosition, bool, ZombieClassType, param_1, int, param_2, CTerrorPlayer *, param_3, Vector *, param_4) {
  //int client = 0;
  //if (param_3) client = gamehelpers->EntityToBCompatRef(reinterpret_cast<CBaseEntity *>(param_3));
  g_pSM->LogMessage(myself, "%d::GetRandomPZSpawnPosition(ZombieClassType: %d, int: %d, CTerrorPlayer: %d, Vector: (%f, %f, %f))", this, param_1, param_2, param_3, param_4->x, param_4->y, param_4->z);
  return DETOUR_MEMBER_CALL(GetRandomPZSpawnPosition)(param_1, param_2, param_3, param_4);
}

// Crash everthing on purpose!
DETOUR_DECL_MEMBER0(StackTrace, void) {
  DETOUR_MEMBER_CALL(StackTrace)();
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
  
  Detour_SwapTeams = DETOUR_CREATE_MEMBER(SwapTeams, "CDirector::SwapTeams");
  if (Detour_SwapTeams != nullptr) {
    Detour_SwapTeams->EnableDetour();
  } else {
    g_pSM->LogError(myself, "Failed to get signature for CDirector::SwapTeams");
  }
  
  /*
  Detour_GetRandomPZSpawnPosition = DETOUR_CREATE_MEMBER(GetRandomPZSpawnPosition, "ZombieManager::GetRandomPZSpawnPosition");
  if (Detour_GetRandomPZSpawnPosition != nullptr) {
    Detour_GetRandomPZSpawnPosition->EnableDetour();
  } else {
    g_pSM->LogError(myself, "Failed to get signature for ZombieManager::GetRandomPZSpawnPosition");
  }
  */
  
  /*
  Detour_StackTrace = DETOUR_CREATE_MEMBER(StackTrace, "StackTrace");
  if (Detour_StackTrace != nullptr) {
    Detour_StackTrace->EnableDetour();
  } else {
    g_pSM->LogError(myself, "Failed to get signature for StackTrace");
  }
  */
}

void DestroyDetours() {
  if (Detour_ReplaceTank) Detour_ReplaceTank->Destroy();
  if (Detour_TakeOverBot) Detour_TakeOverBot->Destroy();
  if (Detour_TakeOverZombieBot) Detour_TakeOverZombieBot->Destroy();
  if (Detour_ReplaceWithBot) Detour_ReplaceWithBot->Destroy();
  if (Detour_SetHumanSpectator) Detour_SetHumanSpectator->Destroy();
  if (Detour_OnFirstSurvivorLeftSafeArea) Detour_OnFirstSurvivorLeftSafeArea->Destroy();
  if (Detour_EndVersusModeRound) Detour_EndVersusModeRound->Destroy();
  if (Detour_SwapTeams) Detour_SwapTeams->Destroy();
  if (Detour_GetRandomPZSpawnPosition) Detour_GetRandomPZSpawnPosition->Destroy();
  if (Detour_StackTrace) Detour_StackTrace->Destroy();
}