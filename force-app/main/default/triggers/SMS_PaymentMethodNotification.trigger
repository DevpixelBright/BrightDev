trigger SMS_PaymentMethodNotification on Zuora__PaymentMethod__c (before delete) { 
    Profile userProfile = [SELECT id,Name FROM Profile WHERE id = :UserInfo.getProfileId()];     
    
    if(userProfile.Name == 'API') {
        List<OrgWideEmailAddress> orgWideAddress = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        List<EmailTemplate> emailTemplates = [SELECT Id,Name FROM EmailTemplate WHERE Name = 'SMS Payment Method Update ACH' OR Name = 'SMS Payment Method Update Credit Card'];
        String creditCardTemplateId;
        String achTemplateId;
        
        for(EmailTemplate et : EmailTemplates){
            if(et.Name == 'SMS Payment Method Update ACH')
                achTemplateId = et.Id;
            else if(et.Name == 'SMS Payment Method Update Credit Card') 
                creditCardTemplateId = et.Id;
        }
        
        Map<String,List<Zuora__PaymentMethod__c>> subIdPaymentMethod = new Map<String,List<Zuora__PaymentMethod__c>>();
        
        for(Zuora__PaymentMethod__c paymentMethod : trigger.old){
            if((paymentMethod.Zuora__Type__c == 'CreditCard' || paymentMethod.Zuora__Type__c == 'ACH') && paymentMethod.Is_SubscriptionActive__c)  {
                if (!subIdPaymentMethod.containsKey(paymentMethod.Subscription_Id__c))
                    subIdPaymentMethod.put(paymentMethod.Subscription_Id__c, new List<Zuora__PaymentMethod__c>());
                        
                subIdPaymentMethod.get(paymentMethod.Subscription_Id__c).add(paymentMethod);     
            }      
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
        for(Subscriptions__c subscription : [SELECT id,Name,Contact__c FROM Subscriptions__c WHERE Name in :subIdPaymentMethod.keyset()]){
            for(Zuora__PaymentMethod__c paymentMethod : subIdPaymentMethod.get(subscription.Name)){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {paymentMethod.Private_Email__c});
                email.setBccAddresses(new String[] {'emailtosalesforce@5-2ijsaxt3w491q1lp6mgopwf1bwap8tktw7ffpwk8v71kew5gl1.z-n9io6maj.cs11.le.sandbox.salesforce.com'});
                email.setTargetObjectId(subscription.Contact__c);
                email.setWhatId(paymentMethod.Id);
                email.setSaveAsActivity(false);
                email.setOrgWideEmailAddressId(orgWideAddress[0].Id);
                
                if(paymentMethod.Zuora__Type__c == 'CreditCard')
                    email.setTemplateId(creditCardTemplateId);
                else if(paymentMethod.Zuora__Type__c == 'ACH')
                    email.setTemplateId(achTemplateId);
                
                emails.add(email);    
            }    
        }
    
        if(emails.size() > 0) 
            Messaging.sendEmail(emails); 
    }
}