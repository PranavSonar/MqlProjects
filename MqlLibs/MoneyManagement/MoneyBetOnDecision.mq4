//+------------------------------------------------------------------+
//|                                           MoneyBetOnDecision.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version"1.00"
#property strict

#include "BaseMoneyManagement.mq4"
#include "../DecisionMaking/BaseDecision.mq4"

class MoneyBetOnDecision : public BaseMoneyManagement
{
	protected:
		double MaxDecision;
		double CurrentDecision;
		int NumberOfBots;
	
	public:
		MoneyBetOnDecision(double maxDecision = 0.0, double currentDecision = 0.0, int numberOfBots = 0)
		{
			this.MaxDecision = maxDecision;
			this.CurrentDecision = currentDecision;
			
			if(numberOfBots != 0)
				this.NumberOfBots = numberOfBots;
			else
				this.AutoDetectNumberOfBots();
		}
		
		virtual void SetCurrentDecision(double currentDecision) { this.CurrentDecision = currentDecision; }
		virtual void SetMaxDecision(double maxDecision) { this.MaxDecision = maxDecision; }
		
		virtual double GetPriceBasedOnDecision()
		{
			double onePip = (Point()*10.0);
			return onePip * pow(2.0, this.CurrentDecision/this.MaxDecision) / NumberOfBots; // to do: check & fix
		}
};