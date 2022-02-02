public class SMS_BadWorkflowMitigation {
    
    public SMS_BadWorkflowMitigation() {}
    
    public static Boolean isPrimarySubscription(String contactId) {
        List<Subscriptions__c> subscriptions = [    
            SELECT  Id
            FROM    Subscriptions__c
            WHERE   Contact__c = :contactId AND Status__c = 'Active'
        ];                                                 
        
        return subscriptions.size() == 1;
    }
    /*
    Moved to temp class to bypass a deployment issue with SMS_Orders
    public static Boolean isPrimarySubscriptionReinstatement(String contactId, String mrisSubscriptionId) {
        List<Contact> sfContact = [    
            SELECT  Id
            FROM    Contact
            WHERE   Id = :contactId AND Primary_Subscription_ID__c = :mrisSubscriptionId
        ];                                                 
        
        return sfContact.size() == 1;
    }
    */
    
    /*
    This is for populating the legacy StatusChangeFee field that is on the subscription.
    This field is no longer used by the new system. However, some of the legacy systems
    continue to depend on it. Therefore, we are populating it separately here, which
    allows us to remove it later on when the field becomes fully deprecated.
    */
    public static Boolean updateStatusChangeFee(String orderId) {
        List<SMS_Order__c> orders = [
            SELECT  MRIS_Subscription_Id__r.Name,
                    (
                        SELECT  Name
                        FROM    SMS_OrderItems__r
                        WHERE   IsCore__c = true AND
                                OneTimeProductRatePlanId__c != null AND
                                RecurringProductRatePlanId__c != null
                    )
            FROM    SMS_Order__c 
            WHERE   Id = :orderId
        ];
        
        if (orders.size() != 1) return false;

        List<Subscriptions__c> subscriptions = [    
            SELECT  Id
            FROM    Subscriptions__c
            WHERE   Name = :orders[0].MRIS_Subscription_Id__r.Name
        ]; 
                                                
        if (subscriptions.size() != 1) return false;
        
        List<SMS_OrderItem__c> items = orders[0].SMS_OrderItems__r;

        if (items.size() > 1) return false;
        
        try {
            subscriptions[0].Status_Change_Fee__c = items.size() == 0 ? 'No Charge' : '$295';
            update subscriptions[0];
            
            return true;
        }
        catch (Exception e) {
            return false;
        }
    }
    
    /*
        Used to bypass callout limits from the SubscriptionAfterInsertUpdate trigger when a Subscription is updated
        in the Auto-Suspend batch process.
        The SubscriptionAfterInsterUpdate was modified to no call this functionality if it detects a batch context.
    */
    public static void sendUpdatedSubscriptionToQueueProcessor(
            Map<Id,string> oldSerializedSubscriptionsMap, 
            Map<Id,string> newSerializedSubscriptionsMap) {
        
        if(newSerializedSubscriptionsMap.size() > 0 && oldSerializedSubscriptionsMap.size() > 0) {
            SubscriptionUtility.sendSubscriptionToQueueProcessor(
                'UPDATE',
                newSerializedSubscriptionsMap,
                oldSerializedSubscriptionsMap);
        }
    }
    
    /*
        Used to generate a list to select the entire subscription object's fields.
    */
    public static string getAllSelectFieldsForSubscription() {
        
        return ' Addl_Display_Name__c, '+
'Agent_Office_Phone__c, '+
'AgentKey__c, '+
'AgentRealPingID__c, '+
'Billing_Addl_Display_Name__c, '+
'Billing_Box__c, '+
'Billing_City__c, '+
'Billing_Country__c, '+
'Billing_County__c, '+
'Billing_State__c, '+
'Billing_Street_Direction__c, '+
'Billing_Street_Name__c, '+
'Billing_Street_Number__c, '+
'Billing_Street_Suffix__c, '+
'Billing_Street_Type__c, '+
'Billing_Unit_Number__c, '+
'Billing_Unit_Type__c, '+
'Billing_Zip__c, '+
'Billing_Zip_4__c, '+
'Box__c, '+
'City__c, '+
'Contact__c, '+
'Contact_Type__c, '+
'Copy_Address_to_Billing__c, '+
'Country__c, '+
'County__c, '+
'CS_Status_ID__c, '+
'Date_Billing_Begins__c, '+
'Date_Joined__c, '+
'Date_Reinstated__c, '+
'Date_Terminated__c, '+
'Deleted__c, '+
'Fax__c, '+
'Home_Fax__c, '+
'Id, '+
'Import_ID__c, '+
'Import_Source__c, '+
'License__c, '+
'MDS_Status__c, '+
'Mobile_Phone__c, '+
'Name, '+
'Nickname__c, '+
'NRDS_ID__c, '+
'Pager__c, '+
'Primary__c, '+
'Primary_Phone__c, '+
'PrismSubscriptionID__c, '+
'Private_Email__c, '+
'Public_Email__c, '+
'QAS_Billing_Country__c, '+
'QAS_Billing_County__c, '+
'QAS_Billing_POBox__c, '+
'QAS_Billing_Record_Type__c, '+
'QAS_Billing_Street_Direction__c, '+
'QAS_Billing_Street_Type__c, '+
'QAS_Billing_Unit_Type__c, '+
'QAS_Billing_Validation_Footnote__c, '+
'QAS_Billing_Validation_Status__c, '+
'QAS_Billing_Validation_Timestamp__c, '+
'QAS_Mailing_Country__c, '+
'QAS_Mailing_County__c, '+
'QAS_Mailing_POBox__c, '+
'QAS_Mailing_Record_Type__c, '+
'QAS_Mailing_Street_Direction__c, '+
'QAS_Mailing_Street_Type__c, '+
'QAS_Mailing_Unit_Type__c, '+
'QAS_Validation_Footnote__c, '+
'QAS_Validation_Status__c, '+
'QAS_Validation_Timestamp__c, '+
'Related_Location_Broker_Office__c, '+
'SF_Subscription_ID__c, '+
'SFDC_Application__c, '+
'State__c, '+
'Status__c, '+
'Status_Change_Fee__c, '+
'Status_Change_Reason__c, '+
'Street_Direction__c, '+
'Street_Name__c, '+
'Street_Number__c, '+
'Street_Number_Suffix__c, '+
'Street_Type__c, '+
'Subscription_Key__c, '+
'Subscription_Type__c, '+
'Unit__c, '+
'Unit_Type__c, '+
'VM_Ext__c, '+
'Voicemail__c, '+
'Website__c, '+
'Zip__c, '+
'Zip_4__c, '+
'Zuora_Status__c, '+
'ZuoraSubscriptionPreactivationSync__c ';
    }
    
        
    
    public class CustomException extends Exception {}
}