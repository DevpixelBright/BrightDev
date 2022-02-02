public class Communities_Base_Controller {
    public Boolean debugMode { get; private set; }
    
    public String primaryId { get; private set; }
    public boolean isValidAndActiveSubscription { get; private set; }
    public String requestedSubscriptionId { get; private set; } 
    
    public String name { get; private set; }
    public String email { get; private set; }
    public String role { get; private set; }
    public String association { get; private set; }
    public String county { get; private set; }
    public String acc { get; private set; }
    public String accName { get; private set; }

    public Communities_Base_Controller() {
        String debug = ApexPages.currentPage().getParameters().get('debug');
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
        
        system.debug('****' + ApexPages.currentPage().getUrl());
        
        String url = ApexPages.currentPage().getUrl();
        String pageName = (url != null) ? url.substringBetween('apex/', '?') : null;
        
        primaryId = '';

        List<User> correctUser = [
            SELECT  FederationIdentifier
            FROM    User
            WHERE   Id = :UserInfo.getUserId()
        ];

        if(correctUser.size() == 0) return;

        primaryId = correctUser[0].FederationIdentifier;

        if(String.IsBlank(primaryId)) return;

        List<Contact> contact = [SELECT  Id, Name
                                 FROM    Contact
                                 WHERE   Id IN (
                                     SELECT  Contact__c
                                     FROM    Subscriptions__c 
                                     WHERE   Name = :primaryId
                                 )
                                ];

        if (contact.size() == 0) 
            return;
        else
            name = contact[0].Name;

        List<Subscriptions__c> subs = [SELECT Name, Status__c, Import_Source__c, BRIGHT_ConversionIsInPreview__c, QAS_Mailing_County__c, Related_Location_Broker_Office__r.Name,Private_Email__c, Subscription_Type__c, Country__c, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Account_Name__c,
                                       (
                                           SELECT  Id
                                           FROM    Relationships__r
                                           WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager') AND
                                           (
                                               Relationship_End_Date__c = null OR 
                                               Relationship_End_Date__c >= TODAY
                                           )
                                       )
                                       FROM    Subscriptions__c 
                                       WHERE   Contact__c = :contact[0].Id 
                                      ];
        
        for (Integer i = 0; i<subs.size(); i++) {
            if(subs[i].Name == primaryId){
                email = subs[i].Private_Email__c;
                role = subs[i].Subscription_Type__c;
                county = subs[i].QAS_Mailing_County__c;
                acc = subs[i].Related_Location_Broker_Office__r.Name;
                accName = subs[i].Related_Location_Broker_Office__r.Account_Name__c;
            }
        }
        
        
        if (pageName == 'Communities_LicenseAssociations' ||
            pageName == 'Communities_OfficeDetails'||
            pageName == 'Communities_ListingBroker'){
            requestedSubscriptionId = ApexPages.currentPage().getParameters().get('sid');
            log('Requested Subscription Id: ' + requestedSubscriptionId);
        }else{
            requestedSubscriptionId = ApexPages.currentPage().getParameters().get('id');
            log('Requested Subscription Id: ' + requestedSubscriptionId);  
        }

        Boolean bypass = Boolean.valueOf(Label.MRIS_Communities_Bypass_Access_Control);
        
        if (bypass || String.isBlank(requestedSubscriptionId)) {
            isValidAndActiveSubscription = true;
    
            log('Bypassing access control...');
            log('isValidAndActiveSubscription: ' + isValidAndActiveSubscription);
    
            return;
        }
        else
            isValidAndActiveSubscription = false;

        Boolean isValidUser = false;
        for (Integer i = 0; i<subs.size(); i++) {
            log('Associated Subscriptiontion: ' + subs[i].Id + ' Name: ' + subs[i].Name);
            if (requestedSubscriptionId.equals(subs[i].Name)){
                isValidUser = true;
                if(subs[i].Status__c == 'Active') 
                    isValidAndActiveSubscription = true;
                
                system.Debug('---pageName--->'+pageName);
                if(subs[i].Import_Source__c == 'JSMLS' && subs[i].BRIGHT_ConversionIsInPreview__c == true 
                  && pageName != null && (pageName == 'Communities_NewApplications' 
                     || pageName == 'Communities_AgentTransferListing'
                     || pageName == 'Communities_PayBrokerageBalances'
                     || pageName == 'Communities_BrokerageDataLicensing'
                     || pageName == 'Communities_BrokeragePaymentMethods'
                     || pageName == 'Communities_ListingTransferRequests'
                     || pageName == 'Communities_AgentListings'
                     || pageName == 'Communities_AgentAccuracy'
                     || pageName == 'Communities_AgentTransferRequest')){
                    //isValidUser = false;
                    isValidAndActiveSubscription = false;
                }
            }
            
        }        
        
        log('---isValidUser-->'+isValidUser);
        if(isValidUser && CommunityPagesInactiveSubscribers__c.getValues(pageName) != null)
            isValidAndActiveSubscription = true;
       
        log('isValidAndActiveSubscription: ' + isValidAndActiveSubscription);
    }

    private void log(String message) {
        if (debugMode)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}