//+------------------------------------------------------------------+
//|                                     TestRobertProgramChanged.mq4 |
//|               Copyright Robert Costache & co (Alexandru Chirita) |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Robert Costache & co (Alexandru Chirita)"
#property link      ""
#property version   "1.00"
#property strict

#include <MyMql/UnOwnedTransactionManagement/CrappyTranManagement.mqh>
#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/Global/Info/ScreenInfo.mqh>
#include <MyMql/Global/Money/Generator/LimitGenerator.mqh>

BaseMoneyManagement money;
LimitGenerator limitGenerator;
CrappyTranManagement tran;
ScreenInfo scrn;


input int MaxOrderOpen = 5;
input int StartTestClose = 4;
input int ContinueRunning = 1;
input double UsagePercentage = 60.00;
input double TpLimitPips = 30.00;
input double SlLimitPips = 50.00;
input double FxPairs = 8.00;


double ManagementLots;
double Lotsdivider;
double TargetTP, TargetSL, ComputeSpread;
int CurrentOpenOrders;
int OrderIsBuyValue;


int OnInit()
{
	Initialisation();
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	printf("OnDeinit: %d", reason);
}
 
void OnTick()
{
	RefreshRates(); // refresh Ask, Bid, etc
	
	CurrentOpenOrders = 0;
	SumCompute();   
	tran.ModifyOrders(TargetTP, TargetSL);
	
	if (TargetSL == 0.00)
		OpenNewOrder();
	else if (CurrentOpenOrders < MaxOrderOpen)
		TestNewOrder();
	
	if (CurrentOpenOrders > StartTestClose)
		tran.TestCloseProfit();
	
	scrn.PrintCurrentValue(tran.GetOrdersProfit());
}
 
void LotsDividerCompute()
{
	Lotsdivider = 0.0;
	for(int i=1;i<=MaxOrderOpen;i++)
		Lotsdivider = Lotsdivider + MathPow(2,i-1);
	Lotsdivider = Lotsdivider*(FxPairs/2.0);
}
 
void SumCompute()
{
	double AveragePrice = 0.00;
	TargetTP = 0.00;
	TargetSL = 0.00;
	OrderIsBuyValue = -1;
	
	tran.Get_OpenOrders_AvgPrice(CurrentOpenOrders, AveragePrice, OrderIsBuyValue);
	limitGenerator.CalculateTP_SL(TargetTP, TargetSL, TpLimitPips, SlLimitPips, OrderIsBuyValue, AveragePrice, _Symbol, ComputeSpread);
}
 
bool OpenNewOrder()
{
	bool statusOk = true;
	Initialisation();
	ComputeSpread = Ask-Bid;
	
	if (ContinueRunning == 1)
		statusOk = statusOk & tran.OpenOrderBasedOnRSI50(ManagementLots);
	return statusOk;
}
 
bool TestNewOrder()
{
	bool statusOk = true;
	double NextLotNumber = ManagementLots*MathPow(2,CurrentOpenOrders);
	double RSIValue = iRSI(Symbol(), PERIOD_H1, 14, 4, 0);
	string PrintValue = "Cont"+IntegerToString(CurrentOpenOrders+1)+" iRSI = "+DoubleToStr(NormalizeDouble(RSIValue,2),2);
	double pip = Point/10.0;
	
	if (OrderIsBuyValue == 1)
	{
		if ((Ask - TargetSL)/pip < SlLimitPips*0.66)
			statusOk = statusOk & (OrderSend(Symbol(),OP_BUY,NextLotNumber,Ask,3,0,0,PrintValue,0,0,clrGreen) > 0);
	}
	else if (OrderIsBuyValue == 0) //sell order
	{
		if ((TargetSL - Bid)/pip < SlLimitPips*0.66)
			statusOk = statusOk & (OrderSend(Symbol(),OP_SELL,NextLotNumber,Bid,3,0,0,PrintValue,0,0,clrRed) > 0);    
	}
	
	return statusOk;
}

void Initialisation()
{
	double TotalAmount = money.GetTotalAmount();
	double ComputePrice = money.CalculateCurrencyRateForSymbol(_Symbol, iTime(_Symbol,PERIOD_CURRENT,0),PERIOD_CURRENT,0);
	LotsDividerCompute();
	ComputeSpread = Ask-Bid;

	if(ComputePrice == 0.0)
	{
		ComputePrice = 1;
	}
	double TotalLot = NormalizeDouble(TotalAmount/ComputePrice/10.00,2);
	ManagementLots = NormalizeDouble(TotalLot / 100.00*UsagePercentage/Lotsdivider,2);
}
