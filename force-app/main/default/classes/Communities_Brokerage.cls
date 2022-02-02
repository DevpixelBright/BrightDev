public class Communities_Brokerage {
    
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public String cancelUrl { get; private set; }

    public Boolean debugMode { get; private set; }
    public Boolean isTrendLogin { get; set; }
    public String serviceJurisdiction { get; set; }
    public Boolean hasBOR { get; set; }
    public Boolean hasAS { get; set; }
    public Boolean hasOM { get; set; }
	
    public Boolean isJSMLS {get; set;}
    public List<SubscriptionData> Subscriptions { get; set; }
    
    public Communities_Brokerage() {
        initialLoad = true;
		isJSMLS = false;
        String debug = ApexPages.currentPage().getParameters().get('debug');
        
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
        isTrendLogin = false;
        serviceJurisdiction = 'MRIS';
    }
    
    public void loadSubscriptions() {
        initialLoad = false;
        hasError = false;
        hasBOR = false;
        hasAS = false;
        hasOM = false;
        
        try {
            this.Subscriptions = new List<SubscriptionData>();

            List<User> currentUser = [
                SELECT   FederationIdentifier 
                FROM     User 
                WHERE    Id = :Userinfo.getUserId()
            ];
                   
            if (currentUser.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 

            String primaryId = currentUser[0].FederationIdentifier;
            
            if (String.IsBlank(primaryId))
                throw new CustomException('Invalid MRIS Subscription ID: No Federated ID found >> ' + currentUser); 
                            
            List<Subscriptions__c> subscriptionList = [
                SELECT  Contact__c, Service_Jurisdiction__c, Import_Source__c, BRIGHT_ConversionIsInPreview__c
                FROM    Subscriptions__c
                WHERE   Name = :primaryId
            ];
            
            
            if (subscriptionList.size() != 1)
                throw new CustomException('Invalid MRIS Subscription ID: No Contact found >> ' + currentUser[0]); 
            
            Subscriptions__c subscription = subscriptionList[0];
            subscriptionList.clear();
            
            if(subscription.Service_Jurisdiction__c == 'TREND')    
                isTrendLogin = true;
            //if(subscription.Import_Source__c == 'JSMLS' && subscription.BRIGHT_ConversionIsInPreview__c == true)
               // isJSMLS = true;
                
            serviceJurisdiction = subscription.Service_Jurisdiction__c;
 
            Map<Id,Subscriptions__c> subscriptionMap = new Map<Id, Subscriptions__c>([
                SELECT  Id, Name, Service_Jurisdiction__c, Billing_Jurisdiction__c, TREND_Login_Name__c      
                FROM    Subscriptions__c
                WHERE   Contact__c = :subscription.Contact__c AND
                Status__c = 'Active'
            ]);

            if (subscriptionMap.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Subscriptions found from Contact >> ' + subscription.Contact__c);
    
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, 
                                     Relationship_Type__c, 
                                     Broker_Office__c,
                                     Broker_Office__r.ParentId,
                                     Broker_Office__r.Name,
                                     Subscription__r.Name, 
                                     Subscription__r.Contact__r.Name  
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription__c  IN :subscriptionMap.keySet()]; 
            System.debug('****' + relationships);                 
            if(relationships.Size() == 0)
                throw new CustomException('You do not have permission to access this page');
                
            Set<String> subIds = new Set<String>();
            for(Relationship__c r : relationships) {
                subIds.add(r.Subscription__r.Name);
                if(r.Relationship_Type__c  == 'Broker Of Record')
                    hasBOR = true;
                else if(r.Relationship_Type__c  == 'Authorized Signer') 
                    hasAS = true;
                else if(r.Relationship_Type__c == 'Office Manager')
                    hasOM = true;
            }  
    
            List<String> categories = new List<String> {
                'office_roster',
                    'Office_Exclusives',
                'office_accuracy',
                'w9_form',    
                'office_information',
                'office_statement',
                'responsible_broker',    
                'new_applications',
                'transfer_requests',
                'authorized_signers',
                'Communication_Preferences',
                'datalicensing_fees',
                'datalicensing_products',
                'brokerage_paymentmethods',
                'Listing_Transfer_Request',
                'Broker_Authorization_Form',
                'Office_Manager',
                'Broker_Hierarchy_Form'
                
            };
            
            System.debug('*** subIds:' + subIds);
            if(subIds.Size() == 0)
                throw new CustomException('We’re sorry, but you do not appear to have access to this page.');
                
            for (String subId : subIds) {
                for (String category : categories) {
                    SubscriptionData objSub = new SubscriptionData();               
                    objSub.Category = category;
                    objSub.Id = subId;
                    objSub.displayText = subId;
                    this.Subscriptions.add(objSub);              
                }
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
    
           
    public class CustomException extends Exception {}
}