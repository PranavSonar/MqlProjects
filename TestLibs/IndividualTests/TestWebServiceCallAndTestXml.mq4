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
	
	GlobalContext.DatabaseLog.ParametersSet("TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastDataLogAndDetail");
	SafePrintString(wsLog.GetResult());
	
	
	GlobalContext.DatabaseLog.ParametersSet("TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastDataLogDetail");
	SafePrintString(wsLog.GetResult());
	
	GlobalContext.DatabaseLog.ParametersSet("TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastDataLog");
	SafePrintString(wsLog.GetResult());
	
	GlobalContext.DatabaseLog.ParametersSet("TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastProcedureLog");
	SafePrintString(wsLog.GetResult());
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
