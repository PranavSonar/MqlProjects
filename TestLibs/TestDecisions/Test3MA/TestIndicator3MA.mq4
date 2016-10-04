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
#property indicator_buffers 13
//#property indicator_color1  clrIndigo
//#property indicator_color2  clrIndigo
//#property indicator_color3  clrIndigo
//#property indicator_color4  clrIndigo
//#property indicator_color5  clrDarkBlue
//#property indicator_color6  clrDarkBlue
//#property indicator_color7  clrDarkBlue
//#property indicator_color8  clrDarkBlue
//#property indicator_color9  clrMidnightBlue
//#property indicator_color10 clrMidnightBlue
//#property indicator_color11 clrMidnightBlue
//#property indicator_color12 clrMidnightBlue

#include <MyMql/DecisionMaking/Decision3MA.mqh>
#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <MyMql/Generator/GenerateTPandSL.mqh>
#include <MyMql/Info/ScreenInfo.mqh>
#include <MyMql/Info/VerboseInfo.mqh>
#include <Files/FileTxt.mqh>
#include <MyMql/Global/Log/WebServiceLog.mqh>
#include <MyMql/Global/Global.mqh>



double Buf_CloseH1[], Buf_MedianH1[],
	Buf_CloseD1[], Buf_MedianD1[],
	Buf_CloseW1[], Buf_MedianW1[];

double Buf_CloseShiftedH1[], Buf_MedianShiftedH1[],
	Buf_CloseShiftedD1[], Buf_MedianShiftedD1[],
	Buf_CloseShiftedW1[], Buf_MedianShiftedW1[];

double Buf_Decision[];

//+------------------------------------------------------------------+
//| Indicator initialization function (used for testing)             |
//+------------------------------------------------------------------+
int init()
{
	// print some verbose info
	//VerboseInfo vi;
	//vi.BalanceAccountInfo();
	//vi.ClientAndTerminalInfo();
	//vi.PrintMarketInfo();
	
	
	SetIndexBuffer(0, Buf_CloseH1);
	SetIndexStyle(0, DRAW_SECTION, STYLE_SOLID, 1, clrIndigo);
	SetIndexBuffer(1, Buf_MedianH1);
	SetIndexStyle(1, DRAW_SECTION, STYLE_SOLID, 2, clrIndigo);
	SetIndexBuffer(2, Buf_CloseShiftedH1);
	SetIndexStyle(2, DRAW_SECTION, STYLE_DOT, 1, clrDarkBlue);
	SetIndexBuffer(3, Buf_MedianShiftedH1);
	SetIndexStyle(3, DRAW_SECTION, STYLE_DOT, 2, clrDarkBlue);
	
	SetIndexBuffer(4, Buf_CloseD1);
	SetIndexStyle(4, DRAW_SECTION, STYLE_SOLID, 1, clrDarkBlue);
	SetIndexBuffer(5, Buf_MedianD1);
	SetIndexStyle(5, DRAW_SECTION, STYLE_SOLID, 2, clrDarkBlue);
	SetIndexBuffer(6, Buf_CloseShiftedD1);
	SetIndexStyle(6, DRAW_SECTION, STYLE_DOT, 1, clrMidnightBlue);
	SetIndexBuffer(7, Buf_MedianShiftedD1);
	SetIndexStyle(7, DRAW_SECTION, STYLE_DOT, 2, clrMidnightBlue);
	
	SetIndexBuffer(8, Buf_CloseW1);
	SetIndexStyle(8, DRAW_SECTION, STYLE_SOLID, 1, clrMidnightBlue);
	SetIndexBuffer(9, Buf_MedianW1);
	SetIndexStyle(9, DRAW_SECTION, STYLE_SOLID, 2, clrMidnightBlue);
	SetIndexBuffer(10, Buf_CloseShiftedW1);
	SetIndexStyle(10, DRAW_SECTION, STYLE_DOT, 1, clrIndigo);
	SetIndexBuffer(11, Buf_MedianShiftedW1);
	SetIndexStyle(11, DRAW_SECTION, STYLE_DOT, 2, clrIndigo);
	
	SetIndexBuffer(12, Buf_Decision);
	SetIndexStyle(12, DRAW_SECTION, STYLE_SOLID, 0, clrNONE);
	
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
   
	WebServiceLog wslog(false,false,false,"3MA.txt");
	Decision3MA decision;
	BaseMoneyManagement money;
	ScreenInfo screen;
	GenerateTPandSL generator;
	//bool openFile = true;
	
	//if(logToFile && openFile) {
	//	logFile.Open("LogFile.txt", FILE_READ | FILE_WRITE | FILE_ANSI);
	//	logFile.Seek(0, SEEK_END);
	//	openFile = false;
	//}
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/money.Pip();
	
	transaction.SetSimulatedOrderObjectName("SimulatedOrder3MA");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLoss3MA");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfit3MA");
	
	transaction.AutoAddTransactionData(spreadPips);
	
	while(i >= 0)
	{
		double d = decision.GetDecision(i);
		decision.SetIndicatorData(Buf_CloseH1, Buf_MedianH1, Buf_CloseD1, Buf_MedianD1, Buf_CloseW1, Buf_MedianW1, i);
		decision.SetIndicatorShiftedData(Buf_CloseShiftedH1, Buf_MedianShiftedH1, Buf_CloseShiftedD1, Buf_MedianShiftedD1, Buf_CloseShiftedW1, Buf_MedianShiftedW1, i);
		Buf_Decision[i] = d;
		
		// calculate profit/loss, TPs, SLs, etc
		transaction.CalculateData(i);
		
		//if(logToFile)
		//	logFile.WriteString(transaction.OrdersToString(true));
		////SafePrintString(transaction.OrdersToString());
		////Print("");
		
		if(d != IncertitudeDecision)
		{
			if(d > 0.0) { // Buy
				double price = Close[i] + spread; // Ask
				money.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_BUY, price, false, spread);
				generator.ValidateAndFixTPandSL(TP, SL, price, OP_BUY, spread, false);
				transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, price, 0, SL, TP, NULL, 0, 0, clrNONE, i);
				
				
				//if(logToFile) {
				//	logFile.WriteString("[" + IntegerToString(i) + "] New order buy " + DoubleToString(price) + " " + DoubleToString(SL) + " " + DoubleToString(TP));
				//	logFile.WriteString(transaction.OrdersToString(true));
				//}
				////SafePrintString(transaction.OrdersToString());
				////Print("");
			} else { // Sell
				double price = Close[i]; // Bid
				money.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_SELL, price, false, spread);
				generator.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, false);
				transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, price, 0, SL, TP, NULL, 0, 0, clrNONE, i);
				
				
				//if(logToFile) {
				//	logFile.WriteString("[" + IntegerToString(i) + "] New order sell " + DoubleToString(price) + " " + DoubleToString(SL) + " " + DoubleToString(TP));
				//	logFile.WriteString(transaction.OrdersToString(true));
				//}
				////SafePrintString(transaction.OrdersToString());
				////Print("");
			}
			
			screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(-1)),clrGray, 20, 0);
			screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
			screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
		}
		
		//transaction.FlowWithTrend_UpdateSL_TP_UsingConstants(2.6*spreadPips, 1.6*spreadPips);
		i--;
	}
	
	//if(logToFile)
	//	logFile.Flush();
	
	
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
	wslog.DataLog("TestIndicator3MA on " + _Symbol, summary);
	Comment(summary);
	
	
   _EW
	return 0;
}
