//+------------------------------------------------------------------+
//|                                            UnsignedLongTests.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

const unsigned long Mask1 = 0x55555555; /*0x55555555 = 1431655765*/
const unsigned long Mask2 = 0xAAAAAAAA; /*0xAAAAAAAA = 2863311530*/

int OnInit()
{
	unsigned long test1 = 32;
	test1 = test1 & Mask1;
	Print("test1=" + IntegerToString(test1));
	
	unsigned long test2 = 32232;
	test2 = test2 & Mask2;
	Print("test2=" + IntegerToString(test2));
	
	return(INIT_SUCCEEDED);
}
