//+------------------------------------------------------------------+
//|                                     TestRobertProgramChanged.mq4 |
//|               Copyright Robert Costache & co (Alexandru Chirita) |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Robert Costache & co (Alexandru Chirita)"
#property link      ""
#property version   "1.00"
#property strict

#include "../../MqlLibs/TransactionManagement/CrappyTranManagement.mq4"
#include "../../MqlLibs/MoneyManagement/BaseMoneyManagement.mq4"
#include "../../MqlLibs/VerboseInfo/ScreenInfo.mq4"

BaseMoneyManagement money;
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
int OrderIsBuy;


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
	
	scrn.CurrentValue(tran.GetOrdersProfit());
}
 
void LotsDividerCompute()
{
	Lotsdivider = 0;
	for(int i=1;i<=MaxOrderOpen;i++)
		Lotsdivider = Lotsdivider + MathPow(2,i-1);
	Lotsdivider = Lotsdivider*(FxPairs/2);
}
 
void SumCompute()
{
	double AveragePrice = 0.00;
	TargetTP = 0.00;
	TargetSL = 0.00;
	OrderIsBuy = -1;
	
	tran.Get_OpenOrders_AvgPrice(CurrentOpenOrders, AveragePrice, OrderIsBuy);
	money.CalculateTP_SL(TargetTP, TargetSL, OrderIsBuy, TpLimitPips, SlLimitPips, AveragePrice, ComputeSpread);
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
	
	if (OrderIsBuy == 1)
	{
		if ((Ask - TargetSL)/pip < SlLimitPips*0.66)
			statusOk = statusOk & (OrderSend(Symbol(),OP_BUY,NextLotNumber,Ask,3,0,0,PrintValue,0,0,clrGreen) > 0);
	}
	else if (OrderIsBuy == 0) //sell order
	{
		if ((TargetSL - Bid)/pip < SlLimitPips*0.66)
			statusOk = statusOk & (OrderSend(Symbol(),OP_SELL,NextLotNumber,Bid,3,0,0,PrintValue,0,0,clrRed) > 0);    
	}
	
	return statusOk;
}

void Initialisation()
{
	double TotalAmount = money.GetTotalAmount();
	double ComputePrice = money.CalculatePriceForUSD();
	double TotalLot = NormalizeDouble(TotalAmount/ComputePrice/10.00,2);
	
	LotsDividerCompute();
	ComputeSpread = Ask-Bid;
	
	ManagementLots = NormalizeDouble(TotalLot / 100.00*UsagePercentage/Lotsdivider,2);
}
