//+------------------------------------------------------------------+
//|                                           FollowTrendTranMan.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "BaseTransactionManagement.mq4"
#include "..\MoneyManagement\BaseMoneyManagement.mq4"

class FollowTrendTranMan : public BaseTransactionManagement
{
	public:
		bool FollowTrend_UpdateSL_TP_UsingConstants(double targetSLpips = 30.0, double targetTPpips = 50.0, bool allCharts = false)
		{
			bool statusOk = RefreshRates();
			BaseMoneyManagement money;
			double targetTP, targetSL;
			money.CalculateTP_SL(targetTP, targetSL, OrderType(), OrderOpenPrice());
			
			if ((targetTP > 0) || (targetSL > 0))
			{
				for(int i=OrdersTotal()-1; i>=0; i--)
				{
					statusOk = statusOk & OrderSelect(i, SELECT_BY_POS);
					if (OrderSymbol() == Symbol() || allCharts)
					{
						if ((OrderStopLoss() != targetSL)  && (targetSL != 0.0))
							statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),targetSL,OrderTakeProfit(),0,Blue);
						if ((OrderTakeProfit() != targetTP)  && (targetTP != 0.0))
							statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),targetTP,0,Blue);
					}
				}
			}
			return statusOk;
		}
};
