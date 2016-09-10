//+------------------------------------------------------------------+
//|                                              WhateverTheTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

void OnStart()
{
	printf("AccountFreeMargin = %f", AccountFreeMargin());
	printf("RemainingAccountFreeMargin = %f", AccountFreeMarginCheck(Symbol(),OP_SELL, 0.01));
}
