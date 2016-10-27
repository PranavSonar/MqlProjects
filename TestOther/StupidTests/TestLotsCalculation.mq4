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

double ValidateLot(double lot)
{
	double minLot = MarketInfo(_Symbol,MODE_MINLOT);
	double maxLot = MarketInfo(_Symbol,MODE_MAXLOT);
	
	if(lot < minLot)
		lot = minLot;
	else if(lot > maxLot)
		lot = maxLot;
	
	return lot;
}

double GetMarginFromLots(double lot)
{
	double validatedLot = ValidateLot(lot);
	double oneLotMargin = MarketInfo(_Symbol,MODE_MARGINREQUIRED);
	
	return validatedLot * oneLotMargin;
}


int OnInit()
{
	if(FirstSymbol == NULL)
	{
		GlobalContext.DatabaseLog.Initialize(true);
		GlobalContext.DatabaseLog.NewTradingSession("TestLotsCalculation.mq4");
	}
	
	double OneLotMargin = MarketInfo(_Symbol,MODE_MARGINREQUIRED);
	double MinLotMargin = OneLotMargin*MarketInfo(_Symbol,MODE_MINLOT);
	double MaxLotMargin = OneLotMargin*MarketInfo(_Symbol,MODE_MAXLOT);

	//// same as:
	//double MinLotMargin = GetMarginFromLots(MarketInfo(_Symbol,MODE_MINLOT));
	//double MaxLotMargin = GetMarginFromLots(MarketInfo(_Symbol,MODE_MAXLOT));
	
	double MarginAmount = 100; //this means we want to use 200 ron for trade
	double lotMM = MarginAmount / OneLotMargin;
	double LotStep = MarketInfo(_Symbol,MODE_LOTSTEP);
	
	lotMM = NormalizeDouble(lotMM/LotStep,0) * LotStep;
	
	bool CanTradeOnThis = MinLotMargin < MarginAmount;
	bool CanTradeOnThis2 = MinLotMargin < MarginAmount*2;
	bool CanTradeOnThis5 = MinLotMargin < MarginAmount*5;
	
	GlobalContext.DatabaseLog.DataLog("MarginRequired on symbol " + _Symbol,
		"CanTrade100:" + BoolToString(CanTradeOnThis)
		+ " CanTrade200:" + BoolToString(CanTradeOnThis2)
		+ " CanTrade500:" + BoolToString(CanTradeOnThis5)
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
	GlobalContext.DatabaseLog.EndTradingSession("TestLotsCalculation.mq4");
	return(INIT_SUCCEEDED);
}
