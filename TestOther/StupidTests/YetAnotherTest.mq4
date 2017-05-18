//+------------------------------------------------------------------+
//|                                               YetAnotherTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/Base/BaseObject.mqh>

class A
{
	public:
		A() { Print("Whatever"); }
		
		virtual void PrintSomeData() { Print("Printed from A: " + __FUNCTION__); }
};

class B : A
{
	private:
		int asdadf;
		
	public:
		B() { asdadf = 12; Print("Another"); }
		
		virtual void PrintSomeData() { Print("Printed from B: " + IntegerToString(asdadf) + " " + __FUNCTION__); }
};

void OnStart()
{
//	
//	A *a;
//	B b;
//	a = (A*) &b;
//	a.PrintSomeData();
   bool res = SendNotification("Salutare");
   
   
   Print(BoolToString(res) + " " + IntegerToString(_LastError));
   Sleep(2000);
}

