#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

#property description "First program made, used to check some MQL4 functions" 

const double BuyDecision = 1.0;
const double IncertitudeDecision = 0.0;
const double SellDecision = -1.0;
const double InvalidValue = 0.0;
const int ShiftValue = 1;

int OnInit()
{
	// Print (one time) information
	ClientAndTerminalInfo();
	BalanceAccountInfo();
	PrintMarketInfo();
	
	// Validations
	if(!IsExpertEnabled())
	{
		Print("Expert is not enabled. Nothing to do here. Exiting.");
		return (INIT_FAILED);
	}
	
	if(!IsTradeAllowed())
	{
		Print("Trade is not allowed. Nothing to do here. Exiting.");
		return (INIT_FAILED);
	}
	
	//--- create timer 
	EventSetTimer(1);
   
	return (INIT_SUCCEEDED);
}

void ClientAndTerminalInfo()
{
	Print("#----------------------------------------------------------------------------------------------#");
	printf("# IsDemo: %s", IsDemo()?"true":"false"); 
	printf("# IsTesting: %s", IsTesting()?"true":"false");
	printf("# Symbol: %s", Symbol());
	printf("# Period: %d", Period());
	printf("# PeriodSeconds: %d", PeriodSeconds());
	printf("# Digits (the accuracy of price of the current chart symbol): %d", Digits());
	printf("# Point (the point size of the current symbol in the quote currency): %f", Point());
	printf("# IsLibrariesAllowed: %s", IsLibrariesAllowed()?"true":"false"); 
	printf("# TerminalName: %s", TerminalName());
	printf("# TerminalCompany: %s" + TerminalCompany());
	printf("# Working directory is: %s", TerminalPath());
	printf("# SymbolsTotal: %d", SymbolsTotal(false));
	Print("#----------------------------------------------------------------------------------------------#");
}

