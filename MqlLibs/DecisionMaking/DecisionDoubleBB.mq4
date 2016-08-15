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
		double BBs2, BBs1, BBm, BBd1, BBd2;
		
	public:
		DecisionDoubleBB(int verboseLevel = 0, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verboseLevel,shiftValue,internalShift) { InternalSL = 0.0; InternalTP = 0.0; }
		DecisionDoubleBB(double sl, double tp, int verboseLevel = 0, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verboseLevel,shiftValue,internalShift) { InternalSL = sl; InternalTP = tp; }
		
		virtual double GetBBs2() { return BBs2; }
		virtual double GetBBs1() { return BBs1; }
		virtual double GetBBm()  { return BBm;  }
		virtual double GetBBd1() { return BBd1; }
		virtual double GetBBd2() { return BBd2; }
		
		virtual void SetIndicatorData(double &Buffer_BBs2[], double &Buffer_BBs1[], double &Buffer_BBm[], double &Buffer_BBd1[], double &Buffer_BBd2[], int index)
			{ Buffer_BBs2[index] = BBs2; Buffer_BBs1[index] = BBs1; Buffer_BBm[index] = BBm; Buffer_BBd1[index] = BBd1; Buffer_BBd2[index] = BBd2; }
		
		virtual double GetMaxDecision()
		{
			// max(doubleBBResult) = +/- 4.0 (Buy = +; Sell = -)
			// min(doubleBBResult) = 0.0 (Incertitude = 0)
			return 4.0;
		}
		
		virtual double GetDecision(double internalBandsDeviation = 1.0, int shift = 0, double internalBandsDeviationWhole = 2.0)
		{
			return GetDecision(InternalSL, InternalTP, internalBandsDeviation, shift, internalBandsDeviationWhole);
		}
		
		virtual double GetDecision(double &stopLoss, double &takeProfit, double internalBandsDeviation = 1.0, int shift = 0, double internalBandsDeviationWhole = 2.0)
		{
			if((shift == 0) && (GetShiftValue() != 0))
				shift = GetShiftValue();
			
			// Calculate decisions based on Bollinger Bands
			BBs2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_UPPER, shift);
			//double BBs2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
			BBs1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
			//double BBs1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
			BBm  = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, MODE_MAIN,   MODE_BASE, shift);
			//double BBmShifted  = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, MODE_MAIN,   MODE_BASE,  ShiftValue);
			BBd1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
			//double BBd1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
			BBd2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_LOWER, shift);
			//double BBd2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
			
			// no Bollinger Bands calculation at all?
			if((BBs2 == 0.0) || (BBs1 == 0.0) || (BBm == 0.0) || (BBd1 == 0.0) || (BBd2 == 0))
				return IncertitudeDecision;
			
			// wrong Bollinger Bands calculation?
			if(!((BBs1<BBs2) && (BBm<BBs1) && (BBd1<BBm) && (BBd2<BBd1)))
				return IncertitudeDecision;
			
			double closeLevel = iClose(Symbol(), Period(), shift);
			double closeLevelShift = iClose(Symbol(), Period(), shift + ShiftValue);
			
			// max(doubleBBResult) = +/- 4.0 (Buy = +; Sell = -)
			// min(doubleBBResult) = 0.0 (Incertitude = 0)
			double result = InvalidValue;
			
			if((closeLevel <= BBd2) // lower than the last two lines
				&& (closeLevelShift > closeLevel)) // and the close level goes down
			{
				result += 4*SellDecision;
				stopLoss = BBm;
				takeProfit = BBd2 - (BBd1 - BBd2); // approx. calculation
			}
			
			if((closeLevel >= BBd2) && (closeLevel <= BBd1) // between the last two lines
				&& (closeLevelShift > closeLevel)) // and the close level goes down
			{
				result += 2*SellDecision;
				stopLoss = BBm;
				takeProfit = BBd2;
			}
			
			if((closeLevel >= BBs1) && (closeLevel <= BBs2) // between the first two lines
				&& (closeLevelShift < closeLevel)) // and the close level goes up
			{
				result += 2*BuyDecision;
				stopLoss = BBm;
				takeProfit = BBs2;
			}
			
			if((closeLevel >= BBs2) // even higher than the first line
				&& (closeLevelShift < closeLevel)) // and the close level goes up
			{
				result += 4*BuyDecision;
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
