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
		string paramters[];
		ResizeAndSet(paramters,__FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession", paramters);
		
		GlobalContext.Config.Initialize(true, true, false, true);
		
		// Setup system only at the beginning:
		system.SetupTransactionSystem(_Symbol);
	}
	
	system.TestTransactionSystemForCurrentSymbol();
	
	if(!GlobalContext.Config.ChangeSymbol())
	{
		ResizeAndSet(parameters,__FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession", parameters);
	}
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	Print("ErrorDescription(reason=" + IntegerToString(reason) + "): " + UninitDescription(reason) +
		" ErrorDescription(_LastError=" + IntegerToString(_LastError) + "): " + ErrorDescription(_LastError));
}
