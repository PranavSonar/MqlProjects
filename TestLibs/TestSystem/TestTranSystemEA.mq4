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
			double minLots = MarketInfo(symbol, MODE_MINLOT);
			
			
			if(lots.IsMarginOk(symbol, minLots))
			{
				system.CleanTranData();
				system.AddChartTransactionData(element);
				system.InitializeFromFirstChartTranData();
				system.SetupTransactionSystem();
				system.RunTransactionSystemForCurrentSymbol();
				//if((system.chartTranData[0].LastDecisionBarShift < 3) && (system.chartTranData[0].LastDecisionBarShift != -1))
					break;
			}
			
			orderNo++;
			if((orderNo > maxOrderNo) && (maxOrderNo != 0))
				break;
			
			//isTransactionAllowedOnChartTransactionData = GlobalContext.Config.IsTradeAllowedOnEA(symbol);	
			//change chart here?
		}
		delete element;
	}
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	
	
	// not changing symbols for now	
	////if(!GlobalContext.Config.ChangeSymbol())
	bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
	bool existsChartTransactionData = system.ExistsChartTransactionData(_Symbol, PERIOD_CURRENT, typename(DecisionDoubleBB), typename(BaseLotManagement), typename(BaseTransactionManagement));
	
	if(((!isTradeAllowedOnEA) || (!existsChartTransactionData)) && (!StringIsNullOrEmpty(system.FirstPositionTransactionData().TranSymbol)))
	{
		Print("Chart symbol should change! From " + _Symbol + " to " + system.FirstPositionTransactionData().TranSymbol);
		ChartTransactionData nextChartTranData = system.FirstPositionTransactionData(); //system.NextPositionTransactionData();
		GlobalContext.Config.ChangeSymbol(nextChartTranData.TranSymbol, PERIOD_CURRENT);
		GlobalContext.ChartIsChanging = true;
	}
	
	ChartRedraw();
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	//// Run only on each new bar; even though the system has useOnlyFirstDecisionAndConfirmItWithOtherDecisions = true
	//if(!GlobalContext.Config.IsNewBar())
	//{
	//	RefreshRates();
	//	return;
	//}
	
	if(GlobalContext.ChartIsChanging)
	{
		Sleep(10);
		return;
	}
	
	// run EA (maybe it can trade even on symbols which are not current, which means refactor & fix)
	system.RunTransactionSystemForCurrentSymbol(); // run EA
	
	Print("After tick calc.");
	
	ChartTransactionData chartTranData = system.CurrentPositionTransactionData();
	ChartTransactionData nextChartTranData = system.NextPositionTransactionData();
	
	if((chartTranData != nextChartTranData) && (!StringIsNullOrEmpty(chartTranData.TranSymbol)))
	{
		Print("Symbol should change!");
		GlobalContext.Config.ChangeSymbol(chartTranData.TranSymbol, PERIOD_CURRENT /*chartTranData.TimeFrame*/);
		GlobalContext.ChartIsChanging = true;
	}
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	
	system.PrintDeInitReason(reason);
	system.CleanTranData();
	system.RemoveUnusedDecisionsTransactionsAndLots();
}
