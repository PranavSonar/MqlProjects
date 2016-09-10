//+------------------------------------------------------------------+
//|                                                  StringSplit.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
	string line = "param1=asfdadsf 2435 2&param2=23wer fwerg werg";
	string lines[];
	StringSplit(line, StringGetCharacter("&",0), lines);
	
	Print(lines[0]);
	Print(lines[1]);
	return(INIT_SUCCEEDED);
}