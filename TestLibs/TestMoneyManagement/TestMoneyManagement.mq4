//+------------------------------------------------------------------+
//|                                          TestMoneyManagement.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function (used for testing)                |
//+------------------------------------------------------------------+
int OnInit()
{
	BaseMoneyManagement money;
	//--- CalculatePriceForUSD
	printf("CalculatePriceForUSD(isOrderSymbol = false, isBaseCurrency = false): %f", money.CalculateCurrencyPriceForUSD(false, false));
	printf("CalculateCurrencyPrice(isOrderSymbol = false, isBaseCurrency = false): %f", money.CalculateCurrencyPrice(false,false));
	
	//--- GetTotalAmount
	printf("GetTotalAmount: %f", money.GetTotalAmount());

	//--- CalculateTP_SL
	double TP, SL;
	money.CalculateTP_SL(TP,SL,OP_BUY,30.0,20.0,10.0,10.0); printf("CalculateTP_SL: buy: TP = %f, SL = %f", TP, SL);
	money.CalculateTP_SL(TP,SL,OP_SELL,30.0,20.0,10.0,10.0); printf("CalculateTP_SL: sell: TP = %f, SL = %f", TP, SL);
	
	//--- CheckPriceGoesOurWay (obsolete; removed)
	//printf("CheckPriceGoesOurWay: %f", money.CheckPriceGoesOurWay());
	
	//--- CalculatePrice
	printf("CalculateCurrencyPrice: %f", money.CalculateCurrencyPrice(false, false));
	
	
	return(INIT_SUCCEEDED);
}