void BalanceAccountInfo()
{
	Print("#----------------------------------------------------------------------------------------------#");
	printf("# AccountBalance: %G",AccountInfoDouble(ACCOUNT_BALANCE)); 
	printf("# AccountCredit: %G",AccountInfoDouble(ACCOUNT_CREDIT)); 
	printf("# AccountProfit: %G",AccountInfoDouble(ACCOUNT_PROFIT)); 
	printf("# AccountEquity: %G",AccountInfoDouble(ACCOUNT_EQUITY)); 
	printf("# AccountMargin: %G",AccountInfoDouble(ACCOUNT_MARGIN)); 
	printf("# AccountMarginFree: %G",AccountInfoDouble(ACCOUNT_FREEMARGIN)); 
	printf("# AccountMarginLevel: %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)); 
	printf("# AccountMarginSoCall: %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)); 
	printf("# AccountMarginSoSo: %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
	Print("#----------------------------------------------------------------------------------------------#");
}

void PrintMarketInfo()
{
	Print("#----------------------------------------------------------------------------------------------#");
	printf("|> MarketInfo(ModeBid): %f", MarketInfo(Symbol(), MODE_BID));
	printf("|> MarketInfo(ModeAsk): %f", MarketInfo(Symbol(), MODE_ASK));
	printf("|> MarketInfo(ModePoint): %f", MarketInfo(Symbol(), MODE_POINT));
	printf("|> MarketInfo(ModeDigits): %d", (int)MarketInfo(Symbol(), MODE_DIGITS));
	printf("|> MarketInfo(ModeSpread): %d", (int)MarketInfo(Symbol(), MODE_SPREAD));
	printf("|> Calculated spread(Ask-Bid): %f", MarketInfo(Symbol(), MODE_ASK) - MarketInfo(Symbol(), MODE_BID));
	Print("#----------------------------------------------------------------------------------------------#");
}

void OnDeinit(const int reason)
{
}

double GetDecisionUsingRSI()
{
	// Analysis based on Relative Strength levels:
	double rsiLevelCloseH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, 0);
	double rsiLevelMedianH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, 0);
	double rsiLevelCloseShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, ShiftValue);
	double rsiLevelMedianShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, ShiftValue);
	
	double rsiLevelCloseD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, 0);
	double rsiLevelMedianD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, 0);
	double rsiLevelCloseShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, ShiftValue);
	double rsiLevelMedianShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, ShiftValue);
	
	double rsiLevelCloseW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, 0);
	double rsiLevelMedianW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, 0);
	double rsiLevelCloseShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, ShiftValue);
	double rsiLevelMedianShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, ShiftValue);
	
	// partial results based on each RSI level
	double rsiLevelCloseResultH1 = 
		(rsiLevelCloseH1 >= 70.0 && rsiLevelCloseH1 < rsiLevelCloseShiftedH1 ? BuyDecision : IncertitudeDecision) + // H1 (fast)
		(rsiLevelCloseH1 <= 30.0 && rsiLevelCloseH1 != InvalidValue && rsiLevelCloseH1 > rsiLevelCloseShiftedH1 ? SellDecision : IncertitudeDecision);
	double rsiLevelMedianResultH1 = 
		(rsiLevelMedianH1 >= 70.0 && rsiLevelMedianH1 < rsiLevelMedianShiftedH1 ? BuyDecision : IncertitudeDecision ) +
		(rsiLevelMedianH1 <= 30.0 && rsiLevelMedianH1 != InvalidValue && rsiLevelMedianH1 > rsiLevelMedianShiftedH1 ? SellDecision : IncertitudeDecision);
	double rsiLevelCloseResultD1 = 
		(rsiLevelCloseD1 >= 70.0 && rsiLevelCloseD1 < rsiLevelCloseShiftedD1 ? BuyDecision : IncertitudeDecision) + // D1 (medium)
		(rsiLevelCloseD1 <= 30.0 && rsiLevelCloseD1 != InvalidValue && rsiLevelCloseD1 > rsiLevelCloseShiftedD1 ? SellDecision : IncertitudeDecision);
	double rsiLevelMedianResultD1 =
		(rsiLevelMedianD1 >= 70.0 && rsiLevelMedianD1 < rsiLevelMedianShiftedD1 ? BuyDecision : IncertitudeDecision) +
		(rsiLevelMedianD1 <= 30.0 && rsiLevelMedianD1 != InvalidValue && rsiLevelMedianD1 > rsiLevelMedianShiftedD1 ? SellDecision : IncertitudeDecision);
	double rsiLevelCloseResultW1 =
		(rsiLevelCloseW1 >= 70.0 && rsiLevelCloseW1 < rsiLevelCloseShiftedW1 ? BuyDecision : IncertitudeDecision) + // W1 (slow)
		(rsiLevelCloseW1 <= 30.0 && rsiLevelCloseW1 != InvalidValue && rsiLevelCloseW1 > rsiLevelCloseShiftedW1 ? SellDecision : IncertitudeDecision);
	double rsiLevelMedianResultW1 =
		(rsiLevelMedianW1 >= 70.0 && rsiLevelMedianW1 < rsiLevelMedianShiftedW1 ? BuyDecision : IncertitudeDecision) +
		(rsiLevelMedianW1 <= 30.0 && rsiLevelMedianW1 != InvalidValue && rsiLevelMedianW1 > rsiLevelMedianShiftedW1 ? SellDecision : IncertitudeDecision);
	
	// max(rsiResult) = +/- 6.0
	// min(rsiResult) = 0.0
	double rsiResult =
		rsiLevelCloseResultH1 +
		rsiLevelMedianResultH1 +
		rsiLevelCloseResultD1 +
		rsiLevelMedianResultD1 +
		rsiLevelCloseResultW1 +
		rsiLevelMedianResultW1;
	
	printf("RSI Level Decision [%f]: H1: %f %f D1: %f %f W1: %f %f\nRSI partial decision: H1: %f %f D1: %f %f W1: %f %f\n",
		// final RSI decision
		rsiResult,
		// close/median levels
		rsiLevelCloseH1, rsiLevelMedianH1,
		rsiLevelCloseD1, rsiLevelMedianD1,
		rsiLevelCloseW1, rsiLevelMedianW1,
		// partial RSI decisions
		rsiLevelCloseResultH1, rsiLevelMedianResultH1,
		rsiLevelCloseResultD1, rsiLevelMedianResultD1,
		rsiLevelCloseResultW1, rsiLevelMedianResultW1
	);
	
	return rsiResult;
}

