//+------------------------------------------------------------------+
//|                                                       Test02.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Base\BeforeObject.mqh>

//Close (or Open, High, Low) = Bid
//Close (or Open, High, Low) + Spread = Ask

void OnStart()
{
	SafePrintString("Open:" + DoubleToStr(Open[0]) + " Close:" + DoubleToStr(Close[0]) + " Close+Spread:" + DoubleToStr(Close[0] + Ask - Bid) + " High:" + DoubleToStr(High[0]) + " Low:" + DoubleToStr(Low[0]) + " Ask:" + DoubleToStr(Ask) + " Bid:" + DoubleToStr(Bid) + " MarketAsk" + DoubleToStr(MarketInfo(Symbol(), MODE_ASK)) + " MarketBid:" + DoubleToStr( MarketInfo(Symbol(), MODE_BID)));
}
