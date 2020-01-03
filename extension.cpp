#include <ISDKTools.h>
#include "extension.h"
#if SOURCE_ENGINE == SE_TF2
# include "tf2/tf2.h"
#elif SOURCE_ENGINE == SE_LEFT4DEAD2
# include "l4d2/l4d2.h"
#endif

NyxTools g_Plugin;		/**< Global singleton for extension's main interface */
SMEXT_LINK(&g_Plugin);

IBinTools *g_pBinTools = NULL;
IGameConfig *g_pGameConf = NULL;
IServerGameEnts *gameents = NULL;
IServerTools *servertools = NULL;
ISDKTools *g_pSDKTools = NULL;

bool NyxTools::SDK_OnLoad(char *error, size_t maxlength, bool late) {
  sharesys->RegisterLibrary(myself, "NyxTools");
  plsys->AddPluginsListener(this);

#if SOURCE_ENGINE == SE_TF2
  g_TF2Tools.SDK_OnLoad(error, maxlength, late);
#elif SOURCE_ENGINE == SE_LEFT4DEAD2
  g_L4D2Tools.SDK_OnLoad(error, maxlength, late);
#endif

  return true;
}

void NyxTools::SDK_OnUnload() {
#if SOURCE_ENGINE == SE_TF2
  g_TF2Tools.SDK_OnUnload();
#elif SOURCE_ENGINE == SE_LEFT4DEAD2
  g_L4D2Tools.SDK_OnUnload();
#endif
}

void NyxTools::SDK_OnAllLoaded() {
  SM_GET_LATE_IFACE(SDKTOOLS, g_pSDKTools);

#if SOURCE_ENGINE == SE_TF2
  g_TF2Tools.SDK_OnAllLoaded();
#elif SOURCE_ENGINE == SE_LEFT4DEAD2
  g_L4D2Tools.SDK_OnAllLoaded();
#endif
}

void NyxTools::OnPluginLoaded(IPlugin *plugin) {
  // OnPluginLoaded
}

void NyxTools::OnPluginUnloaded(IPlugin *plugin) {
  // OnPluginUnloaded
}

bool NyxTools::SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlen, bool late) {
  GET_V_IFACE_ANY(GetServerFactory, servertools, IServerTools, VSERVERTOOLS_INTERFACE_VERSION);

  return true;
}

void NyxTools::OnCoreMapStart(edict_t *pEdictList, int edictCount, int clientMax) {
#if SOURCE_ENGINE == SE_TF2
  g_TF2Tools.OnCoreMapStart(pEdictList, edictCount, clientMax);
#endif
}
