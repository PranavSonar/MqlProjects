//+------------------------------------------------------------------+
//|                                                 SimpleTestBB.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int OnInit()
{
	EventSetTimer(4);	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	EventKillTimer();
}

void OnTick() {}

void OnTimer() {}