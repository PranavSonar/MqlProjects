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
	
	element.ParseXml("<element a=\"b\"/>");
	if(element.GetXmlFromElement() != "<element a=\"b\"/>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("<element/>");
	if(element.GetXmlFromElement() != "<element/>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("<element/>\n");
	if(element.GetXmlFromElement() != "<element/>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("\n\n\n\n<element/>");
	if(element.GetXmlFromElement() != "<element/>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("<element/>\n\n\n");
	if(element.GetXmlFromElement() != "<element/>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("<element></element>");
	if(element.GetXmlFromElement() != "<element/>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("<element>\n</element>");
	if(element.GetXmlFromElement() != "<element/>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("<element>\n<e1/>\n</element>");
	if(element.GetXmlFromElement() != "<element><e1/></element>")
		Print(element.GetXmlFromElement());
	element.Clear();
	
	element.ParseXml("<element>\n<e1/><e2><e3/></e2>\n</element>");
	if(element.GetXmlFromElement() != "<element><e1/><e2><e3/></e2></element>")
		SafePrintString(element.GetXmlFromElement());
	element.Clear();
	
	
	element.ParseXml("<element><e0><e3/><es/><e1><ex/><eb/><e2><ev/><xa/><f3/></e2><ef/><ek/></e1><ec/><e5/></e0><fs/><2d/></element>");
	if(element.GetXmlFromElement() != "<element><e0><e3/><es/><e1><ex/><eb/><e2><ev/><xa/><f3/></e2><ef/><ek/></e1><ec/><e5/></e0><fs/><2d/></element>")
		SafePrintString(element.GetXmlFromElement() + " != <element><e0><e3/><es/><e1><ex/><eb/><e2><ev/><xa/><f3/></e2><ef/><ek/></e1><ec/><e5/></e0><fs/><2d/></element>");
	element.Clear();
	
	
	element.ParseXml("<element>\n<e0><e1><e2><e3/></e2></e1></e0>\n</element>");
	if(element.GetXmlFromElement() != "<element><e0><e1><e2><e3/></e2></e1></e0></element>")
		SafePrintString(element.GetXmlFromElement() + " != <element><e0><e1><e2><e3/></e2></e1></e0></element>");
	element.Clear();
	

	element.ParseXml("<element>\n<e1/><e0/><e2><e3/><e4/></e2>\n<e5/></element>");
	if(element.GetXmlFromElement() != "<element><e1/><e0/><e2><e3/><e4/></e2><e5/></element>")
		SafePrintString(element.GetXmlFromElement() + " != <element><e1/><e0/><e2><e3/><e4/></e2><e5/></element>" );
	element.Clear();
	
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
