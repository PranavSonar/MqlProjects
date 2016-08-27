//+------------------------------------------------------------------+
//|                                                TestArray.mql.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int numbers[];

void OnStart()
{
	
	ArrayResize(numbers,1);
	numbers[0] = 1;
	
	printf("numbers[0]=%f", numbers[0]);
	ArrayResize(numbers,2);
	numbers[1] = 4;
	
	for(int i=0;i<ArraySize(numbers);i++)
		printf("numbers[i=%d]=%f", i, numbers[i]);
}
