//+------------------------------------------------------------------+
//|                                                TestIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

#property indicator_chart_window

#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Gray
#property indicator_color4 Red
#property indicator_color5 Blue

#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>
#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <Files/FileTxt.mqh>
#include <MyMql/Global/Global.mqh>


double Buf_BBs2[], Buf_BBs1[], Buf_BBm[], Buf_BBd1[], Buf_BBd2[];
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
	
	
	SetIndexBuffer(0, Buf_BBs2);
	SetIndexStyle(0, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(1, Buf_BBs1);
	SetIndexStyle(1, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(2, Buf_BBm);
	SetIndexStyle(2, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(3, Buf_BBd1);
	SetIndexStyle(3, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(4, Buf_BBd2);
	SetIndexStyle(4, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(5, Buf_Decision);
	SetIndexStyle(5, DRAW_SECTION, STYLE_SOLID, 0, clrNONE);
	
	//if(logToFile)
	//	logFile.Open("LogFile.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_REWRITE);
	
	return INIT_SUCCEEDED;
}

//void OnDeinit(const int reason)
//{
//	if(logToFile)
//		logFile.Close();
//}

//bool logToFile = false;
//static CFileTxt logFile;
static FlowWithTrendTranMan transaction;

int start()
{
   _SW
   
	GlobalContext.DatabaseLog.Initialize(false,false,false,"2BB.txt");
	DecisionDoubleBB decision;
	ScreenInfo screen;
//	bool openFile = true;
	
//	if(logToFile && openFile) {
//		logFile.Open("LogFile.txt", FILE_READ | FILE_WRITE | FILE_ANSI);
//		logFile.Seek(0, SEEK_END);
//		openFile = false;
//	}
	
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/GlobalContext.Money.Pip();
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	transaction.SetSimulatedOrderObjectName("SimulatedOrderBA");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLossBA");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfitBA");
	
	transaction.AutoAddTransactionData(spreadPips);
	
	while(i >= 0)
	{
		double d = decision.GetDecision(SL, TP, 1.0, i);
		decision.SetIndicatorData(Buf_BBs2, Buf_BBs1, Buf_BBm, Buf_BBd1, Buf_BBd2, i);
		Buf_Decision[i] = d;
		
		// calculate profit/loss, TPs, SLs, etc
		transaction.CalculateData(i);
		
		//if(logToFile)
		//	logFile.WriteString(transaction.OrdersToString(true));
		
		if(d > 0.0) { // Buy
			double price = Close[i] + spread; // Ask
			GlobalContext.Money.CalculateTP_SL(TP, SL, OP_BUY, price, false, spread, 3*spread, spread);
			GlobalContext.Limit.ValidateAndFixTPandSL(TP, SL, price, OP_BUY, spread, false);
			
			transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, price, 0, SL ,TP, NULL, 0, 0, clrNONE, i);
			
//				if(logToFile) {
//					logFile.WriteString("[" + IntegerToString(i) + "] New order buy " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
//					logFile.WriteString(transaction.OrdersToString(true));
//				}
			
		} else if(d < 0.0) { // Sell
			double price = Close[i]; // Bid
			GlobalContext.Money.CalculateTP_SL(TP, SL, OP_SELL, price, false, spread, 3*spread, spread);
			GlobalContext.Limit.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, false);
			transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, price, 0, SL, TP, NULL, 0, 0, clrNONE, i);
			
			//if(logToFile) {
			//	logFile.WriteString("[" + IntegerToString(i) + "] New order sell " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			//	logFile.WriteString(transaction.OrdersToString(true));
			//}
		}
		
		//transaction.FlowWithTrend_UpdateSL_TP_UsingConstants(2.6*spreadPips, 1.6*spreadPips);
		i--;
	}
	
	//if(logToFile)
	//	logFile.Flush();
	
	screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders()),clrGray, 20, 0);
	screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
	screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
	
	double profit;
	int count, countNegative, countPositive;
	transaction.GetBestTPandSL(TP, SL, profit, count, countNegative, countPositive);
	string summary = "Best profit: " + DoubleToString(profit,2)
		+ "\nBest Take profit: " + DoubleToString(TP,4) + " (spreadPips * " + DoubleToString(TP/spreadPips,2) + ")" 
		+ "\nBest Stop loss: " + DoubleToString(SL,4) + " (spreadPips * " + DoubleToString(SL/spreadPips,2) + ")"
		+ "\nCount orders: " + IntegerToString(count) + " (" + IntegerToString(countPositive) + " positive orders & " + IntegerToString(countNegative) + " negative orders); Procentual profit: " + DoubleToString((double)countPositive/(count>0?(double)count:1))
		+ "\n\nMaximum profit (sum): " + DoubleToString(transaction.GetTotalMaximumProfitFromOrders(),2)
		+ "\nMinimum profit (sum): " + DoubleToString(transaction.GetTotalMinimumProfitFromOrders(),2)
		+ "\nMedium profit (avg): " + DoubleToString(transaction.GetTotalMediumProfitFromOrders(),2)
		+ "\n\nSpread: " + DoubleToString(spreadPips, 4)
		+ "\nTake profit / Spread (best from average): " + DoubleToString(TP/spreadPips,4)
		+ "\nStop loss / Spread (best from average): " + DoubleToString(SL/spreadPips,4);
	GlobalContext.DatabaseLog.DataLog("TestIndicator3MA on " + _Symbol, summary);
	Comment(summary);
	
	
	_EW
	return 0;
}
