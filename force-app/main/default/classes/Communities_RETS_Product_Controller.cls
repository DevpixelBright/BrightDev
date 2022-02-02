public class Communities_RETS_Product_Controller {
    
    public List<RETS_Product_Order__c> activebilledorders { get; set;}
    public List<RETS_Product_Order__c> activeunbilledorders { get; set;}
    public List<RETS_Product_Order__c> inactiveorders { get; set;}
    public String subscriptionId { get; set;}
    public string brokerage;
    
     public list<SelectOption> options { get; set;}
     public Map<String,String> officeIds { get; set; }
     public String officeId { get; set; } 
    public String brokerageID { get;set;}
 
    
    public Communities_RETS_Product_Controller() {
        
        activebilledorders = new List<RETS_Product_Order__c>();
        activeunbilledorders = new List<RETS_Product_Order__c>();
        inactiveorders = new List<RETS_Product_Order__c>();
        brokerage = 'false';
        
        subscriptionId = ApexPages.currentPage().getParameters().get('id');
        brokerage = ApexPages.currentPage().getParameters().get('brokerage');
        system.debug('---brokerage value--->'+brokerage);
        
        if (String.IsBlank(subscriptionId))
            throw new CustomException('Invalid BRIGHT Subscription ID: No subscription ID found');   
        
        if(brokerage == 'true'){
            getOfficeDetails();
        }
               
        getActiveBillingProducts();
    	getInactiveProducts();        
	}
    
    private void getActiveBillingProducts() {
        try{
            
            string query = 'SELECT ID, Name, Start_Date__c, End_Date__c, RETS_Sub_Product__c, RETS_Sub_Product__r.Name, RETS_Sub_Product__r.Name__c, URL__c, Vendor_Product__c, Vendor_Product__r.Name, Vendor_Product__r.Authorized_Use__c, ';
            if(brokerage == 'true'){
            	
            	list<Subscriptions__c> selSub = [Select Related_Location_Broker_Office__c From Subscriptions__c Where name =: subscriptionId];
                system.debug('Brokerage ID' +brokerageID );
            	
            	query += 'Brokerage__c, Brokerage__r.Name';
            	query += ' From RETS_Product_Order__c Where  Status__c = \'Active\' AND Brokerage__c = \''+ brokerageID +'\'  ORDER By Start_Date__c DESC';
            }
            else{
            	
            	query += 'Agent__c, Agent__r.Name, Agent_Office__c, On_Behalf_of_Agent__c, On_Behalf_of_Agent__r.Name, On_Behalf_of_Agent__r.contact__r.Name';
            	query += ' From RETS_Product_Order__c Where  Status__c = \'Active\' AND Agent__r.Name = \''+ subscriptionId +'\' ORDER By Start_Date__c DESC';
            }
            
            system.debug('---activebilledorders ---->'+query);
            activebilledorders = Database.query(query);         
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));
        }
    }
    
    
    private void getInactiveProducts() {
        try{
            string query = 'SELECT ID, Name, Start_Date__c, End_Date__c, RETS_Sub_Product__c, RETS_Sub_Product__r.Name, RETS_Sub_Product__r.Name__c, URL__c, Vendor_Product__c, Vendor_Product__r.Name, Vendor_Product__r.Authorized_Use__c, ';
            
            if(brokerage == 'true'){
            	
            	list<Subscriptions__c> selSub = [Select Related_Location_Broker_Office__c From Subscriptions__c Where name =: subscriptionId];
            	
            	query += 'Brokerage__c, Brokerage__r.Name';
            	query += ' From RETS_Product_Order__c Where  Status__c = \'Inactive\' AND Brokerage__c = \''+ brokerageID +'\'  ORDER By Start_Date__c DESC';
            }
            else{
            	
            	query += 'Agent__c, Agent__r.Name, Agent_Office__c, On_Behalf_of_Agent__c, On_Behalf_of_Agent__r.Name, On_Behalf_of_Agent__r.contact__r.Name';
            	query += ' From RETS_Product_Order__c Where  Status__c = \'Inactive\' AND Agent__r.Name = \''+ subscriptionId +'\' ORDER By Start_Date__c DESC';
            }
            
            system.debug('---activebilledorders ---->'+query);
            inactiveorders = Database.query(query);
            
            system.debug('---inactiveorders ---->'+inactiveorders);
        }
        catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));
        }
    }
    
     public void getOfficeDetails(){  
         
		try {
        
        list<Relationship__c> lstRelations = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,
													Subscription__c, Subscription__r.Name, Subscription__r.Contact__r.Name, Broker_Office__r.Name
													FROM Relationship__c
													WHERE Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
													AND ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                                    AND  Broker_office__r.type = 'Residential' AND Broker_Office__r.Company_Type__c = 'Broker Office'
                                                    AND  Subscription_ID__c = :subscriptionId];
            
            officeIds = new Map<String,String>();
            
             if(lstRelations.size() > 0){
                 
               brokerageID = lstRelations[0].Broker_Office__c;
                 
            }else{
                
                throw new CustomException('No brokerge found for the subscription');
            }
            
            for(Relationship__c relation : lstRelations) { 
                
                officeIds.put(relation.Broker_Office__c, relation.Broker_Office__r.Name);
                
            }
                     
                options = new list<SelectOption>();     
            
            for(String key : officeIds.keySet()){
                
                    options.add(new SelectOption(key, officeIds.get(key)));               
            }
            
     
        }catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    
      public void reloadBrokerages() {
        try {
            System.debug('***officeId'+ officeId);
             brokerageID = officeId;
             getActiveBillingProducts();
    	     getInactiveProducts();  
        }
        catch(Exception e) {
            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));              
        }                  
    }
    
    
    public class CustomException extends Exception {}   
}