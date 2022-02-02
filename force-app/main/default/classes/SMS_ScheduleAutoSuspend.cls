global class SMS_ScheduleAutoSuspend implements Schedulable {
    global void execute(SchedulableContext sc) {
        if(SMS_AutoSuspend_Status__c.getValues('Auto Suspend').IsActive__c) {
            String days, amount, maximumAccounts;        
            String weekday = system.now().format('EEEE');
            system.debug('*** Weekday :' + weekday);
            List<SMS_AutoSuspend_Config__c> config = new List<SMS_AutoSuspend_Config__c>();
            config = [SELECT IsSuspend__c,
                             Threshold_Accounts__c,
                             Threshold_Amount__c,
                             Threshold_Days__c
                      FROM   SMS_AutoSuspend_Config__c 
                      WHERE  Day_of_Week__c = :weekday 
                     ]; 
            
            if(config.size() == 1 && config[0].IsSuspend__c)  
                SMS_SuspendAccounts_Zuora.suspendAccounts(String.ValueOf(config[0].Threshold_Accounts__c), String.ValueOf(config[0].Threshold_Amount__c), String.ValueOf(config[0].Threshold_Days__c));    
        }
    }
       
    public SMS_ScheduleAutoSuspend() {
        
    }    
}