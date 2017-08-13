//+------------------------------------------------------------------+
//|                                TestReceiveGlobalVarIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Global.mqh>



GlobalVariableCommunication comm(true, true);
string lastRec;

int OnInit()
{
	comm.SendText("Same to you too");
	return(INIT_SUCCEEDED);
}

//void OnTick() {}
void OnTimer()
{
	comm.SendAndReceive();
	string rec = comm.GetReceivedText();

	if((rec != "") && (lastRec != rec))
	{
		Print(rec);
		lastRec = rec;
	}
}


void OnDeinit(const int reason)
{
	comm.CleanBuffers();
}

  
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
// do nothing
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  