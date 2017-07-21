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
   private:
      string context;
      
	public:
	   SystemCommands(string ctx = NULL) { context = ctx; }
	   
		void GetSystemCommands(string &commands[])
		{
			if(context == NULL)
			{
				ArrayResize(commands, 16);
				commands[0] = "[h]help";
				commands[1] = "[p]print";
				commands[2] = "[o]config";
				commands[3] = "[d]discovery";
				commands[4] = "[l]light system";
				commands[5] = "[s]system";
				commands[6] = "[a]EA";
				commands[7] = "[i]indicator";
				commands[8] = "[n]analysis indicator";
				commands[9] = "[o]orders view";
				commands[10] = "[%]probability of order";
				commands[11] = "[m]manual order";
				commands[12] = "[u]update order";
				commands[13] = "[c]call WS proc";
				commands[14] = "[r]screenshot";
				commands[15] = "[x]exit/[q]quit";
			}
		}
		
		string GetSystemCommandToExecute(string command)
		{
		   if(context == NULL)
		   {
		      if((command == "[h]help") || (command == "h") || (command == "help"))
   		      return "help";
   		   else if((command == "[p]print") || (command == "p") || (command == "print"))
   		      return context = "print";
   		   else if((command == "[o]config") || (command == "o") || (command == "config"))
   		      return context = "config";
   		   else if((command == "[d]discovery") || (command == "d") || (command == "discovery"))
   		      return context = "discovery";
   		   else if((command == "[l]light system") || (command == "l") || (command == "light system") || (command == "light"))
   		      return context = "light";
   		   else if((command == "[s]system") || (command == "s") || (command == "system"))
   		      return context = "system";
   		   else if((command == "[a]EA") || (command == "a") || (command == "EA"))
   		      return context = "EA";
   		   else if((command == "[i]indicator") || (command == "i") || (command == "indicator"))
   		      return context = "indicator";
   		   else if((command == "[n]analysis indicator") || (command == "n") || (command == "analysis indicator") || (command == "analysis"))
   		      return context = "analysis";
   		   else if((command == "[o]orders view") || (command == "o") || (command == "orders view") || (command == "orders") || (command == "order"))
   		      return context = "probability";
   		   else if((command == "[%]probability of order") || (command == "%") || (command == "probability of order") || (command == "probability"))
   		      return context = "probability";
   		   else if((command == "[m]manual order") || (command == "m") || (command == "manual order") || (command == "manual"))
   		      return context = "manual";
   		   else if((command == "[u]update order") || (command == "u") || (command == "update order") || (command == "update"))
   		      return context = "update";
   		   else if((command == "[c]call WS proc") || (command == "c") || (command == "call WS proc") || (command == "call"))
   		      return context = "call";
   		   else if((command == "[r]screenshot") || (command == "r") || (command == "screenshot"))
   		      return context = "screenshot";
   		   else if((command == "[x]exit/[q]quit") || (command == "x") || (command == "q") || (command == "exit") || (command == "quit"))
   		      return context = "exit";
		   }
		   
		   return NULL;
		}
		
		bool NeedRefresh(string command)
		{
		   command = GetSystemCommandToExecute(command);
		   switch(command)
		   {
		      case "help":
		         return false;
		      case "print":
		      case "config":
		      case "discovery":
		      case "light":
		      case "system":
		      case "EA":
		      case "indicator":
		      case "analysis":
		      case "orders":
		      case "probability":
		      case "manual":
		      case "update":
		      case "call":
		      case "screenshot":
		      case "exit":
		         return true;
		   };
		   return false;
		}
};
