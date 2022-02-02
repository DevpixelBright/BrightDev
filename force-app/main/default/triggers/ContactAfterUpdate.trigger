trigger ContactAfterUpdate on Contact (after update) {

    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    
    // QAS required code
    // QAS_NA.CAAddressCorrection.ExecuteCAAsyncForTriggerConfigurationsOnly(trigger.new);
    
    //Call the future method with the list of Subscription objects
    Map<Id,String> newJsonSubscriptionString = new Map<Id,String>();
    Map<Id,String> oldJsonSubscriptionString = new Map<Id,String>();
    List<Subscriptions__c> sList = new List<Subscriptions__c>();
    List<Id> contactIds = new List<Id>();
    
    for (Contact contact : Trigger.new) { 
        if(String.isNotBlank(contact.Service_Jurisdiction__c) && contact.Service_Jurisdiction__c != 'MRIS'){
            system.debug('Bypass if not MRIS: ' + contact.Id);
            continue;    
        }
    
        Contact oldContact = Trigger.oldMap.get(contact.id);
        
      //  if ((oldContact.Primary_Subscription__c != null) && (oldContact.Primary_Subscription__c != contact.Primary_Subscription__c)) 
      //      ContactProcessingUtlity.changePrimaryFlag(oldContact.Primary_Subscription__c, contact.Primary_Subscription__c);
               
        if ((oldContact.Birthdate != contact.Birthdate)
           ||(oldContact.Professional_Designations__c != contact.Professional_Designations__c)
           ||(oldContact.FirstName != contact.FirstName)
           ||(oldContact.LastName != contact.LastName)
           ||(oldContact.Salutation != contact.Salutation)
           ||(oldContact.Middle_Name__c != contact.Middle_Name__c)
           ||(oldContact.Nickname__c != contact.Nickname__c)
           ||(oldContact.Suffix__c != contact.Suffix__c)) {
        
            contactIds.add(contact.id);
        }
        
    }
    
    try{ 
        if(contactIds.Size() > 0) {
            List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
            subscriptions = [SELECT s.Zip__c, s.Zip_4__c, s.Website__c, s.WL_Street_Address__c, s.Voicemail__c, s.VM_Ext__c, s.Unit__c, 
                                    s.Unit_Type__c, s.SystemModstamp, s.Subscription_Type__c, s.Street_Type__c, s.Street_Number__c, 
                                    s.Street_Number_Suffix__c, s.Street_Name__c, s.Street_Direction__c, s.Status__c, s.Status_Change_Reason__c, 
                                    s.Status_Change_Fee__c, s.State__c, s.SF_Subscription_ID__c, s.SFDC_Application__c, s.Related_Location_Broker_Office__c, 
                                    s.Quarterly_Fee__c, s.QAS_Validation_Timestamp__c, s.QAS_Validation_Status__c, s.QAS_Validation_Footnote__c, 
                                    s.QAS_Billing_Validation_Timestamp__c, s.QAS_Billing_Validation_Status__c, s.QAS_Billing_Validation_Footnote__c, 
                                    s.Public_Email__c, s.Private_Email__c, s.PrismSubscriptionID__c, s.Primary__c, s.Primary_Phone__c, s.PrimarySubNum__c, 
                                    s.Pager__c, s.Name, s.NRDS_ID__c, s.Mobile_Phone__c, s.MDS_Status__c, s.License__c, s.LastModifiedDate, s.LastModifiedById, 
                                    s.LastActivityDate, s.IsDeleted, s.Initial_Subscription_Fee__c, s.Import_Source__c, s.Import_ID__c, s.Id, s.Home_Fax__c, 
                                    s.Fax__c, s.Deleted__c, s.Date_Terminated__c, s.Date_Reinstated__c, s.Date_Joined__c, s.Date_Billing_Begins__c, s.DATETERMINATED__c, 
                                    s.DATELASTMODIFIED__c, s.DATEESTABLISHED__c, s.CreatedDate, s.CreatedById, s.County__c, s.Country__c, s.Copy_Address_to_Billing__c, 
                                    s.Contact__c, s.Contact_Type__c, s.City__c, s.CUSTOMERREFERENCE__c, s.CUSTOMERPOSTALCODE__c, s.CUSTOMERNAME__c, s.CUSTOMERHOMEPHONE__c, 
                                    s.CUSTOMERCLASS__c, s.CUSTOMERCELLPHONE__c, s.CUSTOMERADDRESSLINE2__c, s.CUSTOMERADDRESSLINE1__c, s.CUSTOMERADDRESSID__c, s.CS_Status_ID__c, 
                                    s.Box__c, s.Billing_Zip__c, s.Billing_Zip_4__c, s.Billing_Unit_Type__c, s.Billing_Unit_Number__c, s.Billing_Street_Type__c, 
                                    s.Billing_Street_Suffix__c, s.Billing_Street_Number__c, s.Billing_Street_Name__c, s.Billing_Street_Direction__c, s.Billing_State__c, 
                                    s.Billing_County__c, s.Billing_Country__c, s.Billing_City__c, s.Billing_Box__c, s.Billing_Addl_Display_Name__c, s.BILLINGCYCLE__c, 
                                    s.Agent_Office_Phone__c, s.AgentRealPingID__c, s.AgentKey__c, s.Addl_Display_Name__c 
                             FROM   Subscriptions__c s 
                             WHERE  s.Contact__c =: contactIds AND s.Status__C in ('Active','Inactive') AND s.AgentKey__C != null AND s.MDS_Status__C = 'Success' AND (s.Service_Jurisdiction__c = 'MRIS' OR s.Service_Jurisdiction__c = NULL)];
            if(subscriptions.Size() > 0) {
                for(Subscriptions__c s: subscriptions){
                   // if(newJsonSubscriptionString.size() == 5){
                   //     SubscriptionUtility.sendSubscriptionToQueueProcessor('FORCE UPDATE', newJsonSubscriptionString,newJsonSubscriptionString );                
                   //     newJsonSubscriptionString = new Map<Id,String>();   
                   // }
                    newJsonSubscriptionString.put(s.id, JSON.serialize(s));
                } 
            }
            
            //if (newJsonSubscriptionString.keySet().size() > 0) 
            //    SubscriptionUtility.sendSubscriptionToQueueProcessor('FORCE UPDATE', newJsonSubscriptionString,newJsonSubscriptionString );                
        }
    } 
    catch(AsyncException e) {
    
    }   
}