//+------------------------------------------------------------------+
//|                                           TestMarginRequired.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Global.mqh>
#include <MyMql\Global\Log\WebServiceLog.mqh>

extern bool UseIndicatorChangeChart = true;
extern bool UseKeyBoardChangeChart = false;


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
		GlobalContext.DatabaseLog.ParametersSet("TestLotsCalculation.mq4");
		GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	}
	
	double OneLotMargin = MarketInfo(_Symbol,MODE_MARGINREQUIRED);
	double MinLotMargin = OneLotMargin*MarketInfo(_Symbol,MODE_MINLOT);
	double MaxLotMargin = OneLotMargin*MarketInfo(_Symbol,MODE_MAXLOT);

	//// same as:
	//double MinLotMargin = GetMarginFromLots(MarketInfo(_Symbol,MODE_MINLOT));
	//double MaxLotMargin = GetMarginFromLots(MarketInfo(_Symbol,MODE_MAXLOT));
	
	//double MarginAmount = 100; //this means we want to use 200 ron for trade
	double MarginAmount = AccountFreeMargin();
	double lotMM = MarginAmount / OneLotMargin;
	double LotStep = MarketInfo(_Symbol,MODE_LOTSTEP);
	
	lotMM = NormalizeDouble(lotMM/LotStep,0) * LotStep;
	
	bool CanTradeOnThis = MinLotMargin < MarginAmount;
	bool CanTradeOnThis2 = MinLotMargin*2 < MarginAmount;
	bool CanTradeOnThis5 = MinLotMargin*5 < MarginAmount;
	bool CanTradeOnThis10 = MinLotMargin*10 < MarginAmount;
	
	GlobalContext.DatabaseLog.ParametersSet(__FILE__, "MarginRequired on symbol " + _Symbol,
		"CanTrade1:" + BoolToString(CanTradeOnThis)
		+ " CanTrade2:" + BoolToString(CanTradeOnThis2)
		+ " CanTrade5:" + BoolToString(CanTradeOnThis5)
		+ " CanTrade10:" + BoolToString(CanTradeOnThis10)
		+ " OneLotMargin:" + DoubleToString(OneLotMargin,3)
		+ " MinLotMargin:" + DoubleToString(MinLotMargin,3)
		+ " MaxLotMargin:" + DoubleToString(MaxLotMargin,3)
		+ " MarginAmount:" + DoubleToString(MarginAmount,3)
		+ " MinLot:" + DoubleToString(MarketInfo(_Symbol,MODE_MINLOT),3)
		+ " MaxLot:" + DoubleToString(MarketInfo(_Symbol,MODE_MAXLOT),3)
		+ " lotMM:" + DoubleToString(lotMM,3)
		+ " LotStep:" + DoubleToString(LotStep,3)
	);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLog");
	
	GlobalContext.Config.Initialize(true, true, false, true, __FILE__);
	GlobalContext.Config.ChangeSymbol();


	CurrentSymbol = GlobalContext.Config.GetNextSymbol(_Symbol);
	if(!StringIsNullOrEmpty(CurrentSymbol))
	{
   	if((UseIndicatorChangeChart) && (GlobalVariableCheck(GlobalVariableSymbolNameConst)))
   		GlobalVariableSet(GlobalVariableSymbolNameConst, (double)GlobalContext.Library.GetSymbolPositionFromName(CurrentSymbol));
   	else
   		GlobalContext.Config.ChangeSymbol(CurrentSymbol, PERIOD_CURRENT, UseKeyBoardChangeChart);
   	GlobalContext.ChartIsChanging = true;
	}
	else
	{
   	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
   	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
   	
	   Print("Expert remove");
	   ExpertRemove();
   } 	
	
	//ChartApplyTemplate(ChartID(), "Default");
	
	return(INIT_SUCCEEDED);
}
