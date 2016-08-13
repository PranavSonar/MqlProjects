//+------------------------------------------------------------------+
//|                                                    BaseOrder.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../VerboseInfo/ScreenInfo.mq4"


const string SimulatedOrder = "SimulatedOrder";
const string SimulatedStopLoss = "SimulatedStopLoss";
const string SimulatedTakeProfit = "SimulatedTakeProfit";

class BaseOrder
{
	protected:
		ScreenInfo screen;
		int SimulatedOrderSelected;
		
	public:
		BaseOrder()
		{
			this.SimulatedOrderSelected = -1;
		}
	
		virtual int SimulateOrderSend( 
			string   symbol,              // symbol 
			int      cmd,                 // operation 
			double   volume,              // volume 
			double   price,               // price 
			int      slippage,            // slippage 
			double   stoploss,            // stop loss 
			double   takeprofit,          // take profit 
			string   comment=NULL,        // comment 
			int      magic=0,             // magic number 
			datetime expiration=0,        // pending order expiration 
			color    arrow_color=clrNONE  // color 
		)
		{
			string objectName = screen.NewObjectName(SimulatedOrder, magic);
			bool statusOk = ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[0], price);
			ObjectSet(objectName, OBJPROP_COLOR, Gray);
			ObjectSet(objectName, OBJPROP_WIDTH, 3);
			
			objectName = screen.NewObjectName(SimulatedStopLoss, magic);
			statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[0], stoploss);
			ObjectSet(objectName, OBJPROP_COLOR, Red);
			ObjectSet(objectName, OBJPROP_WIDTH, 1);
			
			objectName = screen.NewObjectName(SimulatedTakeProfit, magic);
			statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[0], takeprofit);
			ObjectSet(objectName, OBJPROP_COLOR, Green);
			ObjectSet(objectName, OBJPROP_WIDTH, 1);
			
			return statusOk;
		}
		
		
		virtual bool  SimulateOrderModify( 
			int        ticket,      // ticket 
			double     price,       // price 
			double     stoploss,    // stop loss 
			double     takeprofit,  // take profit 
			datetime   expiration,  // expiration 
			color      arrow_color  // color 
		)
		{
			if(SimulatedOrderSelected == -1)
				return false;
			
			int magic = SimulatedOrderSelected;
			
			string objectName = screen.ReplaceObjectName(SimulatedOrder, magic);
			bool statusOk = ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[0], price);
			ObjectSet(objectName, OBJPROP_COLOR, Gray);
			ObjectSet(objectName, OBJPROP_WIDTH, 3);
			
			if(stoploss != 0)
			{
				objectName = screen.ReplaceObjectName(SimulatedStopLoss, magic);
				statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[0], stoploss);
				ObjectSet(objectName, OBJPROP_COLOR, Red);
				ObjectSet(objectName, OBJPROP_WIDTH, 1);
			}
			
			if(takeprofit != 0)
			{
				objectName = screen.ReplaceObjectName(SimulatedTakeProfit, magic);
				statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[0], takeprofit);
				ObjectSet(objectName, OBJPROP_COLOR, Green);
				ObjectSet(objectName, OBJPROP_WIDTH, 1);
			}
			
			return statusOk;
		}
		
		
		virtual int SimulatedOrdersTotal()
		{
			int objectsTotal = ObjectsTotal();
			int ordersTotal = 0;
			
			for(int i=0; i<objectsTotal; i++)
			{
				string name = ObjectName(i);
				if(StringFind(name, SimulatedOrder) == 0) // starts with "SimulatedOrder"
					ordersTotal++;
			}
			
			return ordersTotal;
		}
		
		
		virtual double SimulatedOrderStopLoss()
		{
			if(SimulatedOrderSelected == -1)
				return 0.0;
			return ObjectGet(SimulatedStopLoss + IntegerToString(SimulatedOrderSelected), OBJPROP_PRICE1);
		}
		
		
		virtual double SimulatedOrderTakeProfit()
		{
			if(SimulatedOrderSelected == -1)
				return 0.0;
			return ObjectGet(SimulatedTakeProfit + IntegerToString(SimulatedOrderSelected), OBJPROP_PRICE1);
		}
};