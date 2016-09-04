//+------------------------------------------------------------------+
//|                                                       Test02.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>


void OnStart()
{
	BaseMoneyManagement money;
	SafePrintString(money.ToString());
}
