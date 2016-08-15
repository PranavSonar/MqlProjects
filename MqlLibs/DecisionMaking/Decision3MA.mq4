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
	private:
		double maLevelCloseH1, maLevelMedianH1,
			maLevelCloseD1, maLevelMedianD1,
			maLevelCloseW1, maLevelMedianW1;
		
		double maLevelCloseShiftedH1, maLevelMedianShiftedH1,
			maLevelCloseShiftedD1, maLevelMedianShiftedD1,
			maLevelCloseShiftedW1, maLevelMedianShiftedW1;
		
	public:
		Decision3MA(bool verbose = false, int shiftValue = 1, int internalShift = 0) : DecisionIndicator(verbose, shiftValue, internalShift) {}
		
		virtual double GetCloseH1()  { return maLevelCloseH1;  }
		virtual double GetMedianH1() { return maLevelMedianH1; }
		virtual double GetCloseD1()  { return maLevelCloseD1;  }
		virtual double GetMedianD1() { return maLevelMedianD1; }
		virtual double GetCloseW1()  { return maLevelCloseW1;  }
		virtual double GetMedianW1() { return maLevelMedianW1; }
		
		virtual double GetCloseShiftedH1()  { return maLevelCloseShiftedH1;  }
		virtual double GetMedianShiftedH1() { return maLevelMedianShiftedH1; }
		virtual double GetCloseShiftedD1()  { return maLevelCloseShiftedD1;  }
		virtual double GetMedianShiftedD1() { return maLevelMedianShiftedD1; }
		virtual double GetCloseShiftedW1()  { return maLevelCloseShiftedW1;  }
		virtual double GetMedianShiftedW1() { return maLevelMedianShiftedW1; }
		
		
		virtual void SetIndicatorData(
			double &Buffer_CloseShiftedH1[], double &Buffer_MedianShiftedH1[],
			double &Buffer_CloseShiftedD1[], double &Buffer_MedianShiftedD1[],
			double &Buffer_CloseShiftedW1[], double &Buffer_MedianShiftedW1[],
			int index)
		{ Buffer_CloseShiftedH1[index] = maLevelCloseShiftedH1; Buffer_MedianShiftedH1[index] = maLevelMedianShiftedH1;
			Buffer_CloseShiftedD1[index] = maLevelCloseShiftedD1; Buffer_MedianShiftedD1[index] = maLevelMedianShiftedD1;
			Buffer_CloseShiftedW1[index] = maLevelCloseShiftedW1; Buffer_MedianShiftedW1[index] = maLevelMedianShiftedW1; }
		
		virtual void SetIndicatorShiftedData(
			double &Buffer_CloseH1[], double &Buffer_MedianH1[],
			double &Buffer_CloseD1[], double &Buffer_MedianD1[],
			double &Buffer_CloseW1[], double &Buffer_MedianW1[],
			int index)
		{ Buffer_CloseH1[index] = maLevelCloseH1; Buffer_MedianH1[index] = maLevelMedianH1;
			Buffer_CloseD1[index] = maLevelCloseD1; Buffer_MedianD1[index] = maLevelMedianD1;
			Buffer_CloseW1[index] = maLevelCloseW1; Buffer_MedianW1[index] = maLevelMedianW1; }
		
		
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
			maLevelCloseH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			maLevelMedianH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift)
			) / 4.0;
			maLevelCloseShiftedH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_CLOSE, internalShift + ShiftValue)
			) / 4.0;
			maLevelMedianShiftedH1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_H1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift + ShiftValue)
			) / 4.0;
			
			if((maLevelCloseH1 == 0.0) || (maLevelMedianH1 == 0.0) || (maLevelCloseShiftedH1 == 0.0) || (maLevelMedianShiftedH1 == 0.0))
				return IncertitudeDecision;
			
			// D1 (medium)
			maLevelCloseD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			maLevelMedianD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift)
			) / 4.0;
			maLevelCloseShiftedD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			maLevelMedianShiftedD1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_D1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift + ShiftValue)
			) / 4.0;
			
			if((maLevelCloseD1 == 0.0) || (maLevelMedianD1 == 0.0) || (maLevelCloseShiftedD1 == 0.0) || (maLevelMedianShiftedD1 == 0.0))
				return IncertitudeDecision;
			
			// W1 (slow)
			maLevelCloseW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			maLevelMedianW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift)
			) / 4.0;
			maLevelCloseShiftedW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_CLOSE, internalShift + ShiftValue)
			) / 4.0;
			maLevelMedianShiftedW1 = (
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_EMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_LWMA, PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, PERIOD_W1, 0, MODE_SMMA, PRICE_MEDIAN, internalShift + ShiftValue)
			) / 4.0;
			
			//if((maLevelCloseW1 == 0.0) || (maLevelMedianW1 == 0.0) || (maLevelCloseShiftedW1 == 0.0) || (maLevelMedianShiftedW1 == 0.0))
			//	return IncertitudeDecision;
			
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
				if((GetVerboseLevel() > 1) || (maResult != 0.0))
				{
					string text = StringFormat("MA Level Decision: [%s(%.0f)] [ ", maResult > 0.0 ? "buy" : "sell", maResult);
					text += StringFormatNumberNotZero("H1[c]: %.0f ", maLevelCloseResultH1);
					text += StringFormatNumberNotZero("H1[m]: %.0f ", maLevelMedianResultH1);
					text += StringFormatNumberNotZero("D1[c]: %.0f ", maLevelCloseResultD1);
					text += StringFormatNumberNotZero("D1[m]: %.0f ", maLevelMedianResultD1);
					text += StringFormatNumberNotZero("W1[c]: %.0f ", maLevelCloseResultW1);
					text += StringFormatNumberNotZero("W1[m]: %.0f ", maLevelMedianResultW1);
					text += StringFormat("]: [close=%f median=%f]", closeLevel, medianLevel);
					Print(text);
					
					text = "MA Level Data: ";
					text += ReturnStringOnNumberNotZero(StringFormat("H1[c,cs]: %f %f ", maLevelCloseH1, maLevelCloseShiftedH1), maLevelCloseResultH1);
					text += ReturnStringOnNumberNotZero(StringFormat("H1[m,ms]: %f %f ", maLevelMedianH1, maLevelMedianShiftedH1), maLevelMedianResultH1);
					text += ReturnStringOnNumberNotZero(StringFormat("D1[c,cs]: %f %f ", maLevelCloseD1, maLevelCloseShiftedD1), maLevelCloseResultD1);
					text += ReturnStringOnNumberNotZero(StringFormat("D1[m,ms]: %f %f ", maLevelMedianD1, maLevelMedianShiftedD1), maLevelMedianResultD1);
					text += ReturnStringOnNumberNotZero(StringFormat("W1[c,cs]: %f %f ", maLevelCloseW1, maLevelCloseShiftedW1), maLevelCloseResultW1);
					text += ReturnStringOnNumberNotZero(StringFormat("W1[m,ms]: %f %f ", maLevelMedianW1, maLevelMedianShiftedW1), maLevelMedianResultW1);
					Print(text);
					
					text = "Other info: ";
					text += ReturnStringOnCondition("simple buy decision: (value is not invalid) && (maLevel < close/median < maLevelShifted)", maResult > 0.0);
					text += ReturnStringOnCondition("simple sell decision: (value is not invalid) && (maLevel > close/median > maLevelShifted)", maResult < 0.0);
					Print(text);
					
					if(MathAbs(maResult) > 1.0)
					{
						text = "Other info: ";
						text += ReturnStringOnCondition("complex buy decision: (value is not invalid) && (maFasterLevel > maFasterLevelShifted) && (maFasterLevel > maSlowerLevel) && (maFasterLevel crossed maSlowerLevel)", maResult > 1.0);
						text += ReturnStringOnCondition("complex sell decision: (value is not invalid) && (maFasterLevel < maFasterLevelShifted) && (maFasterLevel < maSlowerLevel) && (maFasterLevel crossed maSlowerLevel)", maResult < 1.0);
						Print(text);
					}
				}
			}
			
			return maResult;
		}
};