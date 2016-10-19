//+------------------------------------------------------------------+
//|                                          TestLotsCalculation.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Global.mqh>
#include <MyMql\Global\Log\WebServiceLog.mqh>

int OnInit()
{
	WebServiceLog wslog(true);
	if(FirstSymbol == NULL)
		wslog.NewTradingSession();
	
	double OneLotMargin = MarketInfo(_Symbol,MODE_MARGINREQUIRED);
	double MinLotMargin = OneLotMargin*MarketInfo(_Symbol,MODE_MINLOT);
	double MaxLotMargin = OneLotMargin*MarketInfo(_Symbol,MODE_MAXLOT);
	double MarginAmount = 100; //this means we want to use 200 ron for trade
	double lotMM = MarginAmount / OneLotMargin;
	double LotStep = MarketInfo(_Symbol,MODE_LOTSTEP);
	
	lotMM = NormalizeDouble(lotMM/LotStep,0) * LotStep;
	
	bool CanTradeOnThis = MinLotMargin < MarginAmount;
	bool CanTradeOnThis2 = MinLotMargin < MarginAmount*2;
	bool CanTradeOnThis5 = MinLotMargin < MarginAmount*5;
	
	wslog.DataLog("MarginRequired on symbol " + _Symbol,
		"CanTradeOnThis:" + BoolToString(CanTradeOnThis)
		+ " CanTradeOnThis2:" + BoolToString(CanTradeOnThis2)
		+ " CanTradeOnThis5:" + BoolToString(CanTradeOnThis5)
		+ " OneLotMargin:" + DoubleToString(OneLotMargin,3)
		+ " MinLotMargin:" + DoubleToString(MinLotMargin,3)
		+ " MaxLotMargin:" + DoubleToString(MaxLotMargin,3)
		+ " MarginAmount:" + DoubleToString(MarginAmount,3)
		+ " MinLot:" + DoubleToString(MarketInfo(_Symbol,MODE_MINLOT),3)
		+ " MaxLot:" + DoubleToString(MarketInfo(_Symbol,MODE_MAXLOT),3)
		+ " lotMM:" + DoubleToString(lotMM,3)
		+ " LotStep:" + DoubleToString(LotStep,3)
	);
	
	GlobalContext.Config.Initialize(true, true, false, true);
	GlobalContext.Config.ChangeSymbol();
	wslog.EndTradingSession();
	return(INIT_SUCCEEDED);
}
