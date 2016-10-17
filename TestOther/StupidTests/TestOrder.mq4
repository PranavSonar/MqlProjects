//+------------------------------------------------------------------+
//|                                                       Test02.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Base\BeforeObject.mqh>
#include <Files/FileTxt.mqh>

double atan2(double y,double x)
/*
Returns the principal value of the arc tangent of y/x,
expressed in radians. To compute the value, the function 
uses the sign of both arguments to determine the quadrant.
y - double value representing an y-coordinate.
x - double value representing an x-coordinate. 
*/
{
	double a;
	if(fabs(x)>fabs(y))
		a=atan(y/x);
	else
	{
		a=atan(x/y); // pi/4 <= a <= pi/4
	if(a<0.)
		a=-1.*M_PI_2-a; //a is negative, so we're adding
	else
		a=M_PI_2-a;
	}
	if(x<0.)
	{
		if(y<0.)
			a=a-M_PI;
		else
			a=a+M_PI;
	}
	return a;
}

void ShowObject(string objectName, datetime timeFirst, double closeFirst, datetime timeLast, double closeLast, color objectColor)
{
	// we should limit the shit we're doing on the chart, really now XD
	if(ObjectsTotal(ChartID()) > 500)
		return;
	//ObjectsDeleteAll(ChartID());
	
	datetime auxTime; double auxPrice;
	if(timeFirst < timeLast)
	{
		auxTime = timeFirst; timeFirst = timeLast; timeLast = auxTime;
		auxPrice = closeFirst; closeFirst = closeLast; closeLast = auxPrice;
	}
	
	double angle = (timeFirst - timeLast) / (closeFirst - closeLast);
	bool selection = false;
	long chartId = ChartID();
	ObjectCreate(chartId, objectName, OBJ_GANNLINE, 0, timeLast, closeLast, timeFirst, closeFirst);
	ObjectSet(objectName, OBJPROP_COLOR, objectColor);
	ObjectSet(objectName, OBJPROP_WIDTH, 0.3);
	ObjectSet(objectName, OBJPROP_RAY_RIGHT, false);
	ObjectSetInteger(chartId, objectName, OBJPROP_SELECTABLE, selection); 
	ObjectSetInteger(chartId, objectName, OBJPROP_SELECTED, selection);
	ObjectSetDouble(chartId, objectName, OBJPROP_ANGLE, angle); 
}


void OnInit()
{
	
	string objectName = "SimulatedOrderObject";
	ShowObject(objectName, Time[1], Close[1], Time[100], Close[100], Red);
	ShowObject(objectName + "0", Time[100], Close[100], Time[2], Close[2], Blue);
	ShowObject(objectName + "1", Time[3], Close[3], Time[101], Close[101], Yellow);
	ShowObject(objectName + "2", Time[4], Close[4], Time[104], Close[104], Aqua);
	ShowObject(objectName + "3", Time[12], Close[12], Time[1], Close[1], Green);
	ShowObject(objectName + "4", Time[12], Close[12], Time[2], Close[2], Maroon);
}
