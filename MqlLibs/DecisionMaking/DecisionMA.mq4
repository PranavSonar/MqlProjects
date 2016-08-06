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

class DecisionMA : public DecisionIndicator
{
	public:
		DecisionMA() : DecisionIndicator(false) {}
		DecisionMA(bool verbose) : DecisionIndicator(verbose) {}
		DecisionMA(bool verbose, int shift) : DecisionIndicator(verbose, shift) {}
		
		double GetDecision()
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
			
			if(Verbose)
			{
				printf("MA Level Decision [%f]: [close=%f median=%f]  H1: %f %f %f %f D1: %f %f %f %f W1: %f %f %f %f\n",
					maResult, closeLevel, medianLevel,
					maLevelCloseH1, maLevelCloseShiftedH1, maLevelMedianH1, maLevelMedianShiftedH1,
					maLevelCloseD1, maLevelCloseShiftedD1, maLevelMedianD1, maLevelMedianShiftedD1,
					maLevelCloseW1, maLevelCloseShiftedW1, maLevelMedianW1, maLevelMedianShiftedW1
				);
			}
			
			return maResult;
		}
};