//+------------------------------------------------------------------+
//|                                               YetAnotherTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

void OnStart()
{
	string str = "";
	for(int i=0; i<230; i++)
	{
		str += "*";
		if(i > 228)
			Print("|" + str + "|");
	}
	
	Print("String lenght: " + IntegerToString(StringLen(str)));
}

