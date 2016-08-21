//+------------------------------------------------------------------+
//|                                                   BaseObject.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Object.mqh>

class BaseObject : CObject
{
	private:
		int VerboseLevel;
		bool TracingProcedureStart;
		string TracingProcedureName;
		
	public:
		BaseObject(int verboseLevel = 0, string tracingProcedureName = "") { this.VerboseLevel = verboseLevel; this.TracingProcedureStart = true; this.TracingProcedureName = tracingProcedureName; }
		
		virtual void TraceProcedure(string procedureName = "")
		{
			if((procedureName == "") && (this.TracingProcedureName == ""))
				return;
			if(procedureName != "")
				this.TracingProcedureName = procedureName;
			
			if(this.TracingProcedureStart)
			{
				Print(" > " + this.TracingProcedureName + " entered");
				this.TracingProcedureStart = false;
			} else {
				Print(" > " + this.TracingProcedureName + " exited");
				this.TracingProcedureStart = true;
				this.TracingProcedureName = "";
			}
		}
		
		virtual int GetVerboseLevel()
		{
			return this.VerboseLevel;
		}
		
		virtual void SetVerboseLevel(int verboseLevel)
		{
			this.VerboseLevel = verboseLevel;
		}
		
		virtual bool IsVerboseMode()
		{
			return this.VerboseLevel >= 1;
		}
		
		virtual string StringFormatNumberNotZero(string format, double number) { if(number != 0.0) return StringFormat(format, number); return ""; }
		virtual string StringFormatNumberWithCondition(string format, double number, bool condition) { if(condition) return StringFormat(format, number); return ""; }
		virtual string ReturnStringOnCondition(string text, bool condition) { if(condition) return text; return ""; }
		virtual string ReturnStringOnNumberNotZero(string text, double number) { return ReturnStringOnCondition(text, number != 0.0); }
};