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
	GlobalContext.DatabaseLog.Initialize(true);
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
		
	GlobalContext.Config.Initialize(true, true, false, false, __FILE__);
	GlobalContext.Config.AllowTrades();
		
	// Setup system only at the beginning:
		
	// Add manual config only at the beginning:
	//system.AddChartTransactionData("ETCETH", PERIOD_H1, typename(DecisionDoubleBB), typename(LotManagement), typename(BaseTransactionManagement), true);
	//system.AddChartTransactionData("BTCUSD", PERIOD_H1, typename(DecisionDoubleBB), typename(LotManagement), typename(BaseTransactionManagement), false);
		
		
	// Or auto add using WebService
	XmlElement *element = new XmlElement();
		
	bool isTransactionAllowedOnChartTransactionData = false;
	if(!isTransactionAllowedOnChartTransactionData)
		Print("Transactions are not allowed");
	GlobalContext.DatabaseLog.ParametersSet(_Symbol);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadResultFromSymbol");
	
	element.Clear();
	element.ParseXml(GlobalContext.DatabaseLog.Result);
			
	if((element.GetTagType() == TagType_InvalidTag) ||
	(element.GetTagType() == TagType_CleanTag))
		Print(__FILE__ + " Invalid tag type after parsing!");
			
	if(element.GetChildByElementName("USP_ReadResultFromSymbol_Result") == NULL)//GlobalContext.DatabaseLog.Result == "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<string xmlns=\"http://tempuri.org/\" />")
		Print(__FILE__ + " invalid response received");
	BaseLotManagement lots;
	double minLots = MarketInfo(symbol, MODE_MINLOT);
			
	bool isMarginOk = lots.IsMarginOk(symbol, minLots);
	if(isMarginOk)
	{
		system.CleanTranData();
		system.AddChartTransactionData(element);
		system.InitializeFromFirstChartTranData();
		system.SetupTransactionSystem(_Symbol);
		system.RunTransactionSystemForCurrentSymbol();
		//if((system.chartTranData[0].LastDecisionBarShift < 3) && (system.chartTranData[0].LastDecisionBarShift != -1))
	}
	else
		Print(__FUNCTION__ + " margin is not ok for symbol " + _Symbol);
	delete element;
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	
	bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
	if(!isTradeAllowedOnEA)
		Print(__FUNCTION__ + " trade is not allowed on EA.");
	
	ChartRedraw();
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	// run EA (maybe it can trade even on symbols which are not current, which means refactor & fix)
	system.RunTransactionSystemForCurrentSymbol(); // run EA
	
	Print("After tick calc.");
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	system.PrintDeInitReason(reason);
	system.CleanTranData();
	system.RemoveUnusedDecisionsTransactionsAndLots();
}
