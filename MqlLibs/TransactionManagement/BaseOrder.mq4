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

#include "../BaseLibs/BaseObject.mq4"


const string SimulatedOrder = "SimulatedOrder";
const string SimulatedStopLoss = "SimulatedStopLoss";
const string SimulatedTakeProfit = "SimulatedTakeProfit";

class BaseOrder : public BaseObject
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
			color    arrow_color=clrNONE, // color 
			int shift = 0
		)
		{
			string objectName = screen.NewObjectName(SimulatedOrder, magic);
			bool statusOk = ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[shift], price);
			color currentOrderColor = cmd == OP_BUY ? Blue : (cmd == OP_SELL ? Orange : Gray);
			ObjectSet(objectName, OBJPROP_COLOR, currentOrderColor);
			ObjectSet(objectName, OBJPROP_WIDTH, 3);
			
			if(IsVerboseMode())
			{
				printf("%s: price = %f; time = %s", objectName, price, TimeToStr(Time[shift])); 
			}
			
			if(stoploss != 0)
			{
				objectName = screen.NewObjectName(SimulatedStopLoss, magic);
				statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[shift], stoploss);
				ObjectSet(objectName, OBJPROP_COLOR, Red);
				ObjectSet(objectName, OBJPROP_WIDTH, 1);
			
				if(IsVerboseMode())
				{
					printf("%s: SL = %f; time = %s", objectName, stoploss, TimeToStr(Time[shift])); 
				}
			}
			
			if(takeprofit != 0)
			{
				objectName = screen.NewObjectName(SimulatedTakeProfit, magic);
				statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[shift], takeprofit);
				ObjectSet(objectName, OBJPROP_COLOR, Green);
				ObjectSet(objectName, OBJPROP_WIDTH, 1);
			
				if(IsVerboseMode())
				{
					printf("%s: SL = %f; time = %s", objectName, takeprofit, TimeToStr(Time[shift])); 
				}
			}
			
			return statusOk;
		}
		
		
		virtual bool  SimulateOrderModify( 
			int        ticket,      // ticket 
			double     price,       // price 
			double     stoploss,    // stop loss 
			double     takeprofit,  // take profit 
			datetime   expiration,  // expiration 
			color      arrow_color, // color 
			int shift = 0
		)
		{
			if(SimulatedOrderSelected == -1)
				return false;
			
			int magic = SimulatedOrderSelected;
			
			string objectName = screen.ReplaceObjectName(SimulatedOrder, magic);
			bool statusOk = ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[shift], price);
			ObjectSet(objectName, OBJPROP_COLOR, Gray);
			ObjectSet(objectName, OBJPROP_WIDTH, 0.5);
			
			if(IsVerboseMode())
			{
				printf("%s: price = %f; time = %s", objectName, price, TimeToStr(Time[shift])); 
			}
			
			if(stoploss != 0)
			{
				objectName = screen.ReplaceObjectName(SimulatedStopLoss, magic);
				statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[shift], stoploss);
				ObjectSet(objectName, OBJPROP_COLOR, Red);
				ObjectSet(objectName, OBJPROP_WIDTH, 0.3);
				
				if(IsVerboseMode())
				{
					printf("%s: SL = %f; time = %s", objectName, stoploss, TimeToStr(Time[shift])); 
				}
			}
			
			if(takeprofit != 0)
			{
				objectName = screen.ReplaceObjectName(SimulatedTakeProfit, magic);
				statusOk = statusOk & ObjectCreate(ChartID(),objectName, OBJ_VLINE, 0, Time[0], takeprofit);
				ObjectSet(objectName, OBJPROP_COLOR, Green);
				ObjectSet(objectName, OBJPROP_WIDTH, 0.3);
				
				if(IsVerboseMode())
				{
					printf("%s: SL = %f; time = %s", objectName, takeprofit, TimeToStr(Time[shift])); 
				}
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