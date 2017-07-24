//+------------------------------------------------------------------+
//|                                               SystemCommands.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https) ||//www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https) ||//www.mql5.com"
#property strict

#include <MyMql/Base/BaseObject.mqh>

class SystemCommands : public BaseObject
{
   private:
      string context;
      
	public:
	   SystemCommands(string ctx = NULL) { context = ctx; }
	   
	   string GetContext() { return context; }
	   
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
			} else if(context == "print") {
				ArrayResize(commands, 7);
				commands[0] = "[d]discovery";
				commands[1] = "[s]system";
				commands[2] = "[o]orders";
				commands[3] = "[r]results";
				commands[4] = "[v]variables";
				commands[5] = "[c]config";
				commands[6] = "[b]back";
			} else if((context == "discovery") || (context == "light") || (context == "system") || (context == "EA")) {
				ArrayResize(commands, 5);
				commands[0] = "[1]one symbol";
				commands[1] = "[c]current symbol";
				commands[2] = "[w]watchlist symbols";
				commands[3] = "[a]all symbols";
				commands[4] = "[b]back";
			} else if(StringFind(context,"call") == 0) {
				ArrayResize(commands, 1); // to do: choose between procedures, for 1st word (after call
				commands[0] = "[b]back";
			} else if(context == "config") {
				ArrayResize(commands, 3);
				commands[0] = "[c]change";
				commands[1] = "[p]print";
				commands[2] = "[b]back";
			} else if(context == "indicator") {
				ArrayResize(commands, 4);
				commands[0] = "[d]decision";
				commands[1] = "[s]show";
				commands[2] = "[o]orders";
				commands[3] = "[b]back";
			} else if(context == "analysis") {
				ArrayResize(commands, 1); // to do: choose between available indicators
				commands[0] = "[b]back";
			} else if(context == "orders") { // to do: complete orders; it was way bigger than this
				ArrayResize(commands, 1);
				commands[0] = "[b]back";
			} else if(context == "probability") {
				ArrayResize(commands, 4);
				commands[0] = "opened";
				commands[1] = "virtual";
				commands[2] = "new";
				commands[3] = "[b]back";
			} else if(context == "manual") {
				ArrayResize(commands, 1); // to do: maybe something can be done for any of those: manual/symbol/% of margin used/order type(buy/sell)/TP & SL type(pips, simple s/r, 2BB, Fibonacci s/r, MA s/r)/virtual limits
				commands[0] = "[b]back";
			} else if(context == "update") {
				ArrayResize(commands, 7);
				commands[0] = "TakeProfit";
				commands[1] = "StopLoss";
				commands[2] = "close";
				commands[3] = "trailing stop";
				commands[4] = "notification";
				commands[5] = "virtual";
				commands[6] = "[b]back";
			} else if(context == "call") {
				ArrayResize(commands, 1); // to do: it was more than this
				commands[0] = "[b]back";
			}
		}
		
		string UpdateContext(string value, bool changeContext = false)
		{
		   if(changeContext)
		      context = value;
		   return value;
		}
		
		string GetSystemCommandToExecute(string command, bool changeContext = false)
		{
		   if(context == NULL)
		   {
		      if((command == "[h]help") || (command == "h") || (command == "help"))
   		      return "help";
   		   else if((command == "[p]print") || (command == "p") || (command == "print"))
   		      return UpdateContext("print", changeContext);
   		   else if((command == "[o]config") || (command == "o") || (command == "config"))
   		      return UpdateContext("config", changeContext);
   		   else if((command == "[d]discovery") || (command == "d") || (command == "discovery"))
   		      return UpdateContext("discovery", changeContext);
   		   else if((command == "[l]light system") || (command == "l") || (command == "light system") || (command == "light"))
   		      return UpdateContext("light", changeContext);
   		   else if((command == "[s]system") || (command == "s") || (command == "system"))
   		      return UpdateContext("system", changeContext);
   		   else if((command == "[a]EA") || (command == "a") || (command == "EA"))
   		      return UpdateContext("EA", changeContext);
   		   else if((command == "[i]indicator") || (command == "i") || (command == "indicator"))
   		      return UpdateContext("indicator", changeContext);
   		   else if((command == "[n]analysis indicator") || (command == "n") || (command == "analysis indicator") || (command == "analysis"))
   		      return UpdateContext("analysis", changeContext);
   		   else if((command == "[o]orders view") || (command == "o") || (command == "orders view") || (command == "orders") || (command == "order"))
   		      return UpdateContext("orders", changeContext);
   		   else if((command == "[%]probability of order") || (command == "%") || (command == "probability of order") || (command == "probability"))
   		      return UpdateContext("probability", changeContext);
   		   else if((command == "[m]manual order") || (command == "m") || (command == "manual order") || (command == "manual"))
   		      return UpdateContext("manual", changeContext);
   		   else if((command == "[u]update order") || (command == "u") || (command == "update order") || (command == "update"))
   		      return UpdateContext("update", changeContext);
   		   else if((command == "[c]call WS proc") || (command == "c") || (command == "call WS proc") || (command == "call"))
   		      return UpdateContext("call", changeContext);
   		   else if((command == "[r]screenshot") || (command == "r") || (command == "screenshot"))
   		      return UpdateContext("screenshot", changeContext);
   		   else if((command == "[x]exit/[q]quit") || (command == "x") || (command == "q") || (command == "exit") || (command == "quit"))
   		      return UpdateContext("exit", changeContext);
		   } else if(context == "print") {
		   	if((command == "[d]discovery") || (command == "discovery") || (command == "d"))
		   		return UpdateContext("print/discovery", changeContext);
		   	else if((command == "[s]system") || (command == "system") || (command == "s"))
		   		return UpdateContext("print/system", changeContext);
		   	else if((command == "[o]orders") || (command == "orders") || (command == "order") || (command == "o"))
		   		return UpdateContext("print/orders", changeContext);
		   	else if((command == "[r]results") || (command == "results") || (command == "result") || (command == "r"))
		   		return UpdateContext("print/results", changeContext);
		   	else if((command == "[v]variables") || (command == "variables") || (command == "variable") || (command == "v"))
		   		return UpdateContext("print/variables", changeContext);
		   	else if((command == "[c]config") || (command == "config") || (command == "c"))
		   		return UpdateContext("print/config", changeContext);
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   	{ UpdateContext(NULL, changeContext); return "back"; }
		   } else if(StringFind(context,"call") == 0) { // WS Proc call
		   	if((command == "[b]back") || (command == "back") || (command == "b")) // to do: validate words (procedure name, params)
		   	{ UpdateContext(NULL, changeContext); return "back"; } 
		   	
		   	string words[];
		   	StringSplit(context, '/', words);
		   	if(ArraySize(words) != 3) // call/procedure name/parameters
		   		return context + "/" + command;
		   } else if((context == "discovery") || (context == "light") || (context == "system") || (context == "EA")) {
		   	if((command == "[1]one symbol") || (command == "one symbol") || (command == "one") || (command == "1"))
		   		return UpdateContext(context + "/one", changeContext);
		   	else if((command == "[c]current symbol") || (command == "current symbol") || (command == "current") || (command == "c"))
		   		return UpdateContext(context + "/current", changeContext);
		   	else if((command == "[w]watchlist symbols") || (command == "watchlist symbols") || (command == "watchlist") || (command == "watch") || (command == "w"))
		   		return UpdateContext(context + "/watchlist", changeContext);
		   	else if((command == "[a]all symbols") ||(command == "all symbols") || (command == "all") || (command == "a"))
		   		return UpdateContext(context + "/all", changeContext);
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   	{ UpdateContext(NULL, changeContext); return "back"; }
		   } else if(context == "config") {
		   	if((command == "[c]change") || (command == "change") || (command == "c"))
		   		return UpdateContext("config/change", changeContext);
		   	else if((command == "[p]print") || (command == "print") || (command == "p"))
		   		return UpdateContext("config/print", changeContext);
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   		{ UpdateContext(NULL, changeContext); return "back"; }
		   } else if(context == "indicator") {
		   	if((command == "[d]decision") || (command == "decision") || (command == "d"))
		   		return UpdateContext("indicator/decision", changeContext);
		   	else if((command == "[s]show") || (command == "show") || (command == "s"))
		   		return UpdateContext("indicator/show", changeContext);
		   	else if((command == "[o]orders") || (command == "orders") || (command == "o"))
		   		return UpdateContext("indicator/orders", changeContext);
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   		{ UpdateContext(NULL, changeContext); return "back"; }
		   } else if(context == "analysis") { // to do: validate word
		   	if((command == "[b]back") || (command == "back") || (command == "b"))
		   	{ UpdateContext(NULL, changeContext); return "back"; }
		   	
		   	string words[];
		   	StringSplit(context, '/', words);
		   	if(ArraySize(words) != 2) // analysis/indicator
		   		return UpdateContext(context + "/" + command, changeContext);
		   } else if(context == "orders") { // to do: complete orders; it was way bigger than this
		   	if((command == "[b]back") || (command == "back") || (command == "b"))
		   	{ UpdateContext(NULL, changeContext); return "back"; }
		   } else if(StringFind(context,"manual") == 0) { // to do: validate words
		   	if((command == "[b]back") || (command == "back") || (command == "b"))
		   	{ UpdateContext(NULL, changeContext); return "back"; }
		   		
		   	string words[];
		   	StringSplit(context, '/', words);
		   	if(ArraySize(words) != 6) // manual/symbol/% of margin used/order type(buy/sell)/TP & SL type(pips, simple s/r, 2BB, Fibonacci s/r, MA s/r)/virtual limits
		   		return context + "/" + command;
		   } else if(StringFind(context,"update") == 0) { // to do: make all for "update" in this context
		   	if((command == "[b]back") || (command == "back") || (command == "b"))
		   	{ UpdateContext(NULL, changeContext); return "back"; }
		   	
		   	if((command == "TakeProfit") || (command == "take profit") || (command == "TP"))
		   		return UpdateContext(context + "/TP", changeContext);
		   	else if((command == "StopLoss") || (command == "stop loss") || (command == "SL"))
		   		return UpdateContext(context + "/SL", changeContext);
		   	else if((command == "close"))
		   		return UpdateContext(context + "/close", changeContext);
		   	else if((command == "trailing stop") || (command == "trailing"))
		   		return UpdateContext(context + "/trailing", changeContext);
		   	else if((command == "notification") || (command == "notif"))
		   		return UpdateContext(context + "/notification", changeContext);
		   	else if((command == "virtual") || (command == "virt"))
		   		return UpdateContext(context + "/virtual", changeContext);
		   } else if(context == "probability") {
		   	if((command == "current") || (command == "opened")) // opened order
		   		return UpdateContext(context + "/current", changeContext);
		   	else if((command == "virtual") || (command == "virt")) // virtual order
		   		return UpdateContext(context + "/virt", changeContext);
		   	else if((command == "new")) // new order
		   		return UpdateContext(context + "/new", changeContext);
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   	{ UpdateContext(NULL, changeContext); return "back"; }
		   }
		   //else if(context == "") {
		   //	if((command == "") || (command == ""))
		   //		return UpdateContext("";
		   //	else if((command == "") || (command == ""))
		   //		return UpdateContext("";
		   //	else if((command == "") || (command == ""))
		   //		return UpdateContext("";
		   //	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   //		return UpdateContext(NULL;
		   //}
		   
		   // default
		   //if((command == "[b]back") || (command == "back") || (command == "b"))
		   //	{ UpdateContext(NULL, changeContext); return "back"; }
		   
		   return NULL; // lucky if command is the whole context; not written one by one, but the whole the first time
		}
		
		bool NeedRefresh(string command)
		{
		   command = GetSystemCommandToExecute(command);
		   if((command == "help") ||
		      (command == "screenshot") ||
		      (command == "exit") ||
		      (command == "discovery/watchlist") ||
		      (command == "discovery/all") ||
		      (command == "print/discovery") ||
		   	(command == "print/system") ||
		   	(command == "print/orders") ||
		   	(command == "print/results") ||
		   	(command == "print/variables") ||
		   	(command == "print/config"))
		         return false;
		   else if((command == "print") ||
		      (command == "config") ||
		      (command == "discovery") ||
		      (command == "light") ||
		      (command == "system") ||
		      (command == "EA") ||
		      (command == "indicator") ||
		      (command == "analysis") ||
		      (command == "orders") ||
		      (command == "probability") ||
		      (command == "manual") ||
		      (command == "update") ||
		      (command == "call") ||
		      (command == "back") ||
		      (command == NULL))
		         return true;
		   return false;
		}
};
