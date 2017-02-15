//+------------------------------------------------------------------+
//|                                       TestSimulateTranSystem.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property strict

#include <MyMql\System\SimulateTranSystem.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>

static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	//EventKillTimer();
	ResetLastError();
	
	if(FirstSymbol == NULL)
	{
		GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
		
		GlobalContext.DatabaseLog.Initialize(true);
		string lastSymbol = system.GetLastSymbol();
		
		if(StringIsNullOrEmpty(lastSymbol))
		{
			GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
			GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
			Print(GlobalContext.Config.GetConfigFile());
			
			system.SetupTransactionSystem(_Symbol);
		}
		else
		{
			GlobalContext.Config.ChangeSymbol(lastSymbol, PERIOD_CURRENT);
		
			system.SetupTransactionSystem(lastSymbol);
			return (INIT_SUCCEEDED);
		}
	}
	
	system.TestTransactionSystemForCurrentSymbol(true, true, false);
	
	if(!GlobalContext.Config.ChangeSymbol())
	{
		GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
		GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	}
	
	//EventSetTimer(4);
	return (INIT_SUCCEEDED);
}

//void OnTimer()
//{
//	string txt = "5 seconds elapsed; program stopped without changing chart; auto removing";
//	Print(txt);
//	Alert(txt);
//	ChartClose(); // auto remove
//}

void OnDeinit(const int reason)
{
	system.PrintDeInitReason(reason);
	system.CleanTranData();
	//system.RemoveUnusedDecisionsTransactionsAndLots();
	//EventKillTimer();
}
