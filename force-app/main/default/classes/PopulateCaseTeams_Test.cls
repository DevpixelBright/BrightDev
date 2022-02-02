@isTest
private class PopulateCaseTeams_Test {

    static testMethod void PopulateCaseTeamsBatch() {
       TestDataFactory tdf = new TestDataFactory();
       
       List<Case> cases = tdf.CreateCases(10);
       Group queue = [select Id, Name from Group where Type = 'Queue' and Name = 'Compliance' limit 1];
       
       for(Case c : cases) {
       		c.OwnerId = queue.Id;
       }
       
       insert cases;
       
       Test.startTest();
       
       PopulateCaseTeams pct = new PopulateCaseTeams();
       Database.executeBatch(pct, 10);
              
       Test.stopTest();
    }
}