//+------------------------------------------------------------------+
//|                                           TestTransactionMan.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <MyMql/MoneyManagement/MoneyBetOnDecision.mqh>
#include <MyMql/Generator/GenerateTPandSL.mqh>

int OnInit()
{
	double SL = 0.0, TP = 0.0;
	FlowWithTrendTranMan followTrend;
	MoneyBetOnDecision money;
	GenerateTPandSL generator;
	int cmd = OP_BUY; //OP_SELL;
	ENUM_MARKETINFO mInfo = MODE_ASK;//MODE_BID;
	
	money.CalculateTP_SL(TP,SL, 50.0, 40.0, cmd,MarketInfo(Symbol(), mInfo),false, 0.0);
	generator.ValidateAndFixTPandSL(TP, SL, MarketInfo(Symbol(), mInfo), cmd);
	followTrend.SimulateOrderSend(Symbol(), cmd, 0.01, MarketInfo(Symbol(),mInfo),0, SL, TP);
	printf("%f %f", SL, TP);
	
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}