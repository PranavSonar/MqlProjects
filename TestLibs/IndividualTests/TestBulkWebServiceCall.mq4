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
	
	//------------------------------------------------------------------
	//////NewTradingSession request
	//------------------------------------------------------------------
	
	wsLog.ParametersSet(__FILE__);
	wsLog.CallWebServiceProcedure("NewTradingSession");
	
	result = wsLog.GetResult(); // wsLog.Result
	SafePrintString(result);
	
	
	//------------------------------------------------------------------
	//////Soap request
	//------------------------------------------------------------------
	
	string soapRequest =
		"<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
		"<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">" +
		"  <soap12:Body>" +
		"    <TestMethod xmlns=\"http://tempuri.org/\">" +
		"      <list>" +
		"        <string>x1</string>" +
		"        <string>x2</string>" +
		"      </list>" +
		"    </TestMethod>" +
		"  </soap12:Body>" +
		"</soap12:Envelope>";
	int requestLength = StringLen(soapRequest);
	char postArray[];
	int postSize = ArraySize(postArray);
	string headers = "Accept: application/soap+xml\r\nContent-Type: application/soap+xml\r\n\r\n";
	string url = "http://localhost/MetatraderWebLog/WebService.asmx";
	char resultChar[];
	
	StringToCharArray(soapRequest, postArray, 0, requestLength);
	
	////WebRequest("POST", url, NULL, "http://stf/\r\nAccept: application/soap+xml\r\nContent-Type: application/soap+xml\r\n\r\n", 500, postArray, postSize, resultChar, headers);
	
	WebRequest("POST", url, headers, 10, postArray, postArray, headers);
	
	result = CharArrayToString(resultChar);
	SafePrintString(result);
	
	
	
	
	//------------------------------------------------------------------
	//////Soap request2
	//------------------------------------------------------------------
	string timeFormat = GetXmlTimeFormat(TimeCurrent());
	soapRequest =
		"<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n" +
		"<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\r\n" +
		"  <soap12:Body>\r\n" +
		"    <TestMethod2 xmlns=\"http://tempuri.org/\">\r\n" +
		"      <list>\r\n" +
		"        <TestStruct>\r\n" +
		"          <sessionName>V</sessionName>\r\n" +
		"          <debugData>X</debugData>\r\n" +
		"          <debugTime>"  + timeFormat + "</debugTime>\r\n" +
		"        </TestStruct>\r\n" +
		"        <TestStruct>\r\n" +
		"          <sessionName>A</sessionName>\r\n" +
		"          <debugData>B</debugData>\r\n" +
		"          <debugTime>" + timeFormat + "</debugTime>\r\n" +
		"        </TestStruct>\r\n" +
		"      </list>\r\n" +
		"    </TestMethod2>\r\n" +
		"  </soap12:Body>\r\n" +
		"</soap12:Envelope>";
	requestLength = StringLen(soapRequest);
	postSize = ArraySize(postArray);
	headers = "Accept: application/soap+xml\r\nContent-Type: application/soap+xml\r\n\r\n";
	url = "http://localhost/MetatraderWebLog/WebService.asmx";
	
	StringToCharArray(soapRequest, postArray, 0, requestLength);
	
	////WebRequest("POST", url, NULL, "http://stf/\r\nAccept: application/soap+xml\r\nContent-Type: application/soap+xml\r\n\r\n", 500, postArray, postSize, resultChar, headers);
	
	WebRequest("POST", url, headers, 10, postArray, postArray, headers);
	
	result = CharArrayToString(resultChar);
	SafePrintString(result);
	
	
	// CallBulkWebServiceProcedure request
	
	wsLog.BulkParametersSet("BulkDebugLog", "V", "X", timeFormat); timeFormat = GetXmlTimeFormat(TimeCurrent());
	wsLog.BulkParametersSet("BulkDebugLog", "X", "N", timeFormat); timeFormat = GetXmlTimeFormat(TimeCurrent());
	wsLog.BulkParametersSet("BulkDebugLog", "Y", "H", timeFormat); timeFormat = GetXmlTimeFormat(TimeCurrent());
	wsLog.BulkParametersSet("BulkDebugLog", "A", "G", timeFormat);
	wsLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	//wsLog.CallBulkWebServiceProcedure("TestMethod2", true);
	
	//------------------------------------------------------------------
	//////EndTradingSession request
	//------------------------------------------------------------------
	
	wsLog.ParametersSet(__FILE__);
	wsLog.CallWebServiceProcedure("EndTradingSession");
	result = wsLog.GetResult(); // wsLog.Result
	SafePrintString(result);
	
	//wsLog.ParametersSet( "TestSimulateTranSystem.mq4");
	//wsLog.CallWebServiceProcedure("ReadLastDataLogAndDetail");
	//result = wsLog.GetResult(); // wsLog.Result
	//SafePrintString(result);
	
//////////
//////////	wsLog.ParametersSet("1");
//////////	wsLog.CallWebServiceProcedure("ReadResult");
//////////	result = wsLog.GetResult(); // wsLog.Result
//////////	element.ParseXml(result);
//////////	SafePrintString("2:" + element.GetXmlFromElement());
//////////	element.Clear();


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
