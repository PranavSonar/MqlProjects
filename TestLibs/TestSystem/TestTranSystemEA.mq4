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

extern bool UseKeyBoardChangeChart = false;
extern bool UseIndicatorChangeChart = true;
extern bool UseOnlyFirstDecisionAndConfirmItWithOtherDecisions = false;

static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);
bool chartIsChanging;

int OnInit()
{
	if(!GlobalContext.ChartIsChanging)
		GlobalContext.InitRefresh();
	
	if(FirstSymbol == NULL)
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
		int orderNo = 1;
		
		while(!isTransactionAllowedOnChartTransactionData)
		{
			GlobalContext.DatabaseLog.ParametersSet(IntegerToString(orderNo)); // OrderNo
			GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadResult");
			
			element.Clear();
			element.ParseXml(GlobalContext.DatabaseLog.Result);
			
			if((element.GetTagType() == TagType_InvalidTag) ||
			(element.GetTagType() == TagType_CleanTag))
				break;
			
			if(element.GetChildByElementName("USP_ReadResult_Result") == NULL)//GlobalContext.DatabaseLog.Result == "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<string xmlns=\"http://tempuri.org/\" />")
			{
				Print("MaxOrderNo" + IntegerToString(orderNo));
				break;
			}
			
			string symbol = element.GetChildTagDataByParentElementName("Symbol");
			int maxOrderNo = (int) StringToInteger(element.GetChildTagDataByParentElementName("MaxOrderNo"));
			BaseLotManagement lots;
	      if(lots.IsMarginOk(symbol, MarketInfo(_Symbol, MODE_MINLOT), 0.4f, true) && GlobalContext.Config.IsTradeAllowedOnEA(symbol))
			{
				system.CleanTranData();
				system.AddChartTransactionData(element);
				system.InitializeFromFirstChartTranData();
				system.SetupTransactionSystem();
				CurrentSymbol = symbol;
				
				if(CurrentSymbol != _Symbol)
				{
					Print(__FUNCTION__ + " Symbol should change from " + _Symbol + " to " + CurrentSymbol);
					
					if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
						GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
					else
						GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
					
					GlobalContext.ChartIsChanging = true;
				}
				return 0;
			}
			
			orderNo++;
			if((orderNo > maxOrderNo) && (maxOrderNo != 0))
				break;
		}
		delete element;
	}
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);
	system.RunTransactionSystemForCurrentSymbol(true);
	
	ChartRedraw();
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	if(GlobalContext.Config.IsNewBar())
		RefreshRates();
	if(GlobalContext.ChartIsChanging)
		return;
	
	// run EA (maybe it can trade even on symbols which are not current, which means refactor & fix)
	
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);
	system.RunTransactionSystemForCurrentSymbol(true); // run EA
	
	Print("After tick calc.");
	
	
//	ChartTransactionData chartTranData = system.CurrentPositionTransactionData();
//	ChartTransactionData nextChartTranData = system.NextPositionTransactionData();
//	if((chartTranData != nextChartTranData) && (!StringIsNullOrEmpty(chartTranData.TranSymbol)))
//	{
//		CurrentSymbol = nextChartTranData.TranSymbol;
//		Print(__FUNCTION__ + " Symbol should change from " + _Symbol + " to " + CurrentSymbol);
//		
//		if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
//			GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
//		else
//			GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
//		
//		GlobalContext.ChartIsChanging = true;
//	}
}

void OnDeinit(const int reason)
{
	if(!GlobalContext.ChartIsChanging)
	{
		GlobalContext.DatabaseLog.ParametersSet(__FILE__);
		GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
		GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
		
		system.PrintDeInitReason(reason);
		system.CleanTranData();
		system.RemoveUnusedDecisionsTransactionsAndLots();
	}
}
