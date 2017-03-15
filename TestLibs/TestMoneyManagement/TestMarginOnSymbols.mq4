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
		
		double freeMarginLeft = 
			(AccountFreeMarginCheck(symbol, OP_BUY, MarketInfo(symbol, MODE_MINLOT)) + 
			AccountFreeMarginCheck(symbol, OP_SELL, MarketInfo(symbol, MODE_MINLOT)))/2.0;
		
		printf(
			"PipChangeRateForSymbol=%f; symbol=%s; baseCurrency=%s; profitCurrency=%s; marginCurrency=%s; accountCurrency=%s freeMarginLeft=%f accountMoney=%f",
			money.PipChangeRateForSymbol(symbol, 0, 0, 0),
			symbol,
			baseSymbolCurrency,
			profitSymbolCurrency,
			marginSymbolCurrency,
			accountCurrency,
			freeMarginLeft,
			AccountBalance() + AccountCredit()
		);
	}
	
	return(INIT_SUCCEEDED);
}
