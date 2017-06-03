//+------------------------------------------------------------------+
//|                                          TestDiscoverySystem.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property strict

#include <MyMql\System\SimulateTranSystem.mqh>
#include <MyMql\Global\Global.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>

//#property indicator_chart_window

extern bool UseDiscoverySystem = false;
extern bool UseLightSystem = true;
extern bool UseFullSystem = false;


extern bool UseKeyBoardChangeChart = false;
extern bool UseIndicatorChangeChart = true;
extern bool StartSimulationAgain = false;
extern bool UseOnlyFirstDecisionAndConfirmItWithOtherDecisions = false;

static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);
const string GlobalVariableNameConst = "GlobalVariableSymbol";

int OnInit() // start()
{
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);
	
	ResetLastError();
	RefreshRates();
	ChartRedraw();
	
	if(!StringIsNullOrEmpty(CurrentSymbol) && (_Symbol != CurrentSymbol))
	{
		Sleep(20);
		if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableNameConst)))
			GlobalVariableSet(GlobalVariableNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
		else
			GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
		Sleep(20);
		return INIT_SUCCEEDED;
	}
	
	if(FirstSymbol == NULL)
	{
		GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
		
		GlobalContext.DatabaseLog.Initialize(true);
		string lastSymbol = system.GetLastSymbol();
		string currentSymbol = GlobalContext.Config.GetNextSymbol(lastSymbol);
		
		if(StringIsNullOrEmpty(lastSymbol) || (StringIsNullOrEmpty(currentSymbol) && StartSimulationAgain))
		{
			GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
			GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
			Print(GlobalContext.Config.GetConfigFile());
			
			if(UseLightSystem || UseFullSystem)
				system.SetupTransactionSystem(); //_Symbol);
		}
		else if(!StringIsNullOrEmpty(currentSymbol))
		{
			if(UseLightSystem || UseFullSystem)
				system.SetupTransactionSystem();
			GlobalContext.Config.InitCurrentSymbol(currentSymbol);
			
			if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableNameConst)))
				GlobalVariableSet(GlobalVariableNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
			else
				GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);

			return (INIT_SUCCEEDED);
		}
		else
			return (INIT_SUCCEEDED);
	}
	
	if(UseDiscoverySystem)
		system.SystemDiscovery();
	else
		system.TestTransactionSystemForCurrentSymbol(true, true, UseLightSystem);
	
	bool symbolChanged = false;
	GlobalContext.Config.InitCurrentSymbol(GlobalContext.Config.GetNextSymbol(CurrentSymbol));
	
	if(!StringIsNullOrEmpty(CurrentSymbol))
	{
		if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableNameConst)))
			GlobalVariableSet(GlobalVariableNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
		else
			symbolChanged = GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
	}
	else
	{
		GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
		GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
		
		if(UseDiscoverySystem)
			Print("Discovery finished! Job done!");
		else if(UseLightSystem || UseFullSystem)
			Print("Simulation finished! Job done!");
		
		GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
		GlobalContext.DatabaseLog.CallWebServiceProcedure("GetResults");
		Print("GetResults execution finished (or at least the WS call)! Job done!");
		
		if(UseLightSystem || UseFullSystem)
			system.FreeArrays();
		
		if(UseDiscoverySystem)
		{
			system.SystemDiscoveryPrintData();
			Print("--=-=-=-=-==================================================================================");
			system.SystemDiscoveryDeleteWorseThanAverage();
			Print("--=-=-=-=-==================================================================================");
			system.SystemDiscoveryPrintData();
		}
		
		Print("Closing expert!");
		ExpertRemove();
	}
	
	//EventSetTimer(4);
	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	system.PrintDeInitReason(reason);
	
	if(!UseDiscoverySystem)
	{
		system.CleanTranData();
		system.RemoveUnusedDecisionsTransactionsAndLots();
	}
	
	if((_Symbol != CurrentSymbol) && (!StringIsNullOrEmpty(CurrentSymbol)))
	{
		if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableNameConst)))
			GlobalVariableSet(GlobalVariableNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
		else
			GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
	}
}
