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

#include "../../../MqlLibs/DecisionMaking/DecisionDoubleBB.mq4"
#include "../../../MqlLibs/TransactionManagement/BaseTransactionManagement.mq4"
#include "../../../MqlLibs/VerboseInfo/ScreenInfo.mq4"
#include "../../../MqlLibs/VerboseInfo/VerboseInfo.mq4"


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
	ScreenInfo screen;
	
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0;
	
	while(i >= 0)
	{
		double d = decision.GetDecision(SL, TP, 1.0, i);
		decision.SetIndicatorData(Buf_BBs2, Buf_BBs1, Buf_BBm, Buf_BBd1, Buf_BBd2, i);
		
		if(d != IncertitudeDecision)
		{
			if(d > 0) // Buy
			{
				transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, MarketInfo(Symbol(),MODE_ASK),0,SL,TP,NULL, 0, 0, clrNONE, i);
			}
			else // Sell
			{
				transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, MarketInfo(Symbol(),MODE_BID),0,SL,TP,NULL, 0, 0, clrNONE, i);
			}
		}
		i--;
	}
	
	return 0;
}
