public class Communities_BrokerNews_controller {
    
     
    public String displayName { get; private set; }
    public String id { get; private set; }
    public Boolean isUpdateEmail { get; set; }
    public Subscriptions__c subscription {get;set;}
    private Boolean isPreferenceEnabled {get;set;}
    public String privateEmail {get;set;}
    
    public Relationship__c relationship {get; set;}
    public boolean isBOR {get; set;}
    public Communities_BrokerNews_controller(){
      
         try {
             isBOR = false;
             isUpdateEmail = false;
             subscription = new Subscriptions__c();
            List<Subscriptions__c> sSubscriptions = new List<Subscriptions__c>();
             id = ApexPages.currentPage().getParameters().get('id');
            
            if (String.isBlank(id)) 
                throw new CustomException('Invalid MRIS Subscription ID'); 
                
            relationship = new Relationship__c();
            list<Relationship__c> lstRelships = [Select Relationship_Type__c, contact__c from Relationship__c 
                                                Where Subscription__r.Name =: id 
                                                And Relationship_Type__c in ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                                                AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= today )];
            system.debug('---lstRelships--->'+lstRelships);      
             
            user oUser = [Select Id, ContactId from User where  Id =: userInfo.getUserId()];  
            
             for(Relationship__c relationship : lstRelships){
                 
               if(relationship.Relationship_Type__c == 'Broker Of Record' && relationship.contact__c == oUser.ContactId) 
                        isBOR = true;        
             }
            if(lstRelships != null && !lstRelships.isEmpty())
                relationship = lstRelships[0];
                  
            sSubscriptions = [SELECT id, 
                                      Name,
                                      Contact_Type__c,
                                      Private_email__c,
                                      Public_email__c,
                                      Related_Location_Broker_Office__c,
                                      Service_Jurisdiction__c,
                                      Billing_Jurisdiction__c,
                                      TREND_Login_Name__c,
                                      BRIGHT_LoginName__c,
                                      contact__C,
                                      contact__r.BRIGHT_email_preferences_NEWS__c,
                                      contact__r.BRIGHT_email_preferences_market__c,
                                      contact__r.BRIGHT_email_preferences_TRAINING__c,
                                      contact__r.BRIGHT_email_preferences_TIPS__c,
                                      contact__r.BRIGHT_email_preferences_PARTNER__c,
                                      contact__r.BRIGHT_email_preferences_BROKER__c,
                                      contact__r.BRIGHT_email_preferences_VENDOR__c,
                                      contact__r.BRIGHT_email_preferences_AGENT_TRANSFER__c,
                                      contact__r.BRIGHT_email_preferences_APPLICATION__c
                                FROM   Subscriptions__c
                                WHERE  Name = :id AND Status__c = 'Active'];        
            
            if(sSubscriptions.Size() != 1)  
                throw new CustomException('Invalid MRIS Subscription ID');
               
            /* Capture display user id for TREND */
            if(sSubscriptions[0].Service_Jurisdiction__c != null && sSubscriptions[0].Service_Jurisdiction__c == 'TREND' && sSubscriptions[0].TREND_Login_Name__c != null)
                displayName = 'TREND: ' + sSubscriptions[0].TREND_Login_Name__c + ' - ' + sSubscriptions[0].Name;
            else if(sSubscriptions[0].Service_Jurisdiction__c != null && sSubscriptions[0].Service_Jurisdiction__c == 'BRIGHT' && sSubscriptions[0].BRIGHT_LoginName__c != null)
                displayName = 'BRIGHT: ' + sSubscriptions[0].BRIGHT_LoginName__c + ' - ' + sSubscriptions[0].Name;
            else
                displayName = sSubscriptions[0].Name;           
                          
             
             subscription = sSubscriptions[0];
             //subscription.contact__r.BRIGHT_email_preferences_BROKER__c = true;
             privateEmail = subscription.Private_Email__c;     
 
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
                  }
    }
    
    public PageReference updatePreferences(){
        try{
        String preferenceName = ApexPages.currentPage().getParameters().get('preferencename');
        isPreferenceEnabled = Boolean.valueOf(ApexPages.currentPage().getParameters().get('preferencevalue'));
        Contact c = new Contact();
        c.Id = subscription.Contact__c;
        system.debug('---subscription.Contact__c--->'+subscription.Contact__c);
        system.debug('****** Preference name ***'+preferenceName);
        system.debug('****** isPreferenceEnabled ***'+isPreferenceEnabled);
        
        /*if(preferenceName == 'news'){
            c.BRIGHT_email_preferences_NEWS__c = isPreferenceEnabled;
        }else if(preferenceName == 'market_trends'){
            c.BRIGHT_email_preferences_market__c = isPreferenceEnabled;
        }else if(preferenceName == 'training'){
             c.BRIGHT_email_preferences_TRAINING__c = isPreferenceEnabled;
        }else if(preferenceName == 'product_tips'){
             c.BRIGHT_email_preferences_TIPS__c = isPreferenceEnabled;
        }else if(preferenceName == 'partner_prod_news'){
              c.BRIGHT_email_preferences_PARTNER__c = isPreferenceEnabled;
        }else*/ if(preferenceName == 'broker_news'){
             c.BRIGHT_email_preferences_BROKER__c = isPreferenceEnabled;
        }else if(preferenceName == 'agent_transfer_notifications'){
             c.BRIGHT_email_preferences_AGENT_TRANSFER__c = isPreferenceEnabled;
        }else if(preferenceName == 'new_application_notifications'){
             c.BRIGHT_email_preferences_APPLICATION__c = isPreferenceEnabled;
        }
            /*else if(preferenceName == 'vendor_news'){
             c.BRIGHT_email_preferences_VENDOR__c = isPreferenceEnabled;
        }*/
        update c;
 
         }catch(Exception e){
             System.debug('Error occurred while updating the preferences'+e.getMessage());
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
         }
        return null;
    }
    /* public PageReference resetPreferences(){
        try{
            isPreferenceEnabled = true;
            Contact c = new Contact();
            c.Id = subscription.Contact__c;
           c.BRIGHT_email_preferences_NEWS__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_market__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_TRAINING__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_TIPS__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_PARTNER__c = isPreferenceEnabled;
            if(subscription.Contact_Type__c == 'Broker' || subscription.Contact_Type__c == 'Office Manager')
                c.BRIGHT_email_preferences_BROKER__c = isPreferenceEnabled;
          //  if(subscription.Contact_Type__c == 'Vendor')
            //    c.BRIGHT_email_preferences_VENDOR__c = isPreferenceEnabled;
            //c.BRIGHT_email_preferences_AGENT_TRANSFER__c = isPreferenceEnabled;
            //c.BRIGHT_email_preferences_APPLICATION__c = isPreferenceEnabled;
            update c;
        }catch(Exception e){
            System.debug('Error occurred while resetting the preferences'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        return null;
    }*/
    public void renderPrivateEmail(){
        isUpdateEmail = true;
    }
    public void updatePrivateEmail(){
        try{
            if(subscription.Private_Email__c == null )
                throw new CustomException('Private Email cannot be null');
            else{
                isUpdateEmail = false;
                privateEmail = subscription.Private_Email__c;
                update subscription;
            }
        }catch(Exception e){
            System.debug('Error occurred while updating private email'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    public PageReference reloadPage(){
        isUpdateEmail = false;
        return ApexPages.currentPage();
    }
    public class CustomException extends Exception {}
}