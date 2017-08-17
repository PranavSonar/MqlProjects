//+------------------------------------------------------------------+
//|                                                SystemWrapper.mqh |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.45"
#property strict

#include "SystemCommands.mqh"
#include <MyMql\System\SimulateTranSystem.mqh>
#include <MyMql\Global\Global.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>

static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);
static GlobalVariableCommunication comm(false, false);

class SystemWrapper
{
	public:
		
		SystemWrapper(
			ENUM_DECISION_TYPE allowedDecisionsConfig = DECISION_TYPE_NONE,
			ENUM_LOT_MANAGEMENT_TYPE allowedMoneyManagementConfig = LOT_MANAGEMENT_NONE,
			ENUM_TRANSACTION_MANAGEMENT_TYPE allowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_NONE)
		{
			system.Initialize(allowedDecisionsConfig, allowedMoneyManagementConfig, allowedTransactionManagementConfig);
			Initialize();
		}
		
		void Initialize(
			bool useDiscoverySystem = false,
			bool useLightSystem = false,
			bool useFullSystem = false,
			bool startSimulationAgain = false,
			bool keepAllObjects = true,
			bool useEA = false,
			bool makeOnlyOneOrder = false,
			bool useManualDecisionEA = true,
			string decisionEA = typename(DecisionDoubleBB),
			string lotManagementEA = typename(BaseLotManagement),
			string transactionManagementEA = typename(BaseTransactionManagement),
			bool isInverseDecisionEA = false,
			bool onlyCurrentSymbol = true,
			bool useKeyBoardChangeChart = false,
			bool useIndicatorChangeChart = true,
			bool useOnlyFirstDecisionAndConfirmItWithOtherDecisions = false
		)
		{
			// Config System
			GlobalContext.Config.SetBoolValue("UseDiscoverySystem", useDiscoverySystem);
			GlobalContext.Config.SetBoolValue("UseLightSystem", useLightSystem);
			GlobalContext.Config.SetBoolValue("UseFullSystem", useFullSystem);
			
			GlobalContext.Config.SetBoolValue("StartSimulationAgain", startSimulationAgain);
			GlobalContext.Config.SetBoolValue("KeepAllObjects", keepAllObjects);
			
			
			// Config EA
			GlobalContext.Config.SetBoolValue("UseEA", useEA);
			GlobalContext.Config.SetBoolValue("MakeOnlyOneOrder", makeOnlyOneOrder);
			GlobalContext.Config.SetBoolValue("UseManualDecisionEA", useManualDecisionEA);
			
			GlobalContext.Config.SetValue("DecisionEA", decisionEA);
			GlobalContext.Config.SetValue("LotManagementEA", lotManagementEA);
			GlobalContext.Config.SetValue("TransactionManagementEA", transactionManagementEA);
			
			GlobalContext.Config.SetBoolValue("IsInverseDecisionEA", isInverseDecisionEA);
			
			// Generic - used both for System & EA
			GlobalContext.Config.SetBoolValue("OnlyCurrentSymbol", onlyCurrentSymbol);
			
			GlobalContext.Config.SetBoolValue("UseKeyBoardChangeChart", useKeyBoardChangeChart);
			GlobalContext.Config.SetBoolValue("UseIndicatorChangeChart", useIndicatorChangeChart);
			
			GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", useOnlyFirstDecisionAndConfirmItWithOtherDecisions);
		}
		
