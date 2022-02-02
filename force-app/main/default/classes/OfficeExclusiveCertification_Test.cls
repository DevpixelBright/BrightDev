@isTest
public class OfficeExclusiveCertification_Test 
{
    @testSetup
    public static void createTestData()
    {
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
        account.Status__c = 'Active';
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
        subscription.Private_Email__c = 'test1@test.com';
        insert subscription; 
        
        Office_Exclusive__c oexc = new Office_Exclusive__c();
        oexc.List_Office_ID__c = account.id;
        oexc.List_Agent_ID__c = subscription.id;
        //oexc.List_Agent_Name__c = 'Test';
        oexc.Property_Address__c = 'TEst';
        oexc.City__c = 'Ames';
        oexc.State__c = 'AE';
        oexc.ZIP__c = '40001';
       insert oexc;
        
        Relationship__c r1 = createRelationship(account.Id, contact.Id,subscription.Id, 'Broker Of Record'); 
        //Relationship__c r2 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        
    }
    
    @isTest
    public static void testCommunities_OfficeExclusive()
    {
        list<Subscriptions__c> subList = [SELECT Id,Name,Status__c,Status_Change_Reason__c FROM Subscriptions__c];
        list<string> subIdList = new list<string>();
        for(Subscriptions__c sub : subList){
            subIdList.add(sub.Id);
        }
        
      //  Office_Exclusive__c oe = new Office_Exclusive__c();
      //  OfficeExclusiveCertification oec = new OfficeExclusiveCertification();
      //  OfficeExclusiveCertification.officeExclusiveWrapper test = new OfficeExclusiveCertification.officeExclusiveWrapper(oexc);
        OfficeExclusiveCertification.getDataMethod(subList[0].Name);
    }
    
   
    private Static Relationship__c createRelationship(String accountId, String contactId, String subscriptionId, String relationType) {
        Relationship__c r = new Relationship__c();
        r.Broker_Office__c = accountId;
        r.Related_Account__c = accountId;
        r.Contact__c = contactId;
        r.Subscription__c = subscriptionId;
        r.Relationship_Type__c = relationType;
        
        r.Status__c = 'Active';
        insert r; 
        
        return r;
    }
    
}