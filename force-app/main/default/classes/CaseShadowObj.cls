public class CaseShadowObj {
	
	public static void HandleCaseOperation(Map<Id,Case> oldCase, Map<Id,Case> newCase, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
		if(isInsert) {
			CaseShadowObj.HandleCaseInsert(newCase.values());
		}
		if(isUpdate) {
			CaseShadowObj.HandleCaseUpdate(oldCase, newCase);	
		}
		if(isDelete) {
			CaseShadowObj.HandleCaseDelete(oldCase);
		}
	}
	
	public static void HandleCaseInsert(List<Case> cases) {
		List<Shadow_Case__c> to_add = new List<Shadow_Case__c>();
		for(Case c : cases) {
			if(c.Shadow_Case__c) {
				to_add.add(CreateTrackingObject(c));
			}
		}
		if(to_add.size() > 0) {
			insert to_add;
		}		
	}
	
	public static void HandleCaseUpdate(Map<Id,Case> oldCase, Map<Id,Case> newCase) {
		List<Shadow_Case__c> to_add = new List<Shadow_Case__c>();
		List<Id> to_delete = new List<Id>();
		List<Id> to_update = new List<Id>();
		
		for(Case c : newCase.values()) {
			if(c.Shadow_Case__c && !oldCase.get(c.Id).Shadow_Case__c) {
				to_add.add(CreateTrackingObject(c));
			}
			else if(!c.Shadow_Case__c && oldCase.get(c.Id).Shadow_Case__c) {
				to_delete.add(c.Id);
			}
			else if(c.Shadow_Case__c && (c.Subscription_ID__c != oldCase.get(c.Id).Subscription_ID__c
			   || c.ContactId != oldCase.get(c.Id).ContactId)) {
				to_update.add(c.Id);
			}
		}
		if(to_add.size() > 0) {
			 insert to_add;
		}
		if(to_delete.size() > 0) {
			List<Shadow_Case__c> shdw = [select Id from Shadow_Case__c where Related_Case__c in :to_delete];
			delete shdw;
		}
		if(to_update.size() > 0) {
			List<Shadow_Case__c> shdw = [select Id, Related_Case__c, Contact__c from Shadow_Case__c where Related_Case__c in :to_update];
			for(Shadow_Case__c s : shdw) {
				s.Subscription__c = newCase.get(s.Related_Case__c).Subscription_ID__c;
				s.Contact__c = newCase.get(s.Related_Case__c).ContactId;
			}
			update shdw;
		}	
	}
	
	public static void HandleCaseDelete(Map<Id,Case> cases) {
		List<Shadow_Case__c> to_delete = [select Id from Shadow_Case__c where Related_Case__c in :cases.keySet()];
		if(to_delete != null && to_delete.size() > 0) {
			delete to_delete;
		}
	}
	
	private static Shadow_Case__c CreateTrackingObject(Case c) {
		Shadow_Case__c shadow = new Shadow_Case__c();
		shadow.Related_Case__c = c.Id;
		shadow.Subscription__c = c.Subscription_ID__c;
		shadow.Contact__c = c.ContactId;
		return shadow;
	}
}