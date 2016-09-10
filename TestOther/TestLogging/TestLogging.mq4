//+------------------------------------------------------------------+
//|                                                  TestLogging.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Base\BeforeObject.mqh>
#include <MyMql\Log\WebServiceLog.mqh>

void OnStart()
{
	WebServiceLog wslog(true);
	
	wslog.NewTradingSession();
	
	wslog.StartProcedureLog("name2", "parameasdasdters234234 ");
	SafePrintString(wslog.Result);
	wslog.EndProcedureLog("name2");
	SafePrintString(wslog.Result);
	wslog.StartProcedureLog("as234 2 43d", "p234 arameas 2345 2345 2345dasdters2342345 2345234 ");
	SafePrintString(wslog.Result);
	wslog.EndProcedureLog("as234 2 43d");
	SafePrintString(wslog.Result);
	wslog.StartProcedureLog("234asdftest test", "parameasd21 5234 5234 52345 asdters234234 ");
	SafePrintString(wslog.Result);
	wslog.EndProcedureLog("234asdftest test");
	SafePrintString(wslog.Result);
	wslog.DataLog("234asdftest test", "w345cw34");
	SafePrintString(wslog.Result);
	wslog.DataLog(" 23 test", "24 57 w345cw34");
	SafePrintString(wslog.Result);
	wslog.EndTradingSession();
	SafePrintString(wslog.Result);
	
}
