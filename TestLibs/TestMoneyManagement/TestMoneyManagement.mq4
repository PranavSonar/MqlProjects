//+------------------------------------------------------------------+
//|                                          TestMoneyManagement.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../MqlLibs/MoneyManagement/BaseMoneyManagement.mq4"

//+------------------------------------------------------------------+
//| Expert initialization function (used for testing)                |
//+------------------------------------------------------------------+
int OnInit()
{
	BaseMoneyManagement money;
	
	//--- CalculatePriceForUSD
	printf("CalculatePriceForUSD: %f", money.CalculatePriceForBaseCurrencyUSD());
	
	//--- GetTotalAmount
	printf("GetTotalAmount: %f", money.GetTotalAmount());

	//--- CalculateTP_SL
	double TP, SL;
	money.CalculateTP_SL(TP,SL,OP_BUY,30,20,10,10); printf("CalculateTP_SL: buy: TP = %f, SL = %f", TP, SL);
	money.CalculateTP_SL(TP,SL,OP_SELL,30,20,10,10); printf("CalculateTP_SL: sell: TP = %f, SL = %f", TP, SL);
	
	//--- CheckPriceGoesOurWay
	printf("CheckPriceGoesOurWay: %f", money.CheckPriceGoesOurWay());
	
	//--- CalculatePrice
	printf("CalculatePrice: %f", money.CalculatePrice());
	
	
	return(INIT_SUCCEEDED);
}
