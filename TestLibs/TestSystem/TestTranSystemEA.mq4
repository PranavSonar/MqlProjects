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
		
		GlobalContext.Config.Initialize(true, true, false, false, __FILE__);
		GlobalContext.Config.AllowTrades();
		
		// Setup system only at the beginning:
		system.SetupTransactionSystem(_Symbol);
		
		// Add manual config only at the beginning:
		//system.AddChartTransactionData("ETCETH", IntegerToTimeFrame(_Period), 0, 0, 0, true);
		system.AddChartTransactionData("BTCUSD", IntegerToTimeFrame(_Period), 0, 0, 0, true);
		
		
		//// Or auto add using WebService
		//XmlElement *element = new XmlElement();
		//GlobalContext.DatabaseLog.ParametersSet("1"); // OrderNo
		//GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadResult");
		//element.ParseXml(GlobalContext.DatabaseLog.Result);
		//system.AddChartTransactionData(element);
		//delete element;
	}
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	
	
	// not changing symbols for now	
	////if(!GlobalContext.Config.ChangeSymbol())
	bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
	bool existsChartTransactionData = system.ExistsChartTransactionData(_Symbol, PERIOD_CURRENT, 0, 0, 0);
	
	if((!isTradeAllowedOnEA) || (!existsChartTransactionData))
	{
		Print("Chart symbol should change!");
		ChartTransactionData nextChartTranData = system.NextPositionTransactionData();
		GlobalContext.Config.ChangeSymbol(nextChartTranData.TranSymbol, nextChartTranData.TimeFrame);
	}
	
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	//if(!GlobalContext.Config.IsNewBar())
	//{
	//	RefreshRates();
	//	return;
	//}
	
	// To do: Load last decision by parsing graph once + new order at beginning, if the bars from the last decision & last bar are less than n(=4?)
	
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
	
	Sleep(300);
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	system.PrintDeInitReason(reason);
}
