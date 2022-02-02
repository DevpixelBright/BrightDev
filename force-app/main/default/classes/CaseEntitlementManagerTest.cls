@isTest
public with sharing class CaseEntitlementManagerTest {

	public static testmethod void InsertRetsCases() {
		TestDataFactory tdf = new TestDataFactory();
		tdf.TriggersOff();
		
		String retsCaseRecordTypeName = 'RETS_Case';
		BusinessHours default_hours = [select Id, Name from BusinessHours where isDefault = true and isActive = true limit 1];

		String supportProcessName = 'AMS RETS SLA Process';
		SlaProcess rets_process = [select Id, Name from SlaProcess where Name = :supportProcessName limit 1];

		RecordType rets_type = [select Id, DeveloperName from RecordType where DeveloperName = :retsCaseRecordTypeName limit 1];
		String retsCaseRecordType = rets_type.Id;
		System.debug('RETS case record type ID: ' + retsCaseRecordType);

		Account a = tdf.MakeBrokerOfficeAccount();		
		insert a;
		a = [select id from Account limit 1];

		Entitlement ent = new Entitlement();
		ent.Name = 'CaseEntitlementManagerTest';
		ent.BusinessHoursId = default_hours.Id;
		ent.SlaProcessId = rets_process.Id;
		ent.Case_Record_Type__c = retsCaseRecordTypeName;
		ent.AccountId = a.Id;
		ent.StartDate = Date.today();
		insert ent;
		
		ent = [select Id, Name, Case_Record_Type__c, BusinessHoursId from Entitlement where Case_Record_Type__c = :retsCaseRecordTypeName limit 1];
		System.debug('entitlement: ' + ent.Id);
		
		List<Case> cases = tdf.CreateCases(retsCaseRecordType, 5);
		
		tdf.TriggersOn();
		
		Test.startTest();
		
		insert cases;
		
		Test.stopTest();
		
		for(Case c : cases) {
			Case cs = [select ID, EntitlementId, BusinessHoursId from Case where Id = :c.Id limit 1];
			System.assertEquals(ent.Id,cs.EntitlementId);
			System.assertEquals(ent.BusinessHoursId,cs.BusinessHoursId);
		}
	}
	
	public static testmethod void InsertMixedCases() {
		TestDataFactory tdf = new TestDataFactory();
		tdf.TriggersOff();
				
		String retsCaseRecordTypeName = 'RETS_Case';
		BusinessHours default_hours = [select Id, Name from BusinessHours where isDefault = true and isActive = true limit 1];

		String supportProcessName = 'AMS RETS SLA Process';
		SlaProcess rets_process = [select Id, Name from SlaProcess where Name = :supportProcessName limit 1];

		RecordType rets_type = [select Id, DeveloperName from RecordType where DeveloperName = :retsCaseRecordTypeName limit 1];
		String retsCaseRecordType = rets_type.Id;
		System.debug('RETS case record type ID: ' + retsCaseRecordType);

		Account a = tdf.MakeBrokerOfficeAccount();		
		insert a;
		a = [select id from Account limit 1];

		Entitlement ent = new Entitlement();
		ent.Name = 'CaseEntitlementManagerTest';
		ent.BusinessHoursId = default_hours.Id;
		ent.SlaProcessId = rets_process.Id;
		ent.Case_Record_Type__c = retsCaseRecordTypeName;
		ent.AccountId = a.Id;
		ent.StartDate = Date.today();
		insert ent;

		ent = [select Id, Name, Case_Record_Type__c, BusinessHoursId from Entitlement where Case_Record_Type__c = :retsCaseRecordTypeName limit 1];
		System.debug('entitlement: ' + ent.Id);

		List<Case> cases = tdf.CreateCases(retsCaseRecordType, 5);
		cases.addAll(tdf.CreateCases(5));
		
		tdf.TriggersOn();
		
		Test.startTest();
		
		insert cases;
		
		Test.stopTest();
		
		for(Case c : cases) {
			Case cs = [select Id, RecordTypeId, EntitlementId, BusinessHoursId from Case where Id = :c.Id limit 1];
			
			if(cs.RecordTypeId == retsCaseRecordType) {
				System.assertEquals(ent.Id,cs.EntitlementId);
				System.assertEquals(ent.BusinessHoursId,cs.BusinessHoursId);
			} else {
				System.assertNotEquals(ent.Id,cs.EntitlementId);
				//System.assertEquals(cs.BusinessHoursId,null);
			}
		}
	}
}