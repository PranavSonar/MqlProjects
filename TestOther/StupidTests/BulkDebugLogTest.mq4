//+------------------------------------------------------------------+
//|                                             BulkDebugLogTest.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Global.mqh>

int OnInit()
{
	GlobalContext.Config.Initialize(true, true, true, true, __FILE__);
	GlobalContext.DatabaseLog.Initialize(true);

	GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
	GlobalContext.DatabaseLog.Initialize(true);

	GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadConfigTable");
	GlobalContext.SessionXmlData.ParseXml(GlobalContext.DatabaseLog.Result);

	Print(GlobalContext.SessionXmlData.GetElementName());
	Print(GlobalContext.SessionXmlData.GetFullElementData());
	int i = 0;
	XmlElement* element = GlobalContext.SessionXmlData.GetChildByElementName("ArrayOfUSP_GetConfigTableData_Result");

	//if (element != null)
	//	element = element.GetChildByPosition(0);
	if (element != NULL)
		element = element.GetChildByPosition(i);

	while (element != NULL)
	{
		Print(element.GetChildTagDataByParentElementName("Config") + "=" + element.GetChildTagDataByParentElementName("Value"));
		i++;

		element = GlobalContext.SessionXmlData.GetChildByElementName("ArrayOfUSP_GetConfigTableData_Result");
		//if(element != NULL)
		//	element = GlobalContext.SessionXmlData.GetChildByPosition(0);
		if (element != NULL)
			element = element.GetChildByPosition(i);
	}

	// NewTradingSession
	//GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
	//GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");

	//string message = "debug message something " + __FILE__ + " " +__FUNCTION__ + " " +__LINE__;
	//GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
	//	GlobalContext.Config.GetSessionName(),
	//	message,
	//	TimeAsParameter());

	//GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);

	// EndTradingSession
	//GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
	//GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");

	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}
