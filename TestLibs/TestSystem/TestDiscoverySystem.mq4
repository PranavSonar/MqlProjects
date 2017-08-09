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



// Config System
extern bool UseDiscoverySystem = false;
extern bool UseLightSystem = true;
extern bool UseFullSystem = false;

extern bool StartSimulationAgain = false;
extern bool KeepAllObjects = true;



// Config EA
extern bool UseEA = false;
extern bool MakeOnlyOneOrder = false;

extern bool UseManualDecisionEA = true;
extern string DecisionEA = typename(DecisionDoubleBB);
extern string LotManagementEA = typename(BaseLotManagement);
extern string TransactionManagementEA = typename(BaseTransactionManagement);
extern bool IsInverseDecisionEA = false;



// Generic - used both for System & EA
extern bool OnlyCurrentSymbol = true;

extern bool UseKeyBoardChangeChart = false;
extern bool UseIndicatorChangeChart = true;

extern bool UseOnlyFirstDecisionAndConfirmItWithOtherDecisions = false;


static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);
	
	ResetLastError();
	RefreshRates();
	ChartRedraw();
	
	if(UseEA)
	{
		GlobalContext.Config.AllowTrades();
	
		bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
		if(!isTradeAllowedOnEA)
		{
			Print(__FUNCTION__ + ": Trade is not allowed on EA for symbol " + _Symbol);
			return (INIT_FAILED);
		}
		
		// Add manual config only at the beginning:
		system.CleanTranData();
		
		if(UseManualDecisionEA)
		{
			system.AddChartTransactionData(
			   _Symbol,
			   PERIOD_CURRENT,
			   DecisionEA,
			   LotManagementEA,
			   TransactionManagementEA,
			   IsInverseDecisionEA);
		}
		else // Use Automatic Decision EA - needs Database simulation data + run GetResults, WS call, etc
		{
			XmlElement *element = new XmlElement();
			
			bool isTransactionAllowedOnChartTransactionData = false;
			int orderNo = 1;
			
			while(!isTransactionAllowedOnChartTransactionData)
			{
				GlobalContext.DatabaseLog.ParametersSet(IntegerToString(orderNo)); // OrderNo
				GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadResult");
				
				element.Clear();
				element.ParseXml(GlobalContext.DatabaseLog.Result);
				
				if((element.GetTagType() == TagType_InvalidTag) ||
				(element.GetTagType() == TagType_CleanTag))
					break;
				
				if(element.GetChildByElementName("USP_ReadResult_Result") == NULL)//GlobalContext.DatabaseLog.Result == "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<string xmlns=\"http://tempuri.org/\" />")
				{
					Print("MaxOrderNo" + IntegerToString(orderNo));
					break;
				}
				
				string symbol = element.GetChildTagDataByParentElementName("Symbol");
				int maxOrderNo = (int) StringToInteger(element.GetChildTagDataByParentElementName("MaxOrderNo"));
				BaseLotManagement lots;
		      if(lots.IsMarginOk(symbol, MarketInfo(_Symbol, MODE_MINLOT), 0.4f, true) && GlobalContext.Config.IsTradeAllowedOnEA(symbol))
				{
					system.CleanTranData();
					system.AddChartTransactionData(element);
					system.InitializeFromFirstChartTranData();
					system.SetupTransactionSystem();
					CurrentSymbol = symbol;
					
					if(CurrentSymbol != _Symbol)
					{
						Print(__FUNCTION__ + " Symbol should change from " + _Symbol + " to " + CurrentSymbol);
						
						if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
							GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
						else
							GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
						
						GlobalContext.ChartIsChanging = true;
					}
					return 0;
				}
				
				orderNo++;
				if((orderNo > maxOrderNo) && (maxOrderNo != 0))
					break;
			}
			delete element;
		}
		
		system.LoadCurrentOrdersToAllTransactionTypes();
		
		BaseLotManagement lots;
		if(lots.IsMarginOk(_Symbol, MarketInfo(_Symbol, MODE_MINLOT), 0.4f, true))
		{
			system.InitializeFromFirstChartTranData(true);
			system.PrintFirstChartTranData();
			system.SetupTransactionSystem();
			
			system.RunTransactionSystemForCurrentSymbol(true);
		}
		else
		{
			Print(__FUNCTION__ + " margin is not ok for symbol " + _Symbol);
			return (INIT_FAILED);
		}
	}
	
	if(!OnlyCurrentSymbol)
	{
		if(!StringIsNullOrEmpty(CurrentSymbol) && (_Symbol != CurrentSymbol))
		{
			Sleep(10);
			if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
				GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
			else
				GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
			Sleep(10);
			return INIT_SUCCEEDED;
		}
	}
	
	if(FirstSymbol == NULL)
	{
		GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
		GlobalContext.DatabaseLog.Initialize(true);
		
		string lastSymbol = NULL, currentSymbol = NULL;
		
		if(OnlyCurrentSymbol)
			currentSymbol = lastSymbol = _Symbol;
		else
		{
			lastSymbol = system.GetLastSymbol();
			currentSymbol = GlobalContext.Config.GetNextSymbol(lastSymbol);
		}
		
		if(StringIsNullOrEmpty(lastSymbol) || (StringIsNullOrEmpty(currentSymbol) && StartSimulationAgain))
		{
			if(UseFullSystem)
			{
				GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
				GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
				Print(GlobalContext.Config.GetConfigFile());
			}
			
			if(UseLightSystem || UseFullSystem)
				system.SetupTransactionSystem();
		}
		else if(!StringIsNullOrEmpty(currentSymbol))
		{
			if(UseLightSystem || UseFullSystem)
				system.SetupTransactionSystem();
			GlobalContext.Config.InitCurrentSymbol(currentSymbol);
			
			if(!OnlyCurrentSymbol)
			{
				if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
					GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
				else
					GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
			}
			
			if(!OnlyCurrentSymbol)
				return (INIT_SUCCEEDED);
		}
		else
			return (INIT_SUCCEEDED);
	}
	
	if(UseDiscoverySystem)
		system.SystemDiscovery();
	else
		system.TestTransactionSystemForCurrentSymbol(true, true, UseLightSystem, KeepAllObjects);
	
	if(!OnlyCurrentSymbol)
		GlobalContext.Config.InitCurrentSymbol(GlobalContext.Config.GetNextSymbol(CurrentSymbol));
	
	if((!OnlyCurrentSymbol) && (!StringIsNullOrEmpty(CurrentSymbol)))
	{
		if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
			GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
		else
			GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
	}
	else
	{
		if(UseFullSystem)
		{
			GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
			GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
		}
		
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
			//system.SystemDiscoveryPrintData();
			//Print("--=-=-=-=-==================================================================================");
			system.SystemDiscoveryDeleteWorseThanAverage();
			Print("--=-=-=-=-==================================================================================");
			system.SystemDiscoveryPrintData();
		}
		
		Print("Closing [ExpertRemove]!"); ExpertRemove();
	}
	
	//EventSetTimer(4);
	return (INIT_SUCCEEDED);
}

void OnTick()
{
	if(UseEA)
	{
		if(GlobalContext.Config.IsNewBar())
			RefreshRates();
		if(GlobalContext.ChartIsChanging)
			return;
		
		system.RunTransactionSystemForCurrentSymbol(true);
	}
}

void OnDeinit(const int reason)
{
	// Bulk debug anyway
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	system.PrintDeInitReason(reason);
	
	if(!UseDiscoverySystem)
	{
		system.CleanTranData();
		system.RemoveUnusedDecisionsTransactionsAndLots();
	}
	
	if(!OnlyCurrentSymbol)
	{
		if((_Symbol != CurrentSymbol) && (!StringIsNullOrEmpty(CurrentSymbol)))
		{
			if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
				GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
			else
				GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
		}
	}
}
