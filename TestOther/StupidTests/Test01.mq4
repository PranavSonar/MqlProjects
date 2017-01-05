//+------------------------------------------------------------------+
//|                                               YetAnotherTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Global.mqh>

int OnStart()
{
	ResetLastError();
	if(FirstSymbol == NULL)
	{
		GlobalContext.DatabaseLog.Initialize(true);
		GlobalContext.DatabaseLog.ParametersSet(__FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	}
	Print("Symbol:" + _Symbol + " IsTradeAllowed:" + BoolToString(GlobalContext.Library.IsTradeAllowedOnSymbol()));
	
	GlobalContext.Config.Initialize(true, true, false, true);
	
	if(!GlobalContext.Config.ChangeSymbol())
	{
		GlobalContext.DatabaseLog.ParametersSet(__FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	}
	
	return(INIT_SUCCEEDED);
}

