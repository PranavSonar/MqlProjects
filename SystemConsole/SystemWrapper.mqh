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
	    ENUM_TRANSACTION_MANAGEMENT_TYPE allowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_NONE);

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
	    bool allowChangingSymbol = true,
	    bool useKeyBoardChangeChart = false,
	    bool useIndicatorChangeChart = true,
	    bool useOnlyFirstDecisionAndConfirmItWithOtherDecisions = false
	);

	int OnInitWrapper();
	void OnDeinitWrapper(const int reason);

	bool ChangeSymbol();

	void OnTickWrapper();
	void OnTimerWrapper();

	void ExecuteCommand(string command);
};


SystemWrapper::SystemWrapper(
    ENUM_DECISION_TYPE allowedDecisionsConfig = DECISION_TYPE_NONE,
    ENUM_LOT_MANAGEMENT_TYPE allowedMoneyManagementConfig = LOT_MANAGEMENT_NONE,
    ENUM_TRANSACTION_MANAGEMENT_TYPE allowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_NONE)
{
	system.Initialize(allowedDecisionsConfig, allowedMoneyManagementConfig, allowedTransactionManagementConfig);
	Initialize();
}

void SystemWrapper::Initialize(
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
    bool allowChangingSymbol = true,
    bool useKeyBoardChangeChart = false,
    bool useIndicatorChangeChart = true,
    bool useOnlyFirstDecisionAndConfirmItWithOtherDecisions = false
)
{
	// Config System
	GlobalContext.Config.SetBoolValueIfNotExists("UseDiscoverySystem", useDiscoverySystem);
	GlobalContext.Config.SetBoolValueIfNotExists("UseLightSystem", useLightSystem);
	GlobalContext.Config.SetBoolValueIfNotExists("UseFullSystem", useFullSystem);

	GlobalContext.Config.SetBoolValueIfNotExists("StartSimulationAgain", startSimulationAgain);
	GlobalContext.Config.SetBoolValueIfNotExists("KeepAllObjects", keepAllObjects);


	// Config EA
	GlobalContext.Config.SetBoolValueIfNotExists("UseEA", useEA);
	GlobalContext.Config.SetBoolValueIfNotExists("MakeOnlyOneOrder", makeOnlyOneOrder);
	GlobalContext.Config.SetBoolValueIfNotExists("UseManualDecisionEA", useManualDecisionEA);

	GlobalContext.Config.SetValueIfNotExists("DecisionEA", decisionEA);
	GlobalContext.Config.SetValueIfNotExists("LotManagementEA", lotManagementEA);
	GlobalContext.Config.SetValueIfNotExists("TransactionManagementEA", transactionManagementEA);

	GlobalContext.Config.SetBoolValueIfNotExists("IsInverseDecisionEA", isInverseDecisionEA);

	// Generic - used both for System & EA
	GlobalContext.Config.SetBoolValueIfNotExists("OnlyCurrentSymbol", onlyCurrentSymbol);
	GlobalContext.Config.SetBoolValueIfNotExists("AllowChangingSymbol", allowChangingSymbol);

	GlobalContext.Config.SetBoolValueIfNotExists("UseKeyBoardChangeChart", useKeyBoardChangeChart);
	GlobalContext.Config.SetBoolValueIfNotExists("UseIndicatorChangeChart", useIndicatorChangeChart);

	GlobalContext.Config.SetBoolValueIfNotExists("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", useOnlyFirstDecisionAndConfirmItWithOtherDecisions);
}

