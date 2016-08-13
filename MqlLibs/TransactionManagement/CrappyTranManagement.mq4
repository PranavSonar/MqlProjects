//+------------------------------------------------------------------+
//|                                         CrappyTranManagement.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "BaseTransactionManagement.mq4"

class CrappyTranManagement : public BaseTransactionManagement
{
	public:
		virtual void Get_SumLotsOrders_OpenOrders_AvgPrice(double &sumLots, double &sumOrders, int &currentOpenOrders, double &averagePrice, int &firstOrderIsBuy, bool allCharts = false)
		{
			for(int i=OrdersTotal()-1; i>=0; OrderSelect(--i, SELECT_BY_POS))
			{
				if (OrderSymbol() == Symbol() || allCharts)
				{
					sumLots = sumLots + OrderLots();
					sumOrders = sumOrders + (OrderLots() * OrderOpenPrice());
					
					if (OrderType() == OP_BUY)
						firstOrderIsBuy = 1;
					else
						firstOrderIsBuy = 0;
					currentOpenOrders = currentOpenOrders + 1;
				}
			}
			
			if (sumLots > 0.00)
			{
				averagePrice = sumOrders / sumLots;
			}
		}
		
		virtual void Get_OpenOrders_AvgPrice(int &currentOpenOrders, double &averagePrice, int &firstOrderIsBuy, bool allCharts = false)
		{
			double dummyVar_SumLots, dummyVar_SumOrders;
			Get_SumLotsOrders_OpenOrders_AvgPrice(dummyVar_SumLots,dummyVar_SumOrders,
				currentOpenOrders,averagePrice,firstOrderIsBuy,allCharts);
		}
		
		virtual bool OpenOrderBasedOnRSI50(double lots, int period = 14, int slippage = 3, ENUM_APPLIED_PRICE price = PRICE_MEDIAN, int shift = 0)
		{
			bool statusOk = RefreshRates(); // refresh Ask, Bid;
			double RSIValue = iRSI(Symbol(), Period(), period, price, shift);
			
			if (RSIValue < 50)
				statusOk = statusOk & (OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,0,0,"iRSI Level = "+DoubleToStr(NormalizeDouble(RSIValue,2),2),0,0,clrRed) > 0);
			else
				statusOk = statusOk & (OrderSend(Symbol(),OP_BUY,lots,Ask,slippage,0,0,"iRSI Level = "+DoubleToStr(NormalizeDouble(RSIValue,2),2),0,0,clrGreen) > 0);
			
			return statusOk;
		}
		
		virtual bool SimulateOrderBasedOnRSI50(double lots, int period = 14, int slippage = 3, ENUM_APPLIED_PRICE price = PRICE_MEDIAN, int shift = 0)
		{
			bool statusOk = RefreshRates(); // refresh Ask, Bid;
			double RSIValue = iRSI(Symbol(), Period(), period, price, shift);
			
			if (RSIValue < 50)
				statusOk = statusOk & (SimulateOrderSend(Symbol(),OP_SELL,lots,Bid,slippage,0,0,"iRSI Level = "+DoubleToStr(NormalizeDouble(RSIValue,2),2),0,0,clrRed) > 0);
			else
				statusOk = statusOk & (SimulateOrderSend(Symbol(),OP_BUY,lots,Ask,slippage,0,0,"iRSI Level = "+DoubleToStr(NormalizeDouble(RSIValue,2),2),0,0,clrGreen) > 0);
			
			return statusOk;
		}
		
};
