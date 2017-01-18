//+------------------------------------------------------------------+
//|                                           TestWebServiceCall.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <MyMql\Global\Global.mqh>
#include <MyMql\Global\Log\Xml\XmlElement.mqh>

int OnInit()
{
	OnlineWebServiceLog wsLog(true);
	XmlElement element;
	string result = NULL;
	
	
	wsLog.ParametersSet(__FILE__);
	wsLog.CallWebServiceProcedure("NewTradingSession");
	result = wsLog.GetResult(); // wsLog.Result
	SafePrintString(result);
	
	
	
	wsLog.ParametersSet(__FILE__);
	wsLog.CallWebServiceProcedure("EndTradingSession");
	result = wsLog.GetResult(); // wsLog.Result
	SafePrintString(result);
	
	//wsLog.ParametersSet( "TestSimulateTranSystem.mq4");
	//wsLog.CallWebServiceProcedure("ReadLastDataLogAndDetail");
	//result = wsLog.GetResult(); // wsLog.Result
	//SafePrintString(result);

	wsLog.ParametersSet(__FILE__);
	wsLog.CallWebServiceProcedure("GetResults");
	result = wsLog.GetResult(); // wsLog.Result
	element.ParseXml(result);
	SafePrintString("2:" + element.GetXmlFromElement());
	element.Clear();
		
	element.ParseXml(result);
	SafePrintString("1:" + element.GetXmlFromElement());
	element.Clear();


//	wsLog.ParametersSet( "TestSimulateTranSystem.mq4");
//	wsLog.CallWebServiceProcedure("ReadLastDataLogDetail");
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("2:" + element.GetXmlFromElement());
//	element.Clear();
//	
//	wsLog.ParametersSet( "TestSimulateTranSystem.mq4");
//	wsLog.CallWebServiceProcedure("ReadLastDataLog");
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("3:" + element.GetXmlFromElement());
//	element.Clear();
//	
//	wsLog.ParametersSet( "TestSimulateTranSystem.mq4");
//	wsLog.CallWebServiceProcedure("ReadLastProcedureLog");
//	element.ParseXml(wsLog.GetResult()); // wsLog.Result
//	SafePrintString("4:" + element.GetXmlFromElement());
//	element.Clear();
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
