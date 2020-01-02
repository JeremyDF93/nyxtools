#ifndef _INCLUDE_NYXTOOLS_DETOURS_H_
#define _INCLUDE_NYXTOOLS_DETOURS_H_

#include "extension.h"
#include <IGameHelpers.h>
#include "CDetour/detours.h"

class CTerrorPlayer;

bool InitialiseDetours();
void RemoveDetours();

extern IForward *g_replaceTank;
extern IForward *g_isWeaponAllowedToExistForward;
extern IForward *g_isMeleeWeaponAllowedToExistForward;

#endif //_INCLUDE_NYXTOOLS_DETOURS_H_