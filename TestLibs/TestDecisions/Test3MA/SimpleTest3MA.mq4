//+------------------------------------------------------------------+
//|                                                 SimpleTestBB.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/DecisionMaking/Decision3CombinedMA.mqh>
#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <Files/FileTxt.mqh>
#include <MyMql/Global/Global.mqh>

int OnInit()
{
	// print some verbose info
	//VerboseInfo vi;
	//vi.BalanceAccountInfo();
	//vi.ClientAndTerminalInfo();
	//vi.PrintMarketInfo();
	
	GlobalContext.DatabaseLog.Initialize(true);
	GlobalContext.DatabaseLog.NewTradingSession("SimpleTest3MA");
	
	if(IsTesting())
		return INIT_SUCCEEDED;
	return ExpertValidationsTest(Symbol());
}

void OnDeinit(const int reason)
{
}


static FlowWithTrendTranMan transaction;

void OnTick() {
	Decision3CombinedMA decision;
	
	//decision.SetVerboseLevel(1);
	//transaction.SetVerboseLevel(1);
	
	double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/Pip();
	
	transaction.SetSimulatedOrderObjectName("SimulatedOrder3MA");
	transaction.SetSimulatedStopLossObjectName("SimulatedStopLoss3MA");
	transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfit3MA");
	
	double d = decision.GetDecision();

	// calculate profit/loss, TPs, SLs, etc
	transaction.CalculateData();
	double lots = MarketInfo(_Symbol, MODE_MINLOT); //GlobalContext.Money.GetLotsBasedOnDecision(d, false); -> to be moved
	
	GlobalContext.DatabaseLog.DataLog("OrdersToString", transaction.OrdersToString(true));
	
	transaction.AutoAddTransactionData(spreadPips);
	
	if(d != IncertitudeDecision)
	{
		if(d > 0.0) { // Buy
			double price = MarketInfo(Symbol(), MODE_ASK); // Ask
			GlobalContext.Limit.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_BUY, price, false, spread);
			if((TP != 0.0) || (SL != 0.0))
				GlobalContext.Limit.ValidateAndFixTPandSL(TP, SL, price, OP_BUY, spread, false);
			transaction.SimulateOrderSend(Symbol(), OP_BUY, lots, price, 0, SL, TP, NULL, 0, 0, clrNONE);
			int tichet = OrderSend(Symbol(), OP_BUY, lots, price, 0, SL, TP, NULL, 0, 0, clrAqua);
			
			if(tichet == -1)
				Print("Failed! Reason: " + IntegerToString(GetLastError()));
			
			//GlobalContext.DatabaseLog.DataLog("NewOrder", "New order buy " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			//GlobalContext.DatabaseLog.DataLog("OrdersToString", transaction.OrdersToString(true));
		} else { // Sell
			double price = MarketInfo(Symbol(), MODE_BID); // Bid
			GlobalContext.Limit.CalculateTP_SL(TP, SL, 2.6*spreadPips, 1.6*spreadPips, OP_SELL, price, false, spread);
			if((TP != 0.0) || (SL != 0.0))
				GlobalContext.Limit.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, false);
			transaction.SimulateOrderSend(Symbol(), OP_SELL, lots, price, 0, SL, TP, NULL, 0, 0, clrNONE);
			int tichet = OrderSend(Symbol(), OP_SELL, lots, price, 0, SL, TP, NULL, 0, 0, clrChocolate);
			
			if(tichet == -1)
				Print("Failed! Reason: " + IntegerToString(GetLastError()));
			
			//GlobalContext.DatabaseLog.DataLog("NewOrder", "New order sell " + DoubleToStr(price) + " " + DoubleToStr(SL) + " " + DoubleToStr(TP));
			//GlobalContext.DatabaseLog.DataLog("OrdersToString", transaction.OrdersToString(true));
		}
		
		GlobalContext.Screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(-1)),clrGray, 20, 0);
		GlobalContext.Screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
		GlobalContext.Screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
	}
	
	double profit;
	int count, countNegative, countPositive, irregularLimitsType;
	bool irregularLimits;
	transaction.GetBestTPandSL(TP, SL, profit, count, countNegative, countPositive, irregularLimits, irregularLimitsType);
	string summary = "Best profit: " + DoubleToString(profit,2)
		+ "\nBest Take profit: " + DoubleToString(TP,4) + " (spreadPips * " + DoubleToString(TP/spreadPips,2) + ")" 
		+ "\nBest Stop loss: " + DoubleToString(SL,4) + " (spreadPips * " + DoubleToString(SL/spreadPips,2) + ")"
		+ "\nIrregular Limits: " + BoolToString(irregularLimits) + " Type: " + IntegerToString(irregularLimitsType)
		+ "\nCount orders: " + IntegerToString(count) + " (" + IntegerToString(countPositive) + " positive orders & " + IntegerToString(countNegative) + " negative orders); Procentual profit: " + DoubleToString((double)countPositive/(count>0?(double)count:1))
		+ "\n\nMaximum profit (sum): " + DoubleToString(transaction.GetTotalMaximumProfitFromOrders(),2)
		+ "\nMinimum profit (sum): " + DoubleToString(transaction.GetTotalMinimumProfitFromOrders(),2)
		+ "\nMedium profit (avg): " + DoubleToString(transaction.GetTotalMediumProfitFromOrders(),2)
		+ "\n\nSpread: " + DoubleToString(spreadPips, 4)
		+ "\nTake profit / Spread (best from average): " + DoubleToString(TP/spreadPips,4)
		+ "\nStop loss / Spread (best from average): " + DoubleToString(SL/spreadPips,4);
	//GlobalContext.DatabaseLog.DataLog("SimpleTest3MA on " + _Symbol, summary);
	//Comment(summary);
	
	transaction.FlowWithTrend_UpdateSL_TP_UsingConstants(2.6*spreadPips, 1.6*spreadPips);
	
	GlobalContext.DatabaseLog.EndTradingSession("SimpleTest3MA");
}	