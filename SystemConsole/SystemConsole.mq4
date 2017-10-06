#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#property indicator_chart_window
//#property indicator_separate_window


#include "SystemConsole.mqh"

SystemConsole ExtDialog;


int OnInit(void)
{
	GlobalContext.Config.SetBoolValue("Debug", true);
	if (!ExtDialog.Create(0, "System Console", 0, 50, 50, 500, 400))
		return (INIT_FAILED);

	if (!ExtDialog.Run())
		return (INIT_FAILED);

	return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
	ExtDialog.Destroy(reason);
}

int OnCalculate(
    const int rates_total,
    const int prev_calculated,
    const int begin,
    const double &price[])
{
	return (rates_total);
}

void OnTimer()
{
	string word = comm.OnTimerGetWord();
	if (!StringIsNullOrEmpty(word))
	{
		ExtDialog.ExecuteCommand(word);
		comm.RemoveFirstWord();

		Print(__FUNCTION__ + " " + word);
	}
}


void OnChartEvent(
    const int id,
    const long &lparam,
    const double &dparam,
    const string &sparam)
{
	ExtDialog.ChartEvent(id, lparam, dparam, sparam);
}
