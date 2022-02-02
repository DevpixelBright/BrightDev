@isTest(seealldata = true)
private class SMS_ZuoraUtil_Test{

    private static testMethod void doTestOne() { 
        
        /* zQuery test coverage */
        List<Zuora.zObject> getZObjects1 = SMS_ZuoraMockCall.getZObjects('SELECT Id, Name FROM Account'); 
        List<Zuora.zObject> getZObjects2 = SMS_ZuoraMockCall.getZObjects('SELECT Id, Name FROM Account WHERE Id = \'123\' OR Id = \'124\'');
        List<Zuora.zObject> getZObjects3 = SMS_ZuoraMockCall.getZObjects('SELECT Id, Name FROM Account WHERE Id = \'123\' AND Id = \'124\'');
        List<Zuora.zObject> getZObjects4 = SMS_ZuoraMockCall.getZObjects('SELECT Id, Name FROM Account WHERE Id = \'123\' || Id = \'124\'');
        
        /* zSave test coverage */
        List<Zuora.zObject> InvoiceItems = new List<Zuora.zObject>();
       
        SMS_ZuoraMockCall.isSuccess = true;
        List<Zuora.zApi.SaveResult> results1 = SMS_ZuoraMockCall.getZSaveResult(InvoiceItems); 
        SMS_ZuoraMockCall.isSuccess = false;
        List<Zuora.zApi.SaveResult> results2 = SMS_ZuoraMockCall.getZSaveResult(InvoiceItems);
        
        /* zSubscribe test coverage */
        List<Zuora.zApi.SubscribeRequest> requests1 = new List<Zuora.zApi.SubscribeRequest>();
        
        SMS_ZuoraMockCall.isSuccess = true;
        List<Zuora.zApi.SubscribeResult> results3 = SMS_ZuoraMockCall.getZSubscribeResult(requests1); 
        SMS_ZuoraMockCall.isSuccess = false;
        List<Zuora.zApi.SubscribeResult> results4 = SMS_ZuoraMockCall.getZSubscribeResult(requests1);
        
        /* ZAmend test coverage */
        List<Zuora.zApi.AmendRequest> requests2 = new List<Zuora.zApi.AmendRequest>();
        
        SMS_ZuoraMockCall.isSuccess = true;
        Zuora.zApi.AmendResult results5 = SMS_ZuoraMockCall.getZAmendResult(requests2); 
        SMS_ZuoraMockCall.isSuccess = false;
        Zuora.zApi.AmendResult results6 = SMS_ZuoraMockCall.getZAmendResult(requests2);  
        
        /* ZDelete test coverage */
        List<String> ids = new List<String>{'1','2'};
        
        SMS_ZuoraMockCall.isSuccess = true;
        List<Zuora.zApi.DeleteResult> results7 = SMS_ZuoraMockCall.getZDeleteResults('Account', ids); 
        SMS_ZuoraMockCall.isSuccess = false;
        List<Zuora.zApi.DeleteResult> results8 = SMS_ZuoraMockCall.getZDeleteResults('Account', ids);                
                              
    }
    
    
    private static testMethod void doTestTwo() {
            SMS_ZuoraUtil zUtilInstance;
            try {
            //Code coverage for SMS_ZuoraUtil Class
                 zUtilInstance = new SMS_ZuoraUtil();
            //
            }
            catch(Exception e) {
            
            }
            
            Zuora.zApi.LoginResult zLogin = zUtilInstance.zLogin();
            List<Zuora.zObject> InvoiceItems = new List<Zuora.zObject>();
            List<Zuora.zApi.SaveResult> results1 = zUtilInstance.zgenerate(InvoiceItems);
            List<Zuora.zApi.SaveResult> results2 = zUtilInstance.zcreate(InvoiceItems);
            List<Zuora.zApi.SaveResult> results3 = zUtilInstance.zupdate(InvoiceItems);
            List<Zuora.zApi.SaveResult> results4 = zUtilInstance.zgenerate(InvoiceItems);
            
            List<Zuora.zApi.SubscribeRequest> requests1 = new List<Zuora.zApi.SubscribeRequest>();
            List<Zuora.zApi.SubscribeResult> zsubscribe = zUtilInstance.zsubscribe(requests1);
            
            List<Zuora.zApi.AmendRequest> requests2 = new List<Zuora.zApi.AmendRequest>();
            Zuora.zApi.AmendResult zamend = zUtilInstance.zamend(requests2);
            
            List<String> ids = new List<String>{'1','2'};
            List<Zuora.zApi.DeleteResult> results7 = zUtilInstance.zdelete('Account', ids); 
            
            List<Zuora.zObject> zquery = zUtilInstance.zquery('SELECT Id FROM Account');
            
       
    }
    
}