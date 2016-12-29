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

static SimulateTranSystem system(DECISION_TYPE_2BB, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	ResetLastError();
	if(FirstSymbol == NULL)
	{
		GlobalContext.DatabaseLog.Initialize(true);
		ResizeAndSet(parameters, __FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession", parameters);

		GlobalContext.Config.Initialize(true, true, false, true);
		GlobalContext.Config.AllowTrades();

		// Setup system only at the beginning:
		system.SetupTransactionSystem(_Symbol);

		// Add manual config only at the beginning:
		system.AddChartTransactionData("AUDCHF", PERIOD_H1, 0/*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("AUDCAD", PERIOD_H1, 0/*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("AUDJPY", PERIOD_H1, 0/*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("USDBRL", PERIOD_M15, 0/*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("USDINR", PERIOD_M15, 0/*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("USDCNY", PERIOD_M15, 0/*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
	}
	
	system.RunTransactionSystemForCurrentSymbol(); // run EA
	
	if(!GlobalContext.Config.ChangeSymbol())
	{
		ResizeAndSet(parameters, __FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession", parameters);
	}
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Print("ErrorDescription(reason): " + ErrorDescription(reason) +
   	" reason: " + IntegerToString(reason) +
   	" ErrorDescription(_LastError): " + ErrorDescription(_LastError) + 
   	" _LastError: " + IntegerToString(_LastError));
}
