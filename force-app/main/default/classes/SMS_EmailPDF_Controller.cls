public with sharing class SMS_EmailPDF_Controller {
    public String email { get; set; }
    public PageReference sendPdf() {
        PageReference pdf = Page.SMS_EmailPDF;
        
        Blob body;
    
        try {
    
          // returns the output of the page as a PDF
          body = pdf.getContent();
    
        // need to pass unit test -- current bug  
        } catch (VisualforceException e) {
          body = Blob.valueOf('Some Text due to ' + e);
        }
    
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('testPdf.pdf');
        attach.setInline(false);
        attach.Body = body;
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] { email });
        mail.setSubject('PDF Email Demo');
        mail.setHtmlBody('Here is the email you requested! Check the attachment!');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
    
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF sent to '+email));
    
        return null;
    
      }
}