//+------------------------------------------------------------------+
//|                                                      TestLib.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../BaseLibs/BaseObject.mq4"

class TestLib : public BaseObject
{
	public:
		TestLib() {}
		
		virtual void GetParamsFromFunction(int &testParam)
		{
			testParam = 1;
		}
};