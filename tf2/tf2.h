#ifndef _INCLUDE_NYXTOOLS_TF2_H_
#define _INCLUDE_NYXTOOLS_TF2_H_

#include <IGameHelpers.h>
#include <ISDKTools.h>
#include "extension.h"

class TF2Tools : public IPluginsListener
{
public:
  TF2Tools();
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
  //virtual bool SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlength, bool late);
  //virtual bool SDK_OnMetamodUnload(char *error, size_t maxlength);
  //virtual bool SDK_OnMetamodPauseChange(bool paused, char *error, size_t maxlength);
#endif
private:
  bool m_bDetoursEnabled;
};

class variant_t {
public:
  union {
    bool bVal;
    string_t iszVal;
    int iVal;
    float flVal;
    float vecVal[3];
    color32 rgbaVal;
  };

  CBaseHandle eVal;
  fieldtype_t fieldType;
};

struct inputdata_t {
  CBaseEntity *pActivator;		// The entity that initially caused this chain of output events.
  CBaseEntity *pCaller;			// The entity that fired this particular output.
  variant_t value;				// The data parameter for this output.
  int nOutputID;					// The unique ID of the output that was fired.
};

extern TF2Tools g_TF2Tools;

extern void *gamerules;
extern int g_iPlayingMannVsMachineOffs;
extern bool g_bUpgradesEnabled;
extern bool g_bReviveEnabled;

CBaseEntity *FindEntityByClassname(const char *classname);
bool CreateUpgrades();
void DestroyUpgrades();

#endif // _INCLUDE_NYXTOOLS_TF2_H_
