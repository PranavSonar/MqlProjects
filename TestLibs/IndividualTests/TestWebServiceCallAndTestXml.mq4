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
	string parameters[];
	OnlineWebServiceLog wsLog(true);
	
	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastDataLogAndDetail", parameters);
	SafePrintString(wsLog.GetResult());
	
	
	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastDataLogDetail", parameters);
	SafePrintString(wsLog.GetResult());
	
	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastDataLog", parameters);
	SafePrintString(wsLog.GetResult());
	
	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("ReadLastProcedureLog", parameters);
	SafePrintString(wsLog.GetResult());
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
