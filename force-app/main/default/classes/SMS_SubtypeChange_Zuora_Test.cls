@istest(SeeAllData=true)

private class SMS_SubtypeChange_Zuora_Test  
{
   static testMethod void doTest()
   {
       Account a = new Account();
       Contact c = new Contact();
       Subscriptions__c s = new  Subscriptions__c();
       //try {
       CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
       cau.addAddrs();    
        SMS_ZuoraMockDataGenerator.emptyResult = false; 
       
        a.name = 'ADA1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.State__c = 'VA';
        insert a;
        
        
        c.Email = 'email@something.com';
        c.FirstName = 'Test Class';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.QAS_Mailing_County__c = 'Arlington';
        c.Zip__c = '20171';
        c.State__c = 'VA';
        insert c;       
        
        
        s.Name = '12345';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.AgentKey__c = '123111';
        s.name = '123111';
        s.County__c = 'Fairfax';
        s.Related_Location_Broker_Office__c = a.id;
        s.Contact_Type__c = 'Agent';
        s.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert s;
        
        //}
        //catch(Exception e) {
        //    SMS_ZuoraHistory.createError(e,'SMS_ZuoraCreateParentOrChildAccount_Test', s.SF_Subscription_ID__c);
       // }
        
        List<Subscriptions__c> sSubscriptions = [SELECT Id, Name, 
                                                        Contact__c 
                                                 FROM   Subscriptions__c 
                                                 WHERE  id = :s.id// <- updated to bypass workflow
                                                ];
        
        system.debug('*** sSubscriptions[0].Name : ' + sSubscriptions[0].Name);    
        s.Name = s.SF_Subscription_ID__c; 
        SMS_SubtypeChange_Zuora.createSubscription(sSubscriptions[0].Name);
         
   }
   /*
   static testMethod void doTest1()
   {
       Account a = new Account();
       Contact c = new Contact();
       Subscriptions__c s = new  Subscriptions__c();
       try {
       CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
       cau.addAddrs();    
        
       
        a.name = 'ADA1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.State__c = 'VA';
        insert a;
        
        
        c.Email = 'email@something.com';
        c.FirstName = 'Test Class';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.QAS_Mailing_County__c = 'Arlington';
        c.Zip__c = '20171';
        c.State__c = 'VA';
        insert c;       
        
        
        s.Name = '12345';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.AgentKey__c = '123111';
        s.name = '123111';
        s.County__c = 'Fairfax';
        s.Related_Location_Broker_Office__c = a.id;
        s.Contact_Type__c = 'Agent';
        insert s;
        
        }
        catch(Exception e) {
            SMS_ZuoraHistory.createError(e,'SMS_ZuoraCreateParentOrChildAccount_Test', s.SF_Subscription_ID__c);
        }
        
        List<Subscriptions__c> sSubscriptions = [SELECT Id, Name, 
                                                        Contact__c 
                                                 FROM   Subscriptions__c 
                                                 WHERE  id = :s.id// <- updated to bypass workflow
                                                ];
        
        system.debug('*** sSubscriptions[0].Name : ' + sSubscriptions[0].Name);    
         
        SMS_MockDataGenerator.emptyResult = false;
        SMS_ZuoraCreateParentOrChildAccount_c.createParentOrChildAccount(sSubscriptions[0].Name);
   }
   static testMethod void doTest2()
   {
       SMS_ZuoraCreateParentOrChildAccount_c.createParentOrChildAccount('123456');
   }
   */   
}