//+------------------------------------------------------------------+
//|                                                TestIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrDeepSkyBlue
#property indicator_color3 clrDarkBlue
#property indicator_color4 clrDarkBlue
#property indicator_color5 clrMidnightBlue
#property indicator_color6 clrMidnightBlue

#include <MyMql/DecisionMaking/DecisionRSI.mqh>
#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>
#include <MyMql/TransactionManagement/BaseTransactionManagement.mqh>
#include <MyMql/Generator/GenerateTPandSL.mqh>
#include <MyMql/Info/ScreenInfo.mqh>
#include <MyMql/Info/VerboseInfo.mqh>
#include <Files/FileTxt.mqh>


double Buf_CloseH1[], Buf_MedianH1[],
	Buf_CloseD1[], Buf_MedianD1[],
	Buf_CloseW1[], Buf_MedianW1[];

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
	
	return INIT_SUCCEEDED;
}


static BaseTransactionManagement transaction;

int start()
{
	DecisionRSI decision;
	BaseMoneyManagement money;
	ScreenInfo screen;
	GenerateTPandSL generator;
	bool logToFile = false;
	CFileTxt logFile;
	
	if(logToFile)
		logFile.Open("LogFile.txt", FILE_WRITE | FILE_ANSI | FILE_REWRITE);
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	transaction.SetSimulatedOrderObjectName("SimulatedOrderRSI");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLossRSI");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfitRSI");
	transaction.AddInitializerTransactionData(0.5, 0.5);
	transaction.AddInitializerTransactionData(0.2, 0.2);
	
	
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID);
	
	while(i >= 0)
	{
		double d = decision.GetDecision(i);
		decision.SetIndicatorData(Buf_CloseH1, Buf_MedianH1, Buf_CloseD1, Buf_MedianD1, Buf_CloseW1, Buf_MedianW1, i);
		
		// calculate profit/loss, TPs, SLs, etc
		transaction.CalculateData(i);
		
		if(d != IncertitudeDecision)
		{
			if(d > 0) { // Buy
				double price =  Open[i];
				money.CalculateTP_SL(TP, SL, OP_BUY, price, false, spread, 3*spread, spread);
				generator.ValidateAndFixTPandSL(TP, SL, spread, false);
				
				transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.01, MarketInfo(Symbol(),MODE_ASK),0,SL,TP,NULL, 0, 0, clrNONE, i);
				
				if(logToFile) {
					logFile.WriteString("[" + IntegerToString(i) + "] New order buy " + DoubleToStr(MarketInfo(Symbol(),MODE_ASK)) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
					logFile.WriteString(transaction.OrdersToString(true));
				}
				
			} else { // Sell
				double price = Close[i];
				money.CalculateTP_SL(TP, SL, OP_SELL, price, false, spread, 3*spread, spread);
				generator.ValidateAndFixTPandSL(TP, SL, spread, false);
				transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.01, MarketInfo(Symbol(),MODE_BID),0,SL,TP,NULL, 0, 0, clrNONE, i);
				
				if(logToFile) {
					logFile.WriteString("[" + IntegerToString(i) + "] New order sell " + DoubleToStr(MarketInfo(Symbol(),MODE_BID)) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
					logFile.WriteString(transaction.OrdersToString(true));
				}
			}
			
			screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(-1)),clrGray, 20, 0);
			screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
			screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
		}
		i--;
	}
	
	if(logToFile) {
		logFile.Flush();
		logFile.Close();
	}
	
	
	Comment("Maximum profit: " + DoubleToStr(transaction.GetTotalMaximumProfitFromOrders(),2)
		+ "\nMinimum profit: " + DoubleToStr(transaction.GetTotalMinimumProfitFromOrders(),2)
		+ "\nMedium profit: " + DoubleToStr(transaction.GetTotalMediumProfitFromOrders(),2));
	
	return 0;
}
