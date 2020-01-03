#include "extension.h"
#include "RegNatives.h"

RegNatives g_RegNatives;

void RegNatives::Register(ICallWrapper *pWrapper)
{
	m_Natives.append(pWrapper);
}

void RegNatives::UnregisterAll()
{
	for (size_t iter = 0; iter < m_Natives.length(); ++iter)
	{
		m_Natives[iter]->Destroy();
	}

	m_Natives.clear();
}
