trigger SMS_ZuoraIntegration on Subscriptions__c (after insert, before update, after update) {
    
    
    /*
List<String> accountTypes = new List<String> {'Corporate',
'Financial Institution',
'Government Agency',
'MDS',
'MLS',
'RETS',
'Virtual Tour Vendor'};
*/
    List<String> inactiveSubscriptionIds = new List<String>();
    List<String> accountTypes = new List<String>();
    
    for(SMS_Exclude_Zuora_Integration__c accountType : SMS_Exclude_Zuora_Integration__c.getall().values()) 
        accountTypes.add(accountType.Name);   
    
    if(trigger.IsInsert) {
        for (Subscriptions__c sSubscription : trigger.new) {
            system.debug('*** Trigger Event: Insert --- ZuoraIntegrationWorkflowBypass__c :' + sSubscription.ZuoraIntegrationWorkflowBypass__c);
            system.debug('**** sSubscription :' + sSubscription);
            System.Debug('*** accountTypes: ' + accountTypes);
            List<Account> accounts = [SELECT id,Type 
                                      FROM   Account 
                                      WHERE  Type in :accountTypes 
                                      AND    id = :sSubscription.Related_Location_Broker_Office__c
                                     ];
            
            if(accounts.size() == 0) {
                system.debug('*** SMS_ZuoraIntegration : Yes' );
                system.debug('*** Before Insert SMS_ZuoraIntegration Static getZuoraByPass() : ' + SMS_ZuoraIntegrationWorkflowBypass.zuoraByPass);
                system.debug('*** Before Insert SMS_ZuoraIntegration Static getCounter() : ' + SMS_ZuoraIntegrationWorkflowBypass.counter);
                if(SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass == null) {
                    SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass = sSubscription.ZuoraIntegrationWorkflowBypass__c ;
                    SMS_ZuoraIntegrationWorkflowBypass.Counter = 1;
                    system.debug('*** Insert SMS_ZuoraIntegration set bypass and counter' );
                }
                else {
                    SMS_ZuoraIntegrationWorkflowBypass.Counter++;                 
                    system.debug('*** Insert SMS_ZuoraIntegration set counter ' );
                }
                
                system.debug('*** After Insert SMS_ZuoraIntegration Static getZuoraByPass() : ' + SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass);
                system.debug('*** After Insert SMS_ZuoraIntegration Static getCounter() : ' + SMS_ZuoraIntegrationWorkflowBypass.Counter);
                
                if(!SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass) {
                    //SMS_ZuoraCreateParentOrChildAccount
                    
                    List<Account> personAccounts = [SELECT id,Name 
                                                    FROM   Account 
                                                    WHERE  Contact__c = :sSubscription.Contact__c AND isPersonAccount = true
                                                   ];
                    
                    if(personAccounts.isEmpty()) 
                        SMS_CreatePersonAccount.createPersonAccount(new List<String> {sSubscription.Contact__c}); 
                    
                    System.Debug('### sSubscription : ' + sSubscription);
                    //SMS_ZuoraCreateParentOrChildAccount.createParentOrChildAccount(sSubscription.SF_Subscription_ID__c);
                    SMS_ZuoraCreateParentOrChildAccount.createParentOrChildAccount(sSubscription.Id);  
                }  
                
                
            }
            else {
                try {
                    system.debug('*** SMS_ZuoraIntegration : No'  + accounts[0].Type);
                    
                    throw new  SMS_CustomException('Excluded from Zuora Integration for Account Type : ' + accounts[0].Type);
                }
                catch(Exception e){
                    SMS_ZuoraHistory.createError(e,'SMS_ZuoraIntegration',sSubscription.SF_Subscription_ID__c);
                }
            }
        }
    }
    
    //BRIG-4008 IRON-4869 Private email changes on a subscription the Team/Team Member record must be updated by Bala
    //Bulkified the code as well
    if(Trigger.isAfter && Trigger.isUpdate) {
        SMS_SubEmailUpdate.updatePrivateEmailToRelatedObjs(Trigger.NewMap, Trigger.OldMap);
    }
    //IRON-4826,IRON-4801,IRON-4476 Set status of team member/Lead record to inactive and end date
    if(Trigger.isUpdate && Trigger.isAfter){
        SubscriptionsHandler.checkAndUpdateTeamMembersOnSubInactive(Trigger.NewMap, Trigger.oldMap);
    }
    
    //SAL-4476 Team Lead is Inactivated in SF with a Status Change Reason of Suspended
	//do Teams App API Callout on Subscription Inactive
    //if(Trigger.isUpdate && Trigger.isAfter){
    //    SubscriptionsHandler.checkTeamMembersOnInactive(Trigger.NewMap, Trigger.oldMap);
    //}
    
    if(trigger.IsUpdate && trigger.isBefore) {                                               
        for(Subscriptions__c sSubscription : Trigger.new) {
            system.debug('*** Trigger Event: Update --- ZuoraIntegrationWorkflowBypass__c :' + sSubscription.ZuoraIntegrationWorkflowBypass__c);
            List<Account> accounts = [SELECT id,Type 
                                      FROM   Account 
                                      WHERE  Type in :accountTypes 
                                      AND    id = :sSubscription.Related_Location_Broker_Office__c
                                     ];
            
            if(accounts.size() == 0) {
                if(sSubscription.Private_Email__c != trigger.oldMap.get(sSubscription.id).Private_Email__c){
                    //Below update private email update moved to new method above IRON-4869
                    //SMS_SubEmailUpdate.updatePrivateEmail(sSubscription.Name,sSubscription.Private_Email__c);//Update Private email in Billing Accounts and Subscription Product and Charges
                    
                    //SMS_ZuoraCreateParentOrChildAccount.createAccount(sSubscription.Private_Email__c);
                }
                system.debug('*** SMS_ZuoraIntegration : Yes' );
                system.debug('*** Before Update SMS_ZuoraIntegration Static getZuoraByPass() : ' + SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass);
                system.debug('*** Before Update SMS_ZuoraIntegration Static getCounter() : ' + SMS_ZuoraIntegrationWorkflowBypass.Counter);
                if(SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass == null) {
                    SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass = sSubscription.ZuoraIntegrationWorkflowBypass__c;
                    SMS_ZuoraIntegrationWorkflowBypass.Counter = 1;
                    system.debug('*** Update SMS_ZuoraIntegration set bypass and counter' );
                }
                else {
                    SMS_ZuoraIntegrationWorkflowBypass.Counter++;                    
                    system.debug('*** Update SMS_ZuoraIntegration set counter ' );
                }
                
                system.debug('*** After Update SMS_ZuoraIntegration Static getZuoraByPass() : ' + SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass);
                system.debug('*** After Update SMS_ZuoraIntegration Static getCounter() : ' + SMS_ZuoraIntegrationWorkflowBypass.Counter);
                
                if(!SMS_ZuoraIntegrationWorkflowBypass.ZuoraByPass) {                              
                    //Creation of Subscriptions 
                    if(sSubscription.Status__c == 'Active' && trigger.oldMap.get(sSubscription.id).Status__c != 'Active' && trigger.oldMap.get(sSubscription.id).Status__c != 'Incomplete') {
                        /* BillingAndPayment_Settings__c billAndPaymentSettings = BillingAndPayment_Settings__c.getValues(sSubscription.Billing_Jurisdiction__c);
                        if(billAndPaymentSettings == null){
                        SMS_OnActivationWorkflow.createSubscription(sSubscription.Name,false);
                        }
                        else if(billAndPaymentSettings.Bypass_Billing__c == false){
                        SMS_OnActivationWorkflow.createSubscription(sSubscription.Name,false);
                        }*/
                        
                        SMS_OnActivationWorkflow.createSubscription(sSubscription.Name,false);
                        
                        system.debug('*** Creation of subscription in Zuora for : ' + sSubscription.Name);
                    }
                    
                    //Change in Type and/or Sub-Type /  Billing Jurisdiction
                    if((sSubscription.Status__c == 'Active') && (trigger.oldMap.get(sSubscription.id).Status__c == 'Active')) {
                        if ((sSubscription.Subscription_Type__c != trigger.oldMap.get(sSubscription.id).Subscription_Type__c) || 
                            (sSubscription.Contact_Type__c != trigger.oldMap.get(sSubscription.id).Contact_Type__c) || 
                            (sSubscription.Billing_Jurisdiction__c != trigger.oldMap.get(sSubscription.id).Billing_Jurisdiction__c)) {
                                if(sSubscription.Primary__c == trigger.oldMap.get(sSubscription.id).Primary__c){
                                    system.debug('*** Change in sub type for : ' + sSubscription.Name);
                                    SMS_SubtypeChange_Zuora.createSubscription(sSubscription.Name);
                                }
                            }
                    }
                    
                    //Cancellation of Subscriptions in Zuora
                    if((sSubscription.Status__c == 'Inactive') && (trigger.oldMap.get(sSubscription.id).Status__c != 'Inactive')) {
                        
                        SMS_InactivateSubs_Future.inactivateSubscription(sSubscription.Name);
                        system.debug('*** Deactivation of subscription in Zuora for : ' + sSubscription.Name);
                    }    
                    
                    //SAL-4476 Team Lead is Inactivated in SF with a Status Inactive by Bala July 19, 2021
                    //do Teams App API Callout on Subscription Inactive
                    if((sSubscription.Status__c != trigger.oldMap.get(sSubscription.Id).Status__c && sSubscription.Status__c == 'Inactive') ||
                       (sSubscription.Related_Location_Broker_Office__c != trigger.oldMap.get(sSubscription.Id).Related_Location_Broker_Office__c && 
                        !BORUtilityClass.fetchActiveOfficesFromBrokerage(new List<String>{trigger.oldMap.get(sSubscription.Id).Related_Location_Broker_Office__c}).contains(sSubscription.Related_Location_Broker_Office__c)))
                    {
                        SubscriptionsHandler.inActiveSubscriptionTeamsAppCallout(new set<string>{sSubscription.Name});
                    } 
                    
                    //Update Address(State) in Zuora
                    if(sSubscription.Related_Location_Broker_Office__c != trigger.oldMap.get(sSubscription.Id).Related_Location_Broker_Office__c) {
                        SMS_UpdateAddress_Future.updateContactZuora(sSubscription.Name);
                    }
                    else{
                        if(sSubscription.Private_Email__c != trigger.oldMap.get(sSubscription.id).Private_Email__c) {
                            SMS_SubPrivateEmailUpdate.updateContactEmail(sSubscription.Name);
                        }
                    }
                    
                }                 
                else {
                    sSubscription.ZuoraIntegrationWorkflowBypass__c = false; //Reset bypass value
                }          
                
            }
            else {
                try {
                    system.debug('*** SMS_ZuoraIntegration : No'  + accounts[0].Type);
                    throw new  SMS_CustomException('Excluded from Zuora Integration for Account Type : ' + accounts[0].Type);
                }
                catch(Exception e){
                    SMS_ZuoraHistory.createError(e,'SMS_ZuoraIntegration',sSubscription.Name);
                }
            }
        }
        
        /*
if(inactiveSubscriptionIds.size() > 0){
Datetime currentTime = system.now().addMinutes(1);

String day = string.valueOf(currentTime.day());
String month = string.valueOf(currentTime.month());
String hour = string.valueOf(currentTime.hour());
String minute = string.valueOf(currentTime.minute());
String second = string.valueOf(currentTime.second());
String year = string.valueOf(currentTime.year());

String strJobName = 'InactivateSubs -' + String.ValueOf(Math.random());
String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

system.debug('**** strSchedule :' + strSchedule );
SMS_ScheduleInactivateSubs sz = new SMS_ScheduleInactivateSubs(inactiveSubscriptionIds);

String jobID = system.schedule(strJobName, strSchedule , sz);
system.debug('*** Job Id created for the Scheduled Class :'+ jobID );
}
*/
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        for(Subscriptions__c sSubscription : Trigger.new) {
            system.debug('****sSubscription'+sSubscription);
           if(sSubscription.Status__c == 'Active' && trigger.oldMap.get(sSubscription.id).Status__c != 'Active' && 
               sSubscription.Contact_Type__c == 'Government Agency' && sSubscription.Billing_Period__c != null){
                system.debug('****sSubscription'+sSubscription);
                GovernmentAgency_Class.createOrUpdateGASubscription(sSubscription.Id, trigger.oldMap.get(sSubscription.id).Status__c == 'In Progress');
               }
            
           if(sSubscription.Status__c == 'Inactive' && trigger.oldMap.get(sSubscription.id).Status__c != 'Inactive' && 
               sSubscription.Contact_Type__c == 'Government Agency' && sSubscription.Billing_Period__c != null)
            {
               GovernmentAgency_Class.createOrUpdateGASubscription(sSubscription.Id, false);
           }
           /* if(sSubscription.Status__c == 'Active' && trigger.oldMap.get(sSubscription.id).Status__c == 'In Progress' && 
               sSubscription.Contact_Type__c == 'Government Agency' && sSubscription.Billing_Period__c != null){
                  GovermentAgency_Class.createSetupfeeSubscription(sSubscription.Id);
               }*/
        }
    }
    
    //BRIG-3725, 3724, 3722: Late Fee Waiver logic implemented by Mounika
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        SMS_LateFeeWaiver.checkSubscriptionLateFee(Trigger.New, Trigger.oldMap);
    }
}