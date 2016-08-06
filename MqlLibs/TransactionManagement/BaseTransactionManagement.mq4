//+------------------------------------------------------------------+
//|                                     BaseTransactionManagemen.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class BaseTransactionManagement {
	public:
		BaseTransactionManagement() {}
		
		
		virtual double GetOrdersProfit(bool allCharts = false)
		{
			double profitValue = 0.00;
			for(int i=OrdersTotal()-1; i>=0; OrderSelect(--i, SELECT_BY_POS))
				if (OrderSymbol() == Symbol() || allCharts)
					profitValue = profitValue + OrderProfit();
			return profitValue;
		}
		
		virtual bool CloseOrders(bool allCharts = false)
		{
			bool statusOk = true;
			
			for(int i=OrdersTotal()-1; i>=0; OrderSelect(--i, SELECT_BY_POS))
				if (OrderSymbol() == Symbol() || allCharts)
				{
					if (OrderType() == OP_BUY)
						statusOk = statusOk & OrderClose(OrderTicket(),OrderLots(),Bid,3,Yellow);
					else
						statusOk = statusOk & OrderClose(OrderTicket(),OrderLots(),Ask,3,Yellow);
				}
			
			return statusOk; // true if all orders closed, false if even one couldn't be closed
		}
		
		virtual void TestCloseProfit(bool allCharts = false)
		{
			if (GetOrdersProfit(allCharts) >= 0)
				CloseOrders(allCharts);
		}
		
		virtual bool ModifyOrders(double targetTP, double targetSL, bool allCharts = false)
		{
			bool statusOk = true;
			
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
