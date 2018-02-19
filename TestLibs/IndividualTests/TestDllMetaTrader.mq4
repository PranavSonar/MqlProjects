//+------------------------------------------------------------------+
//|                                            TestDllMetaTrader.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#import "MetaTraderExtensionLibrary.dll"
/*
int OpenFile(string fileName);
bool EndOfStream(int handle);
void CloseFile(int handle);
int ReadCharacter(int handle);
string ReadLine(int handle);
string ReadToEnd(int handle);
void WriteCharacter(int handle, char c);
void WriteLine(int handle, string line);
void WriteString(int handle, string s);
*/

// new ones
//bool FileClear(string fileName);
string FileReadLine(string fileName, int lineNumber);
//void FileReadLineRef(string fileName, int lineNumber, string &lineRef);
//char FileReadCharacter(string fileName, int characterNumber);
//bool FileWriteLine(string fileName, string line);
//bool FileWriteCharacter(string fileName, int character);


//string FileReadLine(string fileName, int lineNumber);
//void FileReadLineRef(string fileName, int lineNumber, string lineRef);
//char FileReadCharacter(string fileName, int characterNumber);
//void FileWriteCharacter(string fileName, char character);
//void FileWriteLine(string fileName, string line);

#import

int OnInit()
{
	Print(FileReadLine("Config.txt", -1));
	Print(FileReadLine("Config.txt", 0));
	Print(FileReadLine("Config.txt", 1));
	Print(FileReadLine("Config.txt", 2));
	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{


}

void OnTick()
{

}
