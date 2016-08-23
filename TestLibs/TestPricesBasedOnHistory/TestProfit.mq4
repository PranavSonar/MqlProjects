//+------------------------------------------------------------------+
//|                                                   TestProfit.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


double getInvestment(bool investmentTypeRisked = true)
// investmentTypeRisked = false (Protected investment) [When SL is used to get a profit, like Trailing Stop or manually set SL]
// investmentTypeRisked = true (Risked investment)
//------------------------------------------------------------------------------------------------------------------------------
{
   double investmentProtected = 0;

   double pip = OrderOpenPrice()-OrderStopLoss();
   double pipC = OrderOpenPrice()-OrderClosePrice();
   double delta = MarketInfo (OrderSymbol(), MODE_TICKVALUE) / MarketInfo(OrderSymbol(), MODE_TICKSIZE);
   double p = pip*delta*OrderLots();
   double pC = pipC*delta*OrderLots();
   //double profit = MarketInfo(Symbol(), MODE_TICKVALUE) * OrderLots() * pipC * 1000;
	//return profit;

   if(pC == 0.0)
   	pC = 1.0;
   
   p += OrderCommission();
   if(TimeDay(OrderOpenTime()) != TimeDay(OrderCloseTime())) // another day of the month
	   p += OrderSwap();
   if(!investmentTypeRisked && OrderProfit() > 0.0)
      investmentProtected += p;
   else if(investmentTypeRisked && 
   	((OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) ||
       (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) ||
       (OrderStopLoss() == 0.0))
            )
   investmentProtected += pC;
   
   return (investmentProtected);
}

int OnInit()
{
	int i, hstTotal=OrdersHistoryTotal();
	BaseMoneyManagement money;
	
	for(i=0;i<hstTotal;i++)
	{
		//---- check selection result
		if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
		{
			Print("Access to history failed with error (",GetLastError(),")");
			break;
		}
		double openPrice = OrderOpenPrice();
		datetime openTime = OrderOpenTime();
		double closePrice = OrderClosePrice();
		datetime closeTime = OrderCloseTime();
		
		double orderLots = OrderLots();
		double orderProfitReal = OrderProfit();
		double orderCommission = OrderCommission();
		string orderType = "";
		switch(OrderType())
		{
			case 0:
				orderType = "buy";
			break;
			case 1:
				orderType = "sell";		   
			break;
			case 2:
				orderType = "buy limit";		   
		   break;
			case 3:
				orderType = "sell limit";		   
		   break;
			case 4:
				orderType = "buy stop";		   
		   break;
			case 5:
				orderType = "sell stop";		   
		   break;
			case 6:
				orderType = "balance";		   
		   break;
			default:
				orderType = "-";
			break;
		}
		
		if(orderType == "balance")
			continue;
		
		//double pip = MarketInfo (OrderSymbol(), MODE_TICKVALUE) / MarketInfo(OrderSymbol(), MODE_TICKSIZE)*MarketInfo (OrderSymbol(), MODE_POINT);
		//double myP = MathAbs(OrderOpenPrice()-OrderClosePrice());
		//double delta = MarketInfo (OrderSymbol (), MODE_TICKVALUE) / MarketInfo(OrderSymbol(), MODE_TICKSIZE);
		//myP = myP*delta*OrderLots();
		int accountLeverage = AccountLeverage();
		double realDelta =
			(OrderType() == OP_BUY ? (OrderClosePrice()-OrderOpenPrice()) : 0.0) + 
			(OrderType() == OP_SELL ? (OrderOpenPrice()-OrderClosePrice()) : 0.0);
		double unRealDelta = OrderStopLoss() != 0.0 ? 
			((OrderType() == OP_BUY ? (OrderStopLoss()-OrderOpenPrice()) : 0.0) + 
			(OrderType() == OP_SELL ? (OrderOpenPrice()-OrderStopLoss()) : 0.0))
			: 0.0;
		
		//double inverseDelta = (OrderType() == OP_SELL ? (closePrice-openPrice) : 0.0) + 
		//	(OrderType() == OP_BUY ? (openPrice-closePrice) : 0.0);
		
		if(unRealDelta != 0.0)
			realDelta += unRealDelta;
		double orderProfitTest = realDelta * MarketInfo(OrderSymbol(), MODE_TICKVALUE) * AccountLeverage() * OrderLots();
		
		// almost OrderCommission() = realDelta *  MarketInfo(OrderSymbol(), MODE_TICKVALUE) * OrderLots() * MarketInfo (OrderSymbol(), MODE_POINT) * MarketInfo(OrderSymbol(), MODE_LOTSIZE)
		printf("[%d] ]%f[ %f %f %f %f",i ,OrderProfit(), orderProfitTest, realDelta, unRealDelta,  (realDelta+unRealDelta) * MarketInfo(OrderSymbol(), MODE_TICKVALUE) * AccountLeverage() * OrderLots());


		//printf("%f", MarketInfo (OrderSymbol(), MODE_POINT));     // 0.01
		//printf("%f", MarketInfo (OrderSymbol(), MODE_TICKVALUE)); // 10.0
		//printf("%f", MarketInfo (OrderSymbol(), MODE_TICKSIZE));  // 0.01
		//printf("%f", MarketInfo(OrderSymbol(), MODE_LOTSIZE)); // 1000.0
		//printf("%f", MarketInfo(OrderSymbol(), MODE_LOTSIZE)); // 1000.0
		
		//printf("[%d]: OrderOpenTime=%s OrderOpenPrice=%f OrderCloseTime=%s OrderClosePrice=%f", i, TimeToStr(openTime), openPrice, TimeToStr(closeTime), closePrice);
		printf("[%d]: Symbol: %s OrderType=%s OrderCommission=%f Lots=%f", i, OrderSymbol(), orderType, orderCommission, OrderLots());
		//printf("[%d]: 1=%f 2=%f 3=%f RealOrderProfit=%f", i, getInvestment(),  getInvestment(false), orderProfitTest, orderProfitReal);
		//printf("[%d]: AccountLeverage=%d AccountMargin=%f", i, accountLeverage, AccountMargin());
		
		//nr loturi = AccountFreeMarginCheck(OrderSymbol(),OrderType(),OrderLots()) / MarketInfo(OrderSymbol(), MODE_MARGINREQUIRED);
		//nr loturi/simbol = 1000 = MarketInfo(OrderSymbol(), MODE_LOTSIZE) = MarketInfo (OrderSymbol(), MODE_TICKVALUE)/MarketInfo (OrderSymbol(), MODE_TICKSIZE);
		
		//printf("[%d]: AccountFreeMarginCheck=%f / MarginRequired=%f = Lots=%f ; LotSize=%f realDelta=%f", i,
			//AccountFreeMarginCheck(OrderSymbol(),OrderType(),OrderLots()),
			//MarketInfo(OrderSymbol(), MODE_MARGINREQUIRED),
			//orderLots,
			//MarketInfo(OrderSymbol(), MODE_LOTSIZE),
			//realDelta);
		// some work with order
	}
	
	return(INIT_SUCCEEDED);
}
