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
	
	string xmlString = "<element a=\"b\"/>";
	string xmlTestString = xmlString;
	element.ParseXml(xmlString);
	if(element.GetXmlFromElement() != xmlTestString)
		Print(element.GetXmlFromElement() + "!=" + xmlTestString);
	element.Clear();
	
	xmlString = "<element a=\"b\" b=\"b\" c=\"b\" d=\"b\" />";
	xmlTestString = "<element a=\"b\" b=\"b\" c=\"b\" d=\"b\"/>";
	element.ParseXml(xmlString);
	if(element.GetXmlFromElement() != xmlTestString)
		Print(element.GetXmlFromElement() + "!=" + xmlTestString);
	element.Clear();
	
	xmlString = "<element>\n<e1/>\n</element>";
	xmlTestString = "<element><e1/></element>";
	element.ParseXml(xmlString);
	if(element.GetXmlFromElement() != xmlTestString)
		Print(element.GetXmlFromElement() + "!=" + xmlTestString);
	element.Clear();
	
	
	xmlString = "<element>\n<e1/><e2><e3/></e2>\n</element>";
	xmlTestString = "<element><e1/><e2><e3/></e2></element>";
	element.ParseXml(xmlString);
	if(element.GetXmlFromElement() != xmlTestString)
		Print(element.GetXmlFromElement() + "!=" + xmlTestString);
	element.Clear();
	
	xmlString = "<element><e0><e3/><es/><e1><ex/><eb/><e2><ev/><xa/><f3/></e2><ef/><ek/></e1><ec/><e5/></e0><fs/><2d/></element>";
	xmlTestString = xmlString;
	element.ParseXml(xmlString);
	if(element.GetXmlFromElement() != xmlTestString)
		Print(element.GetXmlFromElement() + "!=" + xmlTestString);
	element.Clear();
	
	
	xmlString = "<element>\n<e0><e1><e2><e3/></e2></e1></e0>\n</element>";
	xmlTestString = "<element><e0><e1><e2><e3/></e2></e1></e0></element>";
	element.ParseXml(xmlString);
	if(element.GetXmlFromElement() != xmlTestString)
		Print(element.GetXmlFromElement() + "!=" + xmlTestString);
	element.Clear();
	
	xmlString = "<element>\n<e1/><e0/><e2><e3/><e4/></e2>\n<e5/></element>";
	xmlTestString = "<element><e1/><e0/><e2><e3/><e4/></e2><e5/></element>";
	element.ParseXml(xmlString);
	if(element.GetXmlFromElement() != xmlTestString)
		Print(element.GetXmlFromElement() + "!=" + xmlTestString);
	element.Clear();
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
