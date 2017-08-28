//+------------------------------------------------------------------+
//|                                    TestTranSystemEAOneSymbol.mq4 |
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

extern bool UseOnlyFirstDecisionAndConfirmItWithOtherDecisions = false;
static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	GlobalContext.DatabaseLog.Initialize(true);
	GlobalContext.Config.Initialize(true, true, false, false, __FILE__);
	GlobalContext.Config.AllowTrades();
		
	bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
	if(!isTradeAllowedOnEA)
	{
		Print(__FUNCTION__ + " Trade is not allowed on EA for symbol " + _Symbol);
		return (INIT_FAILED);
	}
	
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	
	// Setup system only at the beginning:
		
	// Add manual config only at the beginning:
	//system.AddChartTransactionData("ETCETH", PERIOD_H1, typename(DecisionDoubleBB), typename(LotManagement), typename(BaseTransactionManagement), true);
	//system.AddChartTransactionData("BTCUSD", PERIOD_H1, typename(DecisionDoubleBB), typename(LotManagement), typename(BaseTransactionManagement), false);
		
		
	// Or auto add using WebService
	XmlElement *element = new XmlElement();
	
	GlobalContext.DatabaseLog.ParametersSet(_Symbol);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadResultFromSymbol");
	
	element.Clear();
	element.ParseXml(GlobalContext.DatabaseLog.Result);
			
	if((element.GetTagType() == TagType_InvalidTag) ||
	(element.GetTagType() == TagType_CleanTag))
	{
		Print(__FUNCTION__ + " Invalid tag type after parsing response! (tag type clean or invalid)");
		delete element;
		return (INIT_FAILED);
	}
			
	if(element.GetChildByElementName("USP_ReadResultFromSymbol_Result") == NULL)//GlobalContext.DatabaseLog.Result == "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<string xmlns=\"http://tempuri.org/\" />")
	{
		Print(__FUNCTION__ + " invalid response received (no USP_ReadResultFromSymbol_Result child element)");
		delete element;
		return (INIT_FAILED);
	}
	
	BaseLotManagement lots;
	if(lots.IsMarginOk(_Symbol, MarketInfo(_Symbol, MODE_MINLOT), 0.4f, true))
	{
		system.CleanTranData();
		system.AddChartTransactionData(element);
		system.InitializeFromFirstChartTranData(true);
		system.PrintFirstChartTranData();
		system.SetupTransactionSystem();
		
   	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);
		system.RunTransactionSystemForCurrentSymbol(true);
		//if((system.chartTranData[0].LastDecisionBarShift < 3) && (system.chartTranData[0].LastDecisionBarShift != -1))
	}
	else
	{
		Print(__FUNCTION__ + " margin is not ok for symbol " + _Symbol);
		delete element;
		return (INIT_FAILED);
	}
	delete element;
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	
	ChartRedraw();
	return(INIT_SUCCEEDED);
}

void OnStart()
{
}

void OnTick()
{
	// Run Expert Advisor
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);
	system.RunTransactionSystemForCurrentSymbol(true);
	
	//Print("After tick calc.");
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	
	system.PrintDeInitReason(reason);
	system.FreeArrays();
	system.RemoveUnusedDecisionsTransactionsAndLots();
}