int SystemWrapper::OnInitWrapper()
{
	bool useLightSystem = GlobalContext.Config.GetBoolValue("UseLightSystem");
	bool useDiscoverySystem = GlobalContext.Config.GetBoolValue("UseDiscoverySystem");
	bool useFullSystem = GlobalContext.Config.GetBoolValue("UseFullSystem");
	bool onlyCurrentSymbol = GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol");
	bool useEA = GlobalContext.Config.GetBoolValue("UseEA");

	ResetLastError();
	RefreshRates();
	ChartRedraw();

	comm.Initialize(false, true); // init timers too

	if (GlobalContext.Config.Exists("ReturnToSymbol"))
	{
		Print("ReturnToSymbol");
		CurrentSymbol = GlobalContext.Config.GetValue("ReturnToSymbol");
		GlobalContext.Config.DeleteValue("ReturnToSymbol");

		FirstSymbol = NULL;

		if (ChangeSymbol())
			return INIT_SUCCEEDED;
	}

	if (useEA)
	{
		Print("UseEA");

		GlobalContext.Config.AllowTrades();

		bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
		if (!isTradeAllowedOnEA)
		{
			Print(__FUNCTION__ + ": Trade is not allowed on EA for symbol " + _Symbol);
			return (INIT_FAILED);
		}

		// Add manual config only at the beginning:
		system.CleanTranData();

		if (GlobalContext.Config.GetBoolValue("UseManualDecisionEA"))
		{
			Print("UseEA > UseManualDecisionEA");

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
			Print("UseEA > ReadResult");

			XmlElement *element = new XmlElement();

			bool isTransactionAllowedOnChartTransactionData = false;
			int orderNo = 1;

			while (!isTransactionAllowedOnChartTransactionData)
			{
				GlobalContext.DatabaseLog.ParametersSet(IntegerToString(orderNo)); // OrderNo
				GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadResult");

				element.Clear();
				element.ParseXml(GlobalContext.DatabaseLog.Result);

				if ((element.GetTagType() == TagType_InvalidTag) ||
				        (element.GetTagType() == TagType_CleanTag))
					break;

				if (element.GetChildByElementName("USP_ReadResult_Result") == NULL) //GlobalContext.DatabaseLog.Result == "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<string xmlns=\"http://tempuri.org/\" />")
				{
					Print(__FUNCTION__ + " MaxOrderNo: " + IntegerToString(orderNo));
					break;
				}

				string symbol = element.GetChildTagDataByParentElementName("Symbol");
				int maxOrderNo = (int) StringToInteger(element.GetChildTagDataByParentElementName("MaxOrderNo"));
				BaseLotManagement lots;

				if (lots.IsMarginOk(symbol, MarketInfo(_Symbol, MODE_MINLOT), 0.4f, true) && GlobalContext.Config.IsTradeAllowedOnEA(symbol))
				{
					system.CleanTranData();
					system.AddChartTransactionData(element);
					system.InitializeFromFirstChartTranData();
					system.SetupTransactionSystem();
					CurrentSymbol = symbol;

					ChangeSymbol();
					return INIT_SUCCEEDED;
				}

				orderNo++;
				if ((orderNo > maxOrderNo) && (maxOrderNo != 0))
					break;
			}

			delete element;
		}

		system.LoadCurrentOrdersToAllTransactionTypes();

		BaseLotManagement lots;
		if (lots.IsMarginOk(_Symbol, MarketInfo(_Symbol, MODE_MINLOT), 0.4f, true))
		{
			system.InitializeFromFirstChartTranData(true);
			system.PrintFirstChartTranData();
			system.SetupTransactionSystem();

			Print("Margin OK. Executing RunTransactionSystemForCurrentSymbol.");
			system.RunTransactionSystemForCurrentSymbol(true, true);
		}
		else
		{
			Print(__FUNCTION__ + " margin is not ok for symbol " + _Symbol);
			return (INIT_FAILED);
		}
	}

	if (ChangeSymbol())
		return INIT_SUCCEEDED;

	if (FirstSymbol == NULL)
	{
		GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
		GlobalContext.DatabaseLog.Initialize(true);

		string lastSymbol = NULL, currentSymbol = NULL;

		if (onlyCurrentSymbol)
			currentSymbol = lastSymbol = _Symbol;
		else
		{
			lastSymbol = system.GetLastSymbol();
			currentSymbol = GlobalContext.Config.GetNextSymbol(lastSymbol);
		}

		if (useLightSystem || useFullSystem)
			system.SetupTransactionSystem();

		if (StringIsNullOrEmpty(lastSymbol) || (StringIsNullOrEmpty(currentSymbol) && GlobalContext.Config.GetBoolValue("StartSimulationAgain")))
		{
			if (useFullSystem)
			{
				GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
				GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
			}
		}
		else if (!StringIsNullOrEmpty(currentSymbol))
		{
			GlobalContext.Config.InitCurrentSymbol(currentSymbol);

			if (ChangeSymbol())
				return (INIT_SUCCEEDED);
		}
		else
			return (INIT_SUCCEEDED);
	}

	if (system.IsSetupInvalid())
		system.SetupTransactionSystem();

	system.InitializeFromFirstChartTranData(true);

	PrintIfTrue(useLightSystem || useDiscoverySystem || useFullSystem,
	            "System run for " +
	            (useLightSystem ? "light system" : "") +
	            (useDiscoverySystem ? "discovery system" : "") +
	            (useFullSystem ? "full system" : ""));

	if (useDiscoverySystem)
		system.SystemDiscovery();
	else if (useLightSystem || useFullSystem)
		system.TestTransactionSystemForCurrentSymbol(true, true, useLightSystem, GlobalContext.Config.GetBoolValue("KeepAllObjects"), true);

	if (!onlyCurrentSymbol)
		GlobalContext.Config.InitCurrentSymbol(GlobalContext.Config.GetNextSymbol(CurrentSymbol));

	if (!ChangeSymbol())
	{
		if (useFullSystem)
		{
			GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
			GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
		}

		if (useDiscoverySystem)
			Print("Discovery finished! Job done!");
		else if (useLightSystem)
			Print("Light system simulation finished! Job done!");
		else if (useFullSystem)
			Print("Full system simulation finished! Job done!");

		if (useDiscoverySystem || useLightSystem || useFullSystem)
		{
			GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
			GlobalContext.DatabaseLog.CallWebServiceProcedure("GetResults");
			Print("GetResults WS call execution finished! Job done!");
		}

		if (useDiscoverySystem)
		{
			system.SystemDiscoveryPrintData();
			//system.SystemDiscoveryDeleteWorseThanAverage();
			system.SystemDiscoveryPrintBetterThanAverage();
			system.SystemDiscoveryPrintWorseThanAverage();
			//Print("--=-=-=-=-==================================================================================");
			//system.SystemDiscoveryPrintData();
		}
		else if (useLightSystem || useFullSystem)
			system.FreeArrays();

		if (useDiscoverySystem || useLightSystem || useFullSystem)
		{
			GlobalContext.Config.SetBoolValue("UseLightSystem", false);
			GlobalContext.Config.SetBoolValue("UseDiscoverySystem", false);
			GlobalContext.Config.SetBoolValue("UseFullSystem", false);
		}
		//Print("Closing [ExpertRemove]!"); ExpertRemove();
	}

	//EventSetTimer(4);
	return (INIT_SUCCEEDED);
}

