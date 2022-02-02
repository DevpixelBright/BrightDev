public class Communities_LoginNameChange {
    
    public String newLoginName { get; set; }
    public String loginErrorMessage { get; set; }
    public Boolean isLoginNameAvailable { get; set; }
    
    public Subscriptions__c subscription { get; set; }
    public String subscriptionId { get; set; }
    public String oldLoginName { get; set; } 
    public String displayName { get; set; }
    public boolean showLoginNamechange { get; set; }
        
    public Communities_LoginNameChange(){
        subscriptionId = ApexPages.currentPage().getParameters().get('Id');
        showLoginNamechange = true;
           
        subscription = [SELECT Id, Name, Service_Jurisdiction__c, Billing_Jurisdiction__c, 
                        BRIGHT_LoginName__c, TREND_Login_Name__c
                        FROM  Subscriptions__c 
                        WHERE Name = :subscriptionId
                        ];
           
        /* 
        if(subscription.Service_Jurisdiction__c == 'TREND') 
            oldLoginName = subscription.TREND_Login_Name__c;
        else if(subscription.Service_Jurisdiction__c == 'BRIGHT') 
            oldLoginName = subscription.BRIGHT_LoginName__c;
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Login Name can be changed only for TREND or BRIGHT subscription'));
            showLoginNamechange = false;
        }
        */
        
        
        if(subscription.Service_Jurisdiction__c != null && subscription.Service_Jurisdiction__c == 'TREND' && subscription.TREND_Login_Name__c != null) {
            displayName = 'TREND: ' + subscription.TREND_Login_Name__c + ' - ' + subscription.Name;
            oldLoginName = subscription.TREND_Login_Name__c;
        }
       else if(subscription.Service_Jurisdiction__c != null && subscription.Service_Jurisdiction__c == 'BRIGHT' && subscription.BRIGHT_LoginName__c != null) {
            displayName = 'BRIGHT: ' + subscription.BRIGHT_LoginName__c + ' - ' + subscription.Name;
            oldLoginName = subscription.BRIGHT_LoginName__c;
        }
        else{
            displayName = subscription.Name;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Login Name can be changed only for TREND or BRIGHT subscription'));
            showLoginNamechange = false;
        }
        loginErrorMessage = 'Please enter a login name';    
    }
        
    public void validateLoginName(){
        isLoginNameAvailable = true;
        system.debug('---newLoginName--->'+newLoginName);
        //newLoginName = newLoginName.trim();
        newLoginName = newLoginName.normalizeSpace();
        system.debug('--after trim-newLoginName--->'+newLoginName);
        
        loginErrorMessage = newLoginName;
        
        try{
            LoginName.isAvailable(subscription.Id, newLoginName);                      
        }
        catch(Exception e){
            isLoginNameAvailable = false; 
            loginErrorMessage = e.getMessage() ;
        }
    }
        
    public PageReference saveLoginName(){
        if(subscription.Service_Jurisdiction__c == 'TREND') 
            subscription.TREND_Login_Name__c = newLoginName;   
        if(subscription.Service_Jurisdiction__c == 'BRIGHT') 
            subscription.BRIGHT_LoginName__c = newLoginName;
            
        update subscription;
        //string logoutURL = Label.Logout_URL;
        //PageReference logoutURL = new PageReference(Label.Logout_URL);
        PageReference logoutURL = new PageReference('/customers/secur/logout.jsp');
        return logoutURL;

        /*PageReference subscriptionView = new ApexPages.StandardController(subscription).view();
        return subscriptionView; */
    }
    
    /*
    public PageReference cancel(){
        PageReference cancelURL = new PageReference('https://builddemo-builddemo-mris.cs11.force.com/customers/Communities_MyAccount?id=3204625');
        return cancelURL;
        //PageReference subscriptionView = new ApexPages.StandardController(subscription).view();
        //return subscriptionView;
    }
    */
    
    public class CustomException extends Exception{}
}