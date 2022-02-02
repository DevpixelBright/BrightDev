public class PersonalAssistant{
    
    @AuraEnabled
    public static List<wrapper> getSubscriptionOptions() {
        List<wrapper> values = new List<wrapper>();
        Constants Constants = new Constants();
        values.add(new wrapper(Constants.SALESFORCE_AGENT, Constants.SALESFORCE_AGENT));
        values.add(new wrapper(Constants.PERSONAL_ASSISTANT, Constants.PERSONAL_ASSISTANT));
        values.add(new wrapper(Constants.ASSOCIATE_BROKER, Constants.ASSOCIATE_BROKER));
        values.add(new wrapper(Constants.OFFICE_SECRETARY, Constants.OFFICE_SECRETARY));
        return values;
    }
    
    @AuraEnabled
    public static List<Account> getBrokerOffice(String brokerCode){
        List<Account> lAccounts = new List<Account>();
        if(brokerCode != null && brokerCode != ''){
            String searchText = '%'+ brokerCode + '%';    
            lAccounts = [SELECT Id, Name, Account_Name__c, City__c, State__c, Zip__c FROM Account WHERE (Account_Name__c LIKE :searchText OR Name LIKE :searchText) AND Status__c = 'Active' AND IsPersonAccount = false ORDER BY Account_Name__c ASC LIMIT 100];     
            return lAccounts;
        }
        return lAccounts;
    }
    
    @AuraEnabled
    public static List<Subscriptions__c> getAgentName(String AgentName, String searchKey, String agentType) {
        List<Subscriptions__c> lSub = new List<Subscriptions__c>();
        if(AgentName != null && AgentName != '') {
            //List<Account> acc = new List<Account>();
            //acc = [SELECT Id, Name, Type from Account WHERE Id =:AgentName];
            if(agentType == 'Appraiser'){
                String searchText = '%'+ searchKey + '%'; 
                lSub = [SELECT Id,Name, Contact__c, Contact__r.Name FROM Subscriptions__c WHERE Related_Location_Broker_Office__c= :AgentName AND Contact_Type__c = 'Appraiser' AND Contact__r.Name LIKE :searchText AND Status__c = 'Active'];
            }
            else if(agentType == 'Residential' || agentType == 'Corporate'){
                Set<String> accType = new set<String>();
                accType.add('Agent');
                accType.add('Broker');
                String searchText = '%'+ searchKey + '%'; 
                lSub = [SELECT Id,Name,Contact__c, Contact__r.Name FROM Subscriptions__c WHERE Related_Location_Broker_Office__c= :AgentName AND Contact_Type__c IN: accType AND Contact__r.Name LIKE :searchText AND Status__c = 'Active'];
            }
        }
        return lSub;
    }
    
    @AuraEnabled
    public static List<Subscriptions__c> getSubId(String agentId, String searchText, String brokerId){
        List<Subscriptions__c> lSubscription  = new List<Subscriptions__c>();
        if(searchText != null && searchText != ''){
            searchText += '%';
            lSubscription = [Select Id, Name, Contact__c,Contact__r.AccountId,Related_Location_Broker_Office__c from Subscriptions__c Where Contact__c = :agentId AND Related_Location_Broker_Office__c = :brokerId AND Name LIKE :searchText LIMIT 100];
            return lSubscription;
        }
        return lSubscription;
    }
    
    @AuraEnabled
    public Static MRIS_Application__c submitApplication(MRIS_Application__c oApplication){
        List<Account> lAccounts = [SELECT Id,City__c,Type,County__c,Zip__c,State__c FROM Account WHERE Id =: oApplication.Company_Code__c AND Status__c = 'Active'];
        if(!lAccounts.isEmpty()){
            oApplication.City__c = lAccounts[0].City__c;
            oApplication.County__c = lAccounts[0].County__c;
            oApplication.State__c = lAccounts[0].State__c;
            oApplication.Zip__c = lAccounts[0].Zip__c;
            oApplication.Private_Phone__c = oApplication.Primary_Phone__c;
            oApplication.Mobile_Phone__c = oApplication.Primary_Phone__c;
            oApplication.Public_Email__c = oApplication.Private_Email__c;
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
            oApplication.Application_Expire_Date__c = system.now().AddDays(maxDays);
            oApplication.Status__c = 'New';
            oApplication.Service_Jurisdiction__c = 'BRIGHT';
            if(oApplication.Service_Jurisdiction__c == 'BRIGHT') {
                if(lAccounts[0].County__c!= null) {
                    List<BRIGHT_Billing_Jurisdiction__c> countiesList = new List<BRIGHT_Billing_Jurisdiction__c>();
                    countiesList = [SELECT Id,
                                    Name,
                                    County__c,
                                    State__c,
                                    Billing_Jurisdiction__c
                                    FROM   BRIGHT_Billing_Jurisdiction__c
                                    WHERE  County__c = :lAccounts[0].County__c
                                    AND    State__c = :lAccounts[0].State__c];
                    
                    if(countiesList.Size() > 0)
                        oApplication.Billing_Jurisdiction__c = countiesList[0].Billing_Jurisdiction__c;
                }
            }
            oApplication.Application_Type__c = 'New Agent';
            if(oApplication.Nickname__c == null){
                oApplication.Nickname__c = oApplication.First_Name__c;
            }
            
            if(lAccounts[0].type == 'Appraiser'){
                if(oApplication.Subscription_Type__c == 'Personal Assistant to Appraiser'){
                    oApplication.Type__c = 'Assistant';
                }else if(oApplication.Subscription_Type__c == 'Personal Assistant'){
                    oApplication.Type__c = 'Assistant';  
                }
                
            }
        }
        if(oApplication != null){
            insert oApplication;
        }
        return oApplication;
    }
    
    
    @AuraEnabled
    public static List<wrapper> getPicklistValues(String field_name, String objectName) {
        List<wrapper> values = new List<wrapper>();
        values.add(new wrapper('--- None ---',''));
        List<String> types = new List<String>();
        if(objectName != '' && objectName != null){
            types.add(objectName);
        }
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()){
                    values.add(new wrapper(entry.getLabel(), entry.getValue()));
                }
            }
        }
        return values;
    }
    
    public static List<SelectOption> getSalutation(String field_name, String objectName){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = MRIS_Application__c.Salutation__c.getDescribe();
        
        List<Schema.PicklistEntry> picklists = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : picklists)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    
    @AuraEnabled
    public static Object getConstants(){
        return new Constants();
    }
    
    public class wrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public wrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
}