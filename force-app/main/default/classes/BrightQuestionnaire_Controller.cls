public class BrightQuestionnaire_Controller {
  
    public String contact_type { get; set; } 
    public String Product_offer_details { get; set; }
    public String Product_use { get; set; } 
    public String Broker_name { get; set; } 
    public String Broker_Information { get; set; }
    public List<String> Product_audience { get; set; } 
    public String Is_login_required { get; set; } 
    public String authentication_methods { get; set; }
    public String monitoring_credentials { get; set; } 
    public String bright_data_usage { get; set; } 
    public String authenticate_broker{ get; set; }
    public String broker_services { get; set; } 
    public String data_pull_period { get; set; } 
    public String RETS_data_access { get; set; } 
    public String Is_data_shared { get; set; }
    public String Is_data_display_plugin { get; set; } 
    public String website_URL{ get; set; } 
    public String Primary_Contact_Name{ get; set; }
    public String Primary_Contact_Phone_Number { get; set; }
    public String Primary_Contact_Email_Address { get; set; } 
    public String Technical_Contact_Name{ get; set; }
    public String Technical_Contact_Phone_Number { get; set; }
    public String Technical_Contact_Email_Address { get; set; } 
    public String Billing_Contact_Name{ get; set; }
    public String Billing_Contact_Phone_Number { get; set; }
    public String Billing_Contact_Email_Address { get; set; } 
    public String Administrative_Contact_Name{ get; set; }
    public String Administrative_Contact_Phone_Number { get; set; }
    public String Administrative_Contact_Email_Address { get; set; }
    public String shareDataStr1 { get; set; }
    public String shareDataStr2 { get; set; }
    public String otherInfoStr { get; set; }
    
    public String vendorName1 { get; set; }
    public String vendorName2 { get; set; }
    public Map<String, String> documentsMap { get; set; }
    public String quetionnairType { get; set; }
    
    public BrightQuestionnaire_Controller() {
        try {
            quetionnairType = Apexpages.currentpage().getparameters().get('type');
            if(String.isBlank(quetionnairType))
                quetionnairType = 'IDX';
                
            contact_type = 'Vendor';
            documentsMap = new Map<String, String>();
            List<Document> docs = [SELECT Id, Name FROM Document WHERE Name IN ('Display Fields Document', 'Display Rules document', 'Pricing Structure Document')];   
            if(docs.Size() > 0) {
                for(Document d : docs) {
                    documentsMap.put(d.Name, '/bright/servlet/servlet.FileDownload?file=' + d.Id);
                }    
            }
        }
        catch(Exception e) {
            product_offer_details = e.getMessage();
        }
    } 
    
    Public PageReference submitApplication() {
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                    FROM   QueueSobject 
                                    WHERE  SobjectType = 'Case' 
                                    AND    Queue.DeveloperName = 'Content_Licensing_Queue'];
           
        Case newcase = new Case();
        newCase.OwnerId = queueIds[0].QueueId;
        newcase.Origin ='BRIGHT questionnaire form';
        newcase.Subject='RETS application form';
        newcase.Status = 'Not Started';
        insert newcase;
        
        
        PageReference ref = new PageReference('/apex/BrightQuestionnaire_PDF');
        ref.setRedirect(false);
        //Blob reportPdf = Page.BrightQuestionnaire_pdf.getContentAsPDF();
        Blob reportPdf = Test.isRunningTest() ? Blob.ValueOf('dummy text'): Page.BrightQuestionnaire_pdf.getContentAsPDF();
        Attachment att = new Attachment();
        att.Body = reportPdf;
        att.name='Bright_Questionnaire.pdf';
        att.ParentId = newcase.id;
        insert att;         
        
        if(vendorName1 != null && vendorName1 != '') {
            //Blob reportPdf1 = Page.BrightQuestionnaire_Agreement1.getContentAsPDF();
            Blob reportPdf1 = Test.isRunningTest() ? Blob.ValueOf('dummy text'): Page.BrightQuestionnaire_Agreement1.getContentAsPDF();
            Attachment att1 = new Attachment();
            att1.Body = reportPdf1;
            att1.name='IDX Access Agreement.pdf';
            att1.ParentId = newcase.id;
            insert att1;
        }
        
        if(vendorName2 != null && vendorName2 != '') {
           // Blob reportPdf2 = Page.BrightQuestionnaire_Agreement2.getContentAsPDF();
            Blob reportPdf2 = Test.isRunningTest() ? Blob.ValueOf('dummy text'): Page.BrightQuestionnaire_Agreement2.getContentAsPDF();
            Attachment att2 = new Attachment();
            att2.Body = reportPdf2;
            att2.name='VOW Access Agreement.pdf';
            att2.ParentId = newcase.id;
            insert att2;
        }        
        
        return ref;
    }
}