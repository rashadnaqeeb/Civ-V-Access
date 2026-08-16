/*	-------------------------------------------------------------------------------------------------------
	Civ V Access overlay. See CivVAccessEventQueue.h for why the hot hooks are
	deferred instead of calling Lua from the game-core thread.
	------------------------------------------------------------------------------------------------------- */
#include "CvGameCoreDLLPCH.h"
#include "CivVAccessEventQueue.h"

namespace
{
// One turn of a large multiplayer game produces a few thousand reveal and move
// events. The UI thread drains every frame, so the queue only has to absorb one
// frame's worth of simulation; this is sized well past that so an overflow means
// something genuinely unusual (a whole-map reveal from a map trade) rather than
// normal play.
const int CAPACITY = 16384;

class Queue
{
public:
	Queue() : m_iHead(0), m_iCount(0), m_bOverflowed(false)
	{
		// Runs during DLL static init, before any game thread exists.
		InitializeCriticalSection(&m_cs);
	}

	~Queue()
	{
		DeleteCriticalSection(&m_cs);
	}

	void Push(const char* szName, int iArgc, const int* paiArgs)
	{
		if(iArgc < 0 || iArgc > CivVAccessEventQueue::MAX_ARGS)
			return;

		EnterCriticalSection(&m_cs);
		if(m_iCount >= CAPACITY)
		{
			// Drop the newest rather than evicting the oldest: the consumers
			// replay history in order, and a hole at the front is worse for
			// them than a hole at the back.
			m_bOverflowed = true;
		}
		else
		{
			const int iSlot = (m_iHead + m_iCount) % CAPACITY;
			CivVAccessEventQueue::Event& kEvent = m_aEvents[iSlot];
			kEvent.szName = szName;
			kEvent.iArgc = iArgc;
			for(int i = 0; i < iArgc; ++i)
				kEvent.aiArgs[i] = paiArgs[i];
			++m_iCount;
		}
		LeaveCriticalSection(&m_cs);
	}

	int Drain(CivVAccessEventQueue::Event* paEvents, int iMax)
	{
		int iWritten = 0;
		EnterCriticalSection(&m_cs);
		while(iWritten < iMax && m_iCount > 0)
		{
			paEvents[iWritten++] = m_aEvents[m_iHead];
			m_iHead = (m_iHead + 1) % CAPACITY;
			--m_iCount;
		}
		LeaveCriticalSection(&m_cs);
		return iWritten;
	}

	bool TakeOverflowed()
	{
		EnterCriticalSection(&m_cs);
		const bool bWas = m_bOverflowed;
		m_bOverflowed = false;
		LeaveCriticalSection(&m_cs);
		return bWas;
	}

private:
	CRITICAL_SECTION m_cs;
	CivVAccessEventQueue::Event m_aEvents[CAPACITY];
	int m_iHead;
	int m_iCount;
	bool m_bOverflowed;
};

Queue g_kQueue;
}

void CivVAccessEventQueue::Push(const char* szName, int iArgc, const int* paiArgs)
{
	g_kQueue.Push(szName, iArgc, paiArgs);
}

int CivVAccessEventQueue::Drain(CivVAccessEventQueue::Event* paEvents, int iMax)
{
	return g_kQueue.Drain(paEvents, iMax);
}

bool CivVAccessEventQueue::TakeOverflowed()
{
	return g_kQueue.TakeOverflowed();
}
