//+------------------------------------------------------------------+
//|                                                  TestLogging.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Base\BeforeObject.mqh>
#include <MyMql\Log\WebServiceLog.mqh>


const string XmlEncodingString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n";
const string BeginString = "<string xmlns=\"http://tempuri.org/\">";
const string RowsAffectedString = "Rows affected: 1";
const string EndString = "</string>\0";
const string WSAssertErrorString = "Web service error";

bool TestWebService()
{
	WebServiceLog wslog(true);
	
	wslog.NewTradingSession();
	
	bool isOk = true;
	string param1, param2;
	
	param1 = "name2";
	param2 = "parameasdasdters234234 ";
	wslog.StartProcedureLog(param1, param2);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "StartProcedureLog(" + param1 + "," + param2 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	wslog.EndProcedureLog(param1);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "EndProcedureLog(" + param1 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	param1 = "as234 2 43d";
	param2 = "p234 arameas 2345 2345 2345dasdters2342345 2345234 ";
	wslog.StartProcedureLog(param1, param2);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "StartProcedureLog(" + param1 + "," + param2 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	wslog.EndProcedureLog(param1);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "EndProcedureLog(" + param1 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	param1 = "234asdftest test";
	param2 = "parameasd21 5234 5234 52345 asdters234234 ";
	wslog.StartProcedureLog(param1, param2);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "StartProcedureLog(" + param1 + "," + param2 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	wslog.EndProcedureLog(param1);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "EndProcedureLog(" + param1 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	param1 = "234asdftest test";
	param2 = "w345cw34";
	wslog.DataLog(param1, param2);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "DataLog(" + param1 + "," + param2 + "); Rows affected: 1" + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	param1 = " 23 test";
	param2 = "24 57 w345cw34";
	wslog.DataLog(param1, param2);
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "DataLog(" + param1 + "," + param2 + "); Rows affected: 1" + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	wslog.EndTradingSession();
	isOk = isOk && AssertEqual(wslog.Result, XmlEncodingString + BeginString + "EndTradingSession; Rows affected: 1" + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	// Clean the database; if everything worked until now, it should work now too
	wslog.DeleteLastSession();
	
	return isOk;
}


#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>

bool AssertBB (string text,
	double RealBBd2, double RealBBd1, double RealBBm, double RealBBs1, double RealBBs2,
	double BBd2, double BBd1, double BBm, double BBs1, double BBs2)
{
	int precision = 4;
	bool isOk = true;
	isOk = isOk && AssertEqual(RealBBd2, BBd2, text + "BBd2 failed miserably", precision, false, true);
	isOk = isOk && AssertEqual(RealBBd1, BBd1, text + "BBd1 failed miserably", precision, false, true);
	isOk = isOk && AssertEqual(RealBBm,  BBm,  text + "BBm  failed miserably", precision, false, true);
	isOk = isOk && AssertEqual(RealBBs1, BBs1, text + "BBs1 failed miserably", precision, false, true);
	isOk = isOk && AssertEqual(RealBBs2, BBs2, text + "BBs2 failed miserably", precision, false, true);
	return isOk;
}

void CopyIndicatorBuffer(int handler, int num, int shift, double &values[], int len = 1)
{
	if(CopyBuffer(handler, num, -shift, len, values) < 0)
		Print("The iBands object is not created: Error",GetLastError());
}

bool TestBollingerBands()
{
	bool isOk = true;
	DecisionDoubleBB decision;
	
	int shift = 0, period = Period();
	double BBs2, BBs1, BBm, BBd1, BBd2;
	double internalBandsDeviationWhole = 2.0, internalBandsDeviation = 1.0;
	
#ifdef __MQL5__
	int indicatorHandlerWhole = iBands(Symbol(), PERIOD_CURRENT, period, shift, internalBandsDeviationWhole, PRICE_CLOSE);
	int indicatorHandler = iBands(Symbol(), PERIOD_CURRENT, period, shift, internalBandsDeviation, PRICE_CLOSE);
	double indicatorValues[];
	
	CopyIndicatorBuffer(indicatorHandlerWhole, 1, -shift, indicatorValues);
	double RealBBs2 = indicatorValues[0];
	CopyIndicatorBuffer(indicatorHandler, 1, -shift, indicatorValues);
	double RealBBs1 = indicatorValues[0];
	CopyIndicatorBuffer(indicatorHandler, 0, -shift, indicatorValues);
	double RealBBm  = indicatorValues[0];
	CopyIndicatorBuffer(indicatorHandler, 2, -shift, indicatorValues);
	double RealBBd1 = indicatorValues[0];
	CopyIndicatorBuffer(indicatorHandlerWhole, 2, -shift, indicatorValues);
	double RealBBd2 = indicatorValues[0];
#else
	double RealBBs2 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_UPPER, shift);
	double RealBBs1 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
	double RealBBm  = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviationWhole, 0, MODE_MAIN,   MODE_BASE, shift);
	double RealBBd1 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
	double RealBBd2 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_LOWER, shift);

