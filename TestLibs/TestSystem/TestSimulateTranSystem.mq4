//+------------------------------------------------------------------+
//|                                       TestSimulateTranSystem.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\System\SimulateTranSystem.mqh>

static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	ResetLastError();
	if(FirstSymbol == NULL)
	{
		GlobalContext.DatabaseLog.Initialize(true);
		GlobalContext.DatabaseLog.NewTradingSession(__FILE__);
	}
	
	system.SetupTransactionSystem(_Symbol);
	system.TestTransactionSystemForCurrentSymbol();
	
	GlobalContext.Config.Initialize(true, true, false, true);
	GlobalContext.Config.ChangeSymbol();
	
	GlobalContext.DatabaseLog.EndTradingSession(__FILE__);
	
	return(INIT_SUCCEEDED);
}
