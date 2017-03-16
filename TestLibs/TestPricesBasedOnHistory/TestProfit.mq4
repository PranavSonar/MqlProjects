//+------------------------------------------------------------------+
//|                                                   TestProfit.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/Global/Global.mqh>
#include <MyMql/Simulation/BaseSimulatedOrder.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
	BaseMoneyManagement money;
	
	int hstTotal = OrdersHistoryTotal();
	if(hstTotal == 0)
		Print("No orders until now on account " + IntegerToString(AccountNumber()) + ".");
	
	for(int i=0;i<hstTotal;i++)
	{
		// check selection result
		if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==false)
		{
			Print("Access to history failed with error (",GetLastError(),")");
			break;
		}
		
		string orderType = OrderTypeToString();
		
		if(orderType == "balance")
			continue;
		
		double openPrice = OrderOpenPrice();
		double closePrice = OrderClosePrice();
		datetime closeTime = OrderCloseTime();
		
		double stopLoss = OrderStopLoss();
		double takeProfit = OrderTakeProfit();
		double orderLots = OrderLots() * MarketInfo(OrderSymbol(), MODE_LOTSIZE);
		double orderProfitReal = OrderProfit();
		
		double changeRate = money.CalculateCurrencyRateForSymbol(OrderSymbol(), closeTime, PERIOD_CURRENT, 0);
		double orderProfitTest = (orderType == "sell" ? (openPrice - closePrice) : (closePrice - openPrice)) * orderLots * changeRate;
		
		double orderProfitTakeProfitTest = 0.0;
		if((orderProfitTest > 0.0) && (takeProfit != 0.0))
			orderProfitTakeProfitTest = (orderType == "sell" ? (openPrice - takeProfit) : (takeProfit - openPrice)) * orderProfitTest * orderLots * changeRate;
		
		
		double orderProfitStopLossTest = 0.0;
		if((orderProfitTest < 0.0) && (stopLoss != 0.0))
			orderProfitStopLossTest = (orderType == "sell" ? (openPrice - stopLoss) : (stopLoss - openPrice)) * orderLots * changeRate;
		
		printf("[%d]: realProfit=%f calculatedProfit=%f calculatedProfitStopLoss=%f calculatedProfitTakeProfit=%f", i, OrderProfit(), orderProfitTest, orderProfitStopLossTest, orderProfitTakeProfitTest);
		
		
		BaseSimulatedOrder order(OrderSymbol(), OrderOpenPrice(), OrderLots(), OrderType(), OrderTakeProfit(), OrderStopLoss(), OrderOpenTime(), OrderExpiration(), PERIOD_CURRENT);
		
		printf("[%d]: realProfit=%f calculatedProfit2=%f calculatedProfitStopLoss2=%f calculatedProfitTakeProfit2=%f", i, OrderProfit(),
			order.SimulatedOrderProfit(OrderCloseTime(), OrderClosePrice()),
			order.SimulatedOrderProfit(OrderCloseTime(), OrderStopLoss()),
			order.SimulatedOrderProfit(OrderCloseTime(), OrderTakeProfit()));
		
		printf("[%d]: Symbol: %s OrderType=%s Lots=%f", i, OrderSymbol(), orderType, OrderLots());
	}
	
	return(INIT_SUCCEEDED);
}
