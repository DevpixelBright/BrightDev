public class SMS_Attachment_Controller {
    
    public Id billingAccountId { get; set; }
    public List<Zuora__ZInvoice__c> sfInvoices;
    
    public List<Zuora.zObject> zInvoices;
    
    Zuora.zApi zApiInstance;
    Zuora.zApi.LoginResult zLoginResult;
    
    public SMS_Attachment_Controller(){

    } 
    
    public List<Zuora__ZInvoice__c> getzInvoicesList() {
        sfInvoices = new List<Zuora__ZInvoice__c>();
        sfInvoices = [SELECT Id,Zuora__Balance2__c,Zuora__InvoiceDate__c,Zuora__ZuoraId__c
                     FROM   Zuora__ZInvoice__c
                     WHERE Zuora__BillingAccount__c = :billingAccountId]; 
        return sfInvoices;   
    } 
    
    public List<Zuora.zObject> getZInvoice(){
        zApiInstance = new Zuora.zApi(); 
        zLoginResult = zApiInstance.zlogin();
        
        billingAccountId = ApexPages.currentPage().getParameters().get('Id');
        
        zInvoices = new List<Zuora.zObject>();
        
        //zAccountQuery
        Boolean isNotFirst = false;
        List<Zuora.zObject> zInvoiceItems = new List<Zuora.zObject>();
        
        String invoiceItemQuery = 'SELECT Id, ChargeAmount,ChargeDate,ChargeDescription,ProductDescription, InvoiceId, ChargeName, ProductName, ServiceEndDate, ServiceStartDate FROM InvoiceItem WHERE ';
        
        for(Zuora__ZInvoice__c zInvoice : [SELECT Id,Zuora__Balance2__c,Zuora__InvoiceDate__c,Zuora__ZuoraId__c
                     FROM   Zuora__ZInvoice__c
                     WHERE Zuora__BillingAccount__c = :billingAccountId]) {    
            
            if (isNotFirst) 
                invoiceItemQuery += ' OR ';
            
            invoiceItemQuery += 'InvoiceId = \'' + zInvoice.Id + '\'';
            isNotFirst = true;
        }
        
        if(isNotFirst){
            zInvoiceItems = zApiInstance.zquery(invoiceItemQuery);
            
            }
        
        return zInvoiceItems ;  
    }
    
    public class InvoiceItem{
        public String Id { get; set; }
        public Decimal ChargeAmount { get; set; }
        public DateTime ChargeDate { get; set; }
        public String ChargeDescription { get; set; }
        public String ChargeName { get; set; }
        public String InvoiceId { get; set; }
        public String ProductDescription { get; set; }
        public String ProductName { get; set; }
        public DateTime ServiceEndDate { get; set; }
        public DateTime ServiceStartDate { get; set; }

        public InvoiceItem (Zuora.zObject zInvoiceItem) {
            this.Id = (String) zInvoiceItem.getValue('Id');
            this.ChargeAmount = (Decimal) zInvoiceItem.getValue('ChargeAmount');
            this.ChargeDate = (DateTime) zInvoiceItem.getValue('ChargeDate');
            this.ChargeDescription = (String) zInvoiceItem.getValue('ChargeDescription');
            this.ChargeName = (String) zInvoiceItem.getValue('ChargeName');
            this.InvoiceId = (String) zInvoiceItem.getValue('InvoiceId');
            this.ProductDescription = (String) zInvoiceItem.getValue('ProductDescription');
            this.ProductName = (String) zInvoiceItem.getValue('ProductName');
            this.ServiceEndDate = (DateTime) zInvoiceItem.getValue('ServiceEndDate');
            this.ServiceStartDate = (DateTime) zInvoiceItem.getValue('ServiceStartDate');
        }
    }
}