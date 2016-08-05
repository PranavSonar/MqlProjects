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
	
		
		virtual double GetOrdersProfit(bool onlyCurrentChart = true)
		{
			double profitValue = 0.00;
			for(int i=OrdersTotal()-1; i>=0; OrderSelect(--i, SELECT_BY_POS))
				if (OrderSymbol() == Symbol() && onlyCurrentChart)
					profitValue = profitValue + OrderProfit();
			return profitValue;
		}
		
		virtual bool CloseOrders(bool onlyCurrentChart = true)
		{
			bool statusOk = true;
			
			for(int i=OrdersTotal()-1; i>=0; OrderSelect(--i, SELECT_BY_POS))
				if (OrderSymbol() == Symbol() && onlyCurrentChart)
				{
					if (OrderType() == OP_BUY)
						statusOk = statusOk & OrderClose(OrderTicket(),OrderLots(),Bid,3,Yellow);
					else
						statusOk = statusOk & OrderClose(OrderTicket(),OrderLots(),Ask,3,Yellow);
				}
			
			return statusOk; // true if all orders closed, false if even one couldn't be closed
		}
		
		virtual void TestCloseProfit(bool onlyCurrentChart = true)
		{
			if (GetOrdersProfit(onlyCurrentChart) >= 0)
				CloseOrders(onlyCurrentChart);
		}
};
