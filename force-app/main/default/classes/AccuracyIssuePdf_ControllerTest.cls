@istest
public class AccuracyIssuePdf_ControllerTest 
{
    @istest
    public static void testIssuePdf()
    {
        
        ApexPages.currentPage().getParameters().put('mls', 'testMls');
        ApexPages.currentPage().getParameters().put('address', 'testaddress');
        ApexPages.currentPage().getParameters().put('from', 'testfrom');
        ApexPages.currentPage().getParameters().put('topic', 'testtopic');
        
        
        Account a1 = createAccount('RETS','XYZ124', 'MRIS');
        a1.Status__c = 'Active';
        update a1;
        
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        c1.Status__c = 'Active';
        update c1;
        
        //User communityUser = createCommunityUser(a1, c1); 
        
        Case c = new Case();
        c.SuppliedEmail = 'test@test.com';
        c.Description='from unit test';
        c.Subject ='testing trigger';
        c.Status='New';    
        
        insert c;
        
        ApexPages.currentPage().getParameters().put('caseId', c.Id);
    }
    
    
    private static Account createAccount(String type, String name, String jurisdiction) {
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        //account.Status__c = 'Active';
        account.Primary_Service_Jurisdiction__c = jurisdiction;
        account.Status__c = 'In Progress';
        insert account; 
        
        return account;
    }
    
    private static Contact createContact(String accountId, String jurisdiction) {
        Contact contact = new Contact();
        contact.Email = 'test@test.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'test@test.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        contact.Service_Jurisdiction__c = jurisdiction;
        contact.Status__c = 'In Progress';
        insert contact;
        
        return contact;
    }
}