public with sharing class CaseEntitlementManager {

	public void AssignEntitlements(List<Case> cases) {
		Set<String> recordTypes = getRecordTypes(cases);
		Map<String,String> recordTypeNames = getRecordTypeNames(recordTypes);
		Map<String,Entitlement> entitlements = getEntitlementMap(recordTypeNames.values());

		for(Case c : cases) {
			if(entitlements.containsKey(recordTypeNames.get(c.RecordTypeId))) {
				c.EntitlementId = entitlements.get(recordTypeNames.get(c.RecordTypeId)).Id;
				c.BusinessHoursId = entitlements.get(recordTypeNames.get(c.RecordTypeId)).BusinessHoursId;
			}
		}
	}
	
	private Set<String> getRecordTypes(List<Case> cases) {
		Set<String> types = new Set<String>();
		for(Case c : cases) {
			types.add(c.RecordTypeId);
		}
		return types;
	}
	
	private Map<String,String> getRecordTypeNames(Set<String> recordTypes) {
		List<RecordType> rtlist = [select Id, DeveloperName from RecordType where Id in :recordTypes];
		Map<String,String> rtmap = new Map<String,String>();
		for(RecordType rt : rtlist) {
			rtmap.put(rt.Id,rt.DeveloperName);
		}
		return rtmap;
	}

	private Map<String,Entitlement> getEntitlementMap(List<String> recordTypeNames) {
		Map<String,Entitlement> emap = new Map<String,Entitlement>();
		
		List<Entitlement> elist = [select Id, Name, Case_Record_Type__c, BusinessHoursId from Entitlement where StartDate <= TODAY and (EndDate > TODAY or EndDate = null) and Case_Record_Type__c in :recordTypeNames];
		for(Entitlement e : elist) {
			emap.put(e.Case_Record_Type__c,e);
		} 
		return emap;
	}
}