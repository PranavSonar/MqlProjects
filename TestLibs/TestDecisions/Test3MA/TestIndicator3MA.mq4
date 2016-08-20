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
#property indicator_buffers 12
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

#include "../../../MqlLibs/DecisionMaking/Decision3MA.mq4"
#include "../../../MqlLibs/TransactionManagement/BaseTransactionManagement.mq4"
#include "../../../MqlLibs/VerboseInfo/ScreenInfo.mq4"
#include "../../../MqlLibs/VerboseInfo/VerboseInfo.mq4"


double Buf_CloseH1[], Buf_MedianH1[],
	Buf_CloseD1[], Buf_MedianD1[],
	Buf_CloseW1[], Buf_MedianW1[];

double Buf_CloseShiftedH1[], Buf_MedianShiftedH1[],
	Buf_CloseShiftedD1[], Buf_MedianShiftedD1[],
	Buf_CloseShiftedW1[], Buf_MedianShiftedW1[];

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
	
	return INIT_SUCCEEDED;
}


int start()
{
	int NrDecisionsSell = 0, NrDecisionsBuy = 0;
	Decision3MA decision;
	decision.SetVerboseLevel(1);
	BaseTransactionManagement transaction;
	transaction.SetVerboseLevel(1);
	transaction.SetSimulatedOrder("SimulatedOrder3MA");
	transaction.SetSimulatedStopLoss("SimulatedStopLoss3MA");
	transaction.SetSimulatedTakeProfit("SimulatedTakeProfit3MA");
	ScreenInfo screen;
	
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0;
	
	while(i >= 0)
	{
		double d = decision.GetDecision(i);
		decision.SetIndicatorData(Buf_CloseH1, Buf_MedianH1, Buf_CloseD1, Buf_MedianD1, Buf_CloseW1, Buf_MedianW1, i);
		decision.SetIndicatorShiftedData(Buf_CloseShiftedH1, Buf_MedianShiftedH1, Buf_CloseShiftedD1, Buf_MedianShiftedD1, Buf_CloseShiftedW1, Buf_MedianShiftedW1, i);
		
		if(d != IncertitudeDecision)
		{
			if(d > 0) // Buy
			{
				transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, MarketInfo(Symbol(),MODE_ASK),0,SL,TP,NULL, 0, 0, clrNONE, i);
				NrDecisionsBuy++;
			}
			else // Sell
			{
				transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, MarketInfo(Symbol(),MODE_BID),0,SL,TP,NULL, 0, 0, clrNONE, i);
				NrDecisionsSell++;
			}
			
			screen.ShowTextValue("CurrentValue","Number of decisions: " + IntegerToString(NrDecisionsSell + NrDecisionsBuy),clrGray, 20, 0);
			screen.ShowTextValue("CurrentValueSell","Number of sell decisions: " + IntegerToString(NrDecisionsSell), clrGray, 20, 20);
			screen.ShowTextValue("CurrentValueBuy","Number of buy decisions: " + IntegerToString(NrDecisionsBuy), clrGray, 20, 40);
		}
		i--;
	}
	
	return 0;
}
