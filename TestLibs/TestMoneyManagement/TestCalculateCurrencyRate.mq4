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
	string accountCurrency = AccountCurrency();
	int len = SymbolsTotal(false);
	
	for(int i=0; i<len; i++)
	{
		string symbol = SymbolName(i, false),
			baseSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE),
			profitSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT),
			marginSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_MARGIN);
		
//		if((marginSymbolCurrency == "NZD") || (marginSymbolCurrency == "AUD"))
//			DebugBreak();
		
		printf(
			"CalculateCurrencyPriceForSymbol=%f; symbol=%s; baseCurrency=%s; profitCurrency=%s; marginCurrency=%s; accountCurrency=%s",
			money.CalculateCurrencyRateForSymbol(symbol, false, true, 0, 0, 0),
			symbol,
			baseSymbolCurrency,
			profitSymbolCurrency,
			marginSymbolCurrency,
			accountCurrency
		);
	}
	
	return(INIT_SUCCEEDED);
}
