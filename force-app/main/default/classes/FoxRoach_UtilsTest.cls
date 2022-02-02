@isTest
public class FoxRoach_UtilsTest 
{
    @isTest
    static void testCopyAccountData()
    {
        FoxRoach_Utils.copyAccountData(new FoxRoach_Modal.Account(), new Account());
    }
    
    @isTest
    static void testCopySubscriptionData()
    {
        FoxRoach_Utils.copySubscriptionData(new FoxRoach_Modal.Account(), new Subscriptions__c());
        FoxRoach_Utils.copySubscriptionData(new FoxRoach_Account__c(), new Subscriptions__c());
    }
    
    @isTest
    static void testCopyContactData()
    {
        FoxRoach_Utils.copyContactData(new FoxRoach_Account__c(), new Contact());
        
        FoxRoach_Modal.Account foxAcc = new FoxRoach_Modal.Account();
        foxAcc.address = new FoxRoach_Modal.Address();
        foxAcc.phoneNumbers = new list<FoxRoach_Modal.PhoneNumber>{new FoxRoach_Modal.PhoneNumber()};
        FoxRoach_Utils.copyContactData(foxAcc, new Contact());
    }
    
    @isTest
    static void testUpdateLogAddAttachment()
    {
        FoxRoach_Sync_Log__c log = new FoxRoach_Sync_Log__c();
        FoxRoach_Utils.updateLogAddAttachment(log);
    }
}