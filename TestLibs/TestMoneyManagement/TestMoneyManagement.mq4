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
	//printf("CalculatePriceForUSD(isOrderSymbol = false, isBaseCurrency = false): %f", money.CalculateCurrencyPriceForUSD(false, false));
	printf("CalculateCurrencyPrice(isOrderSymbol = false, isBaseCurrency = false): %f", money.CalculateCurrencyPrice(false,false));
	
	//--- GetTotalAmount
	printf("GetTotalAmount: %f", money.GetTotalAmount());

	//--- CalculateTP_SL
	double TP, SL, TPpips, SLpips, openPrice, spread;
	TPpips = 20.0; SLpips = 10.0; openPrice = 1.253212; spread = 0.02;
	money.CalculateTP_SL(TP,SL,TPpips,SLpips,OP_BUY,openPrice,spread); printf("CalculateTP_SL: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f", TP, SL, TPpips, SLpips, openPrice);
	money.DeCalculateTP_SL(TP,SL,TPpips,SLpips,OP_BUY,openPrice,spread); printf("CalculateTP_SL: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f", TP, SL, TPpips, SLpips, openPrice);
	
	
	TPpips = 20.0; SLpips = 10.0; openPrice = 1.253212; spread = 0.02;
	money.CalculateTP_SL(TP,SL,TPpips,SLpips,OP_SELL,openPrice,spread); printf("CalculateTP_SL: sell: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f", TP, SL, TPpips, SLpips, openPrice);
	money.DeCalculateTP_SL(TP,SL,TPpips,SLpips,OP_SELL,openPrice,spread); printf("CalculateTP_SL: sell: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f", TP, SL, TPpips, SLpips, openPrice);
	
	//--- CheckPriceGoesOurWay (obsolete; removed)
	//printf("CheckPriceGoesOurWay: %f", money.CheckPriceGoesOurWay());
	
	//--- CalculatePrice
	printf("CalculateCurrencyPrice: %f", money.CalculateCurrencyPrice(false, false));
	
	
	return(INIT_SUCCEEDED);
}
