//+------------------------------------------------------------------+
//|                                                   DecisionBB.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "DecisionIndicator.mq4"

class DecisionDoubleBB : public DecisionIndicator
{
	private:
		double InternalSL;
		double InternalTP;
		
	public:
		DecisionDoubleBB() : DecisionIndicator(false) { InternalSL = 0.0; InternalTP = 0.0; }
		DecisionDoubleBB(bool verbose) : DecisionIndicator(verbose) { InternalSL = 0.0; InternalTP = 0.0; }
		DecisionDoubleBB(bool verbose, int shift) : DecisionIndicator(verbose,shift) { InternalSL = 0.0; InternalTP = 0.0; }
		DecisionDoubleBB(bool verbose, int shift, double sl, double tp) : DecisionIndicator(verbose,shift) { InternalSL = sl; InternalTP = tp; }
		
		virtual double GetDecision()
		{
			return GetDecision(1.0);
		}
		
		virtual double GetDecision(double internalBandsDeviation = 1.0)
		{
			return GetDecision(InternalSL, InternalTP, internalBandsDeviation);
		}
		
		virtual double GetDecision(double &stopLoss, double &takeProfit, double internalBandsDeviation = 1.0)
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
			
			if(Verbose)
			{
				printf("Double BB Level Decision [%f]: [close=%f closeShifted=%f] [SL = %f TP = %f] %f %f %f %f %f\n",
					result, closeLevel, closeLevelShift,
					stopLoss, takeProfit,
					BBs2, BBs1, BBm, BBd1, BBd2
				);
			}
			
			return result;
		}

};
