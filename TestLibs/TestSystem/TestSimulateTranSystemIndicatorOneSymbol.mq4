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


#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Gray
#property indicator_color4 Red
#property indicator_color5 Blue


double Buf_BBs2[], Buf_BBs1[], Buf_BBm[], Buf_BBd1[], Buf_BBd2[];
double Buf_Decision[];



static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	// Refresh
	ResetLastError();
	RefreshRates();
	
	SetIndexBuffer(0, Buf_BBs2);
	SetIndexStyle(0, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(1, Buf_BBs1);
	SetIndexStyle(1, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(2, Buf_BBm);
	SetIndexStyle(2, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(3, Buf_BBd1);
	SetIndexStyle(3, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(4, Buf_BBd2);
	SetIndexStyle(4, DRAW_SECTION, STYLE_SOLID, 2);
	
	SetIndexBuffer(5, Buf_Decision);
	SetIndexStyle(5, DRAW_SECTION, STYLE_SOLID, 0, clrNONE);
	
	
	// Early inits
	GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
	GlobalContext.DatabaseLog.Initialize(true);
	
	// NewTradingSession
	GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
	GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	
	// Setup & simulation run
	system.SetupTransactionSystem();
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions",false);
	system.TestTransactionSystemForCurrentSymbol(true, false);

	// EndTradingSession
	GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	Print("Simulation finished! Job done!");

	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	system.PrintDeInitReason(reason);
	system.FreeArrays(); // system.Clean();
	system.CleanTranData();
	system.RemoveUnusedDecisionsTransactionsAndLots();
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   return(rates_total);
}
