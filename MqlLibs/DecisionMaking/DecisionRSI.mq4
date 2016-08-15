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
	private:
		double rsiLevelCloseH1, rsiLevelMedianH1,
			rsiLevelCloseD1, rsiLevelMedianD1,
			rsiLevelCloseW1, rsiLevelMedianW1;
			
	public:
		DecisionRSI(bool verbose = false, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verbose, shiftValue, internalShift) {}
		
		double GetMaxDecision()
		{
			// max(rsiResult) = +/- 12.0 (Buy = +; Sell = -)
			// min(rsiResult) = 0.0 (Incertitude = 0)
			return 12.0;
		}
		
		virtual double GetCloseH1()  { return rsiLevelCloseH1;  }
		virtual double GetMedianH1() { return rsiLevelMedianH1; }
		virtual double GetCloseD1()  { return rsiLevelCloseD1;  }
		virtual double GetMedianD1() { return rsiLevelMedianD1; }
		virtual double GetCloseW1()  { return rsiLevelCloseW1;  }
		virtual double GetMedianW1() { return rsiLevelMedianW1; }
		
		virtual void SetIndicatorData(
			double &Buffer_CloseH1[], double &Buffer_MedianH1[],
			double &Buffer_CloseD1[], double &Buffer_MedianD1[],
			double &Buffer_CloseW1[], double &Buffer_MedianW1[],
			int index
		)
		{ Buffer_CloseH1[index] = rsiLevelCloseH1; Buffer_MedianH1[index] = rsiLevelMedianH1;
			Buffer_CloseD1[index] = rsiLevelCloseD1; Buffer_MedianD1[index] = rsiLevelMedianD1;
			Buffer_CloseW1[index] = rsiLevelCloseW1; Buffer_MedianW1[index] = rsiLevelMedianW1; }
		
		
		double GetDecision(int shift = 0)
		{
			if((shift == 0) && (GetShiftValue() != 0))
				shift = GetShiftValue();
			
			// Analysis based on Relative Strength levels:
			rsiLevelCloseH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, shift);
			rsiLevelMedianH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, shift);
			double rsiLevelCloseShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, shift + ShiftValue);
			double rsiLevelMedianShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, shift + ShiftValue);
			double rsiLevelCloseShifted2H1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, shift + ShiftValue + 1);
			double rsiLevelMedianShifted2H1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, shift + ShiftValue + 1);
			
			rsiLevelCloseD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, shift);
			rsiLevelMedianD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, shift);
			double rsiLevelCloseShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, shift + ShiftValue);
			double rsiLevelMedianShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, shift + ShiftValue);
			double rsiLevelCloseShifted2D1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, shift + ShiftValue + 1);
			double rsiLevelMedianShifted2D1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, shift + ShiftValue + 1);
			
			rsiLevelCloseW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, shift);
			rsiLevelMedianW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, shift);
			double rsiLevelCloseShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, shift + ShiftValue);
			double rsiLevelMedianShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, shift + ShiftValue);
			double rsiLevelCloseShifted2W1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, shift + ShiftValue + 1);
			double rsiLevelMedianShifted2W1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, shift + ShiftValue + 1);
			
			// partial results based on each RSI level
			double rsiLevelCloseResultH1 = 
				((rsiLevelCloseH1 >= 70.0) && (rsiLevelCloseH1 != InvalidValue) ? SellDecision : IncertitudeDecision) + // H1 (fast)
				((rsiLevelCloseH1 <= 30.0) && (rsiLevelCloseH1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
			double rsiLevelMedianResultH1 = 
				((rsiLevelMedianH1 >= 70.0) && (rsiLevelMedianH1 != InvalidValue) ? SellDecision : IncertitudeDecision) +
				((rsiLevelMedianH1 <= 30.0) && (rsiLevelMedianH1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
			double rsiLevelCloseResultD1 = 
				((rsiLevelCloseD1 >= 70.0) && (rsiLevelCloseD1 != InvalidValue) ? SellDecision : IncertitudeDecision) + // D1 (medium)
				((rsiLevelCloseD1 <= 30.0) && (rsiLevelCloseD1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
			double rsiLevelMedianResultD1 =
				((rsiLevelMedianD1 >= 70.0) && (rsiLevelMedianD1 != InvalidValue) ? SellDecision : IncertitudeDecision) +
				((rsiLevelMedianD1 <= 30.0) && (rsiLevelMedianD1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
			double rsiLevelCloseResultW1 =
				((rsiLevelCloseW1 >= 70.0) && (rsiLevelCloseW1 != InvalidValue) ? SellDecision : IncertitudeDecision) + // W1 (slow)
				((rsiLevelCloseW1 <= 30.0) && (rsiLevelCloseW1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
			double rsiLevelMedianResultW1 =
				((rsiLevelMedianW1 >= 70.0) && (rsiLevelMedianW1 != InvalidValue) ? SellDecision : IncertitudeDecision) +
				((rsiLevelMedianW1 <= 30.0) && (rsiLevelMedianW1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
			
			// whole results based on each RSI level (giving more certitude => double the decision result)
			if((((rsiLevelCloseH1 < rsiLevelCloseShiftedH1) || (rsiLevelCloseH1 < rsiLevelCloseShifted2H1)) && (rsiLevelCloseResultH1 == SellDecision)) ||
				(((rsiLevelCloseH1 > rsiLevelCloseShiftedH1) || (rsiLevelCloseH1 > rsiLevelCloseShifted2H1)) && (rsiLevelCloseResultH1 == BuyDecision)))
				rsiLevelCloseResultH1 = rsiLevelCloseResultH1 * 2;
			
			if((((rsiLevelMedianH1 < rsiLevelMedianShiftedH1) || (rsiLevelMedianH1 < rsiLevelMedianShifted2H1)) && (rsiLevelMedianResultH1 == SellDecision)) ||
				(((rsiLevelMedianH1 > rsiLevelMedianShiftedH1) || (rsiLevelMedianH1 > rsiLevelMedianShifted2H1)) && (rsiLevelMedianResultH1 == BuyDecision)))
				rsiLevelMedianResultH1 = rsiLevelMedianResultH1 * 2;
			
			if((((rsiLevelCloseD1 < rsiLevelCloseShiftedD1) || (rsiLevelCloseD1 < rsiLevelCloseShifted2D1)) && (rsiLevelCloseResultD1 == SellDecision)) ||
				(((rsiLevelCloseD1 > rsiLevelCloseShiftedD1) || (rsiLevelCloseD1 > rsiLevelCloseShifted2D1)) && (rsiLevelCloseResultD1 == BuyDecision)))
				rsiLevelCloseResultD1 = rsiLevelCloseResultD1 * 2;
			
			if((((rsiLevelMedianD1 < rsiLevelMedianShiftedD1) || (rsiLevelMedianD1 < rsiLevelMedianShifted2D1)) && (rsiLevelMedianResultD1 == SellDecision)) ||
				(((rsiLevelMedianD1 > rsiLevelMedianShiftedD1) || (rsiLevelMedianD1 > rsiLevelMedianShifted2D1)) && (rsiLevelMedianResultD1 == BuyDecision)))
				rsiLevelMedianResultD1 = rsiLevelMedianResultD1 * 2;
			
			if((((rsiLevelCloseW1 < rsiLevelCloseShiftedW1) || (rsiLevelCloseW1 < rsiLevelCloseShifted2W1)) && (rsiLevelCloseResultW1 == SellDecision)) ||
				(((rsiLevelCloseW1 > rsiLevelCloseShiftedW1) || (rsiLevelCloseW1 > rsiLevelCloseShifted2W1)) && (rsiLevelCloseResultW1 == BuyDecision)))
				rsiLevelCloseResultW1 = rsiLevelCloseResultW1 * 2;
			
			if((((rsiLevelMedianW1 < rsiLevelMedianShiftedW1) || (rsiLevelMedianW1 < rsiLevelMedianShifted2W1)) && (rsiLevelMedianResultW1 == SellDecision)) ||
				(((rsiLevelMedianW1 > rsiLevelMedianShiftedW1) || (rsiLevelMedianW1 > rsiLevelMedianShifted2W1)) && (rsiLevelMedianResultW1 == BuyDecision)))
				rsiLevelMedianResultW1 = rsiLevelMedianResultW1 * 2;
			
			// max(rsiResult) = +/- 12.0
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
