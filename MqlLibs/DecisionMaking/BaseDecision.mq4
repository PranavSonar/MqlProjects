//+------------------------------------------------------------------+
//|                                                 BaseDecision.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../BaseLibs/BaseObject.mq4"

const double BuyDecision = 1.0;
const double IncertitudeDecision = 0.0;
const double SellDecision = -1.0;

class BaseDecision : public BaseObject
{
	public:
		BaseDecision(int verbose = 0) : BaseObject(verbose) {}
		~BaseDecision() {}
	
		virtual double GetDecision() { return IncertitudeDecision; }
};
