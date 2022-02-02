@istest
public class BORUtilityClass_Test {
    
    @isTest static void test1() {
        TestClassUtility.generateData();
        Account a1 = TestClassUtility.createAccount('Residential','XYZ124', 'BRIGHT');
        Account a2 = TestClassUtility.createAccount('Residential','XYZ126', 'BRIGHT');
        Contact c1 = TestClassUtility.createContact(a1.Id, 'BRIGHT'); 
        Subscriptions__c s1 = TestClassUtility.createSubscription(a1.Id, c1.Id, 'BRIGHT');   
        s1.Status__c = 'Active';
        update s1;
        Subscriptions__c sub = [SELECT id, Name FROM Subscriptions__c WHERE Id =: s1.Id];
        List<String> officeIds = new List<String>{a1.Id,a2.Id};
            
        BORUtilityClass.fetchBOR(officeIds);
        BORUtilityClass.fetchActiveOfficesFromBrokerage(officeIds);
    }
}