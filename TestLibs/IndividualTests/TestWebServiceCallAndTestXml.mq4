//+------------------------------------------------------------------+
//|                                           TestWebServiceCall.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Log\OnlineWebServiceLog.mqh>

int OnInit()
{
	OnlineWebServiceLog wsLog(true);
	
	wsLog.ReadLastDataLogAndDetail("TestSimulateTranSystem.mq4");
	SafePrintString(wsLog.GetResult());
	
	wsLog.ReadLastDataLogDetail("TestSimulateTranSystem.mq4");
	SafePrintString(wsLog.GetResult());
	
	wsLog.ReadLastDataLog("TestSimulateTranSystem.mq4");
	SafePrintString(wsLog.GetResult());
	
	wsLog.ReadLastProcedureLog("TestSimulateTranSystem.mq4");
	SafePrintString(wsLog.GetResult());
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
