//+------------------------------------------------------------------+
//|                                            TestRobertProgram.mq4 |
//|                                        Copyright Robert Costache |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Robert Costache & co (Alexandru Chirita)"
#property link      ""
#property version   "1.00"
#property strict

#include "../../MqlLibs/TransactionManagement/BaseTransactionManagement.mq4"
#include "../../MqlLibs/VerboseInfo/ScreenInfo.mq4"

BaseTransactionManagement tran;
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
int MagicNo, CurrentOpenOrders;
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
	CurrentOpenOrders = 0;
	SumCompute();   
	ModifyOrders();
	if (TargetSL == 0.00)
	{
		OpenNewOrder();
	}
	else
	if (CurrentOpenOrders < MaxOrderOpen)
	{ 
		TestNewOrder();
	}
	if (CurrentOpenOrders > StartTestClose)
	{
		tran.TestCloseProfit();
	}
	CurentValue();
}
 
void LotsDividerCompute()
{
	Lotsdivider = 0;
	for(int i=1;i<=MaxOrderOpen;i++)
	{
		Lotsdivider = Lotsdivider + MathPow(2,i-1);
	}
	Lotsdivider = Lotsdivider*(FxPairs/2);
}
 
void SumCompute()
{ 
   double SumLots;
   double SumOrders;
   double AveragePrice;
   TargetTP = 0.00;
   TargetSL = 0.00;
  
   SumLots = 0.00;
   SumOrders = 0.00;
   AveragePrice = 0.00;
   OrderIsBuy = -1;
   
   for(int i= OrdersTotal()-1;i>=0;OrderSelect(--i, SELECT_BY_POS))
   {
      if (OrderSymbol() == Symbol())
      {
         SumLots = SumLots + OrderLots();
         SumOrders = SumOrders + (OrderLots()*OrderOpenPrice());
         if (OrderType() == OP_BUY) //Returns order operation type of the currently selected order.
            OrderIsBuy = 1;
         else
            OrderIsBuy = 0;
         CurrentOpenOrders = CurrentOpenOrders + 1;
      }
   }  
	
	if (SumLots > 0.00)
	{
		AveragePrice = SumOrders / SumLots;
	}
	  
	if (OrderIsBuy == 1)
	{
		TargetTP = AveragePrice + TpLimitPips*Point*10 + (ComputeSpread);
		TargetSL = AveragePrice - SlLimitPips*Point*10 - (ComputeSpread);
	}
	else if (OrderIsBuy == 0)
	{ 
		TargetTP = AveragePrice - TpLimitPips*Point*10 - (ComputeSpread);
		TargetSL = AveragePrice + SlLimitPips*Point*10 + (ComputeSpread);
	}  
}
 
void ModifyOrders()
{
   int Ticket;
   if ((TargetTP > 0) && (TargetSL>0))
   {
      int total = OrdersTotal(); //Returns the number of market and pending orders.
      for(int i=total-1;i>=0;i--)
      {
         Ticket = OrderSelect(i, SELECT_BY_POS); //The function selects an order for further processing.
         if (OrderSymbol() == Symbol())
         {
            if (OrderStopLoss() != TargetSL) //Returns stop loss value of the currently selected order.
               if (TargetSL > 0)
                  Ticket = OrderModify(OrderTicket(),OrderOpenPrice(),TargetSL,TargetTP,0,Blue);
            if (OrderTakeProfit() != TargetTP) //Returns take profit value of the currently selected order.
               if (TargetTP > 0)
                  Ticket = OrderModify(OrderTicket(),OrderOpenPrice(),TargetSL,TargetTP,0,Blue); //Modification of characteristics of the previously opened or pending orders.
				//Returns ticket number of the currently selected order.
				//Returns open price of the currently selected order.
         }
      }
   }
}
 
void OpenNewOrder()
{ 
   double RSIValue;
   int Ticket;
   Initialisation();
   RSIValue = iRSI(Symbol(), PERIOD_H1, 14, 4, 0); // Calculates the Relative Strength Index indicator and returns its value.
   	//Returns the name of a symbol of the current chart.

   if (ContinueRunning == 1)
   {
      if (RSIValue < 50)
      {
         Ticket = OrderSend(Symbol(),OP_SELL,ManagementLots,Bid,3,0,0,"iRSI Level = "+DoubleToStr(NormalizeDouble(RSIValue,2),2),MagicNo,0,clrRed); // The main function used to open market or place a pending order.
      }
      else
      {
         Ticket = OrderSend(Symbol(),OP_BUY,ManagementLots,Ask,3,0,0,"iRSI Level = "+DoubleToStr(NormalizeDouble(RSIValue,2),2),MagicNo,0,clrGreen); // The main function used to open market or place a pending order.
      }  
   }
   ComputeSpread = Ask-Bid;  
}
 