void SystemWrapper::OnDeinitWrapper(const int reason)
{
	// Bulk debug anyway
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	system.PrintDeInitReason(reason);

	if (!GlobalContext.Config.GetBoolValue("UseDiscoverySystem"))
	{
		system.CleanTranData();
		system.RemoveUnusedDecisionsTransactionsAndLots();
	}

	comm.CleanBuffers();
	comm.RemoveTimers();

	if (!GlobalContext.Config.GetBoolValue("OnlyCurrentSymbol"))
	{
		if ((_Symbol != CurrentSymbol) && (!StringIsNullOrEmpty(CurrentSymbol)))
		{
			if ((GlobalContext.Config.GetBoolValue("UseIndicatorChangeChart")) && (GlobalVariableCheck(GetGlobalVariableSymbol())))
				GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
			else
				GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, GlobalContext.Config.GetBoolValue("UseKeyBoardChangeChart"));
		}
	}
}

bool SystemWrapper::ChangeSymbol()
{
	if (!StringIsNullOrEmpty(CurrentSymbol) && (_Symbol != CurrentSymbol) && (GlobalContext.Config.GetBoolValue("AllowChangingSymbol")))
	{
		Print(__FUNCTION__ + " Symbol should change from " + _Symbol + " to " + CurrentSymbol);

		if ((GlobalContext.Config.GetBoolValue("UseIndicatorChangeChart")) && (GlobalVariableCheck(GetGlobalVariableSymbol())))
			GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
		else
			GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, GlobalContext.Config.GetBoolValue("UseKeyBoardChangeChart"));
		Sleep(10);

		return GlobalContext.ChartIsChanging = true;
	}
	return false;
}

