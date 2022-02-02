trigger TerritoryOwnerOpportunity on Opportunity (Before insert,Before update) {
    
    if(Trigger.IsBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            List<ID> listAccountIds = new List<ID>();
             
            for(Opportunity opp : Trigger.NEW){
                  system.debug('*****opp '+opp);
                     listAccountIds.add(opp.AccountId);
            }
            Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id,OwnerId FROM Account WHERE Id IN :listAccountIds]);
            for(Opportunity opp : Trigger.NEW){
                    opp.OwnerId = accounts.get(opp.accountId).OwnerId;
            }
            
        }
      }
}