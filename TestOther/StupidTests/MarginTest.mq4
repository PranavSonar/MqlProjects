//+------------------------------------------------------------------+
//|                                              WhateverTheTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/LotManagement/BaseLotManagement.mqh>

void OnStart()
{
	BaseLotManagement lot;
	double minLot = MarketInfo(_Symbol, MODE_MINLOT);
	double marginReq = MarketInfo(_Symbol, MODE_MARGINREQUIRED);
	Print("Account #",AccountNumber(), " leverage is ", AccountLeverage());
	Print("minLot=" + DoubleToString(minLot) + " marginReq=" + DoubleToString(minLot)); 
	Print("currentLots=0.01 marginOk=" + BoolToString(lot.IsMarginOk(_Symbol, minLot)));
	Print("AccountMargin=" + DoubleToString(AccountMargin()));
	printf("AccountFreeMargin = %f", AccountFreeMargin());
	printf("RemainingAccountFreeMargin=%f  for 0.01 lots", AccountFreeMarginCheck(Symbol(),OP_SELL, minLot));
}
