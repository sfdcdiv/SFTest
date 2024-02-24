@istest
public class LeadConvertControllerTest {
    @istest
    public static void convertLead(){
        New_Lead__c leadnew = new New_Lead__c();
        leadnew.Account_Name__c = 'TEST Account90';
        leadnew.Email__c = 'test@gmailh.com';
        leadnew.Name = 'Test Name23';
        leadnew.Status__c= 'Open';
        leadnew.Account_Type__c = 'Direct';
        leadnew.Address__c = 'Test Address';
        leadnew.Mobile_Number__c= '74842323233';
        leadnew.Rating__c='Hot';
        leadnew.Lead_Source__c='Website';
        insert leadnew;
        
        Account acc = new Account();
        acc.Name =  leadnew.Account_Name__c;
             
        Contact con = new Contact();
        con.LastName = leadnew.Name;
        insert con;
        Contact conNew1 = [select Id, Name from Contact where id=:con.id];
             
        New_Order__c newOrd= new New_Order__c();
        newOrd.name =leadnew.Name;
      
        String accNew = JSON.serialize(acc) ;
        String conNew= JSON.serialize(conNew1);
        String ordNew= JSON.serialize(newOrd);
        String LId= String.valueOf(leadnew.id);
        String LOwnerId= String.valueOf(leadnew.ownerid);
     
        Test.startTest();
        try
         {
     		LeadConvertController.convertLead(LId, accNew,conNew,ordNew,false,LOwnerId);
            // LeadConvertController.convertLead(null, null,null,null,false,null); 
            // LeadConvertController.revertback(LId);
         }
         catch(exception e)
         {
            System.debug(e.getMessage());
         }   
        Test.stopTest();
    }  
    
     @istest
     public static void convertLeadException()
     {
     Test.startTest();
         try
         {     
            LeadConvertController.convertLead(null, null,null,null,false,null);
         }
         catch(exception e)
         {
            System.debug(e.getMessage());
         }   
        Test.stopTest();
    }  
   
    @istest
    public static void revertLead()
    {
        New_Lead__c leadnew1 = new New_Lead__c();
        leadnew1.Account_Name__c = 'TEST Account';
        leadnew1.Email__c = 'test@gmai.com';
        leadnew1.Name = 'Test Name';
        leadnew1.Status__c= 'Converted';
        leadnew1.Lead_Convert_Check__c = false;
        Insert leadnew1;
         
        String leadnew2= String.valueOf(leadnew1.id);
 
        /*
        if(Test.isRunningTest()){  //if TEST, create dummy lead history
         List<New_Lead__History> nlh = new List<New_Lead__History>{}; 
       //OldValue, NewValue not writeable and not able to retrive the history data and exception while updating lead. This is a known SF issue 
         nlh.add(new New_Lead__History(ParentId=leadnew1.id, Field='Status__c'));}
       */
    
       Test.startTest();
        try
            {
           		LeadConvertController.revertback(leadnew2);
             }
       catch(exception e)
           {
            System.debug(e.getMessage()); 
           } 
       Test.stopTest();
      }
 }