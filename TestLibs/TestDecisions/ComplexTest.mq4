//+------------------------------------------------------------------+
//|                                                  RunAllTests.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#property indicator_chart_window  // Drawing in the chart window
//#property indicator_separate_window // Drawing in a separate window
#property indicator_buffers 0       // Number of buffers
#property indicator_color1 Blue     // Color of the 1st line
#property indicator_color2 Red      // Color of the 2nd line

#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>
#include <MyMql/DecisionMaking/Decision3MA.mqh>
#include <MyMql/DecisionMaking/DecisionRSI.mqh>
#include <MyMql/Global/Money/MoneyBetOnDecision.mqh>
#include <MyMql/TransactionManagement/FlowWithTrendTranMan.mqh>
#include <MyMql/Generator/GenerateTPandSL.mqh>
#include <MyMql/Info/ScreenInfo.mqh>
#include <MyMql/Info/VerboseInfo.mqh>
#include <Files/FileTxt.mqh>
#include <MyMql/Global/Log/WebServiceLog.mqh>

input int MaximumNumberOfTransactions;

//+------------------------------------------------------------------+
//| Expert initialization function (used for testing)                |
//+------------------------------------------------------------------+
int init()
{
	// print some verbose info
	//VerboseInfo vi;
	//vi.BalanceAccountInfo();
	//vi.ClientAndTerminalInfo();
	//vi.PrintMarketInfo();
	
	if(IsTesting())
		return INIT_SUCCEEDED;
	return ExpertValidationsTest(Symbol());
}

// UNFINISHED!! WEIRD STUFF HERE!!

int start()
{
	// Decisions:
	DecisionRSI rsiDecision;
	Decision3MA maDecision;
	DecisionDoubleBB bbDecision;
	
	// Transaction management (send/etc)
	FlowWithTrendTranMan transaction;
	transaction.SetVerboseLevel(1);
	
	// Money management:
	MoneyBetOnDecision money(rsiDecision.GetMaxDecision() + maDecision.GetMaxDecision() + bbDecision.GetMaxDecision(),0.0,0);
	
	// Screen management:
	ScreenInfo screen;
	
	int i = Bars - IndicatorCounted() - 1;
	double SL = 0.0, TP = 0.0;
	
	while(i >= 0)
	{
		double decision = bbDecision.GetDecision(SL, TP, 1.0, i) + rsiDecision.GetDecision(i) + maDecision.GetDecision(i);
		int DecisionOrderType = (int)(decision > 0.0 ? BuyDecision : IncertitudeDecision) + 
			(int)(decision < 0.0 ? SellDecision : IncertitudeDecision);
		double price = money.GetPriceBasedOnDecision(decision, false);
		
		if((SL == 0.0) || (TP == 0.0))
			money.CalculateTP_SL(TP, SL, 30.0, 50.0, DecisionOrderType, price); // TP and SL cannot be calculated well without the price
		
		if(decision != IncertitudeDecision)
		{
			int ticket = 1;
			if(DecisionOrderType > 0) { // Buy
				
				//if(IsDemo())
					ticket = ticket * transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, price,0,SL,TP,NULL, 0, 0, clrNONE, i);
				//else
				//	ticket = ticket * OrderSend(Symbol(), OP_BUY, 0.1, price,0,SL,TP,NULL, 0, 0, clrNONE);
				
			} else { // Sell
				//if(IsDemo())
					ticket = ticket * transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, price,0,SL,TP,NULL, 0, 0, clrNONE, i);
				//else
				//	ticket = ticket * OrderSend(Symbol(), OP_SELL, 0.1, price,0,SL,TP,NULL, 0, 0, clrNONE);
				
			}
			
			screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(-1)),clrGray, 20, 0);
			screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
			screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
		
			if(ticket < 0)
				printf("There might be a problem with some order: ticket = %d; LastError = %d", ticket, GetLastError());
		}
		i--;
	}
	
	return 0;
}
