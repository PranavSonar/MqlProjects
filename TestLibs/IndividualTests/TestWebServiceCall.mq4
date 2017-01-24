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


class XmlResult {
	public:
		string Symbol, DecisionName, TransactionName;
		ENUM_TIMEFRAMES Period;
		bool IsInverseDecision, IrregularLimits;
		int OrderNo, BarsPerOrders, PositiveOrdersCount, NegativeOrdersCount, SumClosedOrders;
		double ProcentualProfitResult;
		
		XmlResult()
		{
			Symbol = NULL; DecisionName = NULL; TransactionName = NULL;
			Period = PERIOD_CURRENT;
			IsInverseDecision = false; IrregularLimits = false;
			OrderNo = 0; BarsPerOrders = 0; PositiveOrdersCount = 0; NegativeOrdersCount = 0; SumClosedOrders = 0;
			ProcentualProfitResult = 0.0f;
		}
		
		
		void FillDataFromXmlElement(XmlElement *element)
		{
			this.Symbol = element.GetChildTagDataByParentElementName("Symbol");
			this.DecisionName = element.GetChildTagDataByParentElementName("DecisionName");
			this.TransactionName = element.GetChildTagDataByParentElementName("TransactionName");
			this.Period = StringToTimeFrame(element.GetChildTagDataByParentElementName("Period"));
			this.IsInverseDecision = StringToBool(element.GetChildTagDataByParentElementName("IsInverseDecision"));
			this.IrregularLimits = StringToBool(element.GetChildTagDataByParentElementName("IrregularLimits"));
			this.OrderNo = (int)StringToInteger(element.GetChildTagDataByParentElementName("OrderNo"));
			this.BarsPerOrders = (int)StringToInteger(element.GetChildTagDataByParentElementName("BarsPerOrders"));
			this.NegativeOrdersCount = (int)StringToInteger(element.GetChildTagDataByParentElementName("NegativeOrdersCount"));
			this.PositiveOrdersCount = (int)StringToInteger(element.GetChildTagDataByParentElementName("PositiveOrdersCount"));
			this.SumClosedOrders = (int)StringToInteger(element.GetChildTagDataByParentElementName("SumClosedOrders"));
			this.ProcentualProfitResult = StringToDouble(element.GetChildTagDataByParentElementName("ProcentualProfitResult"));
		}
};

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

	wsLog.ParametersSet("1");
	wsLog.CallWebServiceProcedure("ReadResult");
	result = wsLog.GetResult(); // wsLog.Result
	element.ParseXml(result);
	SafePrintString("2:" + element.GetXmlFromElement());
	
	XmlResult res;
	res.FillDataFromXmlElement(&element);
	
	
	element.Clear();
	
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
