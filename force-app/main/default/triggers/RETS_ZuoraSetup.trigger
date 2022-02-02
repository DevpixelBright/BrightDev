trigger RETS_ZuoraSetup on Account (after update) {
    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;  
    
    for(Account account: trigger.new){ 
        if(account.Status__c == 'Active'){       
            if(trigger.oldMap.get(account.Id).Status__c != account.Status__c){
                if(account.Type == 'RETS'){
                    if(String.isNotBlank(account.RETS_Billing_Type__c) && account.RETS_Billing_Type__c != 'Custom')
                        RETS_ZuoraSetup.setupZuoraVendor(account.Id);                    
                }
                else if(account.Type == 'Residential' && account.Company_Type__c == 'Broker Office')
                    RETS_ZuoraSetup.setupZuoraBrokerage(account.Id); 
                else if(account.Type == 'Government Agency' && account.Billing_Period__c != null)
                    GovernmentAgency_Class.setupZuoraGovtAgency(account.Id);
            }
            //if(account.Type == 'RETS' && trigger.oldMap.get(account.Id).RETS_Billing_Type__c != account.RETS_Billing_Type__c && account.RETS_Billing_Type__c != 'Custom')
                //RETS_ZuoraSetup.changeBillingType(account.Id, trigger.oldMap.get(account.Id).RETS_Billing_Type__c);                            
        
        }        
    } 
}