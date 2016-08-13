//+------------------------------------------------------------------+
//|                                                   BaseObject.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class BaseObject
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
		
		virtual bool IsVerboseMode()
		{
			return this.VerboseLevel >= 1;
		}
};