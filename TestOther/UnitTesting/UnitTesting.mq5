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

bool TestWebService(string &errors)
{
	WebServiceLog wslog(true);
	
	wslog.NewTradingSession();
	
	bool isOk = true;
	string param1, param2;
	
	param1 = "name2";
	param2 = "parameasdasdters234234 ";
	wslog.StartProcedureLog(param1, param2);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "StartProcedureLog(" + param1 + "," + param2 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	wslog.EndProcedureLog(param1);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "EndProcedureLog(" + param1 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	param1 = "as234 2 43d";
	param2 = "p234 arameas 2345 2345 2345dasdters2342345 2345234 ";
	wslog.StartProcedureLog(param1, param2);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "StartProcedureLog(" + param1 + "," + param2 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	wslog.EndProcedureLog(param1);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "EndProcedureLog(" + param1 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	param1 = "234asdftest test";
	param2 = "parameasd21 5234 5234 52345 asdters234234 ";
	wslog.StartProcedureLog(param1, param2);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "StartProcedureLog(" + param1 + "," + param2 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	wslog.EndProcedureLog(param1);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "EndProcedureLog(" + param1 + "); " + RowsAffectedString + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	param1 = "234asdftest test";
	param2 = "w345cw34";
	wslog.DataLog(param1, param2);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "DataLog(" + param1 + "," + param2 + "); Rows affected: 1" + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	param1 = " 23 test";
	param2 = "24 57 w345cw34";
	wslog.DataLog(param1, param2);
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "DataLog(" + param1 + "," + param2 + "); Rows affected: 1" + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	
	wslog.EndTradingSession();
	isOk = isOk && AssertEqual(errors, wslog.Result, XmlEncodingString + BeginString + "EndTradingSession; Rows affected: 1" + EndString, WSAssertErrorString);
	//SafePrintString(wslog.Result);
	
	// Clean the database; if everything worked until now, it should work now too
	wslog.DeleteLastSession();
	
	return isOk;
}


#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>

bool AssertBB (string &errors, string text,
	double RealBBd2, double RealBBd1, double RealBBm, double RealBBs1, double RealBBs2,
	double BBd2, double BBd1, double BBm, double BBs1, double BBs2)
{
	int precision = 4;
	bool isOk = true;
	isOk = isOk && AssertEqual(errors, RealBBd2, BBd2, text + "BBd2 failed miserably", precision, false, false);
	isOk = isOk && AssertEqual(errors, RealBBd1, BBd1, text + "BBd1 failed miserably", precision, false, false);
	isOk = isOk && AssertEqual(errors, RealBBm,  BBm,  text + "BBm  failed miserably", precision, false, false);
	isOk = isOk && AssertEqual(errors, RealBBs1, BBs1, text + "BBs1 failed miserably", precision, false, false);
	isOk = isOk && AssertEqual(errors, RealBBs2, BBs2, text + "BBs2 failed miserably", precision, false, false);
	return isOk;
}

bool TestBollingerBands(string &retErrors)
{
	bool isOk = true;
	DecisionDoubleBB decision;
	
	int shift = 0, period = Period();
	double BBs2, BBs1, BBm, BBd1, BBd2;
	double internalBandsDeviationWhole = 2.0, internalBandsDeviation = 1.0;
	
	double RealBBs2 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_UPPER, shift);
	double RealBBs1 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
	double RealBBm  = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviationWhole, 0, MODE_MAIN,   MODE_BASE, shift);
	double RealBBd1 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
	double RealBBd2 = iBands(Symbol(), PERIOD_CURRENT, period, internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_LOWER, shift);
	
	decision.CalculateBands(BBs2, BBs1, BBm, BBd1, BBd2, internalBandsDeviationWhole, internalBandsDeviation, shift, period-1);
	isOk = isOk && AssertBB(retErrors, IntegerToString(period) + ": ", RealBBd2, RealBBd1, RealBBm, RealBBs1, RealBBs2, BBd2, BBd1, BBm, BBs1, BBs2);
	
	return isOk;
}

#include <MyMql\MoneyManagement\BaseMoneyManagement.mqh>

