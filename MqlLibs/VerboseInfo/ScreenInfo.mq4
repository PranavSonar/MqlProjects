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
		
		virtual void ShowTextValue(string objectName, string value, color textColor = clrNONE, int x = 20, int y = 20, int corner = 1, int size = 14, string font = "Tahoma")
		{
			ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
			ObjectSet(objectName, OBJPROP_CORNER, corner);
			ObjectSet(objectName, OBJPROP_XDISTANCE, x);
			ObjectSet(objectName, OBJPROP_YDISTANCE, y);
			ObjectSetText(objectName, value, size, font, textColor); //The function changes the object description.
		}
		
		virtual string NewObjectName(string prefix, int magicNumber = 0)
		{
			int nr = magicNumber;
			string name = prefix + IntegerToString(nr);
			while(ObjectFind(ChartID(), name) >= 0)
			{
				nr++;
				name = prefix + IntegerToString(nr);
			}
			return name;
		}
		
		
		virtual string ReplaceObjectName(string prefix, int magicNumber = 0)
		{
			int nr = magicNumber;
			string name = prefix + IntegerToString(nr);
			while(ObjectFind(ChartID(), name) < 0)
			{
				nr++;
				name = prefix + IntegerToString(nr);
			}
			ObjectDelete(ChartID(),name);
			
			return name;
		}
		
		virtual string LastObjectName(string prefix)
		{
			int nr = 0;
			string name = prefix + IntegerToString(nr);
			while(ObjectFind(ChartID(), name) >= 0)
			{
				nr++;
				name = prefix + IntegerToString(nr);
			}
			return name;
		}
		
		virtual void PrintCurrentValue(double value = 0.0, string objectName = "CV", color textColor = clrNONE)
		{
			if(textColor == clrNONE)
			{
				if (value < 0.00)
					textColor = Red;
				else if (value == 0.0)
					textColor = Gray;
				else
					textColor = Lime;
			}
			
			if(ObjectFind(ChartID(),objectName) >= 0)
				ObjectDelete(ChartID(),objectName);
			
			ShowTextValue(objectName, "CurrentValue: " + DoubleToString(value,2), textColor);
		}
};
