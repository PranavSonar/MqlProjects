//+------------------------------------------------------------------+
//|                                                 SimpleTestBB.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/DecisionMaking/Decision3MA.mqh>
#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>
#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <MyMql/Generator/GenerateTPandSL.mqh>
#include <MyMql/Info/ScreenInfo.mqh>
#include <MyMql/Info/VerboseInfo.mqh>
#include <MyMql/Log/WebServiceLog.mqh>

int OnInit()
{
	return INIT_SUCCEEDED;//ExpertValidationsTest(Symbol());
}

void OnDeinit(const int reason)
{
}


static FlowWithTrendTranMan transaction;

void OnTick() {
	Decision3MA decision;
	BaseMoneyManagement money;
	ScreenInfo screen;
	GenerateTPandSL generator;
	//WebServiceLog wsLog(false);
	BaseWebServiceLog wsLog();
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/money.Pip();
	
	transaction.SetSimulatedOrderObjectName("SimulatedOrder3MA");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLoss3MA");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfit3MA");
	
	double d = decision.GetDecision(0);

	// calculate profit/loss, TPs, SLs, etc
	transaction.CalculateData(0);
	
	wsLog.DataLog("OrdersToString", transaction.OrdersToString(true));
	
	// add best old transaction data
	transaction.AddInitializerTransactionData(2.6*spreadPips, 2.6*spreadPips);
	transaction.AddInitializerTransactionData(2.6*spreadPips, 1.1*spreadPips);
	transaction.AddInitializerTransactionData(2.6*spreadPips, 1.88*spreadPips);
	transaction.AddInitializerTransactionData(3*spreadPips, 2.6*spreadPips);
	transaction.AddInitializerTransactionData(2.6*spreadPips, 0.3*spreadPips);
	transaction.AddInitializerTransactionData(2.6*spreadPips, 0.1*spreadPips); 
	transaction.AddInitializerTransactionData(2.6*spreadPips, 1.53*spreadPips);
	transaction.AddInitializerTransactionData(2.6*spreadPips, 1.83*spreadPips);
	
	if(d != IncertitudeDecision)
	{
		if(d > 0.0) { // Buy
			double price = MarketInfo(Symbol(), MODE_ASK); // Ask
			money.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_BUY, price, false, spread);
			if((TP != 0.0) || (SL != 0.0))
				generator.ValidateAndFixTPandSL(TP, SL, price, OP_BUY, spread, false);
			transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.01, price, 0, SL, TP, NULL, 0, 0, clrNONE);
			int tichet = OrderSend(Symbol(), OP_BUY, 0.01, price, 0, SL, TP, NULL, 0, 0, clrAqua);
			
			if(tichet == -1)
				Print("Failed! Reason: " + IntegerToString(GetLastError()));
			
			wsLog.DataLog("NewOrder", "New order buy " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			wsLog.DataLog("OrdersToString", transaction.OrdersToString(true));
		} else { // Sell
			double price = MarketInfo(Symbol(), MODE_BID); // Bid
			money.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_SELL, price, false, spread);
			if((TP != 0.0) || (SL != 0.0))
				generator.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, false);
			transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.01, price, 0, SL, TP, NULL, 0, 0, clrNONE);
			int tichet = OrderSend(Symbol(), OP_SELL, 0.01, price, 0, SL, TP, NULL, 0, 0, clrChocolate);
			
			if(tichet == -1)
				Print("Failed! Reason: " + IntegerToString(GetLastError()));
			
			wsLog.DataLog("NewOrder", "New order sell " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			wsLog.DataLog("OrdersToString", transaction.OrdersToString(true));
		}
		
		screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(-1)),clrGray, 20, 0);
		screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
		screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
	}
	
	
	transaction.GetBestTPandSL(TP, SL);
	Comment("Maximum profit: " + DoubleToStr(transaction.GetTotalMaximumProfitFromOrders(),2)
		+ "\nMinimum profit: " + DoubleToStr(transaction.GetTotalMinimumProfitFromOrders(),2)
		+ "\n[Medium profit]: " + DoubleToStr(transaction.GetTotalMediumProfitFromOrders(),2)
		+ "\n\nTake profit (best from average): " + DoubleToStr(TP,4)
		+ "\nStop loss (best from average): " + DoubleToStr(SL,4)
		+ "\nSpread: " + DoubleToStr(spreadPips, 4)
		+ "\nTake profit / Spread (best from average): " + DoubleToStr(TP/spreadPips,4)
		+ "\nStop loss / Spread (best from average): " + DoubleToStr(SL/spreadPips,4)
		);
		
	transaction.FlowWithTrend_UpdateSL_TP_UsingConstants(2.6*spreadPips, 1.6*spreadPips);
	
	wsLog.EndTradingSession();
}	