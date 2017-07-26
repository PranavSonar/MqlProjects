//+------------------------------------------------------------------+
//|                                                SystemConsole.mq4 |
//|                   Copyright 2009-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2009-2014, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict


#include "SystemConsole.mqh"

SystemConsole ExtDialog;

static SystemWrapper systemWrapper;

int OnInit(void)
{
	if(!ExtDialog.Create(0,"System Console",0,50,50,500,400))
		return(INIT_FAILED);
	
	if(!ExtDialog.Run())
		return(INIT_FAILED);
	
	return systemWrapper.OnInitWrapper();
}

void OnDeinit(const int reason)
{
	ExtDialog.Destroy(reason);
	systemWrapper.OnDeinitWrapper(reason);
}
  
int OnCalculate(
   const int rates_total,
   const int prev_calculated,
   const int begin,
   const double &price[])
{
   return(rates_total);
}

void OnTick()
{
	systemWrapper.OnTickWrapper();
}

void OnChartEvent(
	const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam)
{
	ExtDialog.ChartEvent(id,lparam,dparam,sparam);
}
