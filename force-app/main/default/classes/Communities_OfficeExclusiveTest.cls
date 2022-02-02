@isTest(seeAllData=false)
public class Communities_OfficeExclusiveTest {
	
    @isTest static void test1() {
        TestClassUtility.generateData();
        Account a1 = TestClassUtility.createAccount('Residential','XYZ124', 'MRIS');
        Account a2 = TestClassUtility.createAccount('Residential','XYZ1245', 'MRIS');
        a1.ParentId = a2.Id;
        update a1;
        Contact c1 = TestClassUtility.createContact(a1.Id, 'MRIS'); 
        Subscriptions__c s1 = TestClassUtility.createSubscription(a1.Id, c1.Id, 'MRIS');   
        s1.Status__c = 'Active';
        update s1;
        Subscriptions__c sub = [SELECT id, Name FROM Subscriptions__c WHERE Id =: s1.Id];
        Test.setCurrentPageReference(new PageReference('Page.Communities_OfficeExclusive'));
        Communities_OfficeExclusive offExc = new Communities_OfficeExclusive();
        System.currentPageReference().getParameters().put('id', 'test');
        offExc = new Communities_OfficeExclusive();
		System.currentPageReference().getParameters().put('id', sub.Name);
        offExc = new Communities_OfficeExclusive();
        offExc.oOfficeExclusive.Seller_Landlord_Name_1__c = 'test';
        offExc.oOfficeExclusive.Seller_Landlord_Name_2__c = 'test';
        offExc.oOfficeExclusive.New_Construction__c = true;
        offExc.oOfficeExclusive.Property_Address__c = 'test';
        offExc.oOfficeExclusive.City__c = 'test';
        offExc.oOfficeExclusive.State__c = 'test';
        offExc.oOfficeExclusive.ZIP__c = 'test';
        offExc.oOfficeExclusive.Listing_Expiration_Date__c = system.today();
        
        
        offExc.validateForm();
        offExc.oOfficeExclusive.Listing_Agreement_Date__c = system.today();
        offExc.submitOfficeExclusiveForm();
        offExc.oOfficeExclusive.State__c = 'VA';
        offExc.att.name = 'file1';
        offExc.att.body = Blob.valueOf('1111');
        offExc.submitOfficeExclusiveForm();
        system.assertNotEquals(offExc.oOfficeExclusive.Id, Null);
        offExc.subscription.Private_Email__c = 'test@test.com';
        offExc.sendEmailToAgent(offExc.subscription);
        offExc.oOfficeExclusive.New_Construction__c = false;
        offExc.oOfficeExclusive.Unit_Type__c = 'Ste 300';
        offExc.sendEmailToAgent(offExc.subscription);
        offExc.oOfficeExclusive.City__c = null;
        offExc.validateForm();
        Date d1 = offExc.Listing_Agreement_Date;
        Date d2 = offExc.Listing_Expiration_Date;
        Boolean b1 = offExc.isOfficeManager;
        offExc.dummy();
        Communities_OfficeExclusive.searchAgentListings('123', '123');
        Boolean flag = offExc.hasInitialError;
    }
}