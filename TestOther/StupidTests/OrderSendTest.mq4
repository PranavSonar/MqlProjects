//+------------------------------------------------------------------+
//|                                               YetAnotherTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/Global/Money/Generator/LimitGenerator.mqh>

void OnTick()
{
	LimitGenerator generator;
	BaseMoneyManagement money;
	double price = MarketInfo(Symbol(), MODE_BID);
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/Pip();
	
	generator.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_BUY, price, false, spread);
	if((TP != 0.0) || (SL != 0.0))
		generator.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, true);
	int tichet = OrderSend(Symbol(), OP_SELL, 0.01, price, 0, SL, TP, NULL, 0, 0, clrChocolate);
			
	if(tichet == -1)
		Print("Failed! Reason: " + IntegerToString(GetLastError()));		
}

