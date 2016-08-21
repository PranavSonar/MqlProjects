//+------------------------------------------------------------------+
//|                                           MoneyBetOnDecision.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
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
				this.NumberOfBots = this.AutoDetectNumberOfBots();
		}
		
		virtual void SetCurrentDecision(double currentDecision) { this.CurrentDecision = currentDecision; }
		virtual void SetMaxDecision(double maxDecision) { this.MaxDecision = maxDecision; }
		
		virtual double GetPriceBasedOnDecision(double currentDecision = 0)
		{
			if(currentDecision != 0.0)
				this.CurrentDecision = currentDecision;
			if(this.MaxDecision == 0.0)
				this.MaxDecision = 1.0;
			if(this.NumberOfBots == 0.0)
				this.NumberOfBots = 1.0;
			
			double onePip = (Point()*10.0);
			double priceForQuoteCurrency = CalculatePrice(false); // on market closed this price is zero
			double priceBasedOnCurrentDecision = CalculatePrice(currentDecision); // on incertitude this price is zero
			double multiplicationPowerOfTwo = pow(2.0, this.CurrentDecision/this.MaxDecision) / this.NumberOfBots;
			return priceForQuoteCurrency * priceBasedOnCurrentDecision * onePip * multiplicationPowerOfTwo; // to do: check & fix
		}
};