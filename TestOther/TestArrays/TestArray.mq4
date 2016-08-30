//+------------------------------------------------------------------+
//|                                                TestArray.mql.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\DecisionMaking\DecisionDoubleBB.mqh>
#include <MyMql\DecisionMaking\Decision3MA.mqh>
#include <MyMql\DecisionMaking\DecisionRSI.mqh>
#include <MyMql\DecisionMaking\CandleDecision.mqh>

#include <Arrays\ArrayObj.mqh>

void OnStart2()
{
	int numbers[];
	ArrayResize(numbers,1);
	numbers[0] = 1;
	
	printf("numbers[0]=%f", numbers[0]);
	ArrayResize(numbers,2);
	numbers[1] = 4;
	
	for(int i=0;i<ArraySize(numbers);i++)
		printf("numbers[i=%d]=%f", i, numbers[i]);
}

void OnStart()
{
	// List
	CArrayObj* ListOfDecisions = new CArrayObj();
	ListOfDecisions.Add(new DecisionDoubleBB());
	ListOfDecisions.Add(new Decision3MA());
	ListOfDecisions.Add(new DecisionRSI());
	ListOfDecisions.Add(new CandleDecision());
	
	for(int i=0;i<ListOfDecisions.Total();i++)
		printf("ListOfDecisions[i=%d]:%s", i, ((BaseDecision*)ListOfDecisions.At(i)).GetDecisionName());
		
	for(int i=0;i<ListOfDecisions.Total();i++)
		delete ListOfDecisions.At(i);
	delete ListOfDecisions;
	
	
	
	// Array
	BaseDecision *decisions[];
	ArrayResize(decisions,4);
	decisions[0] = new DecisionDoubleBB();
	decisions[1] = new Decision3MA();
	decisions[2] = new DecisionRSI();
	decisions[3] = new CandleDecision();
	
	for(int i=0;i<ArraySize(decisions);i++)
		printf("decision[i=%d]:%s", i, decisions[i].GetDecisionName());
	
	for(int i=0;i<ArraySize(decisions);i++)
		delete decisions[i];
}