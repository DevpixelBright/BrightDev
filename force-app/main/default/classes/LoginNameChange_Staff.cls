public class LoginNameChange_Staff{
    
    public String newLoginName { get; set; }
    public String loginErrorMessage { get; set; }
    public Boolean isLoginNameAvailable { get; set; }
    
    public Subscriptions__c subscription { get; set; }
    public String subscriptionId { get; set; }
    public String oldLoginName { get; set; } 
    
    public boolean showLoginNamechange { get; set; }
    
    public LoginNameChange_Staff(){
       subscriptionId = ApexPages.currentPage().getParameters().get('Id');
       showLoginNamechange = true;
       
       subscription = [SELECT Id, Name, Service_Jurisdiction__c, Billing_Jurisdiction__c, 
                              BRIGHT_LoginName__c, TREND_Login_Name__c
                        FROM  Subscriptions__c 
                        WHERE Id = :subscriptionId
                       ];
       
       
       if(subscription.Service_Jurisdiction__c == 'TREND') 
           oldLoginName = subscription.TREND_Login_Name__c;   
       else if(subscription.Service_Jurisdiction__c == 'BRIGHT') 
           oldLoginName = subscription.BRIGHT_LoginName__c;
       else{
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Login Name can be changed only for TREND or BRIGHT subscription'));
           showLoginNamechange = false;
       }
       loginErrorMessage = 'Please enter a login name';
    }    
    
    public void validateLoginName(){
        isLoginNameAvailable = true;
        loginErrorMessage = newLoginName;
        system.debug('---newLoginName-->'+newLoginName);
        //newLoginName = newLoginName.trim();
        newLoginName = newLoginName.normalizeSpace();
        system.debug('---after trim newLoginName-->'+newLoginName);
        
        try{               
            LoginName.isAvailable(subscriptionId, newLoginName);                      
        }
        catch(Exception e){
            isLoginNameAvailable = false; 
            loginErrorMessage = e.getMessage() ;
        }
        
    }
    
    public PageReference saveLoginName(){
        validateLoginName();
        if(isLoginNameAvailable){
            if(subscription.Service_Jurisdiction__c == 'TREND') 
               subscription.TREND_Login_Name__c = newLoginName;   
            if(subscription.Service_Jurisdiction__c == 'BRIGHT') 
               subscription.BRIGHT_LoginName__c = newLoginName;
               
            update subscription; 
            
            PageReference subscriptionView = new ApexPages.StandardController(subscription).view();
            return subscriptionView; 
       }
       else
           return null; 
    }
    
    public PageReference cancel(){
        PageReference subscriptionView = new ApexPages.StandardController(subscription).view();
        return subscriptionView;
    }
    
    
    public class CustomException extends Exception{}
}