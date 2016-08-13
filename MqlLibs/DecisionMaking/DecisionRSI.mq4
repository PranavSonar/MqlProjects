//+------------------------------------------------------------------+
//|                                                  DecisionRSI.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "DecisionIndicator.mq4"

class DecisionRSI : public DecisionIndicator
{
	public:
		DecisionRSI(bool verbose = false, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verbose, shiftValue, internalShift) {}
		
		
		double GetDecision()
		{
			// Analysis based on Relative Strength levels:
			double rsiLevelCloseH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, InternalShift);
			double rsiLevelMedianH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, InternalShift);
			double rsiLevelCloseShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, InternalShift + ShiftValue);
			double rsiLevelMedianShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, InternalShift + ShiftValue);
			
			double rsiLevelCloseD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, InternalShift);
			double rsiLevelMedianD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, InternalShift);
			double rsiLevelCloseShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, InternalShift + ShiftValue);
			double rsiLevelMedianShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, InternalShift + ShiftValue);
			
			double rsiLevelCloseW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, InternalShift);
			double rsiLevelMedianW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, InternalShift);
			double rsiLevelCloseShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, InternalShift + ShiftValue);
			double rsiLevelMedianShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, InternalShift + ShiftValue);
			
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
			
			if(IsVerboseMode())
			{
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
			}
			
			return rsiResult;
		}
};
