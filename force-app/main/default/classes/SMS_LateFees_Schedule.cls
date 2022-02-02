global class SMS_LateFees_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        if(SMS_LateFees_Status__c.getValues('Late Fees').IsActive__c) {
                
            //String days, amount, maximumAccounts;        
            String weekday = system.now().format('EEEE');
            system.debug('*** Weekday :' + weekday);
            
            List<SMS_Late_Fees_Config__c> config = new List<SMS_Late_Fees_Config__c>();
            config = [SELECT Is_Active__c,
                             Threshold_Accounts__c,
                             Threshold_Amount__c,
                             Threshold_Days__c
                      FROM   SMS_Late_Fees_Config__c
                      WHERE  Day_of_Week__c = :weekday 
                     ]; 
            
            if(config.size() == 1 && config[0].Is_Active__c) {  
                /*List<Zuora__CustomerAccount__c> lateFeeExpiredBillAccs = new List<Zuora__CustomerAccount__c>();
                Date expiryDate = Date.today().addDays(-Integer.ValueOf(config[0].Threshold_Days__c));
                
                for(Zuora__CustomerAccount__c lateFeeExpired : [SELECT id,Name,LateFees_ChargeDate__c
                                                                FROM   Zuora__CustomerAccount__c
                                                                WHERE  LateFees_ChargeDate__c < :expiryDate                                       
                                                               ]){
                 system.debug('*** Expired: ' + lateFeeExpired.LateFees_ChargeDate__c);
                 lateFeeExpired.LateFees_ChargeDate__c = null;
                 lateFeeExpiredBillAccs.add(lateFeeExpired);
                } 
                update lateFeeExpiredBillAccs;*/
                Database.executeBatch(new SMS_LateFees_Zuora(String.ValueOf(config[0].Threshold_Accounts__c), String.ValueOf(config[0].Threshold_Amount__c), String.ValueOf(config[0].Threshold_Days__c)),5); 
            }       
        }
    }
       
    public SMS_LateFees_Schedule() {
        
    }
}