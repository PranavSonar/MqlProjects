#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

#property description "First program made, used to check some MQL4 functions" 

#include "../MqlLibs/VerboseInfo/VerboseInfo.mq4"
#include "../MqlLibs/DecisionMaking/DecisionDoubleBB.mq4"
#include "../MqlLibs/DecisionMaking/DecisionMA.mq4"
#include "../MqlLibs/DecisionMaking/DecisionRSI.mq4"


VerboseInfo vi;

int OnInit()
{
	// Print (one time) information
	vi.ClientAndTerminalInfo();
	vi.BalanceAccountInfo();
	vi.PrintMarketInfo();
	
	// Validations
	if(!IsExpertEnabled())
	{
		Print("Expert is not enabled. Nothing to do here. Exiting.");
		return (INIT_FAILED);
	}
	
	if(!IsTradeAllowed())
	{
		Print("Trade is not allowed. Nothing to do here. Exiting.");
		return (INIT_FAILED);
	}
	
	//--- create timer 
	EventSetTimer(1);
   
	return (INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
}





double CalculateDecision(double stopLoss = 0.0, double takeProfit = 0.0)
{
	DecisionDoubleBB doubleBB;
	DecisionMA ma;
	DecisionRSI rsi;
	
	double finalResult = 
		rsi.GetDecision() +
		ma.GetDecision() +
		doubleBB.GetDecision(stopLoss, takeProfit);
	
	printf("Final decision: %f\n Stop loss: %f\n Take profit: %f",
		finalResult, stopLoss, takeProfit);
	return finalResult;
}

void OnTick()
{
	
}


void OnTimer()
{
	double SL = InvalidValue, TP = InvalidValue;
	double decision = CalculateDecision(SL, TP); // maximum possible value is +/-14.0
	
	if(MathAbs(decision) >= 7.0)
	{
		if(decision > 0.0)
		{
		}
		else {
		
		}
	}
}
