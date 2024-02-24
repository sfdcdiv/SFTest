public with sharing class OrderDetailController {
      //public List<New_Order__c> nod {get;set;}
        public Id orderId {get;set;}
        public List<Order__c> odl{get;set;}
      //public List<Product_List__c> pdtl{get;set;}
     // public Set<String> resultIds = new Set<String>();
     public Order__c getodl(){
          
             return [SELECT Id , Quantity__c FROM Order__c where
                  New_Order__c =: orderId];   
               }
  /*  public OrderDetailController(){
        String orderId =  ApexPages.currentPage().getParameters().get('Order_ID__c');
        //nod = new New_Order__c();
       
        }*/
       
            
        
       // pdtl= new List<Product_List__c>();
       // nod = [SELECT  Order_ID__c , Name, Order_Value__c, Order_Date__c, Delivery_Date__c FROM New_Order__c where
        //           Order_ID__c =: orderId];
       // nod = [SELECT  Order_ID__c , Name, Order_Value__c, Order_Date__c, Delivery_Date__c FROM New_Order__c];
      //  SELECT New_Order__c, New_Product__c, Quantity__c from Order__c where New_Order__c = 'a029D00000GXwcTQAT'
        /* odl = new List<Order__c>();
         odl = [SELECT Id, New_Order__c, Name, New_Product__c, Quantity__c, New_Order__r.Name FROM Order__c
                WHERE New_Order__c =: orderId];
       
        for (Order__c storeoid: odl)  
          {
              resultIds.add(storeoid.Id);  
              system.debug('-------resultIds-----'+resultIds); 
          }
          
        //   odl = new List<Order__c>();
         pdtl = [SELECT Product_Code__c, Name FROM Product_List__c where Id In :resultIds];
        
              */
       
    }