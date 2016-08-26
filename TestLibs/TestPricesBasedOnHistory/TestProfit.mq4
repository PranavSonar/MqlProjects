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
#include <MyMql/Symbols/BaseSymbol.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

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
		
		double openPrice = OrderOpenPrice();
		datetime openTime = OrderOpenTime();
		double closePrice = OrderClosePrice();
		double stopLoss = OrderStopLoss();
		double takeProfit = OrderTakeProfit();
		datetime closeTime = OrderCloseTime();
		double orderLots = OrderLots() * MarketInfo(OrderSymbol(), MODE_LOTSIZE);
		double orderCommission = OrderCommission();
		double orderProfitReal = OrderProfit();
		int accountLeverage = AccountLeverage();
		
		double changeRate = money.CalculateCurrencyPrice(true, true, closeTime);
		double orderProfitTest = (orderType == "sell" ? (openPrice - closePrice) : (closePrice - openPrice)) * orderLots * changeRate;
		
		double orderProfitTakeProfitTest = 0.0;
		if((orderProfitTest > 0.0) && (takeProfit != 0.0))
			orderProfitTakeProfitTest = (orderType == "sell" ? (openPrice - takeProfit) : (takeProfit - openPrice)) * orderProfitTest * orderLots * changeRate;
		
		
		double orderProfitStopLossTest = 0.0;
		if((orderProfitTest < 0.0) && (stopLoss != 0.0))
			orderProfitStopLossTest = (orderType == "sell" ? (openPrice - stopLoss) : (stopLoss - openPrice)) * orderLots * changeRate;
			
		
		printf("[%d]: realProfit=%f calculatedProfit=%f calculatedProfitStopLoss=%f calculatedProfitTakeProfit=%f", i, OrderProfit(), orderProfitTest, orderProfitStopLossTest, orderProfitTakeProfitTest);
		printf("[%d]: Symbol: %s OrderType=%s OrderCommission=%f Lots=%f", i, OrderSymbol(), orderType, orderCommission, OrderLots());
	}
	
	return(INIT_SUCCEEDED);
}
