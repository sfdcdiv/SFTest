public with sharing class LeadConvertController {
    
    @AuraEnabled
    public static void revertBack(String leadId){
        try {
            String fieldName = 'Status__c';
            List<New_Lead__History> leadHistoryList = [SELECT Id, IsDeleted, ParentId, CreatedById, CreatedDate, Field, DataType, OldValue, NewValue 
                                    FROM New_Lead__History Where ParentId =: leadId AND Field =: fieldName Order By Createddate desc Limit 1];

            New_Lead__c leadObj = [Select Id, Name, Status__c From New_Lead__c Where Id =: leadId];
            leadObj.Status__c = leadHistoryList[0].OldValue+'';  
            update leadObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static leadWrapper convertLead(String leadId, String accNew, String conNew, String orderNew, Boolean createOrder, String recordOwner){
        try {
            New_Lead__c leadObj = [Select Id, Name, Status__c, Account_Name__c, Account_Type__c, Email__c, Address__c, Mobile_Number__c, 
                            Rating__c, Lead_Source__c From New_Lead__c Where Id =: leadId];

            Account accObj = (Account)JSON.deserialize(accNew, Account.class);
            Contact conObj = (Contact)JSON.deserialize(conNew, Contact.class);
            New_Order__c orderObj = (New_Order__c)JSON.deserialize(orderNew, New_Order__c.class);

            accObj.Type = leadObj.Account_Type__c;
            accObj.Email__c = leadObj.Email__c;
            accObj.BillingStreet = leadObj.Address__c;
            accObj.Phone = leadObj.Mobile_Number__c;
            accObj.Rating = leadObj.Rating__c;
            accObj.AccountSource = leadObj.Lead_Source__c;
            if(recordOwner != '' && recordOwner != null && recordOwner != 'undefined')    accObj.OwnerId = recordOwner;
            upsert accObj;

            conObj.AccountId = accObj.Id;
            conObj.LastName = conObj.Name;
            conObj.Email = leadObj.Email__c;
            conObj.MailingStreet = leadObj.Address__c;
            conObj.MobilePhone = leadObj.Mobile_Number__c;
            conObj.LeadSource = leadObj.Lead_Source__c;
            if(recordOwner != '' && recordOwner != null && recordOwner != 'undefined')    conObj.OwnerId = recordOwner;
            upsert conObj;

            if(!createOrder){
                orderObj.Account_Name__c = accObj.Id;
                // orderObj.LeadSource = leadObj.Lead_Source__c;
                if(recordOwner != '' && recordOwner != null && recordOwner != 'undefined')    orderObj.OwnerId = recordOwner;
                upsert orderObj;
            }

            leadObj.Lead_Convert_Check__c = false;
            update leadObj;

            leadWrapper ld = new leadWrapper();
            ld.accountId = accObj;
            ld.contactId = conObj;
            if(!createOrder)    ld.newOrderId = orderObj;
            ld.errorMessage = '';
            return ld;
        } catch (Exception e) {
            System.debug(e.getMessage());
            leadWrapper ld = new leadWrapper();
            ld.errorMessage = e.getMessage()+'';
            return ld;
        }
    }

    public class leadWrapper{
        @AuraEnabled public Account accountId{get;set;}
        @AuraEnabled public Contact contactId{get;set;}
        @AuraEnabled public New_Order__c newOrderId{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
    }
}