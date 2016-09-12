//+------------------------------------------------------------------+
//|                                                 SimpleTestBB.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>
#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>
#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <MyMql/Generator/GenerateTPandSL.mqh>
#include <MyMql/Info/ScreenInfo.mqh>
#include <MyMql/Info/VerboseInfo.mqh>
#include <MyMql/Log/WebServiceLog.mqh>


int OnInit()
{
	lastDecision = 0.0;
	nrDecisions = 0;
	return INIT_SUCCEEDED;// ExpertValidationsTest(Symbol());
}

void OnDeinit(const int reason)
{
}


static FlowWithTrendTranMan transaction;
static double lastDecision;
static int nrDecisions;


static WebServiceLog wsLog(false);
//BaseWebServiceLog wsLog();

void OnTick()
{
	
	DecisionDoubleBB decision;
	BaseMoneyManagement money;
	ScreenInfo screen;
	GenerateTPandSL generator;
	
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/money.Pip();
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	transaction.SetSimulatedOrderObjectName("SimulatedOrderBA");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLossBA");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfitBA");
	//transaction.AddInitializerTransactionData(0.5, 0.5); // BB doesn't need shit
	//transaction.AddInitializerTransactionData(0.2, 0.2);

	//transaction.AddInitializerTransactionData(2.6*spreadPips, 1.6*spreadPips); 
	
	
	double d = decision.GetDecision(SL, TP);
	
	if((d != IncertitudeDecision) && (d == lastDecision))
		nrDecisions++;
	else
		nrDecisions = 0;
	
	// calculate profit/loss, TPs, SLs, etc
	//transaction.CalculateData();
	double lots = money.GetLotsBasedOnDecision(d, false);
	
	wsLog.DataLog("OrdersToString", transaction.OrdersToString(true));
	
	if((d != IncertitudeDecision) && (nrDecisions == 0))
	{
		Print(DoubleToStr(d,2));
		if(d > 0) { // Buy
			double price = MarketInfo(Symbol(),MODE_ASK); // Ask
			//money.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_BUY, price, false, spread);
			
			if((TP != 0.0) || (SL != 0.0))
				generator.ValidateAndFixTPandSL(TP, SL, price, OP_BUY, spread, false);
			int tichet = OrderSend(Symbol(), OP_BUY, lots, price, 0, SL, TP, NULL, 0, 0, clrAqua);
			
			if(tichet == -1)
				Print("Failed! Reason: " + IntegerToString(GetLastError()));
			else	
				transaction.SimulateOrderSend(Symbol(), OP_BUY, lots, price, 0, SL ,TP, NULL, 0, 0, clrNONE, 0, tichet);
			
			wsLog.DataLog("NewOrder", "New order buy " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			wsLog.DataLog("OrdersToString", transaction.OrdersToString(true));
		} else { // Sell
			double price = MarketInfo(Symbol(),MODE_BID); // Bid
			//money.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_SELL, price, false, spread);
			
			if((TP != 0.0) || (SL != 0.0))
				generator.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, false);
			transaction.SimulateOrderSend(Symbol(), OP_SELL, lots, price, 0, SL, TP, NULL, 0, 0, clrNONE);
			int tichet = OrderSend(Symbol(), OP_SELL, lots, price, 0, SL, TP, NULL, 0, 0, clrChocolate);
			
			if(tichet == -1)
				Print("Failed! Reason: " + IntegerToString(GetLastError()));
			
			wsLog.DataLog("NewOrder", "New order sell " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			wsLog.DataLog("OrdersToString", transaction.OrdersToString(true));
		}
		
		screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders()),clrGray, 20, 0);
		screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
		screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
	}
	
	lastDecision = d;
	
	//transaction.GetBestTPandSL(TP, SL);
	//Comment("Maximum profit: " + DoubleToStr(transaction.GetTotalMaximumProfitFromOrders(),2)
	//	+ "\nMinimum profit: " + DoubleToStr(transaction.GetTotalMinimumProfitFromOrders(),2)
	//	+ "\n[Medium profit]: " + DoubleToStr(transaction.GetTotalMediumProfitFromOrders(),2)
	//	+ "\n\nTake profit (best from average): " + DoubleToStr(TP,4)
	//	+ "\nStop loss (best from average): " + DoubleToStr(SL,4)
	//	+ "\nSpread: " + DoubleToStr(spreadPips, 4)
	//	+ "\nTake profit / Spread (best from average): " + DoubleToStr(TP/spreadPips,4)
	//	+ "\nStop loss / Spread (best from average): " + DoubleToStr(SL/spreadPips,4)
	//	);
	
	//transaction.FlowWithTrend_UpdateSL_TP_UsingConstants(3*spreadPips, 2*spreadPips);
	//transaction.FlowWithTrend_UpdateSL_TP();
	
	wsLog.EndTradingSession();
}
