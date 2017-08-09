//+------------------------------------------------------------------+
//|                                       TestSimulateTranSystem.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property strict

#property indicator_chart_window
#property indicator_buffers 1

#include <MyMql\Global\Global.mqh>


void CheckForChanging()
{
	string symbol = GlobalContext.Library.GetSymbolNameFromPosition((int)GlobalVariableGet(GlobalVariableSymbolNameConst));
	
	if((symbol != _Symbol) && (!StringIsNullOrEmpty(symbol)))
	{
		Print(__FUNCTION__ + " line " + IntegerToString(__LINE__) + ": Changing chart from " + _Symbol + " to " + symbol); 
		GlobalContext.Config.ChangeSymbol(symbol, PERIOD_CURRENT);
	}
}

int OnInit()
{
	ResetLastError();
	if(FirstSymbol == NULL)
		GlobalContext.Config.Initialize(false, true, false, true, __FILE__);
	
	if(!GlobalVariableCheck(GlobalVariableSymbolNameConst))
		GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(_Symbol));
	
	EventSetTimer(1);
	
	CheckForChanging();
	
	return(INIT_SUCCEEDED);
}

void OnTimer()
{
	CheckForChanging();
}

void OnDeinit(const int reason) {
	GlobalVariableDel(GlobalVariableSymbolNameConst);
	EventKillTimer();
}

void OnTick() { CheckForChanging(); }
int OnCalculate(
	const int rates_total,
	const int prev_calculated,
	const datetime& time[],
	const double& open[],
	const double& high[],
	const double& low[],
	const double& close[],
	const long& tick_volume[],
	const long& volume[],
	const int& spread[]) { CheckForChanging(); return(rates_total); }
