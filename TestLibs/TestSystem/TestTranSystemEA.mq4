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
	RefreshRates();
	if(FirstSymbol == NULL)
	{
		GlobalContext.DatabaseLog.Initialize(true);
		GlobalContext.DatabaseLog.ParametersSet(__FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");

		GlobalContext.Config.Initialize(true, true, false, true);
		GlobalContext.Config.AllowTrades();

		// Setup system only at the beginning:
		system.SetupTransactionSystem(_Symbol);

		// Add manual config only at the beginning:
		system.AddChartTransactionData("ETCETH", PERIOD_H1, 0, 0, 0, true);
		//system.AddChartTransactionData("BFXUSD", PERIOD_H1, 0, 0, 0, true);
		//system.AddChartTransactionData("USDTRY", PERIOD_H1, 0, 0, 0, false);
		system.AddChartTransactionData("BTCUSD", PERIOD_H1, 0, 0, 0, false);
	}
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	
	
	// not changing symbols for now	
	////if(!GlobalContext.Config.ChangeSymbol())
	bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
	bool existsChartTransactionData = system.ExistsChartTransactionData(_Symbol, PERIOD_CURRENT, 0, 0, 0);
	
	if((!isTradeAllowedOnEA) || (!existsChartTransactionData))
	{
		ChartTransactionData nextChartTranData = system.NextTransactionData();
		GlobalContext.Config.ChangeSymbol(nextChartTranData.TranSymbol, nextChartTranData.TimeFrame);
	}
	
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	if(!GlobalContext.Config.IsNewBar())
		Sleep(100);
	//return;
	
	RefreshRates();
	// run EA (maybe it can trade even on symbols which are not current, which means refactor & fix)
	system.RunTransactionSystemForCurrentSymbol(); // run EA
	
	Print("After tick calc.");
	
	ChartTransactionData chartTranData = system.CurrentTransactionData();
	ChartTransactionData nextChartTranData = system.NextTransactionData();
	
	if(chartTranData != nextChartTranData)
	{
		GlobalContext.Config.ChangeSymbol(chartTranData.TranSymbol, chartTranData.TimeFrame);
		Print("Symbol change!");
		//GlobalContext.DatabaseLog.ParametersSet(__FILE__);
		//GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	}
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	
	system.PrintDeInitReason(reason);
}
