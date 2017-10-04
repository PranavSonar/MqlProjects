#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include "SystemWrapper.mqh"

static SystemWrapper systemWrapper;

int OnInit(void)
{
	//ChartIndicatorDelete(ChartID(), ChartWindowFind(), "SystemConsole");
	//ChartIndicatorAdd(ChartID(), ChartWindowFind(), 0 /* handle for "SystemConsole" */); // works only in MT5, damn it
	return systemWrapper.OnInitWrapper();
}

void OnDeinit(const int reason)
{
	systemWrapper.OnDeinitWrapper(reason);
	//ChartIndicatorDelete(ChartID(), ChartWindowFind(), "SystemConsole");
}


void OnTimer()
{
	systemWrapper.OnTimerWrapper();
}

void OnTick()
{
	systemWrapper.OnTickWrapper();
}
