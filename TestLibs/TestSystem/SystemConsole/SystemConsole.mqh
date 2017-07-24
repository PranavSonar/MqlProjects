//+------------------------------------------------------------------+
//|                                                SystemConsole.mqh |
//|                   Copyright 2009-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <MyMql\Base\BeforeObject.mqh>

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\ListView.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\RadioGroup.mqh>
#include <Controls\CheckGroup.mqh>

#include "SystemCommands.mqh"

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (10)      // gap by X coordinate
#define CONTROLS_GAP_Y                      (10)      // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate

//+------------------------------------------------------------------+
//| Class SystemConsole                                              |
//| Usage: main dialog of the SimplePanel application                |
//+------------------------------------------------------------------+
class SystemConsole : public CAppDialog
  {
private:
   CLabel            outputEdit[];                      // the display field object
   CEdit             inputEdit;                       // input edit
   CButton           lockButton;                       // the fixed button object
   CListView         optionsListView;                     // the list object
   CCheckGroup       configCheckGroup;                   // the check box group object
	
	SystemCommands sCommands;
	
public:
                     SystemConsole(void);
                    ~SystemConsole(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateOutputEdit(void);
   bool              CreateInputEdit(void);
   bool              CreateLockButton(void);
   bool              CreateConfigCheckGroup(void);
   bool              CreateOptionsListView(void);
   //--- internal event handlers
   virtual bool      OnResize(void);
   //--- handlers of the dependent controls events
   void              OnClickLockButton(void);
   void              OnChangeOptionsListView(void);
   void              OnChangeConfigCheckGroup(void);
   void              OnEndEditInputEdit(void);
   bool              OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Text handlers
   void              AddLine(string line);
   void              SetText(string text);
   void              UpdateControls(string command);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(SystemConsole)
ON_EVENT(ON_CLICK,lockButton,OnClickLockButton)
ON_EVENT(ON_CHANGE,configCheckGroup,OnChangeConfigCheckGroup)
ON_EVENT(ON_CHANGE,optionsListView,OnChangeOptionsListView)
ON_EVENT(ON_END_EDIT,inputEdit,OnEndEditInputEdit)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
SystemConsole::SystemConsole(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
SystemConsole::~SystemConsole(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool SystemConsole::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateOutputEdit())
      return(false);
   if(!CreateInputEdit())
      return(false);
   if(!CreateLockButton())
      return(false);
   if(!CreateConfigCheckGroup())
      return(false);
   if(!CreateOptionsListView())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the display field                                         |
//+------------------------------------------------------------------+
bool SystemConsole::CreateOutputEdit(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=ClientAreaWidth()-(CONTROLS_GAP_X+BUTTON_WIDTH+CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT);
   int y2=y1+EDIT_HEIGHT;
   int yMax=ClientAreaHeight()-(CONTROLS_GAP_Y+EDIT_HEIGHT+INDENT_BOTTOM);
   int nr = yMax/EDIT_HEIGHT;
   ArrayResize(outputEdit,nr);
   
//--- create
	for(int i=0;i<nr;i++)
	{
		if(!outputEdit[i].Create(m_chart_id,m_name+"OutputEdit" + IntegerToString(i),m_subwin,x1,y1,x2,y2))
	      return(false);
	   //if(!outputEdit.ReadOnly(true))
	   //   return(false);
	   if(!Add(outputEdit[i]))
	      return(false);
	      
   	outputEdit[i].Alignment(WND_ALIGN_WIDTH,INDENT_LEFT,0,INDENT_RIGHT+BUTTON_WIDTH+CONTROLS_GAP_X,0);
   	
   	y1=y2;
   	y2=y1+EDIT_HEIGHT;
	}
	
//--- succeed
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Create the display field                                         |
//+------------------------------------------------------------------+
  bool SystemConsole::CreateInputEdit(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=ClientAreaHeight()-(EDIT_HEIGHT+INDENT_BOTTOM);
   int x2=ClientAreaWidth()-(CONTROLS_GAP_X+BUTTON_WIDTH+CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT);
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!inputEdit.Create(m_chart_id,m_name+"InputEdit",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!inputEdit.ReadOnly(false))
      return(false);
   if(!Add(inputEdit))
      return(false);
   inputEdit.TextAlign(ALIGN_LEFT);
   inputEdit.Alignment(WND_ALIGN_WIDTH,INDENT_LEFT,0,CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT,0);
//--- succeed
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Create the "CreateLockButton" fixed button                       |
//+------------------------------------------------------------------+
bool SystemConsole::CreateLockButton(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-(BUTTON_WIDTH+INDENT_RIGHT);
   int y1=ClientAreaHeight()-(BUTTON_HEIGHT+INDENT_BOTTOM);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!lockButton.Create(m_chart_id,m_name+"LockButton",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!lockButton.Text("Locked"))
      return(false);
   if(!Add(lockButton))
      return(false);
   lockButton.Locking(true);
   lockButton.Alignment(WND_ALIGN_RIGHT|WND_ALIGN_BOTTOM,0,0,INDENT_RIGHT,INDENT_BOTTOM);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup" element                                  |
//+------------------------------------------------------------------+
bool SystemConsole::CreateConfigCheckGroup(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-(BUTTON_WIDTH+INDENT_RIGHT);
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=ClientAreaHeight()-(CONTROLS_GAP_Y+EDIT_HEIGHT+INDENT_BOTTOM);
//--- create
   if(!configCheckGroup.Create(m_chart_id,m_name+"CheckGroup",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(configCheckGroup))
      return(false);
   configCheckGroup.Alignment(WND_ALIGN_HEIGHT,0,y1,0,INDENT_BOTTOM);
//--- fill out with strings
   for(int i=0;i<10;i++)
      if(!configCheckGroup.AddItem("Item "+IntegerToString(i),1<<i))
         return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "ListView" element                                    |
//+------------------------------------------------------------------+
bool SystemConsole::CreateOptionsListView(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-(BUTTON_WIDTH+CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT);
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=ClientAreaHeight()-INDENT_BOTTOM;
//--- create
   if(!optionsListView.Create(m_chart_id,m_name+"ListView",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(optionsListView))
      return(false);
   optionsListView.Alignment(WND_ALIGN_HEIGHT,0,y1,0,INDENT_BOTTOM);
//--- fill out with strings

	string commands [];
	sCommands.GetSystemCommands(commands);
	
   for(int i=0;i<ArraySize(commands);i++)
      if(!optionsListView.ItemAdd(commands[i]))
         return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Handler of resizing                                              |
//+------------------------------------------------------------------+
bool SystemConsole::OnResize(void)
  {
//--- call method of parent class
   if(!CAppDialog::OnResize()) return(false);
//--- coordinates
   
   int paddingTop = 2*INDENT_TOP;
   
   // outputEdit align, move, resize
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=ClientAreaWidth()-(CONTROLS_GAP_X+BUTTON_WIDTH+CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT);
   int y2=y1+EDIT_HEIGHT;
   int yMax=ClientAreaHeight()-(CONTROLS_GAP_Y+EDIT_HEIGHT+INDENT_BOTTOM);
   int nr = yMax/EDIT_HEIGHT;
   ArrayResize(outputEdit,nr);
   
	for(int i=0;i<nr;i++)
	{
	   outputEdit[i].Move(x1,paddingTop+y1);
	   outputEdit[i].Width(x2-x1);
	   outputEdit[i].Height(y2-y1);     
   	outputEdit[i].Alignment(WND_ALIGN_WIDTH,INDENT_LEFT,0,INDENT_RIGHT+BUTTON_WIDTH+CONTROLS_GAP_X,0);
   	
   	y1=y2;
   	y2=y1+EDIT_HEIGHT;
	}
   
   // inputEdit align, move, resize
   x1=INDENT_LEFT;
   y1=ClientAreaHeight()-(EDIT_HEIGHT+INDENT_BOTTOM);
   x2=ClientAreaWidth()-(CONTROLS_GAP_X+BUTTON_WIDTH+CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT);
   y2=y1+EDIT_HEIGHT;
   inputEdit.Move(x1, paddingTop+y1);
   inputEdit.Width(x2-x1);
   inputEdit.Height(y2-y1);
   inputEdit.Alignment(WND_ALIGN_WIDTH,INDENT_LEFT,0,CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT,0);
   
   // lockButton align, move, resize
   x1=ClientAreaWidth()-(BUTTON_WIDTH+INDENT_RIGHT);
   y1=ClientAreaHeight()-(BUTTON_HEIGHT+INDENT_BOTTOM);
   x2=x1+BUTTON_WIDTH;
   y2=y1+BUTTON_HEIGHT;
   lockButton.Move(x1, paddingTop+y1);
   lockButton.Width(x2-x1);
   lockButton.Height(y2-y1);
   lockButton.Alignment(WND_ALIGN_RIGHT|WND_ALIGN_BOTTOM,0,0,INDENT_RIGHT,INDENT_BOTTOM);
   
   // configCheckGroup align, move, resize
   x1=ClientAreaWidth()-(BUTTON_WIDTH+INDENT_RIGHT);
   y1=INDENT_TOP;
   x2=x1+BUTTON_WIDTH;
   y2=ClientAreaHeight()-(CONTROLS_GAP_Y+EDIT_HEIGHT+INDENT_BOTTOM);
   configCheckGroup.Move(x1, paddingTop+y1);
   configCheckGroup.Width(x2-x1);
   configCheckGroup.Height(y2-y1);
   configCheckGroup.Alignment(WND_ALIGN_HEIGHT,0,y1,0,INDENT_BOTTOM);
   
   // optionsListView align, move, resize
   x1=ClientAreaWidth()-(BUTTON_WIDTH+CONTROLS_GAP_X+BUTTON_WIDTH+INDENT_RIGHT);
   y1=INDENT_TOP;
   x2=x1+BUTTON_WIDTH;
   y2=ClientAreaHeight()-INDENT_BOTTOM;
   optionsListView.Move(x1, paddingTop+y1);
   optionsListView.Width(x2-x1);
   optionsListView.Height(y2-y1);
   optionsListView.Alignment(WND_ALIGN_HEIGHT,0,y1,0,INDENT_BOTTOM);
   
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnClickLockButton(void)
  {
   if(lockButton.Pressed())
   {
   	//outputEdit.Text(__FUNCTION__+"On");
   	inputEdit.ReadOnly(true);
   	configCheckGroup.Disable();
   	optionsListView.Disable();
   }
   else
   {
		//outputEdit.Text(__FUNCTION__+"Off");
		inputEdit.ReadOnly(false);
   	configCheckGroup.Enable();
   	optionsListView.Enable();
   	//CreateConfigCheckGroup();
   	//CreateOptionsListView();
   	this.Enable();
   }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnChangeOptionsListView(void)
  {
  	if(optionsListView.IsEnabled())
  	{
  		//AddLine(__FUNCTION__+" \""+optionsListView.Select()+"\"");
  		
  		string command = optionsListView.Select();
   	UpdateControls(command);
  		
 	  //outputEdit.Text(__FUNCTION__+" \""+optionsListView.Select()+"\"");
  	}
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnChangeConfigCheckGroup(void)
  {
  	if(configCheckGroup.IsEnabled())
  	{
  		AddLine(__FUNCTION__+" : Value="+IntegerToString(configCheckGroup.Value()));
   	//outputEdit.Text(__FUNCTION__+" : Value="+IntegerToString(configCheckGroup.Value()));
   }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnEndEditInputEdit(void)
  {
  	if(inputEdit.IsEnabled())
  	{
  		//AddLine(__FUNCTION__+" : Text=\""+inputEdit.Text()+"\"");
   	//outputEdit.Text(__FUNCTION__+" : Text="+inputEdit.Text());
   	//inputEdit.Activate();
	   
	   string command = inputEdit.Text();
   	UpdateControls(command);
   	
   	inputEdit.Text(NULL);
   	//EventChartCustom(ChartID(), CHARTEVENT_CLICK, inputEdit.Left(), inputEdit.Top(), NULL);
   	inputEdit.OnMouseEvent(1, 1, MOUSE_LEFT);
   }
  }
  
  
//+------------------------------------------------------------------+
//| Rest events handler                                                    |
//+------------------------------------------------------------------+
bool SystemConsole::OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- restore buttons' states after mouse move'n'click
   //if(id==CHARTEVENT_CLICK)
   //   m_radio_group.RedrawButtonStates();
//--- let's handle event by parent
   return(false);
  }
//+------------------------------------------------------------------+

void SystemConsole::AddLine(string line)
{
	int outputEditLength = ArraySize(outputEdit);
	
	for(int i=1;i<outputEditLength;i++)
		outputEdit[i-1].Text(outputEdit[i].Text());
	outputEdit[outputEditLength-1].Text(line);
}

void SystemConsole::SetText(string text)
{
	string lines[];
	StringSplit(text, '\n', lines);
	
	int len = ArraySize(lines);
	for(int i=0;i<len;i++)
		AddLine(lines[i]);
}

void SystemConsole::UpdateControls(string command)
{     
  		if(sCommands.NeedRefresh(command))
  		{
  		   optionsListView.Select(CONTROLS_INVALID_INDEX);
  		   optionsListView.ItemsClear(); // this might fuck it up
  		   //while(optionsListView.ItemDelete(0))
  		   //   ;
  		   //optionsListView.ItemDelete(0);
			optionsListView.VScrolled(false);
				   
         command = sCommands.GetSystemCommandToExecute(command, true);
         
      	string commands [];
      	sCommands.GetSystemCommands(commands);
      	
         for(int i=0;i<ArraySize(commands);i++)
            if(!optionsListView.ItemAdd(commands[i]))
               return;
  		}
  		
  		AddLine("\"" + sCommands.GetContext() + "\" \"" + command + "\"");
}