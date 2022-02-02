@istest
public class OppTerrAssignDefaultLogicFilter_Test{
    public static testmethod void oppTerrAssigntest(){
        Account acc =  createAccount('Residential','XYZ124');
        Opportunity opp = createOpportunity(acc.Id);
        List<id> opplistid=new List<id>();
        opplistid.add(opp.id);
        insertTestTerritory(acc.id);
        OppTerrAssignDefaultLogicFilter oppcheck=new OppTerrAssignDefaultLogicFilter();
        Map<Id,Id> mapid=oppcheck.getOpportunityTerritory2Assignments(opplistid);
    }
    
     private static Account createAccount(String type, String name) {
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
        account.Status__c = 'Active';
        insert account; 
        
        return account;
    }
     private static Opportunity createOpportunity(String accountId) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accountId; 
         opp.name = 'test opp';
         opp.StageName ='Generate Opportunity';
         opp.CloseDate=system.today();
        insert opp;
        
        return opp;
    }
    private static void insertTestTerritory(Id AccId)
    { 
        List<Territory2> terri2  = [SELECT id,Name,Territory2ModelId,Territory2TypeId from Territory2 LIMIT 1];
        ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = AccId, Territory2Id =terri2[0].Id, AssociationCause='Territory2Manual' );
        insert objObjectTerritory2Association;

    }
}