@istest(SeeAllData=true) 

private class SMS_ZuoraHistory_Test
{
   static testMethod void ZuoraHistoryTest()
   {
      CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
         
        Account a = new Account();
        a.name = 'ADA1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert a;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.QAS_Mailing_County__c = 'Arlington';
        c.Zip__c = '20171';
        insert c;       
        
        Subscriptions__c s = new  Subscriptions__c();
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
        
        SMS_ZuoraHistory history = new SMS_ZuoraHistory();
           
        SMS_ZuoraHistory.createSuccess('className',s.Id);
        
        String test = 'Test';
        try {
            if (test == 'Test')
                throw new CustomException('Create error testing');    
        }
        Catch(Exception ex) {
            SMS_ZuoraHistory.createError(ex, 'SMS_ZuoraHistory_Test', s.Name);
        }
        
             
        Zuora.zObject errorCode = new Zuora.zObject('ErrorCode');
        List<Zuora.zObject> errors = new List<Zuora.zObject>();
        Zuora.zObject error = new Zuora.zObject('Error');
        error.setValue('Code', '1000');
        error.setValue('Field', '');
        error.setValue('Message', 'Process ZResult test call');
        errors.add(error);
        
        /* Amend result process */    
        try {      
            Zuora.zApi.AmendResult  zAmendResult = new Zuora.zApi.AmendResult();
            zAmendResult.success = false; 
            zAmendResult.errors = errors;
           
            SMS_ZuoraHistory.processZResults(zAmendResult,'SMS_ZuoraHistory_Test', s.Name);
        }
        catch(Exception ex) {
        
        }
        
        /* Delete result process */
        try { 
            Zuora.zApi.DeleteResult zDeleteResult = new Zuora.zApi.DeleteResult();
            zDeleteResult.success = false;
            zDeleteResult.errors = errors;
            
            List<Zuora.zApi.DeleteResult> zDeleteResultList = new List<Zuora.zApi.DeleteResult>();
            zDeleteResultList.add(zDeleteResult);
            
            SMS_ZuoraHistory.processZResults(zDeleteResultList, 'SMS_ZuoraHistory_Test', s.Name);
        }
        catch(Exception ex) {
        
        }
        
        /* Subscribe result process */
        try { 
            Zuora.zApi.SubscribeResult zSubscribeResult = new Zuora.zApi.SubscribeResult();
            zSubscribeResult.success = false;
            zSubscribeResult.errors = errors;
            
            List<Zuora.zApi.SubscribeResult> zSubscribeResultList = new List<Zuora.zApi.SubscribeResult>();
            zSubscribeResultList.add(zSubscribeResult);
            
            SMS_ZuoraHistory.processZResults(zSubscribeResultList, 'SMS_ZuoraHistory_Test', s.Name);
        }
        catch(Exception ex) {
        
        }
        
        /* Save result process */
        try { 
            Zuora.zApi.SaveResult zSaveResult = new Zuora.zApi.SaveResult();
            zSaveResult.success = false;
            zSaveResult.errors = errors;
            
            List<Zuora.zApi.SaveResult> zSaveResultList = new List<Zuora.zApi.SaveResult>();
            zSaveResultList.add(zSaveResult);
            
            SMS_ZuoraHistory.processZResults(zSaveResultList, 'SMS_ZuoraHistory_Test', s.Name);
        }
        catch(Exception ex) {
        
        }                         
   }
   public Class CustomException extends Exception {} 
}