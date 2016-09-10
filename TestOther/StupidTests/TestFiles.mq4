//+------------------------------------------------------------------+
//|                                                       Test02.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Base\BeforeObject.mqh>
#include <Files\FileTxt.mqh>

void OnStart()
{
	CFileTxt logFile;
	logFile.Open("LogFile.txt", FILE_READ | FILE_WRITE | FILE_ANSI);
	logFile.Seek(0, SEEK_END);
	logFile.WriteString("Big whatever 2\n");
	logFile.Flush();
	logFile.Close();
	
	
	CFileTxt logFile2;
	logFile2.Open("LogFile.txt", FILE_READ | FILE_ANSI);
	string line = logFile2.ReadString();
	while(!logFile2.IsEnding())
	{
		line = logFile2.ReadString();
	}
	logFile2.Close();
}
