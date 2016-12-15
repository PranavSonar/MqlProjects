//+------------------------------------------------------------------+
//|                                       TestSimulateTranSystem.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property strict

#include <MyMql\System\SimulateTranSystem.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>

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
	
	if(!GlobalContext.Config.ChangeSymbol())
		GlobalContext.DatabaseLog.EndTradingSession(__FILE__);
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Print("ErrorDescription(reason): " + ErrorDescription(reason) + " reason: " + IntegerToString(reason) + " ErrorDescription(_LastError): " + ErrorDescription(_LastError) + " _LastError: " + IntegerToString(_LastError));
}