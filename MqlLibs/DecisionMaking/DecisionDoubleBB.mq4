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
		DecisionDoubleBB(int verboseLevel = 0, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verboseLevel,shiftValue,internalShift) { InternalSL = 0.0; InternalTP = 0.0; }
		DecisionDoubleBB(double sl, double tp, int verboseLevel = 0, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verboseLevel,shiftValue,internalShift) { InternalSL = sl; InternalTP = tp; }
		
		virtual double GetDecision()
		{
			return GetDecision(1.0);
		}
		
		virtual double GetDecision(double internalBandsDeviation = 1.0)
		{
			return GetDecision(InternalSL, InternalTP, internalBandsDeviation);
		}
		
		virtual double GetDecision(double &stopLoss, double &takeProfit, double internalBandsDeviation = 1.0, int shift = 0, double internalBandsDeviationWhole = 2.0)
		{
			// Calculate decisions based on Bollinger Bands
			double BBs2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_UPPER, shift);
			//double BBs2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
			double BBs1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
			//double BBs1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
			double BBm  = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, MODE_MAIN,   MODE_BASE, shift);
			//double BBmShifted  = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, MODE_MAIN,   MODE_BASE,  ShiftValue);
			double BBd1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
			//double BBd1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
			double BBd2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_LOWER, shift);
			//double BBd2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
			
			// no Bollinger Bands calculation at all?
			if((BBs2 == 0.0) || (BBs1 == 0.0) || (BBm == 0.0) || (BBd1 == 0.0) || (BBd2 == 0))
				return IncertitudeDecision;
			
			// wrong Bollinger Bands calculation?
			if(!((BBs1<BBs2) && (BBm<BBs1) && (BBd1<BBm) && (BBd2<BBd1)))
				return IncertitudeDecision;
			
			double closeLevel = iClose(Symbol(), Period(), shift);
			double closeLevelShift = iClose(Symbol(), Period(), shift + ShiftValue);
			
			double result = InvalidValue;
			
			if((closeLevel <= BBd2) // lower than the last two lines
				&& (closeLevelShift > closeLevel)) // and the close level goes down
			{
				result += 2*SellDecision;
				stopLoss = BBm;
				takeProfit = BBd2 - (BBd1 - BBd2); // approx. calculation
			}
			
			if((closeLevel >= BBd2) && (closeLevel <= BBd1) // between the last two lines
				&& (closeLevelShift > closeLevel)) // and the close level goes down
			{
				result += SellDecision;
				stopLoss = BBm;
				takeProfit = BBd2;
			}
			
			if((closeLevel >= BBs1) && (closeLevel <= BBs2) // between the first two lines
				&& (closeLevelShift < closeLevel)) // and the close level goes up
			{
				result += BuyDecision;
				stopLoss = BBm;
				takeProfit = BBs2;
			}
			
			if((closeLevel >= BBs2) // even higher than the first line
				&& (closeLevelShift < closeLevel)) // and the close level goes up
			{
				result += 2*BuyDecision;
				stopLoss = BBm;
				takeProfit = BBs2 + (BBs2 - BBs1); // approx. calculation
			}
			
			if(IsVerboseMode())
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
