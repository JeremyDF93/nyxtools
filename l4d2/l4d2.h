#ifndef _INCLUDE_NYXTOOLS_L4D2_H_
#define _INCLUDE_NYXTOOLS_L4D2_H_

#include "extension.h"

class L4D2Tools : public IPluginsListener
{
public:
	L4D2Tools();
public:
	virtual bool SDK_OnLoad(char *error, size_t maxlength, bool late);
	virtual void SDK_OnUnload();
	virtual void SDK_OnAllLoaded();
	//virtual void SDK_OnPauseChange(bool paused);
	//virtual bool QueryRunning(char *error, size_t maxlength);
	//virtual void OnCoreMapStart(edict_t *pEdictList, int edictCount, int clientMax);
public: //IPluginsListener
	virtual void OnPluginLoaded(IPlugin *plugin);
	virtual void OnPluginUnloaded(IPlugin *plugin);
public:
#if defined SMEXT_CONF_METAMOD
	//virtual bool SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlength, bool late);
	//virtual bool SDK_OnMetamodUnload(char *error, size_t maxlength);
	//virtual bool SDK_OnMetamodPauseChange(bool paused, char *error, size_t maxlength);
#endif
private:
	bool m_bDetoursEnabled;
};

extern L4D2Tools g_L4D2Tools;

extern void *g_pZombieManager;

#endif // _INCLUDE_NYXTOOLS_L4D2_H_