double GetDecisionUsingMA()
{
	// Analysis based on Moving Average levels:
	double closeLevel = iClose(Symbol(), Period(), 0);
	double medianLevel = (
		iOpen(Symbol(), Period(), 0) +
		iClose(Symbol(), Period(), 0)
	) / 2.0;
	
	// H1 (fast)
	double maLevelCloseH1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_CLOSE, 0)
	) / 4.0;
	double maLevelMedianH1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_MEDIAN, 0)
	) / 4.0;
	double maLevelCloseShiftedH1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_EMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_LWMA, PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_SMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_SMMA, PRICE_CLOSE, 0)
	) / 4.0;
	double maLevelMedianShiftedH1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_EMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_LWMA, PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_SMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, ShiftValue, MODE_SMMA, PRICE_MEDIAN, 0)
	) / 4.0;
	
	// D1 (medium)
	double maLevelCloseD1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_CLOSE, 0)
	) / 4.0;
	double maLevelMedianD1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_MEDIAN, 0)
	) / 4.0;
	double maLevelCloseShiftedD1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_EMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_LWMA, PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_SMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_SMMA, PRICE_CLOSE, 0)
	) / 4.0;
	double maLevelMedianShiftedD1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_EMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_LWMA, PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_SMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, ShiftValue, MODE_SMMA, PRICE_MEDIAN, 0)
	) / 4.0;
	
	// W1 (slow)
	double maLevelCloseW1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_CLOSE, 0)
	) / 4.0;
	double maLevelMedianW1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_MEDIAN, 0)
	) / 4.0;
	double maLevelCloseShiftedW1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_EMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_LWMA, PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_SMA,  PRICE_CLOSE, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_SMMA, PRICE_CLOSE, 0)
	) / 4.0;
	double maLevelMedianShiftedW1 = (
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_EMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_LWMA, PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_SMA,  PRICE_MEDIAN, 0) +
		iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, ShiftValue, MODE_SMMA, PRICE_MEDIAN, 0)
	) / 4.0;
	
	// partial results based on each MA level
	
	// buy:  value is not invalid && maLevel < close/median < maLevelShifted
	// sell: value is not invalid && maLevel > close/median > maLevelShifted
	double maLevelCloseResultH1 = 
		(maLevelCloseH1 != InvalidValue && maLevelCloseH1 < closeLevel && closeLevel < maLevelCloseShiftedH1 ? BuyDecision : IncertitudeDecision) + // H1 (fast)
		(maLevelCloseH1 != InvalidValue && maLevelCloseH1 > closeLevel && closeLevel > maLevelCloseShiftedH1 ? SellDecision : IncertitudeDecision);
	double maLevelMedianResultH1 = 
		(maLevelMedianH1 != InvalidValue && maLevelMedianH1 < medianLevel && medianLevel < maLevelMedianShiftedH1 ? BuyDecision : IncertitudeDecision ) +
		(maLevelMedianH1 != InvalidValue && maLevelMedianH1 > medianLevel && medianLevel > maLevelMedianShiftedH1 ? SellDecision : IncertitudeDecision);
	double maLevelCloseResultD1 = 
		(maLevelCloseD1 != InvalidValue && maLevelCloseD1 < closeLevel && closeLevel < maLevelCloseShiftedD1 ? BuyDecision : IncertitudeDecision) + // D1 (medium)
		(maLevelCloseD1 != InvalidValue && maLevelCloseD1 > closeLevel && closeLevel > maLevelCloseShiftedD1 ? SellDecision : IncertitudeDecision);
	double maLevelMedianResultD1 =
		(maLevelMedianD1 != InvalidValue && maLevelMedianD1 < medianLevel && medianLevel < maLevelMedianShiftedD1 ? BuyDecision : IncertitudeDecision) +
		(maLevelMedianD1 != InvalidValue && maLevelMedianD1 > medianLevel && medianLevel > maLevelMedianShiftedD1 ? SellDecision : IncertitudeDecision);
	double maLevelCloseResultW1 =
		(maLevelCloseW1 != InvalidValue && maLevelCloseW1 < closeLevel && closeLevel < maLevelCloseShiftedW1 ? BuyDecision : IncertitudeDecision) + // W1 (slow)
		(maLevelCloseW1 != InvalidValue && maLevelCloseW1 > closeLevel && closeLevel > maLevelCloseShiftedW1 ? SellDecision : IncertitudeDecision);
	double maLevelMedianResultW1 =
		(maLevelMedianW1 != InvalidValue && maLevelMedianW1 < medianLevel && medianLevel < maLevelMedianShiftedW1 ? BuyDecision : IncertitudeDecision) +
		(maLevelMedianW1 != InvalidValue && maLevelMedianW1 > medianLevel && medianLevel > maLevelMedianShiftedW1 ? SellDecision : IncertitudeDecision);
	
	// max(maResult) = +/- 6.0
	// min(maResult) = 0.0
	double maResult = maLevelCloseResultH1 +
		maLevelMedianResultH1 +
		maLevelCloseResultD1 +
		maLevelMedianResultD1 +
		maLevelCloseResultW1 +
		maLevelMedianResultW1;
	
	printf("MA Level Decision [%f]: [close=%f median=%f]  H1: %f %f %f %f D1: %f %f %f %f W1: %f %f %f %f\n",
		maResult, closeLevel, medianLevel,
		maLevelCloseH1, maLevelCloseShiftedH1, maLevelMedianH1, maLevelMedianShiftedH1,
		maLevelCloseD1, maLevelCloseShiftedD1, maLevelMedianD1, maLevelMedianShiftedD1,
		maLevelCloseW1, maLevelCloseShiftedW1, maLevelMedianW1, maLevelMedianShiftedW1
	);
	
	return maResult;
}


