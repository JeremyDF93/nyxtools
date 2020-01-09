#ifndef _INCLUDE_NYXTOOLS_REGNATIVES_H_
#define _INCLUDE_NYXTOOLS_REGNATIVES_H_

#include <am-vector.h>

class RegNatives
{
public:
  void Register(ICallWrapper *pWrapper);
  void UnregisterAll();
private:
  ke::Vector<ICallWrapper *> m_Natives;
};

extern RegNatives g_RegNatives;

#endif //_INCLUDE_NYXTOOLS_REGNATIVES_H_
