//+------------------------------------------------------------------+
//|                                           TestDecisionsShift.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Base\BeforeObject.mqh>

int OnInit()
{
	unsigned long type = 0, nrSell = 0, nrBuy = 0;
	type = 4 + 16 + 32 + 1024; //1,2,4,8
	
	Print ("initial type=" + IntegerToString(type));
	
	while(type != 0)
	{
		bool buyDecision = type & 0x01;
		bool sellDecision = type & 0x02;
		
		if(sellDecision)
			nrSell++;
			
		
		if(buyDecision)
			nrBuy++;
			
		Print (
			"type=" + IntegerToString(type) + 
			" buy=" + BoolToString(buyDecision) + 
			" sell=" + BoolToString(sellDecision) + 
			" buyNr=" + IntegerToString(nrBuy) + 
			" sellNr=" + IntegerToString(nrSell)
		);
		
		type = type >> 2;
	}
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}
void OnTick() {}