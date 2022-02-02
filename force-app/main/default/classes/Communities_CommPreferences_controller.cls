public class Communities_CommPreferences_controller {
    
    public String displayName { get; private set; }
    public String id { get; private set; }
    public Boolean isUpdateEmail { get; set; }
    public Subscriptions__c subscription {get;set;}
    private Boolean isPreferenceEnabled {get;set;}
    public String privateEmail {get;set;}
    
    public Communities_CommPreferences_controller(){
        
        try {
            isUpdateEmail = false;
            subscription = new Subscriptions__c();
            List<Subscriptions__c> sSubscriptions = new List<Subscriptions__c>();
            id = ApexPages.currentPage().getParameters().get('id');
            
            if (String.isBlank(id)) 
                throw new CustomException('Invalid MRIS Subscription ID'); 
            
            
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
                              contact__r.BRIGHT_email_preferences_Listings__c,
                              contact__r.HasOptedOutOfEmail
                              FROM  Subscriptions__c
                              WHERE Name = :id AND Status__c = 'Active'];        
            
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
            privateEmail = subscription.Private_Email__c;
            system.debug('***BRIGHT_email_preferences_NEWS__c***' +subscription.contact__r.BRIGHT_email_preferences_NEWS__c);
            
            
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
            system.debug('****** Preference name ***'+preferenceName);
            system.debug('****** isPreferenceEnabled ***'+isPreferenceEnabled);
            if(preferenceName == 'email_OptOut'){
                c.HasOptedOutOfEmail = isPreferenceEnabled;
               if(isPreferenceEnabled == true){
                    c.BRIGHT_email_preferences_NEWS__c = false; 
                    c.BRIGHT_email_preferences_market__c = false;
                    c.BRIGHT_email_preferences_TRAINING__c = false;
                    c.BRIGHT_email_preferences_TIPS__c = false;
                    c.BRIGHT_email_preferences_PARTNER__c = false;
                    c.BRIGHT_email_preferences_BROKER__c = false;
                    c.BRIGHT_email_preferences_VENDOR__c = false;
                    //c.BRIGHT_email_preferences_APPLICATION__c = false;
                   // c.BRIGHT_email_preferences_Listings__c = false;
               }
            }else if(preferenceName == 'news'){
                c.BRIGHT_email_preferences_NEWS__c = isPreferenceEnabled;
            }else if(preferenceName == 'market_trends'){
                c.BRIGHT_email_preferences_market__c = isPreferenceEnabled;
            }else if(preferenceName == 'training'){
                c.BRIGHT_email_preferences_TRAINING__c = isPreferenceEnabled;
            }else if(preferenceName == 'product_tips'){
                c.BRIGHT_email_preferences_TIPS__c = isPreferenceEnabled;
            }else if(preferenceName == 'partner_prod_news'){
                c.BRIGHT_email_preferences_PARTNER__c = isPreferenceEnabled;
            }else if(preferenceName == 'broker_news'){
                c.BRIGHT_email_preferences_BROKER__c = isPreferenceEnabled;
            }else if(preferenceName == 'vendor_news'){
                c.BRIGHT_email_preferences_VENDOR__c = isPreferenceEnabled;
            }else if(preferenceName == 'listing_notification'){
                c.BRIGHT_email_preferences_Listings__c = isPreferenceEnabled;
            }
            update c;
            
        }catch(Exception e){
            System.debug('Error occurred while updating the preferences'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        return null;
    }
    
    public PageReference resetPreferences(){
        try{
            isPreferenceEnabled = true;
            Contact c = new Contact();
            c.Id = subscription.Contact__c;
            c.BRIGHT_email_preferences_NEWS__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_market__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_TRAINING__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_TIPS__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_PARTNER__c = isPreferenceEnabled;
            c.BRIGHT_email_preferences_Listings__c = isPreferenceEnabled; 
            if(subscription.Contact_Type__c == 'Broker' || subscription.Contact_Type__c == 'Office Manager')
                c.BRIGHT_email_preferences_BROKER__c = isPreferenceEnabled;
            if(subscription.Contact_Type__c == 'Vendor')
                c.BRIGHT_email_preferences_VENDOR__c = isPreferenceEnabled;
            	c.HasOptedOutOfEmail = false;
            update c;
        }catch(Exception e){
            System.debug('Error occurred while resetting the preferences'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        return null;
    }
    
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