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
				commands[0] = "[h]help";
				commands[1] = "[p]print";
				commands[2] = "[o]config";
				commands[3] = "[d]discovery";
				commands[4] = "[l]light system";
				commands[5] = "[s]system";
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
			} else if(context == "probability") {
				ArrayResize(commands, 4);
				commands[0] = "opened";
				commands[1] = "virtual";
				commands[2] = "new";
				commands[3] = "[b]back";
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
		   } else if(context == "print") {
		   	if((command == "[d]discovery") || (command == "discovery") || (command == "d"))
		   		return context = "print/discovery";
		   	else if((command == "[s]system") || (command == "system") || (command == "s"))
		   		return context = "print/system";
		   	else if((command == "[o]orders") || (command == "orders") || (command == "order") || (command == "o"))
		   		return context = "print/orders";
		   	else if((command == "[r]results") || (command == "results") || (command == "result") || (command == "r"))
		   		return context = "print/results";
		   	else if((command == "[v]variables") || (command == "variables") || (command == "variable") || (command == "v"))
		   		return context = "print/variables";
		   	else if((command == "[c]config") || (command == "config") || (command == "c"))
		   		return context = "print/config";
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   		return context = NULL;
		   } else if(StringFind(context,"call") == 0) { // WS Proc call
		   	if((command == "back") || (command == "b")) // to do: validate words (procedure name, params)
		   		return context = NULL;
		   	
		   	string words[];
		   	StringSplit(context, '/', words);
		   	if(ArraySize(words) != 3) // call/procedure name/parameters
		   		return context + "/" + command;
		   } else if((context == "discovery") || (context == "light") || (context == "system") || (context == "EA")) {
		   	if((command == "[1]one symbol") || (command == "one symbol") || (command == "one") || (command == "1"))
		   		return context = context + "/one";
		   	else if((command == "[c]current symbol") || (command == "current symbol") || (command == "current") || (command == "c"))
		   		return context = context + "/current";
		   	else if((command == "[w]watchlist symbols") || (command == "watchlist symbols") || (command == "watchlist") || (command == "watch") || (command == "w"))
		   		return context = context + "/watchlist";
		   	else if((command == "[a]all symbols") ||(command == "all symbols") || (command == "all") || (command == "a"))
		   		return context = context + "/all";
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   		return context = NULL;
		   } else if(context == "config") {
		   	if((command == "[c]change") || (command == "change") || (command == "c"))
		   		return context = "config/change";
		   	else if((command == "[p]print") || (command == "print") || (command == "p"))
		   		return context = "config/print";
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   		return context = NULL;
		   } else if(context == "indicator") {
		   	if((command == "[d]decision") || (command == "decision") || (command == "d"))
		   		return context = "indicator/decision";
		   	else if((command == "[s]show") || (command == "show") || (command == "s"))
		   		return context = "indicator/show";
		   	else if((command == "[c]orders") || (command == "orders") || (command == "o"))
		   		return context = "indicator/orders";
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   		return context = NULL;
		   } else if(context == "analysis") { // to do: validate word
		   	if((command == "back") || (command == "b"))
		   		return context = NULL;
		   	
		   	string words[];
		   	StringSplit(context, '/', words);
		   	if(ArraySize(words) != 2) // analysis/indicator
		   		return context += "/" + command;
		   } else if(StringFind(context,"manual") == 0) { // to do: validate words
		   	if((command == "back") || (command == "b"))
		   		return context = NULL;
		   		
		   	string words[];
		   	StringSplit(context, '/', words);
		   	if(ArraySize(words) != 6) // manual/symbol/% of margin used/order type(buy/sell)/TP & SL type(pips, simple s/r, 2BB, Fibonacci s/r, MA s/r)/virtual limits
		   		return context + "/" + command;
		   } else if(StringFind(context,"update") == 0) { // to do: make all for "update" in this context
		   	if((command == "back") || (command == "b"))
		   		return context = NULL;
		   	
		   	if((command == "TakeProfit") || (command == "take profit") || (command == "TP"))
		   		return context += "/TP";
		   	else if((command == "StopLoss") || (command == "stop loss") || (command == "SL"))
		   		return context += "/SL";
		   	else if((command == "close"))
		   		return context += "/close";
		   	else if((command == "trailing stop") || (command == "trailing"))
		   		return context += "/trailing";
		   	else if((command == "notification") || (command == "notif"))
		   		return context += "/notification";
		   	else if((command == "virtual") || (command == "virt"))
		   		return context += "/virtual";
		   } else if(context == "probability") {
		   	if((command == "current") || (command == "opened")) // opened order
		   		return context += "/current";
		   	else if((command == "virtual") || (command == "virt")) // virtual order
		   		return context += "/virt";
		   	else if((command == "new")) // new order
		   		return context += "/new";
		   	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   		return context = NULL;
		   }
		   //else if(context == "") {
		   //	if((command == "") || (command == ""))
		   //		return context = "";
		   //	else if((command == "") || (command == ""))
		   //		return context = "";
		   //	else if((command == "") || (command == ""))
		   //		return context = "";
		   //	else if((command == "[b]back") || (command == "back") || (command == "b"))
		   //		return context = NULL;
		   //}
		   
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
		      (command == "call"))
		         return true;
		   return false;
		}
};
