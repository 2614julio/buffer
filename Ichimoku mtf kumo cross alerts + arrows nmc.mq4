//+------------------------------------------------------------------+

#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  Red
#property indicator_color2  Blue
#property indicator_color3  Green
#property indicator_style3  STYLE_DOT
#property indicator_color4  Brown
#property indicator_style4  STYLE_DOT
#property indicator_color5  LimeGreen
#property indicator_color6  Green
#property indicator_style6  STYLE_DOT
#property indicator_color7  Brown
#property indicator_style7  STYLE_DOT

//
//
//
//
//

extern string TimeFrame        = "Current time frame";
extern int    Tenkan           = 9;
extern int    Kijun            = 26;
extern int    Senkou           = 52;
extern bool   Draw_Tenkan      = false;
extern bool   Draw_Kijun       = false;
extern bool   Draw_Kumo        = true;
extern bool   Draw_Chikou      = false;
extern bool   ShowArrows       = false;
extern string arrowsIdentifier = "ichimoku Arrows1";
extern double arrowsUpperGap   = 1.0;
extern double arrowsLowerGap   = 1.0;
extern color  arrowsUpColor    = LimeGreen;
extern color  arrowsDnColor    = Red;
extern int    arrowsUpCode     = 241;
extern int    arrowsDnCode     = 242;

extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = true;
extern bool   alertsEmail      = false;
extern bool   alertsNotify     = false;

//
//
//
//
//

double Tenkan_Buffer[];
double Kijun_Buffer[];
double SpanA_Buffer[];
double SpanB_Buffer[];
double Chinkou_Buffer[];
double SpanA2_Buffer[];
double SpanB2_Buffer[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//
//
//
//
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,Tenkan_Buffer);                                  SetIndexLabel(0,"Tenkan Sen");
   SetIndexBuffer(1,Kijun_Buffer);                                   SetIndexLabel(1,"Kijun Sen");
   SetIndexBuffer(2,SpanA_Buffer);  SetIndexStyle(2,DRAW_HISTOGRAM);  
   SetIndexBuffer(3,SpanB_Buffer);  SetIndexStyle(3,DRAW_HISTOGRAM);  
   SetIndexBuffer(4,Chinkou_Buffer);                                 SetIndexLabel(4,"Chinkou Span");
   SetIndexBuffer(5,SpanA2_Buffer);                                  SetIndexLabel(5,"Senkou Span A");
   SetIndexBuffer(6,SpanB2_Buffer);                                  SetIndexLabel(6,"Senkou Span B");
   SetIndexBuffer(7,trend); 
   if (!Draw_Tenkan) SetIndexStyle(0, DRAW_NONE);
   if (!Draw_Kijun)  SetIndexStyle(1, DRAW_NONE);
   if (!Draw_Chikou) SetIndexStyle(4, DRAW_NONE);
   if (!Draw_Kumo) 
   {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
      SetIndexStyle(6, DRAW_NONE);
   }
   
     //
     //
     //
     //
     //
     
     indicatorFileName = WindowExpertName();
     calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
     returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
     timeFrame         = stringToTimeFrame(TimeFrame);
     SetIndexShift(2,Kijun  * timeFrame/Period()); 
     SetIndexShift(3,Kijun  * timeFrame/Period());
     SetIndexShift(4,-Kijun * timeFrame/Period());
     SetIndexShift(5,Kijun  * timeFrame/Period());
     SetIndexShift(6,Kijun  * timeFrame/Period());    
     
     //
     //
     //
     //
     //
     
     IndicatorShortName(timeFrameToString(timeFrame)+"  Ichimoku");
     
return(0);
}

int deinit() 
{  
   deleteArrows();
return(0);
}

//
//
//
//                           
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,limit;
   
   
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1); 
           if (returnBars) { Tenkan_Buffer[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
     for(i=limit; i>=0; i--)
     {
        double thi    = High[i];
        double tlo    = Low[i];
        double tprice = 0;
        if (i >= Bars - Tenkan) continue;
        for(k = 0; k < Tenkan; k++)
        {
           tprice = High[i+k];
           if(thi < tprice)  thi = tprice;
         
           tprice = Low[i+k];
           if(tlo  > tprice) tlo = tprice;
        }
       
        if ((thi+tlo) > 0.0) 
             Tenkan_Buffer[i] = (thi + tlo)*0.5; 
        else Tenkan_Buffer[i] = 0;
       
        //
        //
        //
        //
        //
        
        double khi    = High[i];
        double klo    = Low[i];
        double kprice = 0;
        if  (i >= Bars - Kijun) continue;
        for (k = 0; k < Kijun; k++)
        {
           kprice = High[i+k];
           if(khi < kprice)  khi  = kprice;
         
           kprice = Low[i+k];
           if(klo  > kprice) klo  = kprice;
        }
        
        if ((khi+klo) > 0.0) 
             Kijun_Buffer[i] = (khi + klo)*0.5; 
        else Kijun_Buffer[i] = 0;
       
        //
        //
        //
        //
        //
        
        double shi    = High[i];
        double slo    = Low[i];
        double sprice = 0;
        if  (i >= Bars - Senkou) continue;
        for (k = 0; k < Senkou; k++)
        {
           sprice = High[i+k];
           if(shi < sprice)  shi  = sprice;
         
           sprice = Low[i+k];
           if(slo  > sprice) slo  = sprice;
        }
       
        //
        //
        //
        //
        //
        
        SpanA_Buffer[i]   = (Kijun_Buffer[i] + Tenkan_Buffer[i])*0.5;
        SpanA2_Buffer[i]  = (Kijun_Buffer[i] + Tenkan_Buffer[i])*0.5;
        SpanB_Buffer[i]   = (shi + slo)*0.5; 
        SpanB2_Buffer[i]  = (shi + slo)*0.5; 
        Chinkou_Buffer[i] = Close[i]; 
        trend[i] = trend[i+1];
           if (Close[i] > MathMax(SpanA_Buffer[i+Kijun],SpanB_Buffer[i+Kijun])) trend[i] = 1;
           if (Close[i] < MathMin(SpanA_Buffer[i+Kijun],SpanB_Buffer[i+Kijun])) trend[i] =-1;
           
           //
           //
           //
           //
           //
           
           if (ShowArrows)
           {
              deleteArrow(Time[i]);
              if (trend[i] != trend[i+1])
                 {
                   if (trend[i] == 1)  drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                   if (trend[i] ==-1)  drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                 }
           }
   
   }
   manageAlerts();
  return(0);
  }
  
  //
  //
  //
  //
  //
   
  limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
  for (i=limit;i>=0;i--)
  {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Tenkan_Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
         Kijun_Buffer[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,1,y);
         SpanA_Buffer[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,2,y);
         SpanB_Buffer[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,3,y);
         Chinkou_Buffer[i]= iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,4,y);
         SpanA2_Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,5,y);
         SpanB2_Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,6,y);
         trend[i]         = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Tenkan,Kijun,Senkou,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,7,y);      
  }
  manageAlerts();
return(0);
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
return(s);
}

//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar)); 
      if (trend[whichBar] != trend[whichBar+1])
      {
        if (trend[whichBar] == 1) doAlert(whichBar,"Price leaving Kumo up");
        if (trend[whichBar] ==-1) doAlert(whichBar,"Price leaving Kumo down");
      }     

      //
      //
      //
      //
      //
            
      
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Ichimoku ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Ichimoku "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}









