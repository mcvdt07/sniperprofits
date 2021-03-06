//+------------------------------------------------------------------+
//|                                           SniperProfitV3.2.2.mq4 |
//|                            Copyright 2021, Machiel Van Der Toorn |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
static input string TrailingProfitLabel = "------------"; //TRAILING PROFIT SETTINGS
input double      Trigger = 18;//--  Trigger Price
input double      TrailingDistance=3;//--  Trailing Distance
input double      Step=0.9;//--  Step

static input string IndividualTakeProfitLabel = "------------"; //INDIVIDUAL TAKE PROFIT
input bool        EnableUniveralProfitLable = FALSE;//ENABLE INDIVIDUAL TAKE PROFIT LEVEL
input double      UniversalTakeProfitLimit = 6;//Take Profit Level
input double      UniversalLossLimit = -18;//Stoploss Level

static input string AfterTradeLabel = "------------"; //AFTER TRAILING PROFIT SETTINGS
input bool        Terminate=FALSE;//--  Shutdown When Done?
static input string SoundLabel = "------------"; //SOUND SETTINGS
input bool        Sound=TRUE;//--  Sound On?
static input string CloseAllLabel = "------------"; //CLOSE ALL OPEN TRADES
input bool        CloseNow=FALSE;//--  Close All Trades Now?

double Highest=0;
bool IsTrailing=FALSE;
bool IsClosing=FALSE;
bool ShutDownTerminal=FALSE;

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnTick()
  {
   double MyAccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double MyAccountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double MyFloatingBalance = MyAccountEquity - MyAccountBalance;
   double MyTakeProfitTrigger = Trigger;
   double TrailingProfit = MyFloatingBalance - TrailingDistance;

   Comment("%%%%%%%%%%%%%%%%"
           ,"\n","%  OPEN ORDERS:                " + string(OrdersTotal()) + "   %"
           ,"\n","%  TRIGGER PRICE:              " + string(MyTakeProfitTrigger) + "   %"
           ,"\n","%  STEP:                           " + DoubleToString(Step,2) + "   %"
           ,"\n","%  PROFIT / LOSS:           " + DoubleToString(MyFloatingBalance,2) + "   %"
           ,"\n","%  TRAILING PROFIT:       " + DoubleToString(Highest,2) + "   %"
           ,"\n","%%%%%%%%%%%%%%%%"
          );

   if(CloseNow == TRUE)   //To Instantly close all open orders
     {
      CloseAllPositions();
      Alert("Set Close All Trades To FALSE!");
     }


   if(OrdersTotal() >= 1) //If there are open orders
     {
      if(MyFloatingBalance > MyTakeProfitTrigger) //Open up when Take profit is triggered
        {
         IsTrailing = True; //Set the trailing button on
         if(TrailingProfit > Highest + Step) // Searching if new profits are higher
           {
            Highest = TrailingProfit; // Set New highest profit
            printf(Highest);
           }
        }

      if(IsTrailing == True) //Check if trailing button is on
        {

         if(MyFloatingBalance < Highest) //If floating balance drops below the trailing profit number
           {
            printf("Close All Positions");
            printf(Highest);
            IsClosing=TRUE; //Trigger call to close all trades
           }
        }
      if(IsClosing == TRUE) //Recuring close for all trades
        {
         CloseAllPositions(); //Close positions
         if(Sound==TRUE)
           {
            PlaySound("smb_world_clear.wav"); //Success Sound
           }
         if(Terminate == TRUE) //Check if terminal must close after all Open trades have been closed
           {
            ShutDownTerminal=TRUE; //If Terminate is true then we call this new variable when all open trades are closed
           }
        }


     }

   if(OrdersTotal() == 0)
     {
      IsTrailing=FALSE;//Reset Trailing swith
      IsClosing=FALSE;//Reset Check for if all trades have closed
      Highest = 0;
      if(ShutDownTerminal == TRUE)//Check if session is to be terminated
        {
         ShutDownTerminal=FALSE;//Reset Boolean
         if(Sound==TRUE)
           {
            PlaySound("smb_bowserfalls.wav"); //Shutdown Sound
           }
         TerminalClose(0); //Close terminal
        }
     }
   if(MyFloatingBalance <= 0){
   MyAlertOnProfit();
   }
  }
//+------------------------------------------------------------------+
//|              Close All Positions Function                                           |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      string CurrencyPair=OrderSymbol();

      if(OrderType()==OP_BUY)
        {
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Violet);
         if(Sound==TRUE)
           {
            PlaySound("smb_coin.wav"); //Success Sound
           }
        }
      else
         if(OrderType()==OP_SELL)
           {
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,Violet);
            if(Sound==TRUE)
              {
               PlaySound("smb_coin.wav"); //Success Sound
              }
           }
     }
  }

//+------------------------------------------------------------------+
void MyAlertOnProfit()
  {
   if(EnableUniveralProfitLable==TRUE)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS)==true)
           {

            if(OrderProfit()>=UniversalTakeProfitLimit || OrderProfit()<=UniversalLossLimit)
              {
               printf(OrderProfit());

               if(OrderType()==OP_BUY)
                 {
                  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Violet);
                  if(Sound==TRUE)
                    {
                     PlaySound("smb_coin.wav"); //Success Sound
                    }
                 }
               else
                  if(OrderType()==OP_SELL)
                    {
                     OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,Violet);
                     if(Sound==TRUE)
                       {
                        PlaySound("smb_coin.wav"); //Success Sound
                       }
                    }

              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
