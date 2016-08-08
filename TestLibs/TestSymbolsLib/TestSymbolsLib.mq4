//+------------------------------------------------------------------+
//|                                               TestSymbolsLib.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include "../../MqlLibs/SymbolsLib/BaseSymbol.mq4"

//+------------------------------------------------------------------+
//| Expert initialization function (used for testing)                |
//+------------------------------------------------------------------+
int OnInit()
{
   BaseSymbol symbol;
   string symbolsList[], result = "";
   
   symbol.PrintAllSymbols();
   Print("SymbolExists: EURRON: ", symbol.SymbolExists("EURRON"));
   Print("SymbolExists: RONEUR: ", symbol.SymbolExists("RONEUR"));
   Print("SymbolPartExists: RON: ", symbol.SymbolPartExists("RON"));
   Print("SymbolPartExists: RON: ", symbol.SymbolPartExists("RON", false));
   symbol.SymbolsListWithSymbolPart("RON", symbolsList);
   symbol.SymbolsListWithSymbolPart("RON", symbolsList, false);
   
   for(int i=0;i<ArraySize(symbolsList);i++)
      result += result + symbolsList[i] + "; ";
      
   Print("SymbolsListWithSymbolPart: RON: " + result);
   
   return(INIT_SUCCEEDED);
}
