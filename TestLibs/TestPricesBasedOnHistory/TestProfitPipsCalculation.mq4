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
#include <MyMql/Global/Symbols/BaseSymbol.mqh>
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
		//---- check selection result
		if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
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
		
		printf("[%d]: pipValue=%f point=%f pipValueChangeRate=%f", i,
			Pip(),
			Point(),
			money.PipChangeRateForSymbol(OrderSymbol(), closeTime, PERIOD_CURRENT, 0));
			
		printf("[%d]: pips=%f profitPerPip(based on lots)=%f finalProfitCalculated=%f", i,
			(orderType == "sell" ? (openPrice - stopLoss) : (stopLoss - openPrice))/Pip(), 
			(orderLots * money.PipChangeRateForSymbol(OrderSymbol(), closeTime, PERIOD_CURRENT, 0)),
			(orderType == "sell" ? (openPrice - stopLoss) : (stopLoss - openPrice))/(orderLots * money.PipChangeRateForSymbol(OrderSymbol(), closeTime, PERIOD_CURRENT, 0)));
		
		//MarketInfo(OrderSymbol(), MODE_MARGININIT)
		//MarketInfo(OrderSymbol(), MODE_MARGINMAINTENANCE)
		//MarketInfo(OrderSymbol(), MODE_MARGINREQUIRED)
		printf("[%d]: Symbol: %s OrderType=%s Lots=%f", i, OrderSymbol(), orderType, OrderLots());
	}
	
	return(INIT_SUCCEEDED);
}
