#include "l4d2/l4d2.h"
#include "l4d2/detours.h"
#include "RegNatives.h"

L4D2Tools g_L4D2Tools;

void *g_pZombieManager = nullptr;

extern sp_nativeinfo_t g_NYXNatives[];

L4D2Tools::L4D2Tools() :
m_bDetoursEnabled(false)
{}

bool L4D2Tools::SDK_OnLoad(char *error, size_t maxlength, bool late) {
  sharesys->AddNatives(myself, g_NYXNatives);
  plsys->AddPluginsListener(this);

  char conf_error[255] = "";
  if (!gameconfs->LoadGameConfigFile("nyxtools.l4d2", &g_pGameConf, conf_error, sizeof(conf_error))) {
    if (conf_error[0]) {
      UTIL_Format(error, maxlength, "Could not read nyxtools.l4d2.txt: %s", conf_error);
    }
    return false;
  }

  CDetourManager::Init(g_pSM->GetScriptingEngine(), g_pGameConf);

  char *addr = nullptr;
  if(!g_pGameConf->GetAddress("TheZombieManager", (void **)&addr)) {
		g_pSM->LogError(myself, "Failed to get address for TheZombieManager");
		return false;
	}
	g_pZombieManager = addr;

  g_pFwdReplaceTank = forwards->CreateForward("L4D2_OnReplaceTank", 
      ET_Event, 2, nullptr, Param_Cell, Param_Cell);
  g_pFwdTakeOverBot = forwards->CreateForward("L4D2_OnTakeOverBot", 
      ET_Event, 2, nullptr, Param_Cell, Param_Cell);
  g_pFwdTakeOverZombieBot = forwards->CreateForward("L4D2_OnTakeOverZombieBot", 
      ET_Event, 2, nullptr, Param_Cell, Param_Cell);
  g_pFwdReplaceWithBot = forwards->CreateForward("L4D2_OnReplaceWithBot", 
      ET_Event, 2, nullptr, Param_Cell, Param_Cell);
  g_pFwdSetHumanSpectator = forwards->CreateForward("L4D2_OnSetHumanSpectator", 
      ET_Event, 2, nullptr, Param_Cell, Param_Cell);
  g_pFwdOnFirstSurvivorLeftSafeArea = forwards->CreateForward("L4D2_OnFirstSurvivorLeftSafeArea", 
      ET_Event, 1, nullptr, Param_Cell);
  g_pFwdEndVersusModeRound = forwards->CreateForward("L4D2_OnEndVersusModeRound", 
      ET_Event, 1, nullptr, Param_Cell);
  g_pFwdOnSwapTeams = forwards->CreateForward("L4D2_OnSwapTeams", 
      ET_Event, 0, nullptr);

  g_pSM->LogMessage(myself, "Loaded L4D2 Tools");
  return true;
}

void L4D2Tools::SDK_OnUnload() {
  g_RegNatives.UnregisterAll();
  gameconfs->CloseGameConfigFile(g_pGameConf);

  forwards->ReleaseForward(g_pFwdReplaceTank);
  forwards->ReleaseForward(g_pFwdTakeOverBot);
  forwards->ReleaseForward(g_pFwdTakeOverZombieBot);
  forwards->ReleaseForward(g_pFwdReplaceWithBot);
  forwards->ReleaseForward(g_pFwdSetHumanSpectator);
  forwards->ReleaseForward(g_pFwdOnFirstSurvivorLeftSafeArea);
  forwards->ReleaseForward(g_pFwdEndVersusModeRound);
  forwards->ReleaseForward(g_pFwdOnSwapTeams);

  g_pSM->LogMessage(myself, "Unloaded L4D2 Tools");
}

void L4D2Tools::SDK_OnAllLoaded() {
  // TODO: stuff
}

void L4D2Tools::OnPluginLoaded(IPlugin *plugin) {
  if (!m_bDetoursEnabled) {
    g_pSM->LogMessage(myself, "Initiating L4D2 Detours");
    m_bDetoursEnabled = true;
    CreateDetours();
  }
}

void L4D2Tools::OnPluginUnloaded(IPlugin *plugin) {
  if (m_bDetoursEnabled) {
    g_pSM->LogMessage(myself, "Disabling L4D2 Detours");
    m_bDetoursEnabled = false;
    DestroyDetours();
  }
}
