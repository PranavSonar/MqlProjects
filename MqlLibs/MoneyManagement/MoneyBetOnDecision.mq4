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
		MoneyBetOnDecision()
		{
			MoneyBetOnDecision(IncertitudeDecision, IncertitudeDecision);
		}
		
		MoneyBetOnDecision(int maxDecision, int currentDecision)
		{
			this.MaxDecision = maxDecision;
			this.CurrentDecision = currentDecision;
		}
		
		MoneyBetOnDecision(int maxDecision, int currentDecision, int numberOfBots)
		{
			MoneyBetOnDecision(maxDecision, currentDecision);
			this.NumberOfBots = numberOfBots;
		}
		
		void ChangeCurrentDecision(int currentDecision)
		{
			this.CurrentDecision = currentDecision;
		}
		
		void ChangeMaxDecision(int maxDecision)
		{
			this.MaxDecision = maxDecision;
		}
		
		
};