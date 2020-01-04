#include <stdlib.h>
#include "extension.h"
#include "tf2/tf2.h"

static cell_t TF2_SetUpgradesMode(IPluginContext *pContext, const cell_t *params) {
  bool enable = (bool) params[1];
  g_bReviveEnabled = (bool) params[2];

  if (enable) {
    if (g_bUpgradesEnabled) {
      return true;
    }

    return (cell_t)(g_bUpgradesEnabled = CreateUpgrades());
  }

  g_bUpgradesEnabled = false;
  DestroyUpgrades();

  return true;
}

static cell_t TF2_IsUpgradesEnabled(IPluginContext *pContext, const cell_t *params) {
  return g_bUpgradesEnabled;
}

sp_nativeinfo_t g_NYXNatives[] = {
  {"TF2_SetUpgradesMode",       TF2_SetUpgradesMode},
  {"TF2_IsUpgradesEnabled",     TF2_IsUpgradesEnabled},
  {nullptr,                        nullptr}
};
