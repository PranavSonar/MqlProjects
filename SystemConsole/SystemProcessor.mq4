//+------------------------------------------------------------------+
//|                                                SystemConsole.mq4 |
//|                   Copyright 2009-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2009-2014, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict


#include "SystemWrapper.mqh"

static SystemWrapper systemWrapper;

int OnInit(void)
{
	return systemWrapper.OnInitWrapper();
}

void OnDeinit(const int reason)
{
	systemWrapper.OnDeinitWrapper(reason);
}


void OnTimer()
{
	systemWrapper.OnTimerWrapper();
}

void OnTick()
{
	systemWrapper.OnTickWrapper();
}
