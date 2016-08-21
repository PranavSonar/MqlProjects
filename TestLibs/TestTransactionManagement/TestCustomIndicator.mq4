//+------------------------------------------------------------------+
//|                                                TestIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#property indicator_chart_window  // Drawing in the chart window
#property indicator_separate_window // Drawing in a separate window
#property indicator_buffers 1       // Number of buffers
#property indicator_color1 Blue     // Color of the 1st line
#property indicator_color2 Red      // Color of the 2nd line

double Buf_0[];                     // Declaring an indicator array


//+------------------------------------------------------------------+
//| Indicator initialization function (used for testing)             |
//+------------------------------------------------------------------+
int init()
{
	SetIndexBuffer(0, Buf_0);
	SetIndexStyle(DRAW_SECTION,STYLE_SOLID, 2);
	return INIT_SUCCEEDED;
}


int start()
{
	int i, Counted_bars;
	Counted_bars = IndicatorCounted();
	i = Bars - Counted_bars - 1;
	
	while(i >= 0)
	{
		Buf_0[i] = (High[i] + Low[i]) / 2.0;
		i--;
	}
	
	return 0;
}
