//+------------------------------------------------------------------+
//|                                           TestWebServiceCall.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <MyMql\Global\Log\OnlineWebServiceLog.mqh>
#include <MyMql\Global\Log\Xml\XmlElement.mqh>

int OnInit()
{
	OnlineWebServiceLog wsLog(true);
	XmlElement element;
	string result = NULL;
	string parameters[];
	
	
	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("NewTradingSession", parameters);
	result = wsLog.GetResult(); // wsLog.Result
	SafePrintString(result);
	
	
	
	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
	wsLog.CallWebServiceProcedure("EndTradingSession", parameters);
	result = wsLog.GetResult(); // wsLog.Result
	SafePrintString(result);
	
	//ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
	//wsLog.CallWebServiceProcedure("ReadLastDataLogAndDetail", parameters);
	//result = wsLog.GetResult(); // wsLog.Result
	//SafePrintString(result);
	
	element.ParseXml(result);
	SafePrintString("1:" + element.GetXmlFromElement());
	element.Clear();

//	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
//	wsLog.CallWebServiceProcedure("ReadLastDataLogDetail", parameters);
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("2:" + element.GetXmlFromElement());
//	element.Clear();
//	
//	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
//	wsLog.CallWebServiceProcedure("ReadLastDataLog", parameters);
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("3:" + element.GetXmlFromElement());
//	element.Clear();
//	
//	ResizeAndSet(parameters, "TestSimulateTranSystem.mq4");
//	wsLog.CallWebServiceProcedure("ReadLastProcedureLog", parameters);
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("4:" + element.GetXmlFromElement());
//	element.Clear();
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
