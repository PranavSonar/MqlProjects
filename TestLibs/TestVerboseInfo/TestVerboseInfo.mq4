//+------------------------------------------------------------------+
//|                                              TestVerboseInfo.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/Info/VerboseInfo.mqh>


int init()
{
	VerboseInfo info;
	info.PrintMarketInfo();
	info.BalanceAccountInfo();
	info.ClientAndTerminalInfo();
	return info.ExpertValidationsTest();
}