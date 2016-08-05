//+------------------------------------------------------------------+
//|                                                  VerboseInfo.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Class VerboseInfo.                                               |
//| Purpose: Get a lot of info from the environment.                 |
//+------------------------------------------------------------------+
class VerboseInfo
{
private:
	string delimiter;
	
public:
	VerboseInfo(string d = "|>") {
		this.delimiter = d;
	}
	
	virtual void LineDelimiter() {
		Print(delimiter + "----------------------------------------------------------------------------------------------" + delimiter);
	}
	
	void SetDelimiter(string d) { delimiter = d; }
	string GetDelimiter() { return delimiter; }
	
	//--- method for getting client and terminal information
	void ClientAndTerminalInfo()
	{
		LineDelimiter();
		printf(delimiter + " IsDemo: %s", IsDemo()?"true":"false"); 
		printf(delimiter + " IsTesting: %s", IsTesting()?"true":"false");
		printf(delimiter + " Symbol: %s", Symbol());
		printf(delimiter + " Period: %d", Period());
		printf(delimiter + " PeriodSeconds: %d", PeriodSeconds());
		printf(delimiter + " Digits (the accuracy of price of the current chart symbol): %d", Digits());
		printf(delimiter + " Point (the point size of the current symbol in the quote currency): %f", Point());
		printf(delimiter + " IsLibrariesAllowed: %s", IsLibrariesAllowed()?"true":"false"); 
		printf(delimiter + " TerminalName: %s", TerminalName());
		printf(delimiter + " TerminalCompany: %s" + TerminalCompany());
		printf(delimiter + " Working directory is: %s", TerminalPath());
		printf(delimiter + " SymbolsTotal: %d", SymbolsTotal(false));
		LineDelimiter();
	}
	
	//--- method for getting balance account information
	void BalanceAccountInfo()
	{
		LineDelimiter();
		printf(delimiter + " AccountBalance: %G",AccountInfoDouble(ACCOUNT_BALANCE)); 
		printf(delimiter + " AccountCredit: %G",AccountInfoDouble(ACCOUNT_CREDIT)); 
		printf(delimiter + " AccountProfit: %G",AccountInfoDouble(ACCOUNT_PROFIT)); 
		printf(delimiter + " AccountEquity: %G",AccountInfoDouble(ACCOUNT_EQUITY)); 
		printf(delimiter + " AccountMargin: %G",AccountInfoDouble(ACCOUNT_MARGIN)); 
		printf(delimiter + " AccountMarginFree: %G",AccountInfoDouble(ACCOUNT_FREEMARGIN)); 
		printf(delimiter + " AccountMarginLevel: %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)); 
		printf(delimiter + " AccountMarginSoCall: %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)); 
		printf(delimiter + " AccountMarginSoSo: %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
		LineDelimiter();
	}
	
	//--- method for getting market information
	void PrintMarketInfo()
	{
		LineDelimiter();
		printf(delimiter + " MarketInfo(ModeBid): %f", MarketInfo(Symbol(), MODE_BID));
		printf(delimiter + " MarketInfo(ModeAsk): %f", MarketInfo(Symbol(), MODE_ASK));
		printf(delimiter + " MarketInfo(ModePoint): %f", MarketInfo(Symbol(), MODE_POINT));
		printf(delimiter + " MarketInfo(ModeDigits): %d", (int)MarketInfo(Symbol(), MODE_DIGITS));
		printf(delimiter + " MarketInfo(ModeSpread): %d", (int)MarketInfo(Symbol(), MODE_SPREAD));
		printf(delimiter + " Calculated spread(Ask-Bid): %f", MarketInfo(Symbol(), MODE_ASK) - MarketInfo(Symbol(), MODE_BID));
		LineDelimiter();
	}
};
