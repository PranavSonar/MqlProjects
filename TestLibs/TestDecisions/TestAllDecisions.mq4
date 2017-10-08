//+------------------------------------------------------------------+
//|                                             TestAllDecisions.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\DecisionMaking\DecisionCombinedMA.mqh>
#include <MyMql\DecisionMaking\DecisionDoubleBB.mqh>
#include <MyMql\DecisionMaking\DecisionRSI.mqh>
#include <MyMql\Global\Config\GlobalConfig.mqh>
#include <MyMql\Global\Log\WebServiceLog.mqh>

void StartCustomIndicator2(int hWnd, string IndicatorName, bool AutomaticallyAcceptDefaults = false)
{
	uchar name2[];
	StringToCharArray(IndicatorName, name2, 0, StringLen(IndicatorName));

	int MessageNumber = RegisterWindowMessageW("MetaTrader4_Internal_Message");
	int r = PostMessageW(hWnd, MessageNumber, 15, name2);
	Sleep(400);

	keybd_event(13, 0, 0, 0);
}

void StartStandardIndicator(int hWnd, string IndicatorName, bool AutomaticallyAcceptDefaults = false)
{
	int MessageNumber = RegisterWindowMessageA("MetaTrader4_Internal_Message");
	PostMessageA(hWnd, MessageNumber, 13, IndicatorName);
	if (AutomaticallyAcceptDefaults) ClearConfigDialog();
}

void StartCustomIndicator(int hWnd, string IndicatorName, bool AutomaticallyAcceptDefaults = false)
{
	int MessageNumber = RegisterWindowMessageA("MetaTrader4_Internal_Message");
	PostMessageA(hWnd, MessageNumber, 15, IndicatorName);

	if (AutomaticallyAcceptDefaults) ClearConfigDialog();
}

void StartEA(int hWnd, string EAName, bool AutomaticallyAcceptDefaults = false)
{
	int MessageNumber = RegisterWindowMessageA("MetaTrader4_Internal_Message");
	PostMessageA(hWnd, MessageNumber, 14, EAName);
	if (AutomaticallyAcceptDefaults) ClearConfigDialog();
}

void StartScript(int hWnd, string ScriptName, bool AutomaticallyAcceptDefaults = false)
{
	int MessageNumber = RegisterWindowMessageA("MetaTrader4_Internal_Message");
	PostMessageA(hWnd, MessageNumber, 16, ScriptName);
	if (AutomaticallyAcceptDefaults) ClearConfigDialog();
}

void ClearConfigDialog()
{
	Sleep(100);
	keybd_event(13, 0, 0, 0);
}

//
//int IndicatorAdd(string indicatorName, string symbol, ENUM_TIMEFRAMES period)
//{
//	MqlParam params[];
//	ArrayResize(params,1);
//
//	params[0].type = TYPE_STRING;
//	params[0].string_value = indicatorName;
//
//	return 0;
//}

int OnInit()
{
	WebServiceLog wslog(true);
	int hWnd = WindowHandle(_Symbol, 0);
	GlobalConfig config(true, true, false, false);

	if (FirstSymbol == NULL)
	{
		GlobalContext.DatabaseLog.ParametersSet(__FILE__);
		wslog.CallWebServiceProcedure("NewTradingSession");
		//StartCustomIndicator2(hWnd,"Projects\\TestLibs\\TestDecisions\\Test3MA\\TestIndicator3MA\0", true);
		//StartCustomIndicator2(hWnd,"Projects\\TestLibs\\TestDecisions\\TestDoubleBB\\TestIndicatorDoubleBB\0", true);
		//StartCustomIndicator2(hWnd,"Projects\\TestLibs\\TestDecisions\\TestRSI\\TestIndicatorRSI\0", true);
		config.Initialize();
	}

	// Navigate next
	Sleep(400); // Wait for indicators to get to end
	config.ChangeSymbol();

	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	wslog.CallWebServiceProcedure("EndTradingSession");

	return (INIT_SUCCEEDED);
}