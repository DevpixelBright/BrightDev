public Class SubscriptionAddressValidation {

    public Subscriptions__c subscription { get; set; }
    
    public SubscriptionAddressValidation() {
        String subscriptionId = ApexPages.currentPage().getParameters().get('id');
        subscription = new Subscriptions__c();
        subscription = [
            SELECT  
                Name,
                id,
                Primary_Phone__c,
                Pager__c,
                Fax__c,
                Voicemail__c,
                VM_Ext__c,
                Mobile_Phone__c,
                Home_Fax__c,
                Agent_Office_Phone__c,
                Website__c,
                Public_Email__c,
                Private_Email__c,
                NRDS_ID__c,
                Primary__c,
                Service_Jurisdiction__c,
                TREND_Login_Name__c,
                
                Contact__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Title,
                Contact__r.Middle_Name__c,
                Contact__r.Suffix__c,
                Contact__r.Nickname__c,
                Contact__r.Website__c,
                
                QAS_Validation_Status__c,
                QAS_Validation_Timestamp__c,
                QAS_Mailing_Record_Type__c,
                
                Street_Type__c,
                Street_Direction__c,
                Unit_Type__c,
                County__c,
                QAS_Mailing_Country__c,
                QAS_Billing_Country__c,
                QAS_Billing_Record_Type__c,
                Billing_County__c,
                Billing_Street_Direction__c,
                Billing_Street_Type__c,
                Billing_Unit_Type__c,
                
                Street_Number__c,
                Street_Number_Suffix__c, 
                Street_Name__c, 
                QAS_Mailing_Street_Type__c,
                QAS_Mailing_Street_Direction__c,
                QAS_Mailing_Unit_Type__c,
                Unit__c,
                City__c,
                State__c,
                Zip__c,
                Zip_4__c,
                Country__c,
                QAS_Mailing_POBox__c,
                Addl_Display_Name__c,
                QAS_Mailing_County__c,
                
                Billing_Street_Number__c,
                Billing_Street_Suffix__c, 
                Billing_Street_Name__c, 
                QAS_Billing_Street_Type__c,
                QAS_Billing_Street_Direction__c,
                QAS_Billing_Unit_Type__c,
                Billing_Unit_Number__c,
                Billing_City__c,
                Billing_State__c,
                Billing_Zip__c,
                Billing_Zip_4__c,
                Billing_Country__c,
                Billing_Box__c,
                Billing_Addl_Display_Name__c,
                QAS_Billing_County__c
            FROM    Subscriptions__c 
            WHERE   Id = :subscriptionId
        ];
                                                     
    } 
    
    public PageReference saveAddress() {
        subscription.AddressValidationStatus__c = 'Verified';
        update subscription;
        
        PageReference pageRef = new PageReference('/' + subscription.Id);
        return pageRef;        
    }
    
    public PageReference useEnteredAddress() {
        Subscriptions__c s = new Subscriptions__C();
        s.Id = subscription.Id;
        s.AddressValidationStatus__c = 'Not Required';
        System.debug('***' + s);
        update s;  
          
        PageReference pageRef = new PageReference('/' + subscription.Id);
        return pageRef;         
    }
}