		int OnInitWrapper()
		{
			ResetLastError();
			RefreshRates();
			ChartRedraw();
			comm.Initialize(false, true); // init timers too
			
			if(GlobalContext.Config.GetBoolValue("UseEA"))
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
				
				if(GlobalContext.Config.GetBoolValue("UseManualDecisionEA"))
				{
					system.AddChartTransactionData(
					   _Symbol,
					   PERIOD_CURRENT,
					   GlobalContext.Config.GetValue("DecisionEA"),
					   GlobalContext.Config.GetValue("LotManagementEA"),
					   GlobalContext.Config.GetValue("TransactionManagementEA"),
					   GlobalContext.Config.GetBoolValue("IsInverseDecisionEA"));
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
								
								if((GlobalContext.Config.GetBoolValue("UseIndicatorChangeChart")) && (GlobalVariableCheck(GetGlobalVariableSymbol())))
									GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
								else
									GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, GlobalContext.Config.GetBoolValue("UseKeyBoardChangeChart"));
								
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
			
			if(!GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol"))
			{
				if(!StringIsNullOrEmpty(CurrentSymbol) && (_Symbol != CurrentSymbol))
				{
					Sleep(10);
					if((GlobalContext.Config.GetBoolValue("UseIndicatorChangeChart")) && (GlobalVariableCheck(GetGlobalVariableSymbol())))
						GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
					else
						GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, GlobalContext.Config.GetBoolValue("UseKeyBoardChangeChart"));
					Sleep(10);
					return INIT_SUCCEEDED;
				}
			}
			
			if(FirstSymbol == NULL)
			{
				GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
				GlobalContext.DatabaseLog.Initialize(true);
				
				string lastSymbol = NULL, currentSymbol = NULL;
				
				if(GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol"))
					currentSymbol = lastSymbol = _Symbol;
				else
				{
					lastSymbol = system.GetLastSymbol();
					currentSymbol = GlobalContext.Config.GetNextSymbol(lastSymbol);
				}
				
				if(StringIsNullOrEmpty(lastSymbol) || (StringIsNullOrEmpty(currentSymbol) && GlobalContext.Config.GetBoolValue("StartSimulationAgain")))
				{
					if(GlobalContext.Config.GetBoolValue("UseFullSystem"))
					{
						GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
						GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
						Print(GlobalContext.Config.GetConfigFile());
					}
					
					if(GlobalContext.Config.GetBoolValue("UseLightSystem") || GlobalContext.Config.GetBoolValue("UseFullSystem"))
						system.SetupTransactionSystem();
				}
				else if(!StringIsNullOrEmpty(currentSymbol))
				{
					if(GlobalContext.Config.GetBoolValue("UseLightSystem") || GlobalContext.Config.GetBoolValue("UseFullSystem"))
						system.SetupTransactionSystem();
					GlobalContext.Config.InitCurrentSymbol(currentSymbol);
					
					if(!GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol"))
					{
						if((GlobalContext.Config.GetBoolValue("UseIndicatorChangeChart")) && (GlobalVariableCheck(GetGlobalVariableSymbol())))
							GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
						else
							GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, GlobalContext.Config.GetBoolValue("UseKeyBoardChangeChart"));
					}
					
					if(!GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol"))
						return (INIT_SUCCEEDED);
				}
				else
					return (INIT_SUCCEEDED);
			}
			
			if(GlobalContext.Config.GetBoolValue("UseDiscoverySystem"))
				system.SystemDiscovery();
			else
				system.TestTransactionSystemForCurrentSymbol(true, true, GlobalContext.Config.GetBoolValue("UseLightSystem"), GlobalContext.Config.GetBoolValue("KeepAllObjects"));
			
			if(!GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol"))
				GlobalContext.Config.InitCurrentSymbol(GlobalContext.Config.GetNextSymbol(CurrentSymbol));
			
			if((!GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol")) && (!StringIsNullOrEmpty(CurrentSymbol)))
			{
				if((GlobalContext.Config.GetBoolValue("UseIndicatorChangeChart")) && (GlobalVariableCheck(GetGlobalVariableSymbol())))
					GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
				else
					GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, GlobalContext.Config.GetBoolValue("UseKeyBoardChangeChart"));
			}
			else
			{
				if(GlobalContext.Config.GetBoolValue("UseFullSystem"))
				{
					GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
					GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
				}
				
				if(GlobalContext.Config.GetBoolValue("UseDiscoverySystem"))
					Print("Discovery finished! Job done!");
				else if(GlobalContext.Config.GetBoolValue("UseLightSystem") || GlobalContext.Config.GetBoolValue("UseFullSystem"))
					Print("Simulation finished! Job done!");
				
				GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
				GlobalContext.DatabaseLog.CallWebServiceProcedure("GetResults");
				Print("GetResults execution finished (or at least the WS call)! Job done!");
				
				if(GlobalContext.Config.GetBoolValue("UseDiscoverySystem"))
				{
					//system.SystemDiscoveryPrintData();
					//Print("--=-=-=-=-==================================================================================");
					system.SystemDiscoveryDeleteWorseThanAverage();
					Print("--=-=-=-=-==================================================================================");
					system.SystemDiscoveryPrintData();
				}
				else if(GlobalContext.Config.GetBoolValue("UseLightSystem") || GlobalContext.Config.GetBoolValue("UseFullSystem"))
					system.FreeArrays();
				
				//Print("Closing [ExpertRemove]!"); ExpertRemove();
			}
			
			//EventSetTimer(4);
			return (INIT_SUCCEEDED);
		}
	
		void OnTickWrapper()
		{
			if(GlobalContext.Config.GetBoolValue("UseEA"))
			{
				if(GlobalContext.Config.IsNewBar())
					RefreshRates();
				if(GlobalContext.ChartIsChanging)
					return;
				
				system.RunTransactionSystemForCurrentSymbol(true);
			}
		}
		
		void OnTimerWrapper()
		{
			string s = comm.OnTimerGetWord();
			if(!StringIsNullOrEmpty(s))
			{
				Print(s); // to do: execute received command
				comm.RemoveFirstWord();
			}
		}
		
		void OnDeinitWrapper(const int reason)
		{
			// Bulk debug anyway
			GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
			system.PrintDeInitReason(reason);
			
			if(!GlobalContext.Config.GetBoolValue("UseDiscoverySystem"))
			{
				system.CleanTranData();
				system.RemoveUnusedDecisionsTransactionsAndLots();
			}
			
			comm.CleanBuffers();
			comm.RemoveTimers();
			
			if(!GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol"))
			{
				if((_Symbol != CurrentSymbol) && (!StringIsNullOrEmpty(CurrentSymbol)))
				{
					if((GlobalContext.Config.GetBoolValue("UseIndicatorChangeChart")) && (GlobalVariableCheck(GetGlobalVariableSymbol())))
						GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
					else
						GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, GlobalContext.Config.GetBoolValue("UseKeyBoardChangeChart"));
				}
			}
		}
};