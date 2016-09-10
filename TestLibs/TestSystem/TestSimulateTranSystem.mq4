//+------------------------------------------------------------------+
//|                                       TestSimulateTranSystem.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Simulation\SimulateTranSystem.mqh>

static SimulateTranSystem system(DECISION_TYPE_ALL, MONEY_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	int len = SymbolsTotal(false);
	
	for(int i=0;i<len;i++)
	{
		string symbolName = SymbolName(i,false);
		system.SetupTransactionSystem(symbolName,0);
		system.TestEachTransactionSystem();
	}
	
	return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
	
}

void OnTick()
{
	
}
