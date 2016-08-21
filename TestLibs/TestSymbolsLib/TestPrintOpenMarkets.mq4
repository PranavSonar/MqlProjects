//+------------------------------------------------------------------+
//|                                         TestPrintOpenMarkets.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/Symbols/BaseSymbol.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function (used for testing)                |
//+------------------------------------------------------------------+
int OnInit()
{
   BaseSymbol symbol;
   symbol.PrintOpenMarkets();
   
   return(INIT_SUCCEEDED);
}