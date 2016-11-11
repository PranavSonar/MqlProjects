//+------------------------------------------------------------------+
//|                                                  TestXML.mq4.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Log\Xml\XmlElement.mqh>

int OnInit()
{
	XmlElement element;
	
	element.SetVerboseLevel(1);
	
	element.ParseXml("<element/>");
	Print(element.GetElementName());
	element.Clear();
	
	element.ParseXml("<element/>\n");
	Print(element.GetElementName());
	element.Clear();
	
	element.ParseXml("\n\n\n\n<element/>");
	Print(element.GetElementName());
	element.Clear();
	
	element.ParseXml("<element/>\n\n\n");
	Print(element.GetElementName());
	element.Clear();
	
	element.ParseXml("<element></element>");
	Print(element.GetElementName());
	element.Clear();
	
	element.ParseXml("<element>\n</element>");
	Print(element.GetElementName());
	element.Clear();
	
	element.ParseXml("<element>\n<e1/>\n</element>");
	Print(element.GetElementName());
	element.Clear();
	
	
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
