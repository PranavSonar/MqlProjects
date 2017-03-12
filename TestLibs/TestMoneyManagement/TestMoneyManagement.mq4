//+------------------------------------------------------------------+
//|                                          TestMoneyManagement.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/Global/Global.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function (used for testing)                |
//+------------------------------------------------------------------+
int OnInit()
{
	BaseMoneyManagement money;
//	LimitGenerator limit;
	
	//--- CalculatePriceForUSD
	//printf("CalculatePriceForUSD(isOrderSymbol = false, isBaseCurrency = false): %f", money.CalculateCurrencyPriceForUSD(false, false));
	printf("CalculateCurrencyPrice(isOrderSymbol = false, isBaseCurrency = false, 0, 0, 0): %f", money.CalculateCurrencyPrice(false, false, 0, 0, 0));
//	
//	//--- GetTotalAmount
//	printf("GetTotalAmount: %f", money.GetTotalAmount());
//
//	//--- CalculateTP_SL
//	double TP, SL, TPpips, SLpips, openPrice, spread;
//	TPpips = 20.0; SLpips = 10.0; openPrice = 1.253212; spread = 0.02;
//	limit.CalculateTP_SL(TP,SL,TPpips,SLpips,OP_BUY,openPrice,false,spread); printf("CalculateTP_SL: buy: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f, spread = %f", TP, SL, TPpips, SLpips, openPrice, spread);
//	limit.DeCalculateTP_SL(TP,SL,TPpips,SLpips,OP_BUY,openPrice,false,spread); printf("CalculateTP_SL: buy: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f, spread = %f", TP, SL, TPpips, SLpips, openPrice, spread);
//	
//	
//	TPpips = 20.0; SLpips = 10.0; openPrice = 1.253212; spread = 0.02;
//	limit.CalculateTP_SL(TP,SL,TPpips,SLpips,OP_SELL,openPrice,false,spread); printf("CalculateTP_SL: sell: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f, spread = %f", TP, SL, TPpips, SLpips, openPrice, spread);
//	limit.DeCalculateTP_SL(TP,SL,TPpips,SLpips,OP_SELL,openPrice,false,spread); printf("CalculateTP_SL: sell: TP = %f, SL = %f, TPpips = %f SLpips = %f, price = %f, spread = %f", TP, SL, TPpips, SLpips, openPrice, spread);
//	
//	//--- CheckPriceGoesOurWay (obsolete; removed)
//	//printf("CheckPriceGoesOurWay: %f", money.CheckPriceGoesOurWay());
//	
//	//--- CalculatePrice
//	printf("CalculateCurrencyPrice: %f", money.CalculateCurrencyPrice(false, false, 0, 0, 0));
//	
//	
	return(INIT_SUCCEEDED);
}
