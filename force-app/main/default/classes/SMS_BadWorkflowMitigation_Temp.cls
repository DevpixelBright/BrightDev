public class SMS_BadWorkflowMitigation_Temp{
    public static Boolean isPrimarySubscriptionReinstatement(String contactId, String mrisSubscriptionId) {
        List<Contact> sfContact = [    
            SELECT  Id
            FROM    Contact
            WHERE   Id = :contactId AND Primary_Subscription_ID__c = :mrisSubscriptionId
        ];                                                 
        
        return sfContact.size() == 1;
    }
}