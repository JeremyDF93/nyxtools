#ifndef _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_
#define _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_

/**
 * @file extension.h
 * @brief Sample extension code header.
 */

#include <smsdk_ext.h>
#include <itoolentity.h>
#include <IBinTools.h>
#include <ISDKTools.h>
#include "util.h"

namespace SourceMod {
	class ISDKTools;
}

class NyxTools :
	public SDKExtension ,
	public IPluginsListener
{
public:
	virtual bool SDK_OnLoad(char *error, size_t maxlength, bool late);
	virtual void SDK_OnUnload();
	virtual void SDK_OnAllLoaded();
	//virtual void SDK_OnPauseChange(bool paused);
	//virtual bool QueryRunning(char *error, size_t maxlength);
	virtual void OnCoreMapStart(edict_t *pEdictList, int edictCount, int clientMax);
public: //IPluginsListener
	virtual void OnPluginLoaded(IPlugin *plugin);
	virtual void OnPluginUnloaded(IPlugin *plugin);
public:
#if defined SMEXT_CONF_METAMOD
	virtual bool SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlen, bool late);
	//virtual bool SDK_OnMetamodUnload(char *error, size_t maxlength);
	//virtual bool SDK_OnMetamodPauseChange(bool paused, char *error, size_t maxlength);
#endif
};

extern IBinTools *g_pBinTools;
extern IGameConfig *g_pGameConf;
extern IServerGameEnts *gameents;
extern IServerTools *servertools;
extern ISDKTools *g_pSDKTools;

#endif // _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_
