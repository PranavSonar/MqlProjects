//+------------------------------------------------------------------+
//|                                           TestChartFunctions.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Charts\Chart.mqh>

int OnInit()
{
	//--- create timer
	EventSetTimer(1);
	
//	long lastChartId = chart.ChartId()-1;
//	
//	while(chart.ChartId() != lastChartId)
//	  {
//	  	chart.Attach();
//	  	chart.ColorBackground(clrAliceBlue);
//	  	chart.Detach();
//	  	
//	   lastChartId = chart.ChartId();
//	   chart.NextChart();
//	   
//	   lastChartId = chart.ChartId();
//	  }
////	
//	for(int i=0;i<chart.WindowsTotal();i++)
//	  {
//	  }
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	//--- destroy timer
	EventKillTimer();
}

void OnTick()
{
	
}

void OnTimer()
{
	CChart chart;
	
	long currChart,prevChart=ChartFirst();
	int i=0,limit=100;
	Print("ChartFirst =",ChartSymbol(prevChart)," ID =",prevChart);
	RecolorChart(prevChart);
	
	// from the ChartNext documentation (url: https://docs.mql4.com/en/chart_operations/chartnext )
	while(i<limit)// We have certainly not more than 100 open charts
	{
		currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID
		if(currChart<0) break;          // Have reached the end of the chart list
		Print(i,ChartSymbol(currChart)," ID =",currChart);
		RecolorChart(currChart);
		
		prevChart=currChart;// let's save the current chart ID for the ChartNext()
		i++;// Do not forget to increase the counter
	}
	
	//long oldChartId = ChartID();
	//long chartId = ChartOpen(Symbol,period);
	//ChartNext(chartId);
	//ChartClose(oldChartId);
	
}

void RecolorChart(long chartId, color chartColor = clrBlack)
{
	CChart chart;
	chart.Attach(chartId);
  	chart.ColorBackground(chartColor);
  	chart.Redraw();
  	chart.Detach();
}