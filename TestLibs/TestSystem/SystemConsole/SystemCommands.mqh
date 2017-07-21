//+------------------------------------------------------------------+
//|                                               SystemCommands.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <MyMql\Base\BaseObject.mqh>

class SystemCommands : public BaseObject
{
	public:
		static void GetSystemCommands(string &commands[], string context = NULL)
		{
			if(context == NULL)
			{
				ArrayResize(commands, 15);
				commands[0] = "exit";
				commands[1] = "discovery";
				commands[2] = "print";
				commands[3] = "call";
				commands[4] = "light";
				commands[5] = "system";
				commands[6] = "config";
				commands[7] = "help";
				commands[8] = "indicator";
				commands[9] = "orders";
				commands[10] = "screenshot";
				commands[11] = "analysis";
				commands[12] = "manual";
				commands[13] = "update";
				commands[14] = "probability";
			}
		}
};
