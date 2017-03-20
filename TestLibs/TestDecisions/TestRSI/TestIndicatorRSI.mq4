//+------------------------------------------------------------------+
//|                                                TestIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrDeepSkyBlue
#property indicator_color3 clrDarkBlue
#property indicator_color4 clrDarkBlue
#property indicator_color5 clrMidnightBlue
#property indicator_color6 clrMidnightBlue

#include <MyMql/DecisionMaking/DecisionRSI.mqh>
#include <MyMql/UnOwnedTransactionManagement/FlowWithTrendTranMan.mqh>
#include <Files/FileTxt.mqh>
#include <MyMql/Global/Global.mqh>


double Buf_CloseH1[], Buf_MedianH1[],
	Buf_CloseD1[], Buf_MedianD1[],
	Buf_CloseW1[], Buf_MedianW1[];
double Buf_Decision[];

//+------------------------------------------------------------------+
//| Indicator initialization function (used for testing)             |
//+------------------------------------------------------------------+
int OnInit()
{
	// print some verbose info
	//VerboseInfo vi;
	//vi.BalanceAccountInfo();
	//vi.ClientAndTerminalInfo();
	//vi.PrintMarketInfo();
	
	
	SetIndexBuffer(0, Buf_CloseH1);
	SetIndexStyle(0, DRAW_SECTION, STYLE_SOLID, 1);
	
	SetIndexBuffer(1, Buf_MedianH1);
	SetIndexStyle(1, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(2, Buf_CloseD1);
	SetIndexStyle(2, DRAW_SECTION, STYLE_SOLID, 1);
	
	SetIndexBuffer(3, Buf_MedianD1);
	SetIndexStyle(3, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(4, Buf_CloseW1);
	SetIndexStyle(4, DRAW_SECTION, STYLE_SOLID, 1);
	
	SetIndexBuffer(5, Buf_MedianW1);
	SetIndexStyle(5, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(6, Buf_Decision);
	SetIndexStyle(6, DRAW_SECTION, STYLE_SOLID, 0, clrNONE);
	
	//if(logToFile)
	//	logFile.Open("LogFile.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_REWRITE);
	
	GlobalContext.DatabaseLog.Initialize(false,false,false,"RSI.txt");
	
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	
	return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
//	if(logToFile)
//		logFile.Close();
	transaction.LogAllOrders();
	
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
}

//bool logToFile = false;
//static CFileTxt logFile;

static FlowWithTrendTranMan transaction;

int start()
{
	_SW
	
	DecisionRSI decision(1,0);
	
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0, spread = MarketInfo(_Symbol,MODE_ASK) - MarketInfo(_Symbol,MODE_BID), spreadPips = spread/Pip();
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	transaction.SetSimulatedOrderObjectName("SimulatedOrderRSI");
	transaction.SetSimulatedTransactionWholeName("SimulatedTransactionWholeRSI");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLossRSI");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfitRSI");
	
	transaction.AutoAddTransactionData(spreadPips);
	
	while(i >= 0)
	{
		GlobalContext.Screen.PrintCurrentValue(i, NULL, "TimeIndex", clrNONE, 20, 20, 1);
		
		unsigned long type;
		double d = decision.GetDecision(i, type);
		decision.SetIndicatorData(Buf_CloseH1, Buf_MedianH1, Buf_CloseD1, Buf_MedianD1, Buf_CloseW1, Buf_MedianW1, i);
		Buf_Decision[i] = d;
		
		// calculate profit/loss, TPs, SLs, etc
		transaction.CalculateData(i);
		
		if(d > 0.0) { // Buy
			double price = Close[i] + spread; // Ask
			GlobalContext.Limit.CalculateTP_SL(TP, SL, 8*spreadPips, 13*spreadPips, OP_BUY, price, _Symbol, spread);
			GlobalContext.Limit.ValidateAndFixTPandSL(TP, SL, price, OP_BUY, spread, false);
			
			transaction.SimulateOrderSend(_Symbol, OP_BUY, 0.01, price, 0, SL, TP, NULL, 0, 0, clrNONE, i);
			
			//GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), "NewOrder", "New order buy " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			//GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLogDetail");
			//GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), "OrdersToString", transaction.OrdersToString(true));
			//GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLogDetail");
			
			//if(logToFile) {
			//	logFile.WriteString("[" + IntegerToString(i) + "] New order buy " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			//	logFile.WriteString(transaction.OrdersToString(true));
			//}
			
		} else if(d < 0.0) { // Sell
			double price = Close[i]; // Bid
			GlobalContext.Limit.CalculateTP_SL(TP, SL, 8*spreadPips, 13*spreadPips, OP_SELL, price, _Symbol, spread);
			GlobalContext.Limit.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, false);
			transaction.SimulateOrderSend(_Symbol, OP_SELL, 0.01, price, 0, SL, TP, NULL, 0, 0, clrNONE, i);
			
			//GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), "NewOrder", "New order sell " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			//GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLogDetail");
			//GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), "OrdersToString", transaction.OrdersToString(true));
			//GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLogDetail");
			
			//if(logToFile) {
			//	logFile.WriteString("[" + IntegerToString(i) + "] New order sell " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			//	logFile.WriteString(transaction.OrdersToString(true));
			//}
		}
		
		//transaction.FlowWithTrend_UpdateSL_TP_UsingConstants(8*spreadPips, 13*spreadPips);
		i--;
	}
	
	//if(logToFile)
	//	logFile.Flush();
	
	GlobalContext.Screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(-1)),clrGray, 20, 0);
	GlobalContext.Screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
	GlobalContext.Screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
	
	double profit, inverseProfit;
	int count, countNegative, countPositive, countInverseNegative, countInversePositive, irregularLimitsType;
	bool irregularLimits, isInverseDecision;
	transaction.GetBestTPandSL(TP, SL, profit, inverseProfit, count, countNegative, countPositive, countInverseNegative, countInversePositive, isInverseDecision, irregularLimits, irregularLimitsType);
	string summary = "Best profit: " + DoubleToString(profit,2) + " [IsInverseDecision: " + BoolToString(isInverseDecision) + "]"
		+ "\nBest Take profit: " + DoubleToString(TP,4) + " (spreadPips * " + DoubleToString(TP/spreadPips,2) + ")" 
		+ "\nBest Stop loss: " + DoubleToString(SL,4) + " (spreadPips * " + DoubleToString(SL/spreadPips,2) + ")"
		+ "\nIrregular Limits: " + BoolToString(irregularLimits) + " Type: " + IntegerToString(irregularLimitsType)
		+ "\nCount orders: " + IntegerToString(count) + " (" + IntegerToString(countPositive) + " positive orders & " + IntegerToString(countNegative) + " negative orders); Procentual profit: " + DoubleToString((double)countPositive*100/(count>0?(double)count:100),3) + "%"
		+ "\nCount inverse orders: " + IntegerToString(count) + " (" + IntegerToString(countInversePositive) + " inverse positive orders & " + IntegerToString(countInverseNegative) + " inverse negative orders); Procentual profit: " + DoubleToString((double)countInversePositive*100/(count>0?(double)count:100),3) + "%"
		//+ "\n\nMaximum profit (sum): " + DoubleToString(transaction.GetTotalMaximumProfitFromOrders(),2)
		//+ "\nMinimum profit (sum): " + DoubleToString(transaction.GetTotalMinimumProfitFromOrders(),2)
		//+ "\nMedium profit (avg): " + DoubleToString(transaction.GetTotalMediumProfitFromOrders(),2)
		+ "\n\nSpread: " + DoubleToString(spreadPips, 4)
		+ "\nTake profit / Spread (best from average): " + DoubleToString(TP/spreadPips,4)
		+ "\nStop loss / Spread (best from average): " + DoubleToString(SL/spreadPips,4);
	
	GlobalContext.DatabaseLog.ParametersSet(__FILE__, decision.GetDecisionName() + " on " + _Symbol, summary);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLog");
	Comment(summary);
	
	
	_EW
	return 0;
}
