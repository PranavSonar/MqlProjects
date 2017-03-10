//+------------------------------------------------------------------+
//|                                             BulkDebugLogTest.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/DecisionMaking/BaseDecision.mqh>

int OnInit()
{
	long stuff = 32;
	stuff = stuff;// & BuyDecisionMask;
	Print(stuff);
	
	long stuff2 = 32232;
	stuff2 = stuff2;// & SellDecisionMask;
	Print(stuff2);
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	
}
