public class NewloginID{
    public String subId {set; get;}
    
    public void passSubId() {
        subId = ApexPages.currentPage().getParameters().get('urlparam');
        System.debug('Page '+subId);
    }
    
   /* public NewloginID() {
        subId = ApexPages.currentPage().getParameters().get('subId');
        System.debug('Page '+subId);
        /* System.debug(subId);
        if(subId != null || subId != '') {
            sub = [SELECT Id, Name, BRIGHT_LoginName__c, TREND_Login_Name__c, Service_Jurisdiction__c 
                   FROM Subscriptions__c 
                   WHERE Name = :subId]; 
        } 
    }
    
    public void validateUpdate() {
       // if((!newValue.isNumeric() && sub.Name == newValue) || sub.BRIGHT_LoginName__c == newValue || sub.TREND_Login_Name__c == newValue) 
           // ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'New Login Name should be Unique')); 
        if(newValue.length() > 25 || newValue.length() < 3) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Login Name should have min: 3 characters and max: 25 characters'));
        }
        else {
            String regex = '^[A-Za-z0-9 @.-]*$';
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(newValue);
            Boolean regexfind =  regexMatcher.find();
            System.debug(regexfind);
            if(regexfind) {
                Integer checkDuplicatesubs = [SELECT count() FROM Subscriptions__c 
                                              WHERE Name = :newValue OR BRIGHT_LoginName__c = :newValue OR TREND_Login_Name__c = :newValue];
                if(checkDuplicatesubs > 0)
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Login Name already Exists'));
                else {
                    if(sub.Service_Jurisdiction__c == 'MRIS') {
                        if(newValue.isNumeric()) {
                            if(newValue == sub.Name)
                                sub.MRIS_Login_ID__c = sub.Name;
                            else
                                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Numeric Login Name should be same as Subscription Id'));
                        }
                        else
                            sub.MRIS_Login_ID__c = newValue;
                        
                        update sub;
                    }
                    else if(sub.Service_Jurisdiction__c == 'BRIGHT') {
                        if(newValue.isNumeric()) {
                            if(newValue == sub.Name)
                                sub.BRIGHT_LoginName__c = sub.Name;
                            else
                                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Numeric Login Name should be same as Subscription Id'));
                        } 
                        else
                            sub.BRIGHT_LoginName__c = newValue;
                        
                        update sub;
                    }
                    else if(sub.Service_Jurisdiction__c == 'TREND') {
                        if(newValue.isNumeric()) {
                            if(newValue == sub.Name)
                                sub.TREND_Login_Name__c = sub.Name; 
                            else
                                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Numeric Login Name should be same as Subscription Id'));
                        } 
                        else 
                            sub.TREND_Login_Name__c = newValue;
                        
                        update sub;
                    }
                }
            }
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'LoginName Pattern is incorrect'));
        }
    }*/
}