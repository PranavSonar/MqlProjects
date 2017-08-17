//+------------------------------------------------------------------+
//|                                       TestReceiveGlobalVarEA.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Global.mqh>

GlobalVariableCommunication comm(false, true);

int OnInit()
{
	comm.SendText("Fuck you");
	return(INIT_SUCCEEDED);
}

//void OnTick() {}
void OnTimer()
{
	string s = comm.OnTimerGetWord();
	if(!StringIsNullOrEmpty(s))
	{
		Print(s);
		comm.RemoveFirstWord();
		comm.RemoveTimers();
	}
}


void OnDeinit(const int reason)
{
	comm.CleanBuffers();
}

//  
//int OnCalculate(const int rates_total,
//                const int prev_calculated,
//                const int begin,
//                const double &price[])
//  {
////---
//// do nothing
////--- return value of prev_calculated for next call
//   return(rates_total);
//  }
//  