#endif
	
	decision.CalculateBands(BBs2, BBs1, BBm, BBd1, BBd2, internalBandsDeviationWhole, internalBandsDeviation, shift, period);
	isOk = isOk && AssertBB(IntegerToString(period) + ": ", RealBBd2, RealBBd1, RealBBm, RealBBs1, RealBBs2, BBd2, BBd1, BBm, BBs1, BBs2);
	
	return isOk;
}

#include <MyMql\MoneyManagement\BaseMoneyManagement.mqh>

bool TestOrderLimits(int orderType = OP_BUY)
{
	bool isOk = true;
	BaseMoneyManagement money;
	
	double price = MarketInfo(Symbol(), MODE_BID);
	double SL = 0.0, TP = 0.0, SL2 = 0.0, TP2 = 0.0, SlLimitPips = 0.0, TpLimitPips = 0.0, SlLimitPips2 = 0.0, TpLimitPips2 = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/money.Pip();
	
	TpLimitPips = 2.6 * spreadPips;
	SlLimitPips = 1.6 * spreadPips;
	money.CalculateTP_SL(TP, SL, TpLimitPips, SlLimitPips, orderType, price, false, spread);
	isOk = isOk && ((TP != 0.0) && (SL != 0.0));
	
	money.CalculateSL(SL2, SlLimitPips, orderType, price, false, spread);
	isOk = isOk && (SL2 == SL);
	
	money.CalculateTP(TP2, TpLimitPips, orderType, price, false, spread);
	isOk = isOk && (TP2 == TP);
	
	money.DeCalculateTP_SL(TP, SL, TpLimitPips2, SlLimitPips2, orderType, price, false, spread);
	isOk = isOk && ((TpLimitPips2 == TpLimitPips) && (SlLimitPips2 == SlLimitPips));
	
	TpLimitPips2 = 0.0;
	money.DeCalculateTP(TP, TpLimitPips2, orderType, price, false, spread);
	isOk = isOk && (TpLimitPips2 == TpLimitPips);
	
	SlLimitPips2 = 0.0;
	money.DeCalculateSL(SL, SlLimitPips2, orderType, price, false, spread);
	isOk = isOk && (SlLimitPips2 == SlLimitPips);
	
	return isOk;
}


#include <MyMql\Config\GlobalConfig.mqh>

bool TestMoneyConversion(bool verbose = false)
{
	bool isOk = true;
	BaseMoneyManagement money;
	
	double convertedPrice = money.CalculateCurrencyPrice(false, false);
	isOk = isOk && (convertedPrice != 0.0);
	
	if((convertedPrice == 0.0) && (verbose == true))
		Print("TestMoneyConversion failed on Symbol: " + Symbol() + " IsBase: " + BoolToString(false));
	
	convertedPrice = money.CalculateCurrencyPrice(false, true);
	isOk = isOk && (convertedPrice != 0.0);
	
	if((convertedPrice == 0.0) && (verbose == true))
		Print("TestMoneyConversion failed on Symbol: " + Symbol() + " IsBase: " + BoolToString(true));
	
	return isOk;
}



void OnInit()
{
	string finalText = "";
	if(!TestWebService())
		finalText += "TestWebService() failed on Symbol: " + Symbol() + "\n";
	
	if(!TestBollingerBands())
		finalText += "TestBollingerBands() failed on Symbol: " + Symbol() + "\n";
	
	if(!TestOrderLimits(OP_BUY))
		finalText += "TestOrderLimits(OP_BUY) failed on Symbol: " + Symbol() + "\n";
	
	if(!TestOrderLimits(OP_SELL))
		finalText += "TestOrderLimits(OP_SELL) failed on Symbol: " + Symbol() + "\n";
	
	if(!TestMoneyConversion(true))
		finalText += "TestMoneyConversion(true) failed on Symbol: " + Symbol() + "\n";
	
	if(finalText == "")
		finalText = "All green";
	
	
	// Log with WebService
	WebServiceLog wslog(true);
	wslog.NewTradingSession();
	wslog.DataLog("UnitTest on " + Symbol(), finalText);
	wslog.EndTradingSession();
	
	SafePrintString(finalText);
	
	// Navigate next
	GlobalConfig config(true, true, false);
	config.ChangeSymbol();
}
