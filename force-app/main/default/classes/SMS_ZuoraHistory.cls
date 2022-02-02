public class SMS_ZuoraHistory {
        
    public static void createError(Exception e,String className, String subscriptionId) {
       /*
        Create records in the SMS_ZuoraHistory object for any Standard/Custom Exception. 
        This record consists of Apex class, Exception Name , error message, MRIS Subscription Id and stack trace.
       */
        System.Debug('*** Exception : ' + e);
        System.Debug('*** className: ' + className);
        System.Debug('*** subscriptionId: ' + subscriptionId);
        List<Subscriptions__c> subscription = new List<Subscriptions__c>();
        SMS_Zuora_History__c zHistory = new SMS_Zuora_History__c();
        zHistory.Apex_Class__c = className;
        zHistory.Error_Message__c = e.getMessage();
        zHistory.Exception_Name__c = e.getTypeName();
        zHistory.Stack_Trace__c = e.getStackTraceString();
        if(String.isNotBlank(subscriptionId)) {
           
            subscription = [SELECT id,Name 
                            FROM   Subscriptions__c 
                            WHERE  id = :subscriptionId 
                            OR     Name = :subscriptionId
                           ];
            System.Debug('*** subscription: ' + subscription);
            if (subscription.Size() > 0)
                zHistory.Subscription__c = subscription[0].Id;
            else
                zHistory.Subscription__c = null;
        }
        zHistory.Status__c = 'Failure';
        
        insert zHistory;
        //createCase(zHistory, subscription[0].Id, subscription[0].Name);
    }
    
    public static void createSuccess(String className, String subscriptionId) {
       /*
        Create records in the SMS_ZuoraHistory object on Success completion
       */
        SMS_Zuora_History__c zHistory = new SMS_Zuora_History__c();
        zHistory.Apex_Class__c = className;
        if(String.isNotBlank(subscriptionId)) {
            List<Subscriptions__c> subscription = new List<Subscriptions__c>();
            subscription = [SELECT id,Name 
                            FROM   Subscriptions__c 
                            WHERE  id = :subscriptionId 
                            OR     Name = :subscriptionId
                           ];
            zHistory.Subscription__c = subscription[0].Id;
        }
        zHistory.Status__c = 'Success';
        
        insert zHistory;
    }
    
    /*
    Overloading processZResults() with appropriate results that are returned from a Zuora transaction.
    These include   
    1. Amend
    2. Save
    3. Susbcribe
    4. Delete
    */
        
    public static void processZResults(Zuora.zApi.AmendResult result, String className, String subscriptionId) {        
        if (!result.Success) {
            String exceptionMsg;        
            Zuora.zObject[] errors = result.errors;
            for (Zuora.zObject error : errors)
                exceptionMsg = exceptionMsg + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';
            if (String.isNotBlank(exceptionMsg))
                throw new CustomException(exceptionMsg);                                              
        }   
    }
    
    public static void processZResults(List<Zuora.zApi.DeleteResult> results, String className, String subscriptionId) {
        String exceptionMsg;
        for (Zuora.zApi.DeleteResult result : results){
            if (!result.Success) {        
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors) 
                    exceptionMsg = exceptionMsg + 'zDeleteCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                   
            }            
        }
        if (String.isNotBlank(exceptionMsg))
            throw new CustomException(exceptionMsg);         
    }
    
    public static void processZResults(List<Zuora.zApi.SubscribeResult> results, String className, String subscriptionId) {
        String exceptionMsg;
        for (Zuora.zApi.SubscribeResult result : results){
            if (!result.Success) {        
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors)
                    exceptionMsg = exceptionMsg + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                    
            }            
        }
        if (String.isNotBlank(exceptionMsg))
            throw new CustomException(exceptionMsg); 
    }
    
    public static void processZResults(List<Zuora.zApi.SaveResult> results, String className, String subscriptionId) {
        String exceptionMsg;
        for (Zuora.zApi.SaveResult result : results){
            if (!result.Success) {        
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors)
                    exceptionMsg = exceptionMsg + 'zSaveCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                                   
            }            
        }
        if (String.isNotBlank(exceptionMsg))
            throw new CustomException(exceptionMsg); 
    }
    
    private static void createCase (SMS_Zuora_History__c zHistory, String sfSubscriptionId, String sfSubscription) {
        String subject = 'Zuora Exception for subscription id - ' + sfSubscription;
        String errorMsg;
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'Provisioning Failures'
                                      ];
        
        Case c = new Case();
        c.Subscription_ID__c = sfSubscriptionId;
        c.Subject = subject;
        c.Status = 'Not Started';
        c.Case_Reason__c = 'Defect';
        c.Description = 'Zuora History: ' + zHistory.Name + ', Error Message: ' + zHistory.Error_Message__c + ', Stack Trace: ' + zHistory.Stack_Trace__c;
        insert c;
    }
    
    public Class CustomException extends Exception {}    
}