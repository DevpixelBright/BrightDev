public without sharing class Communities_AgentTransferRequest {
    
    
    public String subscriptionId { get; set; }
    public String destinationBrokerCode { get; set; }
    public Boolean hasInitialError { get; set; }
    public String brokerCode { get; set; }
    public list<SelectOption> brokerOffices {get; set;} 
    public list<SelectOption> options {get; set;} 
    
    public Account destinationBrokerOffice { get; set; } 
    public Subscriptions__c subscription { get; set; }
    public List<Related_Agent__c> personalAssistants { get; set; }
    
    public Boolean isVerified { get; set; }
    public Boolean isChangeEmail { get; set; }
    public Boolean isApplication { get; set; }
    public String newEmailAddress { get; set; }
    public String selectedPAStr { get; set; }
    public Set<String> selectedPAList { get; set; }
    public String selectedPANames { get; set; }
    public String strselectedPANames { get; set; }
    public String progressValue { get; set; }
    
    /* Block state maintenance */
    public String destinationBlockState { get; set; }
    public String destinationBlockError { get; set; }
    public String contactBlockState { get; set; }
    public String assistantBlockState { get; set; }
    public String reviewBlockState { get; set; }
    
    public Communities_AgentTransferRequest() {
        hasInitialError = false;
        try {
            
            subscriptionId =  Apexpages.currentpage().getparameters().get('Id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID');   
            
            subscription = new Subscriptions__c();
            subscription = [SELECT Id,Name, Related_Location_Broker_Office__c, Private_Email__c,Contact__r.Name, Subscription_Type__c, Contact_Type__c,
                            Related_Location_Broker_Office__r.Name, Related_Location_Broker_Office__r.Account_Name__c,
                            Related_Location_Broker_Office__r.Street_Number__c, Related_Location_Broker_Office__r.Street_Name__c,
                            Related_Location_Broker_Office__r.City__c, Related_Location_Broker_Office__r.State__c, 
                            Related_Location_Broker_Office__r.QAS_Mailing_County__c, Related_Location_Broker_Office__r.Zip__c ,Service_Jurisdiction__c
                            FROM   Subscriptions__c
                            WHERE Name = :subscriptionId];
            
            Set<String> restrictedTypes = new Set<String>{'Assistant', 'Staff', 'Appraiser'};                
                if(restrictedTypes.contains(subscription.Contact_Type__c))
                throw new CustomException('We’re sorry, but you do not appear to have access to this page.');
            
            Integer relationCount = [SELECT  COUNT()
                                     FROM    Relationship__c
                                     WHERE   Relationship_Type__c IN ('Broker Of Record')
                                     AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                     AND     Subscription_ID__c = :subscriptionId];
            Boolean isBOR = false;        
            if(relationCount > 0)    
                isBOR = true;                                         
            
            if(isBOR)
                throw new CustomException('We’re sorry, but you do not appear to have access to this page.');    
            
            isVerified = false;
            isChangeEmail = false;
            isApplication = false;
            destinationBlockState = 'Started';
            progressValue = '0';
            personalAssistants = new List<Related_Agent__c>();  
            
            
        }
        catch(Exception e) {
            hasInitialError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));              
        }  
    }
    
    /* public void verifyDestinationBrokerCode() {   
destinationBlockError = null;
isVerified = false;
try {
if(String.isBlank(destinationBrokerCode))
throw new CustomException('Invalid Broker Code');

destinationBrokerOffice = new Account();
Boolean isValid = true;
String brokerCodeRegex = '[A-Z]{3,6}[0-9]{1,4}$' ;

Pattern MyPattern = Pattern.compile(brokerCodeRegex);            
Matcher MyMatcher = MyPattern.matcher(destinationBrokerCode);

if (!MyMatcher.matches())
isValid = false;

if(isValid) {
if(destinationBrokerCode.trim() == subscription.Related_Location_Broker_Office__r.Name){
destinationBlockError = 'Origination office and destination office should not be same';
}
else{
List<Account> account = [SELECT Id, Name, Account_Name__c, Street_Number__c, Street_Name__c,  City__c, State__c, QAS_Mailing_County__c,Zip__c  
FROM   Account 
WHERE  Name = :destinationBrokerCode AND Status__c = 'Active'];
if(account.size() > 0) {
destinationBrokerOffice = account[0]; 
isVerified = true; 
System.debug('***' + isVerified);
System.debug('***' + destinationBrokerOffice);                    
}
else
destinationBlockError = 'Broker Office Not Available';
}
}
else
destinationBlockError = 'Invalid Broker Code';

}
catch(Exception e) {
destinationBlockError = e.getMessage();
}    
}*/
    
    public void destinationVerified() {
        try {
            isVerified = false;
            destinationBlockState = 'Started';
            contactBlockState = 'Not Started';
            destinationBlockError = null;
            destinationBrokerOffice = new Account();
            destinationBrokerCode = destinationBrokerCode.unescapeHtml4();
            if(String.isBlank(destinationBrokerCode))
                throw new CustomException('Invalid destination broker Code');
            else if(destinationBrokerCode.trim() == subscription.Related_Location_Broker_Office__r.Name)
                throw new CustomException('Origination office and destination office should not be same');
            else {
                
                List<Account> account = [SELECT Id, Name, Account_Name__c, Street_Number__c, Street_Name__c,  City__c, State__c, QAS_Mailing_County__c,Zip__c  
                                         FROM   Account 
                                         WHERE  Name = :destinationBrokerCode AND Status__c = 'Active'];
                if(account.size() > 0) {
                    destinationBrokerOffice = account[0]; 
                    isVerified = true;                    
                }
                else
                    throw new CustomException('Invalid destination broker code');
                
                progressValue = '25';
                destinationBlockState = 'Completed';
                contactBlockState = 'Started';
            }
        }
        Catch(Exception e) {
            destinationBlockError = e.getMessage();
        }
    }     
    
    public void next(){
        try{
            if(isChangeEmail){
                if(String.isBlank(newEmailAddress) || newEmailAddress == subscription.Private_Email__c)
                    throw new CustomException('Enter a new Email Address');
                
                subscription.Private_Email__c = newEmailAddress;
            }
            
            personalAssistants = new List<Related_Agent__c>();
            personalAssistants = [SELECT Id, 
                                  Subscription__c, 
                                  Assistant_to__c, 
                                  Personal_Assistant_Sub_ID__c,
                                  Personal_Assistant_Sub_ID__r.Name, 
                                  Personal_Assistant__c,
                                  Personal_Assistant__r.FirstName,
                                  Personal_Assistant__r.LastName, 
                                  Status__c,
                                  Import_ID__c
                                  FROM   Related_Agent__c
                                  WHERE  Subscription__c = :subscription.Id
                                  AND    Status__c = 'Active'];           
            
            isApplication = true;
            assistantBlockState = 'Started';
            contactBlockState = 'Completed';
            progressValue = '50';
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public void continueToReview() {
        System.debug('*** selectedPAStr:' + selectedPAStr);
        selectedPANames = '';
        selectedPAList = (Set<String>) JSON.Deserialize(selectedPAStr, Set<String>.class);
        System.debug('*** selectedPAList :' + selectedPAList );
        List<String> strList = new List<String>();
        for(String selectedPA : selectedPAList) {
                for(Related_Agent__c ra : personalAssistants) {
                    if(ra.Personal_Assistant_Sub_ID__c == selectedPA) {
                        selectedPANames = ra.Personal_Assistant__r.FirstName + ' ' + ra.Personal_Assistant__r.LastName;    
                        system.debug('PANames'+selectedPANames);
                        strList.add(selectedPANames);
                    }
                }
            }
            strselectedPANames = String.join( strList, ', ' );
            System.debug('*** strselectedPANames :' + strselectedPANames );
            assistantBlockState = 'Completed';
            reviewBlockState = 'Started';
            progressValue = '75';
        }
        
        public PageReference submitApplication(){
            try{ 
                if(isChangeEmail){               
                    subscription.Private_Email__c = newEmailAddress;
                    update subscription;
                }
                
                MRIS_Application__c newApplication = new MRIS_Application__c(); 
                newApplication.Application_Type__c = 'Agent Transfer';
                newApplication.Agent_Subscription_ID__c = subscription.Id;
                
                Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('Agent Transfer').No_Of_Days__c;              
                newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
                newApplication.Destination_Broker_Office__c = destinationBrokerOffice.Id;
                
                newApplication.Company_Code__c = subscription.Related_Location_Broker_Office__c;
                newApplication.Status__c = 'New';
                newApplication.Comments__c = selectedPAStr; 
                newApplication.Private_Email__c = subscription.Private_Email__c;
                newApplication.Service_Jurisdiction__c = Subscription.Service_Jurisdiction__c;
                
                insert newApplication;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your application has been submitted successfully. Please inform your Association Board of Realtors of your transfer, if applicable. Transfers processed in Bright will not notify your Association.'));
                reviewBlockState = 'Completed';
                progressValue = '100';
                return null;
            }
            catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                isApplication = false;
                return null;
            }
            
        }
        public String searchTerm {get; set;}
        @RemoteAction
        public static List<Account> searchBroker(String searchTerm, String mlsName) {
            List<Account> accounts = new List<Account>();
            if(mlsName == 'TREND')
                accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'TREND\' OR Secondary_Service_Jurisdiction__c = \'TREND\') AND IsPersonAccount = false');
            else if(mlsName == 'BRIGHT')
                accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'BRIGHT\' OR Secondary_Service_Jurisdiction__c = \'BRIGHT\') AND IsPersonAccount = false');               
            else
                accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'MRIS\' OR Primary_Service_Jurisdiction__c = NULL OR Secondary_Service_Jurisdiction__c = \'MRIS\') AND IsPersonAccount = false');
            
            return accounts;
        }       
        public void reload(){}
        
        public class CustomException extends Exception {}    
    }