@istest(SeeAllData=true)
public class SMS_DeleteZuoraAccount_Test {

    public static testMethod void doTestOne() {
        
        /* Test data creation */
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs(); 
        
        Account account = new Account();
        account.Name = 'TEST567';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        insert account; 
        
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.Id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;
    
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.Name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        insert subscription; 
        
        /* Setting predefined values for ZuoraMockDataGenerator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('CrmId', account.Id);
        
        /* Setting empty result for ZuoraMockDataGenerator */
        Map<String, Boolean> zObjectEmptyResult = new Map<String, Boolean>();
        zObjectEmptyResult.put('Subscription', true);
        
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues; 
        SMS_ZuoraMockDataGenerator.zObjectEmptyResult = zObjectEmptyResult;        
        

        List<String> personAccountIds = new List<String>{account.Id};

        SMS_DeleteZuoraAccount.deleteZuoraAccount(personAccountIds);
        
        delete contact;
    }

}