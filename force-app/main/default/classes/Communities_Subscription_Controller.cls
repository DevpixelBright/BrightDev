public class Communities_Subscription_Controller {
    public String id { get; private set; }
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public String cancelUrl { get; private set; }
    public string subStatus { get; set; }
    public string subPrimaryId {get; set;}
    
    public Boolean isInactive { get; set; }
    public Boolean activeSubscriptionFound { get; set; }
    public Boolean debugMode { get; private set; }
    public Boolean isTrendLogin { get; set; }
    public Boolean isBrightLogin { get; set; }
    public Boolean isLimited {get; set;}
    
    public List<SubscriptionData> Subscriptions { get; set; }
    public List<Subscriptions__c> subIds { get; set; }
    
    
    public Communities_Subscription_Controller() {
        initialLoad = true;
        isLimited = false;
        
        String debug = ApexPages.currentPage().getParameters().get('debug');
        
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
        isTrendLogin = false;
        isBrightLogin = false;
    }
    
    public void loadSubscriptions() {
        initialLoad = false;
        hasError = false;
        isInactive = false;
        activeSubscriptionFound = false;
        
        try {
            this.Subscriptions = new List<SubscriptionData>();
            
            List<User> currentUser = [
                SELECT   FederationIdentifier 
                FROM     User 
                WHERE    Id = :Userinfo.getUserId()
            ];
            
            if (currentUser.size() == 0)
                throw new CustomException('Invalid BRIGHT Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 
            
            String primaryId = currentUser[0].FederationIdentifier;
            
            if (String.IsBlank(primaryId))
                throw new CustomException('Invalid BRIGHT Subscription ID: No Federated ID found >> ' + currentUser); 
            
            List<Subscriptions__c> subscriptionList = [
                SELECT  Contact__c, Service_Jurisdiction__c, Import_Source__c, BRIGHT_ConversionIsInPreview__c, Contact_Type__c
                FROM    Subscriptions__c
                WHERE   Name = :primaryId
            ];
            
            if (subscriptionList.size() != 1)
                throw new CustomException('Invalid BRIGHT Subscription ID: No Contact found >> ' + currentUser[0]); 
            
            Subscriptions__c subscription = subscriptionList[0];
            subscriptionList.clear();
            
            
            if(subscription.Service_Jurisdiction__c == 'TREND')    
                isTrendLogin = true;
            if(subscription.Service_Jurisdiction__c == 'BRIGHT')    
                isBrightLogin = true;           
            
            if(subscription.Contact_Type__c == 'Limited Public Records Only')
               isLimited = true;
            List<Subscriptions__c> subIds = [
                SELECT  Name, Status__c, Service_Jurisdiction__c,Primary__c,Billing_Jurisdiction__c, TREND_Login_Name__c      
                FROM    Subscriptions__c
                WHERE   Contact__c = :subscription.Contact__c
            ];
            
            if (subIds.size() == 0){              
                throw new CustomException('Invalid BRIGHT Subscription ID: No Subscriptions found from Contact >> ' + subscription.Contact__c);
            }
            
            List<String> categories = new List<String> {
                'contact_information',
                    'view_invoices',
                    'pay_my_balances',
                    'my_payment_methods',
                    'subscribed_products',
                    'license_associations',
                    'agent_transfer',
                    'communication_preferences',
                    'RETS_Products',
                    'Agent_Accuracy_Notifications',
                    'Broker_Authorization_Request',
                    'Office_Exclusive_Certification',
                    'Office_Exclusive'
                    
                    };
                        if(isBrightLogin){
                            categories.add('mls_settings');
                            categories.add('Listing_Transfer');
                        }
            
            System.debug('*** subIds:' + subIds);
            for (Subscriptions__c subId : subIds) {
                if(subId.Status__c.equalsIgnoreCase('Inactive')){
                    isInactive = true;
                    subPrimaryId = primaryId;
                    subStatus = 'Inactive';
                }
                if(subId.Status__c.equalsIgnoreCase('Active')){
                    activeSubscriptionFound = true;
                    isInactive = false;
                    for (String category : categories) {
                        SubscriptionData objSub = new SubscriptionData();
                        
                        objSub.Category = category;
                        objSub.Id = subId.Name;
                        objSub.displayText = subId.Name;
                        if(subId.Service_Jurisdiction__c != null && subId.Service_Jurisdiction__c == 'TREND') {
                            if(subId.TREND_Login_Name__c != null)
                                objSub.displayText = subId.TREND_Login_Name__c + ' - ' + subId.Name; 
                        }
                        
                        this.Subscriptions.add(objSub);              
                    }
                }
            }  
            
            if(!activeSubscriptionFound){
                throw new CustomException('Invalid BRIGHT Subscription ID: No Subscriptions found from Contact >> ' + subscription.Contact__c);	   
            }
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }
    
    public class SubscriptionData {
        public String Category { get; set; }
        public String Id { get; set; }
        public String displayText { get; set; }
    }
    
    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
    
    public class CustomException extends Exception {}
}