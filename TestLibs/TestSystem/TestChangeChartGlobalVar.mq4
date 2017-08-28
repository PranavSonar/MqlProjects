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
	string symbol = GlobalContext.Library.GetSymbolNameFromPosition((int)GlobalVariableGet(GetGlobalVariableSymbol()));
	ENUM_TIMEFRAMES period = IntegerToTimeFrame((int)GlobalVariableGet(GetGlobalVariablePeriod()));
	bool needChange = false;
	
	if((symbol != _Symbol) && (!StringIsNullOrEmpty(symbol)))
	{
		Print(__FUNCTION__ + " line " + IntegerToString(__LINE__) + ": Changing chart from " + _Symbol + " to " + symbol); 
		needChange = true;
	}
	
	if(IntegerToTimeFrame(Period()) != period)
	{
		Print(__FUNCTION__ + " line " + IntegerToString(__LINE__) + ": Changing chart from " + EnumToString(IntegerToTimeFrame(_Period)) + " to " + EnumToString(period));
		needChange = true;
	}
	
	if(needChange)
		GlobalContext.Config.ChangeSymbol(symbol, period);
}

int OnInit()
{
	ResetLastError();
	if(FirstSymbol == NULL)
		GlobalContext.Config.Initialize(false, true, false, true, __FILE__);
	
	if(!GlobalVariableCheck(GetGlobalVariableSymbol()))
		GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(_Symbol));
	
	EventSetTimer(1);
	
	CheckForChanging();
	
	return(INIT_SUCCEEDED);
}

void OnTimer()
{
	CheckForChanging();
}

void OnDeinit(const int reason) {
	GlobalVariableDel(GetGlobalVariableSymbol());
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