double GetDecisionUsingDoubleBB(double internalBandsDeviation = 1.0)
{
	double SL = 0.0, TP = 0.0;
	return GetDecisionUsingDoubleBB(SL, TP, internalBandsDeviation);
}

double GetDecisionUsingDoubleBB(double &stopLoss, double &takeProfit, double internalBandsDeviation = 1.0)
{
	// Calculate decisions based on Bollinger Bands
	double BBs2 = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
	//double BBs2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
	double BBs1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
	//double BBs1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
	double BBm  = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, MODE_MAIN,   MODE_BASE,  0);
	//double BBmShifted  = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, MODE_MAIN,   MODE_BASE,  ShiftValue);
	double BBd1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
	//double BBd1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
	double BBd2 = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
	//double BBd2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
	
	
	double closeLevel = iClose(Symbol(), Period(), 0);
	double closeLevelShift = iClose(Symbol(), Period(), ShiftValue);
	
	double result = InvalidValue;
	if(closeLevel >= BBd2 && closeLevel <= BBd1 && closeLevelShift > closeLevel)
	{
		result += 2*SellDecision;
		stopLoss = BBm;
		takeProfit = BBd2;
	}
	
	if(closeLevel >= BBs1 && closeLevel <= BBd2 && closeLevelShift < closeLevel)
	{
		result += 2*BuyDecision;
		stopLoss = BBm;
		takeProfit = BBs2;
	}
	
	printf("Double BB Level Decision [%f]: [close=%f closeShifted=%f] [SL = %f TP = %f] %f %f %f %f %f\n",
		result, closeLevel, closeLevelShift,
		stopLoss, takeProfit,
		BBs2, BBs1, BBm, BBd1, BBd2
	);
	
	return result;
}

double CalculateDecision(double stopLoss = 0.0, double takeProfit = 0.0)
{
	double finalResult = 
		GetDecisionUsingRSI() +
		GetDecisionUsingMA() +
		GetDecisionUsingDoubleBB(stopLoss, takeProfit);
	
	printf("Final decision: %f\n Stop loss: %f\n Take profit: %f",
		finalResult, stopLoss, takeProfit);
	return finalResult;
}

void OnTick()
{
	
}


void OnTimer()
{
	double SL = InvalidValue, TP = InvalidValue;
	double decision = CalculateDecision(SL, TP); // maximum possible value is +/-14.0
	
	if(MathAbs(decision) >= 7.0)
	{
		if(decision > 0.0)
		{
		}
		else {
		
		}
	}
}