bool TestOrderLimits(string &errors, int orderType = OP_BUY)
{
	bool isOk = true;
	BaseMoneyManagement money;
	
	int digits = 5;
	double price = MarketInfo(Symbol(), MODE_BID);
	double SL = 0.0, TP = 0.0, SL2 = 0.0, TP2 = 0.0, SlLimitPips = 0.0, TpLimitPips = 0.0, SlLimitPips2 = 0.0, TpLimitPips2 = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/money.Pip();
	
	TpLimitPips = 2.6 * spreadPips;
	SlLimitPips = 1.6 * spreadPips;
	money.CalculateTP_SL(TP, SL, TpLimitPips, SlLimitPips, orderType, price, false, spread);
   if((TP == 0.0) || (SL == 0.0))
   {
      isOk = false;
      errors += "CalculateTP(" + IntegerToString(orderType) + "; " + DoubleToString(NormalizeDouble(TP, digits)) + "==0.0 || " + DoubleToString(NormalizeDouble(SL, digits)) + "==0.0) ";
   }

	money.CalculateSL(SL2, SlLimitPips, orderType, price, false, spread);
	if(NormalizeDouble(SL2, digits) != NormalizeDouble(SL, digits))
   {
      isOk = false;
      errors += "CalculateTP(" + IntegerToString(orderType) + "; " + DoubleToString(NormalizeDouble(SL2, digits)) + "!=" + DoubleToString(NormalizeDouble(SL, digits)) + ") ";
   }
	
	money.CalculateTP(TP2, TpLimitPips, orderType, price, false, spread);
	if(NormalizeDouble(TP2, digits) != NormalizeDouble(TP, digits))
   {
      isOk = false;
      errors += "CalculateTP(" + IntegerToString(orderType) + "; " + DoubleToString(NormalizeDouble(TP2, digits)) + "!=" + DoubleToString(NormalizeDouble(TP, digits)) + ") ";
   }
   
	money.DeCalculateTP_SL(TP, SL, TpLimitPips2, SlLimitPips2, orderType, price, false, spread);
	if(NormalizeDouble(TpLimitPips2, digits) != NormalizeDouble(TpLimitPips, digits))
   {
      isOk = false;
      errors += "DeCalculateTP_SL(" + IntegerToString(orderType) + "; " + DoubleToString(NormalizeDouble(TpLimitPips2, digits)) + "!=" + DoubleToString(NormalizeDouble(TpLimitPips, digits)) + ") ";
   }
   if(NormalizeDouble(SlLimitPips2, digits) != NormalizeDouble(SlLimitPips, digits))
   {
      isOk = false;
      errors += "DeCalculateTP_SL(" + IntegerToString(orderType) + "; " + DoubleToString(NormalizeDouble(SlLimitPips2, digits)) + "!=" + DoubleToString(NormalizeDouble(SlLimitPips, digits)) + ") ";
   }
   
	TpLimitPips2 = 0.0;
	money.DeCalculateTP(TP, TpLimitPips2, orderType, price, false, spread);
	if(NormalizeDouble(TpLimitPips2, digits) != NormalizeDouble(TpLimitPips, digits))
   {
      isOk = false;
      errors += "DeCalculateTP(" + IntegerToString(orderType) + "; " + DoubleToString(NormalizeDouble(TpLimitPips2, digits)) + "!=" + DoubleToString(NormalizeDouble(TpLimitPips, digits)) + ") ";
   }
   
	SlLimitPips2 = 0.0;
	money.DeCalculateSL(SL, SlLimitPips2, orderType, price, false, spread);
	
   if(NormalizeDouble(SlLimitPips2, digits) != NormalizeDouble(SlLimitPips, digits))
   {
      isOk = false;
      errors += "DeCalculateSL(" + IntegerToString(orderType) + "; " + DoubleToString(NormalizeDouble(SlLimitPips2, digits)) + "!=" + DoubleToString(NormalizeDouble(SlLimitPips, digits)) + ") ";
   }
	return isOk;
}


#include <MyMql\Config\GlobalConfig.mqh>

bool TestMoneyConversion(string &errors, bool verbose = false)
{
   bool isOk = true;
   BaseMoneyManagement money;
   
   double convertedPrice = money.CalculateCurrencyPrice(false, false);
   if(convertedPrice == 0.0)
   {
      isOk = false;
      errors += "money.CalculateCurrencyPrice(false, false)==0.0 ";
      if(verbose)
         printf("money.CalculateCurrencyPrice(false, false)==0.0 ");
   }
   
   convertedPrice = money.CalculateCurrencyPrice(false, true);
   if(convertedPrice == 0.0)
   {
      isOk = false;
      errors += "money.CalculateCurrencyPrice(false, true)==0.0 ";
      if(verbose)
         printf("money.CalculateCurrencyPrice(false, true)==0.0 ");
   }
   
   return isOk;
}



void OnInit()
{
	string finalText = "", errors = "";
	if(!TestWebService(errors))
		finalText += "TestWebService() failed on Symbol: " + Symbol() + " (" + errors + ")\n";
	
	// The test is not going to work as is. Ignore for now
	//if(!TestBollingerBands())
	//	finalText += "TestBollingerBands() failed on Symbol: " + Symbol() + "\n";
	
	if(!TestOrderLimits(errors, OP_BUY))
		finalText += "TestOrderLimits(OP_BUY) failed on Symbol: " + Symbol() + " (" + errors + ")\n";
	
	if(!TestOrderLimits(errors, OP_SELL))
		finalText += "TestOrderLimits(OP_SELL) failed on Symbol: " + Symbol() + " (" + errors + ")\n";
	
	if(!TestMoneyConversion(errors, false))
		finalText += "TestMoneyConversion(true) failed on Symbol: " + Symbol() + " (" + errors + ")\n";
	
	if(finalText == "")
		finalText = "All green";
	
	
	// Log with WebService
	WebServiceLog wslog(true);
	wslog.NewTradingSession();
	
	if(!MarketInfo(_Symbol, MODE_TRADEALLOWED))
	   finalText += "; Trade not allowed";
	wslog.DataLog("UnitTest on " + Symbol(), finalText);
	wslog.EndTradingSession();
	
	SafePrintString(finalText);
	
	// Navigate next
	GlobalConfig config(true, true, false, false);
	config.ChangeSymbol();
}
