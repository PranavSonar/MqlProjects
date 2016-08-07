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

class FollowTrendTranMan : public BaseTransactionManagement
{
	public:
		void FollowTrend_UpdateSL_TP(double targetSL, double targetTP, bool allCharts = false)
		{
			bool statusOk = RefreshRates();
			
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
