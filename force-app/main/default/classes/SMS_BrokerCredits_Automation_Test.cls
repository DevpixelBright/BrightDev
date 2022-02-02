@istest(seealldata = true)
private class SMS_BrokerCredits_Automation_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;    
    
    private static testMethod void doTestNew() {
        try {
            Map<String, String> preDefinedValues = new Map<String, String>();
            preDefinedValues.put('zAccountId', '45345wWseferr34sfdf');
            SMS_BrokerCredits_Automation obj = new SMS_BrokerCredits_Automation();
            List<SMS_BrokerCredits_Automation.BrokerCredit> creditObjList = new List<SMS_BrokerCredits_Automation.BrokerCredit>();
            
            List<Subscriptions__c> subs = [SELECT Id, Name FROM Subscriptions__c WHERE Status__c = 'Active' LIMIT 2];
            for(Subscriptions__c s : subs) {
                for(Integer i=0; i<31; i++) {
                    SMS_BrokerCredits_Automation.BrokerCredit obj2 = new SMS_BrokerCredits_Automation.BrokerCredit();
                    obj2.subscriptionId = s.Name;
                    obj2.zRatePlanName = 'Broker Credits 2016';
                    obj2.zRatePlanChargeName = 'Broker Credits 2016';
                    obj2.zRatePlanId = '45345wWErwer345435';
                    obj2.zRatePlanChargeId = '45345wWErwer34sfdf';
                    obj2.numOfCredits = 2;
                    obj2.totalCreditAmount = 200;
                    obj2.isSelected = true;
                    obj2.isValid = true;
                    obj2.zAccountId = '45345wWseferr34sfdf';
                    obj2.notes = 'Test';
                    obj2.status = 'Active';
                    obj2.subscriberName = 'Testing';
                    obj2.zuoraStatus = 'Active';       
                    obj2.fileName = 'test';
                    obj2.processed = false;
                    creditObjList.add(obj2);
                }
            }
            String str = JSON.serialize(creditObjList);
            
            obj.creditsFromFileJSON = str;
            //obj.fileRecords();
            
            
            //SMS_BrokerCredits_Automation.validateData(str);
            //SMS_BrokerCredits_Automation.createRatePlan(str);
			//SMS_BrokerCredits_Automation.checkFile('test');
            
            //SMS_ZuoraMockCall.isSuccess = true;
            //SMS_BrokerCredits_Automation.createRatePlan(str);
            //createSMSCAH('test', subs[0].Id, 200);
            
            obj.fileRecords();
            SMS_BrokerCredits_Automation.checkFile('test');
            SMS_BrokerCredits_Automation.validateData(str);
            SMS_BrokerCredits_Automation.createRatePlan(str);
            
        }
        catch(Exception e) {
        
        }
    }
    
    private static testMethod void doTestOne() {
        try {
            Map<String, String> preDefinedValues = new Map<String, String>();
            preDefinedValues.put('zAccountId', '45345wWseferr34sfdf');
            SMS_BrokerCredits_Automation obj = new SMS_BrokerCredits_Automation();
            List<SMS_BrokerCredits_Automation.BrokerCredit> creditObjList = new List<SMS_BrokerCredits_Automation.BrokerCredit>();
            
            List<Subscriptions__c> subs = [SELECT Id, Name FROM Subscriptions__c WHERE Status__c = 'Active' LIMIT 2];
            for(Subscriptions__c s : subs) {
                for(Integer i=0; i<31; i++) {
                    SMS_BrokerCredits_Automation.BrokerCredit obj2 = new SMS_BrokerCredits_Automation.BrokerCredit();
                    obj2.subscriptionId = s.Name;
                    obj2.zRatePlanName = 'Broker Credits 2016';
                    obj2.zRatePlanChargeName = 'Broker Credits 2016';
                    obj2.zRatePlanId = '45345wWErwer345435';
                    obj2.zRatePlanChargeId = '45345wWErwer34sfdf';
                    obj2.numOfCredits = 2;
                    obj2.totalCreditAmount = 200;
                    obj2.isSelected = true;
                    obj2.isValid = true;
                    obj2.zAccountId = '45345wWseferr34sfdf';
                    obj2.notes = 'Test';
                    obj2.status = 'InActive';
                    obj2.subscriberName = 'Testing';
                    obj2.zuoraStatus = 'Active';       
                    
                    creditObjList.add(obj2);
                }
            }
            String str = JSON.serialize(creditObjList);
            SMS_BrokerCredits_Automation.validateData(str);
            SMS_BrokerCredits_Automation.createRatePlan(str);
            
                        
            //SMS_ZuoraMockCall.isSuccess = true;
            //SMS_BrokerCredits_Automation.createRatePlan(str);
              
        }
        catch(Exception e) {
        	system.debug('--exception in test class-->'+e.getMessage());
        }
    }
    
    private static testMethod void doTestTwo() {
        try {
            SMS_ZuoraMockCall.isSuccess = false;
            Map<String, String> preDefinedValues = new Map<String, String>();
            preDefinedValues.put('zAccountId', '45345wWseferr34sfdf');
            SMS_BrokerCredits_Automation obj = new SMS_BrokerCredits_Automation();
            List<SMS_BrokerCredits_Automation.BrokerCredit> creditObjList = new List<SMS_BrokerCredits_Automation.BrokerCredit>();
            
            List<Subscriptions__c> subs = [SELECT Id, Name FROM Subscriptions__c WHERE Status__c = 'Active' LIMIT 2];
            for(Subscriptions__c s : subs) {
                for(Integer i=0; i<31; i++) {
                    SMS_BrokerCredits_Automation.BrokerCredit obj2 = new SMS_BrokerCredits_Automation.BrokerCredit();
                    obj2.subscriptionId = s.Name;
                    obj2.zRatePlanName = 'Broker Credits 2016';
                    obj2.zRatePlanChargeName = 'Broker Credits 2016';
                    obj2.zRatePlanId = '45345wWErwer345435';
                    obj2.zRatePlanChargeId = '45345wWErwer34sfdf';
                    obj2.numOfCredits = 2;
                    obj2.totalCreditAmount = 200;
                    obj2.isSelected = true;
                    obj2.isValid = true;
                    obj2.zAccountId = '45345wWseferr34sfdf';
                    obj2.notes = 'Test';
                    obj2.status = 'Active';
                    obj2.subscriberName = 'Testing';
                    obj2.zuoraStatus = 'Active';       
                    
                    creditObjList.add(obj2);
                }
            }
            String str = JSON.serialize(creditObjList);
            
                        
            SMS_BrokerCredits_Automation.validateData(str);
            SMS_BrokerCredits_Automation.createRatePlan(str);
            
            SMS_ZuoraMockCall.isSuccess = true;
            SMS_BrokerCredits_Automation.createRatePlan(str);
        }
        catch(Exception e) {
        
        }
    }    
    
    private static void createAccount(String type, String name){
        account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        insert account; 
    }
    
    private static void createContact(String accountId){
        contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;  
    }
    
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';

        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    public static SMS_CreditsAutomationHistory__c createSMSCAH(string filename, string subId, decimal amount){
        
        SMS_CreditsAutomationHistory__c newcah = new SMS_CreditsAutomationHistory__c();
        newcah.SubscriptionId__c = subId;
        newcah.Amount__c = amount;
        newcah.FileName__c = fileName;
        newcah.Status__c = 'In Progress';
        insert newcah;
        return newcah;
    } 

}