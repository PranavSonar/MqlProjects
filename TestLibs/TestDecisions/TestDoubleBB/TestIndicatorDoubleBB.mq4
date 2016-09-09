//+------------------------------------------------------------------+
//|                                                TestIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property indicator_chart_window

#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Gray
#property indicator_color4 Red
#property indicator_color5 Blue

#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>
#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>
#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <MyMql/Generator/GenerateTPandSL.mqh>
#include <MyMql/Info/ScreenInfo.mqh>
#include <MyMql/Info/VerboseInfo.mqh>
#include <Files/FileTxt.mqh>


double Buf_BBs2[], Buf_BBs1[], Buf_BBm[], Buf_BBd1[], Buf_BBd2[];

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
	
	return INIT_SUCCEEDED;
}


static FlowWithTrendTranMan transaction;

int start()
{
	DecisionDoubleBB decision;
	BaseMoneyManagement money;
	ScreenInfo screen;
	GenerateTPandSL generator;
	bool logToFile = false;
	CFileTxt logFile;
	
	if(logToFile)
		logFile.Open("LogFile.txt", FILE_WRITE | FILE_ANSI | FILE_REWRITE);
		
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/money.Pip();
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	transaction.SetSimulatedOrderObjectName("SimulatedOrderBA");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLossBA");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfitBA");
	//transaction.AddInitializerTransactionData(0.5, 0.5); // BB doesn't need shit
	//transaction.AddInitializerTransactionData(0.2, 0.2);

	transaction.AddInitializerTransactionData(2.6*spreadPips, 1.6*spreadPips); 
	
	
	while(i >= 0)
	{
		double d = decision.GetDecision(SL, TP, 1.0, i);
		decision.SetIndicatorData(Buf_BBs2, Buf_BBs1, Buf_BBm, Buf_BBd1, Buf_BBd2, i);
		
		// calculate profit/loss, TPs, SLs, etc
		transaction.CalculateData(i);
		
		if(logToFile)
			logFile.WriteString(transaction.OrdersToString(true));
		
		if(d != IncertitudeDecision)
		{
			if(d > 0) { // Buy
				double price = Close[i] + spread; // Ask
				money.CalculateTP_SL(TP, SL, OP_BUY, price, false, spread, 3*spread, spread);
				generator.ValidateAndFixTPandSL(TP, SL, price, spread, false);
				
				transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, price, 0, SL ,TP, NULL, 0, 0, clrNONE, i);
				
				if(logToFile) {
					logFile.WriteString("[" + IntegerToString(i) + "] New order buy " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
					logFile.WriteString(transaction.OrdersToString(true));
				}
				
			} else { // Sell
				double price = Close[i]; // Bid
				money.CalculateTP_SL(TP, SL, OP_SELL, price, false, spread, 3*spread, spread);
				generator.ValidateAndFixTPandSL(TP, SL, price, spread, false);
				transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, price, 0, SL, TP, NULL, 0, 0, clrNONE, i);
				
				if(logToFile) {
					logFile.WriteString("[" + IntegerToString(i) + "] New order sell " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
					logFile.WriteString(transaction.OrdersToString(true));
				}
			}
			
			screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders()),clrGray, 20, 0);
			screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
			screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
		}
		
		
		//transaction.FlowWithTrend_UpdateSL_TP_UsingConstants(2.6*spreadPips, 1.6*spreadPips);
		i--;
	}
	
	if(logToFile) {
		logFile.Flush();
		logFile.Close();
	}
	
	transaction.GetBestTPandSL(TP, SL);
	Comment("Maximum profit: " + DoubleToStr(transaction.GetTotalMaximumProfitFromOrders(),2)
		+ "\nMinimum profit: " + DoubleToStr(transaction.GetTotalMinimumProfitFromOrders(),2)
		+ "\n[Medium profit]: " + DoubleToStr(transaction.GetTotalMediumProfitFromOrders(),2)
		+ "\n\nTake profit (best from average): " + DoubleToStr(TP,4)
		+ "\nStop loss (best from average): " + DoubleToStr(SL,4)
		+ "\nSpread: " + DoubleToStr(spreadPips, 4)
		+ "\nTake profit / Spread (best from average): " + DoubleToStr(TP/spreadPips,4)
		+ "\nStop loss / Spread (best from average): " + DoubleToStr(SL/spreadPips,4)
		);
	
	return 0;
}
