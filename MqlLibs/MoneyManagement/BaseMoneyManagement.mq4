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

class BaseMoneyManagement
{
	public:
		BaseMoneyManagement() {}
		
		virtual double GetTotalAmount() { return AccountBalance() + AccountCredit(); }
		
		virtual void CalculateTP_SL(double &tp, double &sl, int orderIsBuy, double tpLimitPips, double slLimitPips, double price, double spread)
		{
			double pip = Point * 10;
			
			if (orderIsBuy == 1)
			{
				tp = price + (tpLimitPips*pip) + (spread);
				sl = price - (slLimitPips*pip) - (spread);
			}
			else if (orderIsBuy == 0)
			{ 
				tp = price - (tpLimitPips*pip) - (spread);
				sl = price + (slLimitPips*pip) + (spread);
			}
		}
		
		virtual double CalculatePriceForUSD()
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
			else if(baseCurrency == "CAD")
				return 1/MarketInfo("USDCAD",MODE_BID);
			else if(baseCurrency == "CHF")
				return 1/MarketInfo("USDCHF",MODE_BID);
			else if(baseCurrency == "SGD")
				return 1/MarketInfo("USDSGD",MODE_BID);
			else if(baseCurrency == "USD")
				return 1.00;
			else
				return 0.0;
		}
};