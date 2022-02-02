public class AgentListingTransfer{
    
    public String subscriptionId { get; set; }
    public String destinationBrokerCode { get; set; }
    
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
    public String progressValue { get; set; }
    
    /* Block state maintenance */
    public String destinationBlockState { get; set; }
    public String destinationBlockError { get; set; }
    public String contactBlockState { get; set; }
    public String assistantBlockState { get; set; }
    public String reviewBlockState { get; set; }
   
    public AgentListingTransfer(){
        subscriptionId = ApexPages.currentPage().getParameters().get('id');
        subscription = new Subscriptions__c();
        subscription = [SELECT Id,Name, Related_Location_Broker_Office__c, Private_Email__c,Contact__r.Name,
                               Related_Location_Broker_Office__r.Name, Related_Location_Broker_Office__r.Account_Name__c,
                               Related_Location_Broker_Office__r.Street_Number__c, Related_Location_Broker_Office__r.Street_Name__c,
                               Related_Location_Broker_Office__r.City__c, Related_Location_Broker_Office__r.State__c, 
                               Related_Location_Broker_Office__r.QAS_Mailing_County__c, Related_Location_Broker_Office__r.Zip__c 
                        FROM   Subscriptions__c
                        WHERE Name = :subscriptionId
                       ];       
        isVerified = false;
        isChangeEmail = false;
        isApplication = false;
        destinationBlockState = 'Started';
        progressValue = '0';
        personalAssistants = new List<Related_Agent__c>();
    }
    
    public void reload(){}
        
    public void verifyDestinationBrokerCode() {        
         destinationBlockError = null;
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
            else
                destinationBlockError = 'Invalid Broker Code';

        }
        catch(Exception e) {
             destinationBlockError = e.getMessage();
        }    
    }
    
    public void destinationVerified() {
        progressValue = '25';
        destinationBlockState = 'Completed';
        contactBlockState = 'Started';
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
        for(String selectedPA : selectedPAList) {
            for(Related_Agent__c ra : personalAssistants) {
                if(ra.Personal_Assistant_Sub_ID__c == selectedPA) {
                    selectedPANames = ra.Personal_Assistant__r.FirstName + ' ' + ra.Personal_Assistant__r.LastName + ', ';
                }
            }
        }
        System.debug('*** selectedPANames :' + selectedPANames );
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
            
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('Default').No_Of_Days__c;
            newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
            newApplication.Destination_Broker_Office__c = destinationBrokerOffice.Id;
            
            newApplication.Company_Code__c = subscription.Related_Location_Broker_Office__c;
            newApplication.Status__c = 'New';
            newApplication.Comments__c = selectedPAStr; 
            
            insert newApplication;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your application submitted successfully.'));
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
    
    public class CustomException extends Exception{}
}