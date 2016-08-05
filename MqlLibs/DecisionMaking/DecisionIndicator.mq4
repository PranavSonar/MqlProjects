//+------------------------------------------------------------------+
//|                                            DecisionIndicator.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "BaseDecision.mq4"


const double InvalidValue = 0.0;

class DecisionIndicator : BaseDecision
{
	protected:
		bool Verbose;
		int ShiftValue;
		
	public:
		DecisionIndicator(bool verbose = true, int shiftValue = 1)
		{
			this.Verbose = verbose;
			this.ShiftValue = shiftValue;
		}
	
		~DecisionIndicator() {}
};
