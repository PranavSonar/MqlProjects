//+------------------------------------------------------------------+
//|                                          BaseMoneyManagement.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../SymbolsLib/BaseSymbol.mq4"
#include "../BaseLibs/BaseObject.mq4"


// Should be defined the same as decision type (because it also has sell/buy)
#define OrderIsBuy 1
#define OrderIsSell -1
#define OrderIsIncert 0

class BaseMoneyManagement : public BaseObject
{
	private:
		BaseSymbol symbol;
		
	public:
		BaseMoneyManagement() {}
		
		virtual double GetTotalAmount() { return AccountBalance() + AccountCredit(); }
		
		virtual bool CheckPriceGoesOurWay()
		{
			bool statusOk = true;
			
			return statusOk;
		}
		
		virtual void CalculateTP_SL(double &tp, double &sl, int orderType, double price, double tpLimitPips = 50.0, double slLimitPips = 30.0, double spread = 0.0)
		{
			if(spread == 0.0) {
				spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID);
			}
			
			double pip = Point * 10;
			
			if (orderType == OrderIsBuy)
			{
				tp = price + (tpLimitPips*pip) + (spread);
				sl = price - (slLimitPips*pip) - (spread);
			}
			else if (orderType == OrderIsSell)
			{
				tp = price - (tpLimitPips*pip) - (spread);
				sl = price + (slLimitPips*pip) + (spread);
			}
		}
		
		virtual double CalculatePriceForBaseCurrencyUSD()
		{
			string baseCurrency = StringSubstr(Symbol(),0,3);
			if(baseCurrency == "AUD")
				return MarketInfo("AUDUSD",MODE_BID);
			else if(baseCurrency == "EUR")
				return MarketInfo("EURUSD",MODE_BID);
			else if(baseCurrency == "GBP")
				return MarketInfo("GBPUSD",MODE_BID);
			else if(baseCurrency == "NZD")
				return MarketInfo("NZDUSD",MODE_BID);
			
			double invertedPrice = 0.0;
			if(baseCurrency == "CAD") {
				invertedPrice = MarketInfo("USDCAD", MODE_BID);
				return invertedPrice != 0 ? 1.0/invertedPrice : 0.0;
			} else if(baseCurrency == "CHF") {
				invertedPrice = MarketInfo("USDCHF", MODE_BID);
				return invertedPrice != 0 ? 1.0/invertedPrice : 0.0;
			} else if(baseCurrency == "SGD") {
				invertedPrice = MarketInfo("USDSGD", MODE_BID);
				return invertedPrice != 0 ? 1.0/invertedPrice : 0.0;
			} else if(baseCurrency == "USD")
				return 1.00;
			else
				return 0.0;
		}
		
		virtual double CalculatePriceForBaseCurrency()
		{
			string accountCurrency = AccountCurrency();
			if(accountCurrency == "")
				return 0.0;
			else if(accountCurrency == "USD")
				return CalculatePriceForBaseCurrencyUSD();
			
			string baseCurrency = StringSubstr(Symbol(),0,3);
			
			if(baseCurrency == accountCurrency)
				return 1.0;
			else
			{
				string testedSymbol = accountCurrency + baseCurrency;
				if(symbol.SymbolExists(testedSymbol))
					return MarketInfo(testedSymbol, MODE_BID);
				
				double invertedPrice = 0.0;
				testedSymbol = baseCurrency + accountCurrency;
				if(symbol.SymbolExists(testedSymbol))
				{
					testedSymbol = symbol.GetSymbolStartingWith(testedSymbol);
					invertedPrice = MarketInfo(testedSymbol, MODE_BID);
					return invertedPrice != 0.0 ? 1.0/invertedPrice : 0.0;
				}
				
				// indirect currency calculate (might need testing)
				string symbolList[];
				symbol.SymbolsListWithSymbolPart(accountCurrency,symbolList);
				testedSymbol = StringSubstr(symbolList[0],3,3) + baseCurrency;
				if(symbol.SymbolExists(testedSymbol)) {
					testedSymbol = symbol.GetSymbolStartingWith(testedSymbol);
					return MarketInfo(symbolList[0], MODE_BID) * MarketInfo(testedSymbol, MODE_BID);
				}
			}
			
			return 0.0;
		}
		
		virtual double CalculatePrice(double decisionType = 0.0)
		{
			double price = 0.0;
			if (decisionType > 0.0)
				price = MarketInfo(Symbol(),MODE_ASK);
			if(decisionType < 0.0)
				price = MarketInfo(Symbol(),MODE_BID);
		
			return price;
		}
		
		virtual int AutoDetectNumberOfBots()
		{
			return WindowsTotal(); // windows might be full of experts.. or not :)
		}
};