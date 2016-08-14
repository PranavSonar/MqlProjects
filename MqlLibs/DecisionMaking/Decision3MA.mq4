//+------------------------------------------------------------------+
//|                                                   DecisionMA.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "DecisionIndicator.mq4"

class Decision3MA : public DecisionIndicator
{
	public:
		Decision3MA(bool verbose = false, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verbose, shiftValue, internalShift) {}
		
		virtual double GetMaxDecision()
		{
			// max(maResult) = +/- 18.0 (Buy = +; Sell = -)
			// min(maResult) = 0.0 (Incertitude = 0)
			return 18.0;
		}
		
		virtual double GetDecision(int internalShift = 0)
		{
			if((internalShift == 0) && (GetShiftValue() != 0))
				internalShift = GetShiftValue();
			
			// Analysis based on Moving Average levels:
			double closeLevel = iClose(Symbol(), Period(), 0);
			double medianLevel = (
				iOpen(Symbol(), Period(), 0) +
				iClose(Symbol(), Period(), 0)
			) / 2.0;
			
			// H1 (fast)
			double maLevelCloseH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			double maLevelMedianH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift)
			) / 4.0;
			double maLevelCloseShiftedH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_CLOSE, internalShift + ShiftValue)
			) / 4.0;
			double maLevelMedianShiftedH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift + ShiftValue)
			) / 4.0;
			
			if((maLevelCloseH1 == 0.0) || (maLevelMedianH1 == 0.0) || (maLevelCloseShiftedH1 == 0.0) || (maLevelMedianShiftedH1 == 0.0))
				return IncertitudeDecision;
			
			// D1 (medium)
			double maLevelCloseD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			double maLevelMedianD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift)
			) / 4.0;
			double maLevelCloseShiftedD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			double maLevelMedianShiftedD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift + ShiftValue)
			) / 4.0;
			
			if((maLevelCloseD1 == 0.0) || (maLevelMedianD1 == 0.0) || (maLevelCloseShiftedD1 == 0.0) || (maLevelMedianShiftedD1 == 0.0))
				return IncertitudeDecision;
			
			// W1 (slow)
			double maLevelCloseW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			double maLevelMedianW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift)
			) / 4.0;
			double maLevelCloseShiftedW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_CLOSE, internalShift + ShiftValue)
			) / 4.0;
			double maLevelMedianShiftedW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift + ShiftValue)
			) / 4.0;
			
			if((maLevelCloseW1 == 0.0) || (maLevelMedianW1 == 0.0) || (maLevelCloseShiftedW1 == 0.0) || (maLevelMedianShiftedW1 == 0.0))
				return IncertitudeDecision;
			
			// partial results based on each MA level
			
			// buy:  value is not invalid && maLevel < close/median < maLevelShifted
			// sell: value is not invalid && maLevel > close/median > maLevelShifted
			double maLevelCloseResultH1 = 
				(((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 < closeLevel) && (closeLevel < maLevelCloseShiftedH1)) ? BuyDecision : IncertitudeDecision) + // H1 (fast)
				(((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 > closeLevel) && (closeLevel > maLevelCloseShiftedH1)) ? SellDecision : IncertitudeDecision);
			double maLevelMedianResultH1 = 
				(((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 < medianLevel) && (medianLevel < maLevelMedianShiftedH1)) ? BuyDecision : IncertitudeDecision) +
				(((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 > medianLevel) && (medianLevel > maLevelMedianShiftedH1)) ? SellDecision : IncertitudeDecision);
			double maLevelCloseResultD1 = 
				(((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 < closeLevel) && (closeLevel < maLevelCloseShiftedD1)) ? BuyDecision : IncertitudeDecision) + // D1 (medium)
				(((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 > closeLevel) && (closeLevel > maLevelCloseShiftedD1)) ? SellDecision : IncertitudeDecision);
			double maLevelMedianResultD1 =
				(((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 < medianLevel) && (medianLevel < maLevelMedianShiftedD1)) ? BuyDecision : IncertitudeDecision) +
				(((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 > medianLevel) && (medianLevel > maLevelMedianShiftedD1)) ? SellDecision : IncertitudeDecision);
			double maLevelCloseResultW1 =
				(((maLevelCloseW1 != InvalidValue) && (maLevelCloseW1 < closeLevel) && (closeLevel < maLevelCloseShiftedW1)) ? BuyDecision : IncertitudeDecision) + // W1 (slow)
				(((maLevelCloseW1 != InvalidValue) && (maLevelCloseW1 > closeLevel) && (closeLevel > maLevelCloseShiftedW1)) ? SellDecision : IncertitudeDecision);
			double maLevelMedianResultW1 =
				(((maLevelMedianW1 != InvalidValue) && (maLevelMedianW1 < medianLevel) && (medianLevel < maLevelMedianShiftedW1)) ? BuyDecision : IncertitudeDecision) +
				(((maLevelMedianW1 != InvalidValue) && (maLevelMedianW1 > medianLevel) && (medianLevel > maLevelMedianShiftedW1)) ? SellDecision : IncertitudeDecision);
			
			// buy:  value is not invalid && maFasterLevel > maFasterLevelShifted && maFasterLevel > maSlowerLevel && maFasterLevel crossed maSlowerLevel (maFasterLevel between maSlowerLevel and maSlowerLevelShifted)
			// sell: value is not invalid && maFasterLevel < maFasterLevelShifted && maFasterLevel < maSlowerLevel && maFasterLevel crossed maSlowerLevel (maFasterLevel between maSlowerLevel and maSlowerLevelShifted)
			double maLevelCloseResultH1xD1 = (((maLevelCloseH1 != InvalidValue) && ((maLevelCloseH1 > maLevelCloseShiftedH1)) && (maLevelCloseH1 > maLevelCloseD1) && ((maLevelCloseD1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? BuyDecision : IncertitudeDecision)
				+ (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 < maLevelCloseShiftedH1) && (maLevelCloseH1 < maLevelCloseD1) && ((maLevelCloseD1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? SellDecision : IncertitudeDecision);
			double maLevelCloseResultH1xW1 = (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 > maLevelCloseShiftedH1) && (maLevelCloseH1 > maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? BuyDecision : IncertitudeDecision)
				+ (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 < maLevelCloseShiftedH1) && (maLevelCloseH1 < maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? SellDecision : IncertitudeDecision);
			double maLevelCloseResultD1xW1 = (((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 > maLevelCloseShiftedD1) && (maLevelCloseD1 > maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseD1) && (maLevelCloseD1 <= maLevelCloseShiftedD1))) ? BuyDecision : IncertitudeDecision)
				+ (((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 < maLevelCloseShiftedD1) && (maLevelCloseD1 < maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseD1) && (maLevelCloseD1 <= maLevelCloseShiftedD1))) ? SellDecision : IncertitudeDecision);
			
			double maLevelMedianResultH1xD1 = (((maLevelMedianH1 != InvalidValue) && ((maLevelMedianH1 > maLevelMedianShiftedH1)) && (maLevelMedianH1 > maLevelMedianD1) && ((maLevelMedianD1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? BuyDecision : IncertitudeDecision)
				+ (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 < maLevelMedianShiftedH1) && (maLevelMedianH1 < maLevelMedianD1) && ((maLevelMedianD1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? SellDecision : IncertitudeDecision);
			double maLevelMedianResultH1xW1 = (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 > maLevelMedianShiftedH1) && (maLevelMedianH1 > maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? BuyDecision : IncertitudeDecision)
				+ (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 < maLevelMedianShiftedH1) && (maLevelMedianH1 < maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? SellDecision : IncertitudeDecision);
			double maLevelMedianResultD1xW1 = (((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 > maLevelMedianShiftedD1) && (maLevelMedianD1 > maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianD1) && (maLevelMedianD1 <= maLevelMedianShiftedD1))) ? BuyDecision : IncertitudeDecision)
				+ (((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 < maLevelMedianShiftedD1) && (maLevelMedianD1 < maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianD1) && (maLevelMedianD1 <= maLevelMedianShiftedD1))) ? SellDecision : IncertitudeDecision);
			
			
			// max(maResult) = +/- 18.0 (Buy = +; Sell = -)
			// min(maResult) = 0.0 (Incertitude = 0)
			double maResult = 
				(maLevelCloseResultH1 + maLevelMedianResultH1 + maLevelCloseResultD1 + maLevelMedianResultD1 + maLevelCloseResultW1 + maLevelMedianResultW1) +
				2 * (maLevelCloseResultH1xD1 + maLevelCloseResultH1xW1 + maLevelCloseResultD1xW1 + maLevelMedianResultH1xD1 + maLevelMedianResultH1xW1 + maLevelMedianResultD1xW1);
			
			if(IsVerboseMode())
			{
				if(maResult != 0.0)
				{
					printf("MA Level Decision [%f H1[c]: %f H1[m]: %f D1[c]: %f D1[m]: %f W1[c]: %f W1[m]: %f]: [close=%f median=%f]",
						maResult, maLevelCloseResultH1, maLevelMedianResultH1, maLevelCloseResultD1, maLevelMedianResultD1, maLevelCloseResultW1, maLevelMedianResultW1, closeLevel, medianLevel
					);
				}
				
				printf("MA Level Data: H1: %f %f %f %f D1: %f %f %f %f W1: %f %f %f %f\n",
					maLevelCloseH1, maLevelCloseShiftedH1, maLevelMedianH1, maLevelMedianShiftedH1,
					maLevelCloseD1, maLevelCloseShiftedD1, maLevelMedianD1, maLevelMedianShiftedD1,
					maLevelCloseW1, maLevelCloseShiftedW1, maLevelMedianW1, maLevelMedianShiftedW1
				);
			}
			
			return maResult;
		}
};