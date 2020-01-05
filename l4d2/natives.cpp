#include <stdlib.h>
#include "extension.h"
#include "l4d2/l4d2.h"

#define REGISTER_NATIVE_ADDR(name, code) \
  void *addr; \
  if (!g_pGameConf->GetMemSig(name, &addr) || !addr) { \
    return pContext->ThrowNativeError("Failed to lookup %s signature.", name); \
  } \
  code; \
  g_RegNatives.Register(pWrapper);

inline CBaseEntity *GetCBaseEntity(int num, bool isplayer) {
  edict_t *pEdict = gamehelpers->EdictOfIndex(num);
  if (!pEdict || pEdict->IsFree()) {
    return NULL;
  }

  if (num > 0 && num <= playerhelpers->GetMaxClients()) {
    IGamePlayer *pPlayer = playerhelpers->GetGamePlayer(pEdict);
    if (!pPlayer || !pPlayer->IsConnected()) {
      return NULL;
    }
  } else if (isplayer) {
    return NULL;
  }

  IServerUnknown *pUnk;
  if ((pUnk=pEdict->GetUnknown()) == NULL) {
    return NULL;
  }

  return pUnk->GetBaseEntity();
}

/*
class CTerrorPlayer;
typedef int ZombieClassType;
SH_DECL_MANUALEXTERN4(GetRandomPZSpawnPosition, bool, ZombieClassType, int, CTerrorPlayer *, Vector *);

static cell_t L4D2_GetRandomPZSpawnPosition(IPluginContext *pContext, const cell_t *params) {
  ZombieClassType classType = (ZombieClassType) params[1];
  int tries = (int) params[2];
  CBaseEntity *pEntity;
  if (!(pEntity = GetCBaseEntity(params[3], true))) {
    return pContext->ThrowNativeError("Client index %d is not valid", params[3]);
  }

  Vector vector;
  cell_t *addr;
  int err;
  if ((err = pContext->LocalToPhysAddr(params[3], &addr)) != SP_ERROR_NONE) {
    return pContext->ThrowNativeError("Could not read vector");
  }

  if (addr != pContext->GetNullRef(SP_NULL_VECTOR)) {
    vector = Vector(sp_ctof(addr[0]), sp_ctof(addr[1]), sp_ctof(addr[2]));
  } else {
    return 0;
  }

  g_pSM->LogMessage(myself, "GetRandomPZSpawnPosition(L4D2ClassType: %d, tries: %d, client: %d, vector: (%f, %f, %f))", classType, tries, pEntity, vector[0], vector[1], vector[2]);
  SH_MCALL(g_pZombieManager, GetRandomPZSpawnPosition)(classType, tries, (CTerrorPlayer *)pEntity, &vector);
  return 1;
}
*/

sp_nativeinfo_t g_NYXNatives[] = {
  {nullptr,                               nullptr}
};
