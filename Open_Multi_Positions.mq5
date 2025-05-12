#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh> //for CTrade

CTrade myTradingControlPanel;

enum Pos_Directions {
   BUY = 0,
   SELL = 1,
};

input int POINTS_BETWEEN_POSITIONS = 100;
input int NUMBER_OF_POSITIONS_TO_OPEN = 10;
//input int STOP_LOSS_POINTS_FROM_ENTRY = 0;
input double LOT_SIZE = 0.01;
input double BASE_PRICE = 0;
input Pos_Directions BUY_OR_SELL = 0;


double Subtract_Points_From_Price(double pPrice, double pPoints) {
   
   //convert price to whole number by moving comma to the right according to the decimal places
   //subtract points from the whole number
   //convert back to price with original number of decimals
   //e.g We want to subtract 315 points from the price:
   // -- 1.08600 * 100000 = 108600 - 315 = 108285 / 100000 = 1.08285
   
   return (pPrice*MathPow(10, _Digits) - pPoints)/MathPow(10, _Digits);
      
}

double Add_Points_to_Price(double pPrice, double pPoints) {
   
   //convert price to whole number by moving comma to the right according to the decimal places
   //add points from the whole number
   //convert back to price with original number of decimals
   //e.g We want to add 315 points from the price:
   // -- 1.08600 * 100000 = 108600 + 315 = 108915 / 100000 = 1.08915
   
   return (pPrice*MathPow(10, _Digits) + pPoints)/MathPow(10, _Digits);
      
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()  {
   
   double Entry_Price = 0;
   double SL = 0; 
   double TP = 0;
   
   //Entries
   //_____________________________________________________________________________________________________________  

   if (BUY_OR_SELL == 0) { //BUYS
   
      //1 - Open a single market order
      myTradingControlPanel.Buy(LOT_SIZE, _Symbol);
      
      //2 - Open limit orders
      
      for (int i=1; i<=NUMBER_OF_POSITIONS_TO_OPEN; i++) {
         Entry_Price = Subtract_Points_From_Price(BASE_PRICE, i*POINTS_BETWEEN_POSITIONS);
         SL = Subtract_Points_From_Price(Entry_Price, 1.5*POINTS_BETWEEN_POSITIONS); 
         TP = Add_Points_to_Price(Entry_Price, 1.5*POINTS_BETWEEN_POSITIONS);
         Print("Entry Price = " + string(Entry_Price));  
         myTradingControlPanel.BuyLimit(LOT_SIZE, Entry_Price, _Symbol, 0, 0);
      }
   }
   else { //SELLS
      //1 - Open a single market order
      myTradingControlPanel.Sell(LOT_SIZE, _Symbol);

      //2 - Open limit orders
      
      for (int i=1; i<=NUMBER_OF_POSITIONS_TO_OPEN; i++) {
         Entry_Price = Add_Points_to_Price(BASE_PRICE, i*POINTS_BETWEEN_POSITIONS);
         TP = Subtract_Points_From_Price(Entry_Price, 1.5*POINTS_BETWEEN_POSITIONS); 
         SL = Add_Points_to_Price(Entry_Price, 1.5*POINTS_BETWEEN_POSITIONS);   
         Print("Entry Price = " + string(Entry_Price));
         myTradingControlPanel.SellLimit(LOT_SIZE, Entry_Price, _Symbol, 0, 0);
      }
   }
   
   return INIT_SUCCEEDED; 
}

