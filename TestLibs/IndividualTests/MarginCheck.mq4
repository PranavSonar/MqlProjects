//+------------------------------------------------------------------+
//|                                                  MarginCheck.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int OnInit()
{
	for(int i=0;i<SymbolsTotal(false);i++)
	{
		string symbol = SymbolName(i, false);
		double marginInit = MarketInfo(symbol, MODE_MARGININIT);
		
		Print("Symbol: " + symbol + " Margin init: " + DoubleToString(marginInit));
	}
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{


}

void OnTick()
{

}
