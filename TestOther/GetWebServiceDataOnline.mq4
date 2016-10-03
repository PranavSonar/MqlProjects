//+------------------------------------------------------------------+
//|                                      GetWebServiceDataOnline.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <MyMql/Log/WebServiceLog.mqh>

int OnInit()
{
	WebServiceLog wsLog(true,true);
	
	//wsLog.LogOldOfflineData();
	wsLog.NewTradingSession();
	wsLog.LogOldOfflineData("2BB.txt");
	wsLog.LogOldOfflineData("RSI.txt");
	wsLog.LogOldOfflineData("3MA.txt");
	wsLog.EndTradingSession();
	
	return(INIT_SUCCEEDED);
}
