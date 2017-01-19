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
		GlobalContext.DatabaseLog.ParametersSet(__FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");

		GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
		GlobalContext.Config.AllowTrades();

		// Setup system only at the beginning:
		system.SetupTransactionSystem(_Symbol);

		// Add manual config only at the beginning:
		system.AddChartTransactionData("AUDCHF", PERIOD_H1, 0 /*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("AUDCAD", PERIOD_H1, 0 /*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("AUDJPY", PERIOD_H1, 0 /*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("USDBRL", PERIOD_M15, 0 /*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("USDINR", PERIOD_M15, 0 /*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
		system.AddChartTransactionData("USDCNY", PERIOD_M15, 0 /*because 2BB only*/, 0 /*lotIndex*/, 0 /*transactionIndex*/, true);
	}
	
	// not changing symbols for now	
//	if(!GlobalContext.Config.ChangeSymbol())
//	{
//		GlobalContext.DatabaseLog.ParametersSet(__FILE__);
//		GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
//	}
	
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	// run EA (maybe it can trade even on symbols which are not current, which means refactor & fix)
	system.RunTransactionSystemForCurrentSymbol(); // run EA
}

void OnDeinit(const int reason)
{
	system.PrintDeInitReason(reason);
}
