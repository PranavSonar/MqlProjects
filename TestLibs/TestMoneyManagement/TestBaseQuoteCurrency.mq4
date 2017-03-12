//+------------------------------------------------------------------+
//|                                        TestBaseQuoteCurrency.mq4 |
//|                                Copyright 2017, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int OnInit()
{
	string accountCurrency = AccountCurrency();
	int len = SymbolsTotal(false);
	
	for(int i=0; i<len; i++)
	{
		string symbol = SymbolName(i, false),
			baseSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE),
			profitSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);
		
		printf(
			"symbol=%s; baseCurrency=%s; profitCurrency=%s; accountCurrency=%s",
			symbol,
			baseSymbolCurrency,
			profitSymbolCurrency,
			accountCurrency
		);
	}
	
	return(INIT_SUCCEEDED);
}
