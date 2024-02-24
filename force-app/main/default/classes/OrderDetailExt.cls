public class OrderDetailExt {
     public New_Order__c newod{get;set;}
     public List<Order__c> od{get;set;}
     public Boolean previewOnly {get; set;}
     public String message {get; set;}
     public OrderDetailExt(ApexPages.StandardController stdController){
        
         id pageid = ApexPages.currentPage().getParameters().get('id');
         this.newod = [select Id,Name,Order_Value__c,Delivery_Date__c,Order_Date__c,Account_Name__c from New_Order__c where id =:pageid];
         this.message = String.valueOf(ApexPages.currentPage().getParameters().get('message'));
         this.od=[select Id, New_Product__c, New_Order__c,Quantity__c ,New_Product__r.Name from Order__c where New_Order__c =: pageid];   
    }
    
    @InvocableMethod(label='Email Order Details PDF' description='Generates and Emails an Oder detail PDF')
    public static List<generatePDFReturnVars> generatePDF(List<generatePDFParams> pdfParamList){
        List<generatePDFReturnVars> returnVarsWrapper = new List<generatePDFReturnVars>();
        
        for(generatePDFParams pdfParams : pdfParamList) {
            String url = 'apex/OrderDetailsPdf?';
            String parameters = 'Id=' + pdfParams.recordId + 
                                '&previewOnly=' + pdfParams.previewOnly + 
                                '&message=' + pdfParams.message;

            PageReference invoicePDF = new PageReference('/' +url + parameters);

            if(!pdfParams.previewOnly){ 
                emailPDF(invoicePDF, pdfParams);
                attachPDF(invoicePDF, pdfParams);
            }
            
            generatePDFReturnVars returnVars = new generatePDFReturnVars();
            returnVars.url = url + parameters;
        
            returnVarsWrapper.add(returnVars);
        }

        return returnVarsWrapper;
    }

    private static void emailPDF(PageReference invoicePDF, generatePDFParams pdfParams){
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

        attachment.setContentType('application/pdf');
        attachment.setFileName('OrderDetails PDF');
        attachment.body = invoicePDF.getContentAsPdf();
        attachment.setInline(false);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[] {pdfParams.email});
        mail.setSubject('OrderDetails PDF');
        mail.setHtmlBody('Here\'s the Invoice PDF you requested.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private static void attachPDF(PageReference invoicePDF, generatePDFParams pdfParams){
        Attachment attachment = new Attachment();

        attachment.Body = invoicePDF.getContentAsPdf();
        attachment.Name = 'invoicePDF--' + Datetime.now() + '.pdf';
        attachment.ParentId = pdfParams.recordId;
        
        insert attachment;
    }

    public class generatePDFParams {
        @invocableVariable(label='Preview only' description='preview only' required=false)
        public Boolean previewOnly;

        @invocableVariable(label='Email' description='recepient email' required=false)
        public String email;

        @invocableVariable(label='RecordId' description='record Id' required=true)
        public String recordId;

        @invocableVariable(label='Message' description='optional message' required=false)
        public String message;
    }

    public class generatePDFReturnVars {
        @invocableVariable(label='Preview PDF URL' description='Preview PDF URL' required=false)
        public String url; 
    }
    
    
    
}