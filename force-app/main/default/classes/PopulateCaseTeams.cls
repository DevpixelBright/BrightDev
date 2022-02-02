global class PopulateCaseTeams implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext bc) {
		List<Id> owners = new List<Id>();
		List<Group> queues = [select Id from Group where Type = 'Queue' and Name in ('Compliance','Compliance Exception Queue','Appeals','Appeals Exceptions','Violations Queue','Violations Exception Queue','Website Monitoring Queue','Website Monitoring Exception Queue')];
		for(Group q : queues) {
			owners.add(q.Id);
		}
		
		UserRole complianceRole = [select Id from UserRole where Name = 'Compliance' limit 1];
		List<User> users = ([select Id from User where UserRoleId = :complianceRole.Id]);
		for(User u : users) {
			owners.add(u.Id);
		}
		
		String allCases = 'select Id from Case where OwnerId in (';
		for(Id o : owners) {
			allCases += '\'' + o + '\','; 
		}
		allCases += '\'\')';

		System.debug(allCases);
		return Database.getQueryLocator(allCases);
	}

	global void execute(Database.BatchableContext BC, List<sObject> cases) {
		Map<Id,Case> casemap = new Map<Id,Case>();
		
		for(sObject obj : cases) {
			Case c = (Case)obj;
			casemap.put(c.Id,c);
		}
		
		CaseTeamTemplate team = [select Id, Name from CaseTeamTemplate where Name = 'MRIS Compliance'];
		List<CaseTeamTemplateRecord> existing = [select Id, ParentId, TeamTemplateId from CaseTeamTemplateRecord where TeamTemplateId = :team.Id and ParentId in :casemap.keySet()];
		
		for(CaseTeamTemplateRecord t : existing) {
			casemap.remove(t.ParentId);
		}
		
		List<CaseTeamTemplateRecord> assign = new List<CaseTeamTemplateRecord>();
				 
		for(Case c : casemap.values()) {
			CaseTeamTemplateRecord r = new CaseTeamTemplateRecord();
			r.ParentId = c.Id;
			r.TeamTemplateId = team.Id;
			assign.add(r);
			
			System.debug('Updating ' + c.Id);
		}
		
		upsert assign;
	}
	
	global void finish(Database.BatchableContext BC) {}
}