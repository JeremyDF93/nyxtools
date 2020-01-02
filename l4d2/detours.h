#ifndef _INCLUDE_NYXTOOLS_DETOURS_H_
#define _INCLUDE_NYXTOOLS_DETOURS_H_

#include "extension.h"
#include <IGameHelpers.h>
#include "CDetour/detours.h"

class CTerrorPlayer;

void InitialiseDetours();
void RemoveDetours();

extern IForward *g_pFwdReplaceTank;
extern IForward *g_pFwdReplaceWithBot;
extern IForward *g_pFwdIsWeaponAllowedToExist;
extern IForward *g_pFwdIsMeleeWeaponAllowedToExist;

#endif //_INCLUDE_NYXTOOLS_DETOURS_H_