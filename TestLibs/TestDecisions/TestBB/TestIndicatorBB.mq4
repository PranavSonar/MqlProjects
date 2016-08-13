//+------------------------------------------------------------------+
//|                                                TestIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property indicator_chart_window  // Drawing in the chart window
//#property indicator_separate_window // Drawing in a separate window
#property indicator_buffers 0       // Number of buffers
#property indicator_color1 Blue     // Color of the 1st line
#property indicator_color2 Red      // Color of the 2nd line

#include "../../../MqlLibs/DecisionMaking/DecisionDoubleBB.mq4"
#include "../../../MqlLibs/TransactionManagement/BaseTransactionManagement.mq4"
#include "../../../MqlLibs/VerboseInfo/ScreenInfo.mq4"
#include "../../../MqlLibs/VerboseInfo/VerboseInfo.mq4"

//+------------------------------------------------------------------+
//| Indicator initialization function (used for testing)             |
//+------------------------------------------------------------------+
int init()
{
	// print some verbose info
	VerboseInfo vi;
	vi.BalanceAccountInfo();
	vi.ClientAndTerminalInfo();
	vi.PrintMarketInfo();
	
	return INIT_SUCCEEDED;
}


int start()
{
	DecisionDoubleBB decision;
	BaseTransactionManagement transaction;
	ScreenInfo screen;
	
	int i = Bars - IndicatorCounted() - 1;
	double SL, TP;
	
	while(i >= 0)
	{
		double d = decision.GetDecision(SL, TP, 1.0, i);
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
