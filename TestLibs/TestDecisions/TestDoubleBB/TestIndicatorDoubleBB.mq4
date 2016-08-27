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
#include <MyMql/TransactionManagement/BaseTransactionManagement.mqh>
#include <MyMql/Info/ScreenInfo.mqh>
#include <MyMql/Info/VerboseInfo.mqh>


double Buf_BBs2[], Buf_BBs1[], Buf_BBm[], Buf_BBd1[], Buf_BBd2[];

//+------------------------------------------------------------------+
//| Indicator initialization function (used for testing)             |
//+------------------------------------------------------------------+
int OnInit()
{
	// print some verbose info
	VerboseInfo vi;
	vi.BalanceAccountInfo();
	vi.ClientAndTerminalInfo();
	vi.PrintMarketInfo();
	
	
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


int start()
{
	DecisionDoubleBB decision;
	decision.SetVerboseLevel(1);
	BaseTransactionManagement transaction;
	transaction.SetVerboseLevel(1);
	transaction.SetSimulatedOrderObjectName("SimulatedOrderBA");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLossBA");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfitBA");
	
	ScreenInfo screen;
	
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0;
	
	while(i >= 0)
	{
		double d = decision.GetDecision(SL, TP, 1.0, i);
		decision.SetIndicatorData(Buf_BBs2, Buf_BBs1, Buf_BBm, Buf_BBd1, Buf_BBd2, i);
		
		// calculate profit/loss, TPs, SLs, etc
		transaction.CalculateData(i);
		
		if(d != IncertitudeDecision)
		{
			if(d > 0) // Buy
				transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, MarketInfo(Symbol(),MODE_ASK),0,SL,TP,NULL, 0, 0, clrNONE, i);
			else // Sell
				transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, MarketInfo(Symbol(),MODE_BID),0,SL,TP,NULL, 0, 0, clrNONE, i);
			
			screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders()),clrGray, 20, 0);
			screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
			screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
		}
		i--;
	}
	
	Comment("Maximum profit: " + DoubleToStr(transaction.GetMaximumProfitFromOrders(),2)
		+ "\nMinimum profit: " + DoubleToStr(transaction.GetMaximumProfitFromOrders(),2)
		+ "\nMedium profit: " + DoubleToStr(transaction.GetMediumProfitFromOrders(),2));
	
	return 0;
}
