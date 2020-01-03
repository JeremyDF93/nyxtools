#include "tf2/tf2.h"
#include "tf2/detours.h"
#include "RegNatives.h"

TF2Tools g_TF2Tools;

void *gamerules = NULL;
int g_iPlayingMannVsMachineOffs = -1;
bool g_bUpgradesEnabled = false;
bool g_bReviveEnabled = false;

extern sp_nativeinfo_t g_NYXNatives[];

TF2Tools::TF2Tools() :
m_bDetoursEnabled(false)
{}

bool TF2Tools::SDK_OnLoad(char *error, size_t maxlength, bool late) {
  sharesys->AddNatives(myself, g_NYXNatives);
  plsys->AddPluginsListener(this);

  char conf_error[255] = "";
  if (!gameconfs->LoadGameConfigFile("nyxtools.tf2", &g_pGameConf, conf_error, sizeof(conf_error))) {
    if (conf_error[0]) {
      UTIL_Format(error, maxlength, "Could not read nyxtools.tf2.txt: %s", conf_error);
    }
    return false;
  }

  CDetourManager::Init(g_pSM->GetScriptingEngine(), g_pGameConf);

  g_pSM->LogMessage(myself, "Loaded TF2 Tools");
  return true;
}

void TF2Tools::SDK_OnAllLoaded() {
  // TODO: Stuff
}

void TF2Tools::SDK_OnUnload() {
  g_RegNatives.UnregisterAll();
  gameconfs->CloseGameConfigFile(g_pGameConf);
  g_pSM->LogMessage(myself, "Unloaded L4D2 Tools");
}

void TF2Tools::OnPluginLoaded(IPlugin *plugin) {
  if (!m_bDetoursEnabled) {
    g_pSM->LogMessage(myself, "Initiating TF2 Detours");
    m_bDetoursEnabled = true;
    CreateDetours();
  }
}

void TF2Tools::OnPluginUnloaded(IPlugin *plugin) {
  if (m_bDetoursEnabled) {
    g_pSM->LogMessage(myself, "Disabling TF2 Detours");
    m_bDetoursEnabled = false;
    DestroyDetours();
  }
}

void TF2Tools::OnCoreMapStart(edict_t *pEdictList, int edictCount, int clientMax) {
  g_bUpgradesEnabled = false;
}

CBaseEntity *FindEntityByClassname(const char *classname) {
  CBaseEntity *pEntity = (CBaseEntity *)servertools->FirstEntity();
  while (pEntity) {
    if (strcmp(gamehelpers->GetEntityClassname(pEntity), classname) == 0) {
      return pEntity;
    }
    pEntity = (CBaseEntity *)servertools->NextEntity(pEntity);
  }

  return NULL;
}

bool CreateUpgrades() {
  if (!g_pSDKTools || !(gamerules = g_pSDKTools->GetGameRules())) {
    g_pSM->LogError(myself, "Failed to find GameRules");
    return false;
  }

  sm_sendprop_info_t info;
  if (!gamehelpers->FindSendPropInfo("CTFGameRulesProxy", "m_bPlayingMannVsMachine", &info)) {
    g_pSM->LogError(myself, "Failed to get prop info for CTFGameRulesProxy::m_bPlayingMannVsMachine");
    return false;
  }
  g_iPlayingMannVsMachineOffs = info.actual_offset;

  CBaseEntity *pEntity;
  pEntity = FindEntityByClassname("func_upgradestation");
  if (!pEntity) {
    g_pSM->LogMessage(myself, "Spawning 'func_upgradestation'");
    pEntity = (CBaseEntity *)servertools->CreateEntityByName("func_upgradestation");
    servertools->DispatchSpawn(pEntity);
  }
  pEntity = FindEntityByClassname("info_populator");
  if (!pEntity) {
    g_pSM->LogMessage(myself, "Spawning 'info_populator'");
    pEntity = (CBaseEntity *)servertools->CreateEntityByName("info_populator");
    servertools->DispatchSpawn(pEntity);
  }

  return true;
}

void DestroyUpgrades() {
  CBaseEntity *pEntity;
  pEntity = FindEntityByClassname("func_upgradestation");
  if (pEntity) {
    datamap_t *pMap = gamehelpers->GetDataMap(pEntity);

    sm_datatable_info_t info;
    if (gamehelpers->FindDataMapInfo(pMap, "InputKill", &info)) {
      g_pSM->LogMessage(myself, "Removing 'func_upgradestation'");
      static inputfunc_t fnKillEntity = info.prop->inputFunc;
      static inputdata_t data;
      (pEntity->*fnKillEntity)(data);
    }
  }
  pEntity = FindEntityByClassname("info_populator");
  if (pEntity) {
    datamap_t *pMap = gamehelpers->GetDataMap(pEntity);
    
    sm_datatable_info_t info;
    if (gamehelpers->FindDataMapInfo(pMap, "InputKill", &info)) {
      g_pSM->LogMessage(myself, "Removing 'info_populator'");
      static inputfunc_t fnKillEntity = info.prop->inputFunc;
      static inputdata_t data;
      (pEntity->*fnKillEntity)(data);
    }
  }
}
