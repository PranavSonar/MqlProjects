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

   double pip = MathAbs(OrderOpenPrice()-OrderStopLoss());
   double pipC = MathAbs(OrderOpenPrice()-OrderClosePrice());
   double delta = MarketInfo (OrderSymbol(), MODE_TICKVALUE) / MarketInfo(OrderSymbol(), MODE_TICKSIZE);
   double p = pip*delta*OrderLots();
   double pC = pipC*delta*OrderLots();
   
   if(pC == 0.0)
   	pC = 1.0;
   
   double exchange = OrderProfit()/pC;
   p *= exchange;
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
   investmentProtected += p;
   
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
		double closingQuoteOnHomeCurrency = money.CalculateCurrencyPrice(false,true);
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
		
		if(closingQuoteOnHomeCurrency == 0.0)
			closingQuoteOnHomeCurrency = 1.0;
		
		//double pip = MarketInfo (OrderSymbol(), MODE_TICKVALUE) / MarketInfo(OrderSymbol(), MODE_TICKSIZE)*MarketInfo (OrderSymbol(), MODE_POINT);
		//double myP = MathAbs(OrderOpenPrice()-OrderClosePrice());
		//double delta = MarketInfo (OrderSymbol (), MODE_TICKVALUE) / MarketInfo(OrderSymbol(), MODE_TICKSIZE);
		//myP = myP*delta*OrderLots();
		int accountLeverage = AccountLeverage();
		double realDelta =  (closePrice-openPrice);
		//(OrderType() == OP_BUY ? (closePrice-openPrice) : 0.0) + 
		//	(OrderType() == OP_SELL ? (openPrice-closePrice) : 0.0);
		//double inverseDelta = (OrderType() == OP_SELL ? (closePrice-openPrice) : 0.0) + 
		//	(OrderType() == OP_BUY ? (openPrice-closePrice) : 0.0);
		double orderProfitTest = realDelta * closingQuoteOnHomeCurrency*accountLeverage*orderLots* MarketInfo (OrderSymbol(), MODE_TICKVALUE) ;
		
		printf("[%d]: OrderOpenTime=%s OrderOpenPrice=%f OrderCloseTime=%s OrderClosePrice=%f", i, TimeToStr(openTime), openPrice, TimeToStr(closeTime), closePrice);
		printf("[%d]: Symbol: %s OrderType=%s OrderCommission=%f ClosingQuoteOnHomeCurrency=%f", i, OrderSymbol(), orderType, orderCommission, closingQuoteOnHomeCurrency);
		printf("[%d]: CalculatedOrderProfitWithoutCommission=%f RealOrderProfitWithoutCommission=%f", i, getInvestment(), orderProfitReal - orderCommission);
		printf("[%d]: AccountLeverage=%d AccountMargin=%f", i, accountLeverage, AccountMargin());
		
		//nr loturi = AccountFreeMarginCheck(OrderSymbol(),OrderType(),OrderLots()) / MarketInfo(OrderSymbol(), MODE_MARGINREQUIRED);
		//nr loturi/simbol = 1000 = MarketInfo(OrderSymbol(), MODE_LOTSIZE);
		
		printf("[%d]: AccountFreeMarginCheck=%f / MarginRequired=%f = Lots=%f ; LotSize=%f realDelta=%f", i,
			AccountFreeMarginCheck(OrderSymbol(),OrderType(),OrderLots()),
			MarketInfo(OrderSymbol(), MODE_MARGINREQUIRED),
			orderLots,
			MarketInfo(OrderSymbol(), MODE_LOTSIZE),
			realDelta);
		// some work with order
	}
	
	return(INIT_SUCCEEDED);
}
