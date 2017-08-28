//+------------------------------------------------------------------+
//|                              TestTranSystemEAOneSymbolManual.mq4 |
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

//#property indicator_chart_window

static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	// Refresh
	ResetLastError();
	RefreshRates();
	
	// Early inits
	GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
	GlobalContext.DatabaseLog.Initialize(true);
	
	// NewTradingSession
	GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
	GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	
	// Setup & simulation run
	system.SetupTransactionSystem();
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", false);
	system.TestTransactionSystemForCurrentSymbol(true, false);

	// EndTradingSession
	GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	Print("Simulation finished! Job done!");
	ExpertRemove();
	
	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	system.PrintDeInitReason(reason);
	system.FreeArrays(); // system.Clean();
	system.CleanTranData();
	system.RemoveUnusedDecisionsTransactionsAndLots();
}
