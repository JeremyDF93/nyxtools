#include "extension.h"
#if SOURCE_ENGINE == SE_LEFT4DEAD2
# include "l4d2.h"
#endif

NyxTools g_Plugin;		/**< Global singleton for extension's main interface */
SMEXT_LINK(&g_Plugin);

IGameConfig *g_pGameConf = NULL;
IServerGameEnts *gameents = NULL;

bool NyxTools::SDK_OnLoad(char *error, size_t maxlength, bool late) {
  sharesys->RegisterLibrary(myself, "NyxTools");
  plsys->AddPluginsListener(this);

#if SOURCE_ENGINE == SE_LEFT4DEAD2
  g_NyxGame.SDK_OnLoad(error, maxlength, late);
#endif

  return true;
}

void NyxTools::SDK_OnUnload() {
#if SOURCE_ENGINE == SE_LEFT4DEAD2
  g_NyxGame.SDK_OnUnload();
#endif
}

void NyxTools::OnPluginLoaded(IPlugin *plugin) {
  // OnPluginLoaded
}

void NyxTools::OnPluginUnloaded(IPlugin *plugin) {
  // OnPluginUnloaded
}
