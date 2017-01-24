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
	RefreshRates();
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
		//system.AddChartTransactionData("ETCETH", PERIOD_H1, 0, 0, 0, true);
		//system.AddChartTransactionData("BFXUSD", PERIOD_H1, 0, 0, 0, true);
		//system.AddChartTransactionData("USDTRY", PERIOD_H1, 0, 0, 0, false);
		//system.AddChartTransactionData("BTCUSD", PERIOD_H1, 0, 0, 0, false);
		
		// Or auto add using WebService
		GlobalContext.DatabaseLog.ParametersSet("1"); // OrderNo
		GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadResult");
		
		XmlElement *element = new XmlElement();
		element.ParseXml(GlobalContext.DatabaseLog.Result);
		system.AddChartTransactionData(element);
		delete element;
	}
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	
	
	// not changing symbols for now	
	////if(!GlobalContext.Config.ChangeSymbol())
	bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
	bool existsChartTransactionData = system.ExistsChartTransactionData(_Symbol, PERIOD_CURRENT, 0, 0, 0);
	
	if((!isTradeAllowedOnEA) || (!existsChartTransactionData))
	{
		ChartTransactionData nextChartTranData = system.NextPositionTransactionData();
		GlobalContext.Config.ChangeSymbol(nextChartTranData.TranSymbol, nextChartTranData.TimeFrame);
	}
	
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	// Run only on each new bar; even though the system has useOnlyFirstDecisionAndConfirmItWithOtherDecisions = true
	if(!GlobalContext.Config.IsNewBar())
	{
		RefreshRates();
		return;
	}
	
	// run EA (maybe it can trade even on symbols which are not current, which means refactor & fix)
	system.RunTransactionSystemForCurrentSymbol(); // run EA
	
	Print("After tick calc.");
	
	ChartTransactionData chartTranData = system.CurrentPositionTransactionData();
	ChartTransactionData nextChartTranData = system.NextPositionTransactionData();
	
	if(chartTranData != nextChartTranData)
	{
		Print("Symbol should change!");
		GlobalContext.Config.ChangeSymbol(chartTranData.TranSymbol, chartTranData.TimeFrame);
	}
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	
	system.PrintDeInitReason(reason);
}
