#include "extension.h"
#include "util.h"
#include "detours.h"

NyxTools g_Plugin;		/**< Global singleton for extension's main interface */
SMEXT_LINK(&g_Plugin);

IGameConfig *g_pGameConf = NULL;
IServerGameEnts *gameents = NULL;

bool NyxTools::SDK_OnLoad(char *error, size_t maxlength, bool late) {
  sharesys->RegisterLibrary(myself, "NyxTools");
  plsys->AddPluginsListener(this);

  char conf_error[255] = "";
#if SOURCE_ENGINE == SE_LEFT4DEAD2
  if (!gameconfs->LoadGameConfigFile("nyxtools.l4d2", &g_pGameConf, conf_error, sizeof(conf_error))) {
    if (conf_error[0]) {
      UTIL_Format(error, maxlength, "Could not read nyxtools.l4d2.txt: %s", conf_error);
    }
    return false;
  }
#endif

  CDetourManager::Init(g_pSM->GetScriptingEngine(), g_pGameConf);

#if SOURCE_ENGINE == SE_LEFT4DEAD2
  g_replaceTank = forwards->CreateForward("L4D2_OnReplaceTank", ET_Event, 3, NULL, Param_Cell, Param_Cell, Param_CellByRef);
  g_isWeaponAllowedToExistForward = forwards->CreateForward("L4D2_OnIsWeaponAllowedToExist", ET_Event, 2, NULL, Param_Cell, Param_CellByRef);
  g_isMeleeWeaponAllowedToExistForward = forwards->CreateForward("L4D2_OnIsMeleeWeaponAllowedToExist", ET_Event, 2, NULL, Param_String, Param_CellByRef);

  m_bDetoursEnabled = false;
#endif

  return true;
}

void NyxTools::SDK_OnUnload() {
  gameconfs->CloseGameConfigFile(g_pGameConf);
}

void NyxTools::OnPluginLoaded(IPlugin *plugin) {
#if SOURCE_ENGINE == SE_LEFT4DEAD2
  if (!m_bDetoursEnabled) {
    m_bDetoursEnabled = InitialiseDetours();
  }
#endif
}

void NyxTools::OnPluginUnloaded(IPlugin *plugin) {
#if SOURCE_ENGINE == SE_LEFT4DEAD2
  if (m_bDetoursEnabled) {
    RemoveDetours();
    m_bDetoursEnabled = false;
  }
#endif
}
