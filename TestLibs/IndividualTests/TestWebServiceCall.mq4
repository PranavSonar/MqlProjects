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
	
	wsLog.ReadLastDataLogAndDetail("TestSimulateTranSystem.mq4");
	element.ParseXml(wsLog.GetResult()); // wsLog.Result
	SafePrintString("1:" + element.GetXmlFromElement());
	element.Clear();

//	wsLog.ReadLastDataLogDetail("TestSimulateTranSystem.mq4");
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("2:" + element.GetXmlFromElement());
//	element.Clear();
//	
//	wsLog.ReadLastDataLog("TestSimulateTranSystem.mq4");
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("3:" + element.GetXmlFromElement());
//	element.Clear();
//	
//	wsLog.ReadLastProcedureLog("TestSimulateTranSystem.mq4");
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("4:" + element.GetXmlFromElement());
//	element.Clear();
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
