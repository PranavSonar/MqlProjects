#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int OnInit()
{
	EventSetTimer(60);
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	EventKillTimer();
}

void OnTick()
{
	
}

void OnTimer()
{
	
}

double OnTester()
{
	double ret=0.0;
	
	return(ret);
}

void OnChartEvent(
	const int id,
	const long &lparam,
	const double &dparam,
	const string &sparam
)
{

}