#include "l4d2.h"
#include "l4d2/detours.h"

NyxGame g_NyxGame;

void *g_pZombieManager = NULL;

NyxGame::NyxGame() :
m_bDetoursEnabled(false)
{}

bool NyxGame::SDK_OnLoad(char *error, size_t maxlength, bool late) {
  plsys->AddPluginsListener(this);

  char conf_error[255] = "";
  if (!gameconfs->LoadGameConfigFile("nyxtools.l4d2", &g_pGameConf, conf_error, sizeof(conf_error))) {
    if (conf_error[0]) {
      UTIL_Format(error, maxlength, "Could not read nyxtools.l4d2.txt: %s", conf_error);
    }
    return false;
  }

  CDetourManager::Init(g_pSM->GetScriptingEngine(), g_pGameConf);

  char *addr = NULL;
  if(!g_pGameConf->GetAddress("TheZombieManager", (void **)&addr)) {
		g_pSM->LogError(myself, "Failed to get address for TheZombieManager");
		return false;
	}
	g_pZombieManager = addr;

  g_pFwdReplaceTank = forwards->CreateForward("L4D2_OnReplaceTank", ET_Event, 2, NULL, Param_Cell, Param_Cell);
  g_pFwdReplaceWithBot = forwards->CreateForward("L4D2_OnReplaceWithBot", ET_Event, 1, NULL, Param_Cell);
  g_pFwdIsWeaponAllowedToExist = forwards->CreateForward("L4D2_OnIsWeaponAllowedToExist", ET_Event, 2, NULL, Param_Cell, Param_CellByRef);
  g_pFwdIsMeleeWeaponAllowedToExist = forwards->CreateForward("L4D2_OnIsMeleeWeaponAllowedToExist", ET_Event, 2, NULL, Param_String, Param_CellByRef);

  g_pSM->LogMessage(myself, "Loaded L4D2 Tools");
  return true;
}

void NyxGame::SDK_OnUnload() {
  g_pSM->LogMessage(myself, "Unloaded L4D2 Tools");
  gameconfs->CloseGameConfigFile(g_pGameConf);
}

void NyxGame::OnPluginLoaded(IPlugin *plugin) {
  if (!m_bDetoursEnabled) {
    g_pSM->LogMessage(myself, "Initiating L4D2 Detours");
    m_bDetoursEnabled = true;
    InitialiseDetours();
  }
}

void NyxGame::OnPluginUnloaded(IPlugin *plugin) {
  if (m_bDetoursEnabled) {
    g_pSM->LogMessage(myself, "Disabling L4D2 Detours");
    m_bDetoursEnabled = false;
    RemoveDetours();
  }
}