void TestNewOrder()
{  
   int Ticket;
   double NextLotNumber;
   double RSIValue;
   string PrintValue;
   RSIValue = iRSI(Symbol(), PERIOD_H1, 14, 4, 0); //Calculates the Relative Strength Index indicator and returns its value.
  	// Returns the name of a symbol of the current chart.

   NextLotNumber = ManagementLots*MathPow(2,CurrentOpenOrders); //The function raises a base to a specified power.
   PrintValue = "Cont"+IntegerToString(CurrentOpenOrders+1)+" iRSI = "+DoubleToStr(NormalizeDouble(RSIValue,2),2); //This function converts value of integer type into a string of a specified length and returns the obtained string.
	   //Returns text string with the specified numerical value converted into a specified precision format.
	   // Rounding floating point number to a specified accuracy.
  
   if (OrderIsBuy == 1)
   {
      if ((Ask - TargetSL)/Point/10 < 2*SlLimitPips/3)
         Ticket = OrderSend(Symbol(),OP_BUY,NextLotNumber,Ask,3,0,0,PrintValue,MagicNo,0,clrGreen); //The main function used to open market or place a pending order.
   }
   else
      if (OrderIsBuy == 0)
      {
         if ((TargetSL - Bid)/Point/10 < 2*SlLimitPips/3)
            Ticket = OrderSend(Symbol(),OP_SELL,NextLotNumber,Bid,3,0,0,PrintValue,MagicNo,0,clrRed); //The main function used to open market or place a pending order.      
      }
}
 
void Initialisation()
{
   string CurrentCurrency, BaseCurrency, SecondCurrency;
   double TotalAmount, TotalLot, ComputePrice;
   ComputePrice = 0;
   MagicNo = 0;
  
   LotsDividerCompute();
     
   ObjectsDeleteAll(0, OBJ_TEXT); //Removes all objects from the specified chart, specified chart subwindow, of the specified type.
   ObjectsDeleteAll(0, OBJ_LABEL);
  
   CurrentCurrency = StringSubstr(Symbol(),0,6); //Extracts a substring from a text string starting from the specified position.
   	//Returns the name of a symbol of the current chart.
   BaseCurrency = StringSubstr(CurrentCurrency,0,3);
   SecondCurrency = StringSubstr(CurrentCurrency,3,3);
   TotalAmount = AccountBalance()+AccountCredit(); //Returns balance value of the current account.
   	//Returns credit value of the current account.
  
   if (BaseCurrency == "AUD")
   {
      ComputePrice = MarketInfo("AUDUSD",MODE_BID); //Returns various data about securities listed in the "Market Watch" window.
     MagicNo = 658568;
   }
   if (BaseCurrency == "CAD")
   {
      ComputePrice = 1/MarketInfo("USDCAD",MODE_BID);
      MagicNo = 676568;
   }
   if (BaseCurrency == "CHF")
   {
      ComputePrice = 1/MarketInfo("USDCHF",MODE_BID);
      MagicNo = 677270;
   }
   if (BaseCurrency == "EUR")
   {
      ComputePrice = MarketInfo("EURUSD",MODE_BID);
      MagicNo = 698582;
   }
   if (BaseCurrency == "GBP")
   {
      ComputePrice = MarketInfo("GBPUSD",MODE_BID);
      MagicNo = 716680;
   }
   if (BaseCurrency == "NZD")
   {
      ComputePrice = MarketInfo("NZDUSD",MODE_BID);
      MagicNo = 789068;
   }
   if (BaseCurrency == "SGD")
   {
      ComputePrice = 1/MarketInfo("USDSGD",MODE_BID);
      MagicNo = 837168;
   }
   if (BaseCurrency == "USD")
   {
      ComputePrice = 1.00;
      MagicNo = 858368;
   }
     
   if (SecondCurrency == "AUD")
   {
      MagicNo = MagicNo + 658568;
   }
   if (SecondCurrency == "CAD")
   {
      MagicNo = MagicNo + 676568;
   }
   if (SecondCurrency == "CHF")
   {
      MagicNo = MagicNo + 677270;
   }
   if (SecondCurrency == "EUR")
   {
      MagicNo = MagicNo + 698582;
   }
   if (SecondCurrency == "GBP")
   {
      MagicNo = MagicNo + 716680;
   }
   if (SecondCurrency == "NZD")
   {
      MagicNo = MagicNo + 789068;
   }
   if (SecondCurrency == "SGD")
   {
      MagicNo = MagicNo + 837168;
   }
   if (SecondCurrency == "USD")
   {
      MagicNo = MagicNo + 858368;
   }  
   if (MagicNo == 0)
   {
      MagicNo = 999999;
   }
   
   TotalLot = NormalizeDouble(TotalAmount/ComputePrice/10.00,2); // Rounding floating point number to a specified accuracy.
   ManagementLots = NormalizeDouble(TotalLot / 100.00*UsagePercentage/Lotsdivider,2); // Rounding floating point number to a specified accuracy.
   ComputeSpread = Ask-Bid; //The latest known seller's price (ask price) for the current symbol. 
   	//The latest known buyer's price (offer price, bid price) of the current symbol.
}
 
void CurentValue()
{
	double CV = tran.GetOrdersProfit();
	color text_color = clrNONE;
	
	if (CV <= 0.00)
		text_color = Red;
	else
		text_color = Lime;
	
	scrn.DeleteAllObjectsTextAndLabel();
	scrn.ShowTextValue("current value","CurrentValue = "+DoubleToString(CV,2));
}
