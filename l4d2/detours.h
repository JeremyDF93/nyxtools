#ifndef _INCLUDE_NYXTOOLS_DETOURS_H_
#define _INCLUDE_NYXTOOLS_DETOURS_H_

#include "extension.h"
#include <IGameHelpers.h>
#include "CDetour/detours.h"

class CTerrorPlayer;

void CreateDetours();
void DestroyDetours();

extern IForward *g_pFwdReplaceTank;
extern IForward *g_pFwdTakeOverBot;
extern IForward *g_pFwdTakeOverZombieBot;
extern IForward *g_pFwdReplaceWithBot;
extern IForward *g_pFwdSetHumanSpectator;

#endif //_INCLUDE_NYXTOOLS_DETOURS_H_