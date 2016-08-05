//+------------------------------------------------------------------+
//|                                                   ScreenInfo.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class ScreenInfo
{
	public:
		ScreenInfo() {}
		
		virtual void DeleteAllObjectsTextAndLabel(int subWindow = 0)
		{
			ObjectsDeleteAll(subWindow, OBJ_TEXT);
			ObjectsDeleteAll(subWindow, OBJ_LABEL);
   		}
	 		
		virtual void DeleteAllObjects(long chartId = 0) { ObjectsDeleteAll(chartId); }
		
		virtual void ShowTextValue(string objectName, string value, int x = 20, int y = 20, int corner = 1, int size = 14, string font = "Tahoma", color textColor = clrNONE)
		{
			ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
			ObjectSet(objectName, OBJPROP_CORNER, corner);
			ObjectSet(objectName, OBJPROP_XDISTANCE, x);
			ObjectSet(objectName, OBJPROP_YDISTANCE, y);
			ObjectSetText(objectName, value, size, font, textColor); //The function changes the object description.
		}
};