void SystemWrapper::OnTickWrapper()
{
	if (GlobalContext.Config.GetBoolValue("UseEA"))
	{
		if (GlobalContext.Config.IsNewBar())
			RefreshRates();
		if (GlobalContext.ChartIsChanging)
			return;

		system.RunTransactionSystemForCurrentSymbol(true);
	}
}

void SystemWrapper::OnTimerWrapper()
{
	string word = comm.OnTimerGetWord();
	if (!StringIsNullOrEmpty(word))
	{
		ExecuteCommand(word);
		comm.RemoveFirstWord();
	}
}

void SystemWrapper::ExecuteCommand(string command)
{
	Print(__FUNCTION__ + " command: " + command);

	string words[];
	StringSplit(command, '/', words);
	int lenWords = ArraySize(words);
	if (lenWords < 2)
	{
		Print(__FUNCTION__ + " Exiting. lenWords: " + IntegerToString(lenWords));
		return;
	}

	string context = words[0];
	command = words[1];

	if (context == "print") {
		if ((command == "[d]discovery") || (command == "discovery") || (command == "d"))
		{

		}
		else if ((command == "[s]system") || (command == "system") || (command == "s"))
		{

		}
		else if ((command == "[o]orders") || (command == "orders") || (command == "order") || (command == "o"))
		{

		}
		else if ((command == "[r]results") || (command == "results") || (command == "result") || (command == "r"))
		{

		}
		else if ((command == "[v]variables") || (command == "variables") || (command == "variable") || (command == "v"))
		{

		}
		else if ((command == "[c]config") || (command == "config") || (command == "c"))
		{

		}
		else if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;
	} else if (StringFind(context, "call") == 0) { // WS Proc call
		if ((command == "[b]back") || (command == "back") || (command == "b")) // to do: validate words (procedure name, params)
			return;

		//StringSplit(context, '/', words);
		//if(ArraySize(words) != 3) // call/procedure name/parameters
		//	return context + "/" + command;
	} else if ((context == "discovery") || (context == "light") || (context == "system") || (context == "EA")) {
		Print(__FUNCTION__ + " context: \"" + context + "\" command: \"" + command + "\"");

		if (context == "discovery")
		{
			GlobalContext.Config.SetBoolValue("UseDiscoverySystem", true);
			GlobalContext.Config.SetBoolValue("UseLightSystem", false);
			GlobalContext.Config.SetBoolValue("UseFullSystem", false);
			GlobalContext.Config.SetBoolValue("UseEA", false);
		}
		else if (context == "light")
		{
			GlobalContext.Config.SetBoolValue("UseDiscoverySystem", false);
			GlobalContext.Config.SetBoolValue("UseLightSystem", true);
			GlobalContext.Config.SetBoolValue("UseFullSystem", false);
			GlobalContext.Config.SetBoolValue("UseEA", false);
		}
		else if (context == "system")
		{
			GlobalContext.Config.SetBoolValue("UseDiscoverySystem", false);
			GlobalContext.Config.SetBoolValue("UseLightSystem", false);
			GlobalContext.Config.SetBoolValue("UseFullSystem", true);
			GlobalContext.Config.SetBoolValue("UseEA", false);
		}
		else if (context == "EA")
		{
			GlobalContext.Config.SetBoolValue("UseDiscoverySystem", false);
			GlobalContext.Config.SetBoolValue("UseLightSystem", false);
			GlobalContext.Config.SetBoolValue("UseFullSystem", false);
			GlobalContext.Config.SetBoolValue("UseEA", true);
			// might need further config (in other place make the config?)
		}

		if ((command == "[1]one symbol") || (command == "one symbol") || (command == "one") || (command == "1"))
		{
			// to do: change chart to that symbol; what symbol??
			// read config in other place??
			GlobalContext.Config.SetBoolValue("OnlyCurrentSymbol", true);
		}
		else if ((command == "[c]current symbol") || (command == "current symbol") || (command == "current") || (command == "c"))
		{
			GlobalContext.Config.SetBoolValue("OnlyCurrentSymbol", true);
		}
		else if ((command == "[w]watchlist symbols") || (command == "watchlist symbols") || (command == "watchlist") || (command == "watch") || (command == "w"))
		{
			// to do: check that OnlyCurrentSymbol=false is enough
			GlobalContext.Config.SetBoolValue("OnlyCurrentSymbol", false);
			GlobalContext.Config.SetBoolValue("OnlyWatchListSymbols", true);
		}
		else if ((command == "[a]all symbols") || (command == "all symbols") || (command == "all") || (command == "a"))
		{
			// to do: check that OnlyCurrentSymbol=false is enough
			GlobalContext.Config.SetBoolValue("OnlyCurrentSymbol", false);
			GlobalContext.Config.SetBoolValue("OnlyWatchListSymbols", false);
		}
		else if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;

		// Go back and forth; the second init (on the same symbol as now) will run system, light system or discovery
		GlobalContext.Config.SetValue("ReturnToSymbol", _Symbol);
		GlobalContext.Config.InitCurrentSymbol(GlobalContext.Config.GetNextSymbol(_Symbol));
		ChangeSymbol();
		return;

		//system.RunTransactionSystemForCurrentSymbol(true); // this is done @init
	} else if (context == "config") {
		if ((command == "[c]change") || (command == "change") || (command == "c"))
			;
		else if ((command == "[p]print") || (command == "print") || (command == "p"))
			;
		else if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;
	} else if (context == "indicator") {
		if ((command == "[d]decision") || (command == "decision") || (command == "d"))
			;
		else if ((command == "[s]show") || (command == "show") || (command == "s"))
			;
		else if ((command == "[o]orders") || (command == "orders") || (command == "o"))
			;
		else if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;
	} else if (context == "analysis") { // to do: validate word
		if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;

		//string words[];
		//StringSplit(context, '/', words);
		//if(ArraySize(words) != 2) // analysis/indicator
		//	return UpdateContext(context + "/" + command, changeContext);
	} else if (context == "orders") { // to do: complete orders; it was way bigger than this
		if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;
	} else if (StringFind(context, "manual") == 0) { // to do: validate words
		if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;

		//string words[];
		//StringSplit(context, '/', words);
		//if(ArraySize(words) != 6) // manual/symbol/% of margin used/order type(buy/sell)/TP & SL type(pips, simple s/r, 2BB, Fibonacci s/r, MA s/r)/virtual limits
		//	return context + "/" + command;
	} else if (StringFind(context, "update") == 0) { // to do: make all for "update" in this context
		if ((command == "TakeProfit") || (command == "take profit") || (command == "TP"))
			;
		else if ((command == "StopLoss") || (command == "stop loss") || (command == "SL"))
			;
		else if ((command == "close"))
			;
		else if ((command == "trailing stop") || (command == "trailing"))
			;
		else if ((command == "notification") || (command == "notif"))
			;
		else if ((command == "virtual") || (command == "virt"))
			;
		else if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;
	} else if (context == "probability") {
		if ((command == "current") || (command == "opened")) // opened order
			;
		else if ((command == "virtual") || (command == "virt")) // virtual order
			;
		else if ((command == "new")) // new order
			;
		else if ((command == "[b]back") || (command == "back") || (command == "b"))
			return;
	}
}
