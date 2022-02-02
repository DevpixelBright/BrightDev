@isTest(seeAllData=false)
public class Communities_OfficeExclusivePDFTest {
	
    @isTest static void test1() {
        TestClassUtility.generateData();
        Account a1 = TestClassUtility.createAccount('Residential','XYZ124', 'MRIS');
        Contact c1 = TestClassUtility.createContact(a1.Id, 'MRIS'); 
        Subscriptions__c s1 = TestClassUtility.createSubscription(a1.Id, c1.Id, 'MRIS');   
        s1.Status__c = 'Active';
        update s1;
        Subscriptions__c sub = [SELECT id, Name FROM Subscriptions__c WHERE Id =: s1.Id];
        Test.setCurrentPageReference(new PageReference('Page.Communities_OfficeExclusivesPDF'));
        Communities_OfficeExclusivePDF offExc = new Communities_OfficeExclusivePDF();
        System.currentPageReference().getParameters().put('id', 'test');
        offExc = new Communities_OfficeExclusivePDF();
		System.currentPageReference().getParameters().put('id', sub.Name);
        offExc = new Communities_OfficeExclusivePDF();
        offExc.sOfficeExclusive.Seller_Landlord_Name_1__c = 'test';
        offExc.sOfficeExclusive.Seller_Landlord_Name_2__c = 'test';
        offExc.sOfficeExclusive.New_Construction__c = true;
        offExc.sOfficeExclusive.Property_Address__c = 'test';
        offExc.sOfficeExclusive.City__c = 'test';
        offExc.sOfficeExclusive.State__c = 'test';
        offExc.sOfficeExclusive.ZIP__c = 'test';
        offExc.sOfficeExclusive.Listing_Expiration_Date__c = system.today();
        offExc.sOfficeExclusive.Listing_Agreement_Date__c = system.today();
    }
}