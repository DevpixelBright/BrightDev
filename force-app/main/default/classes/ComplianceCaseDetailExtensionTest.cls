@isTest
private class ComplianceCaseDetailExtensionTest {

    static testMethod void TestComplianceCaseDetailExtension() {
		TestDataFactory tdf = new TestDataFactory();
		
		Case c = tdf.MakeCase();
		c.Description = 'test';
		insert c;
		c = [select Id from Case limit 1];
		
		Shadow_Case__c shc = new Shadow_Case__c();
		shc.Related_Case__c = c.Id;
		insert shc;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(shc);
		
		Test.startTest();
		
		ComplianceCaseDetailExtension ext = new ComplianceCaseDetailExtension(sc);
		
		Test.stopTest();
		
		System.assertEquals('test',ext.CaseDescription);
    }
}