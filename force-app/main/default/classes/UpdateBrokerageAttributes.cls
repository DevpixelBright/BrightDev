public class UpdateBrokerageAttributes {
    public Static void updateRelatedAccounts(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> RestrictAccount = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        List<Account> updateAccount = new List<Account>();
        for(Id accountId : newMap.keyset()) {
            if (newMap.get(accountId).ParentId==null && newMap.get(accountId).Status__c == 'Active' && newMap.get(accountId).Company_Type__c=='Broker Office' 
                &&(oldMap.get(accountId).Brand__c != newMap.get(accountId).Brand__c || oldMap.get(accountId).HoldingCompany__c!=newMap.get(accountId).HoldingCompany__c )){
                accountIds.add(newMap.get(accountId).Id);
                    accountMap.put(newMap.get(accountId).Id,newMap.get(accountId));
             }else if(oldMap.get(accountId).Brand__c != newMap.get(accountId).Brand__c || oldMap.get(accountId).HoldingCompany__c!=newMap.get(accountId).HoldingCompany__c ){
                    RestrictAccount.add(accountId);
                }
        }
        List<Account> relatedAccounts = [SELECT Id, ParentId, Name,Brand__c,HoldingCompany__c,Broker_Hierarchy_updated_By__c FROM Account WHERE (ParentId IN:accountMap.keyset())];
        for(Account acc:relatedAccounts)
        {
            Account parentAccount = accountMap.get(acc.ParentId);
            acc.Brand__c=parentAccount.Brand__c;
            acc.HoldingCompany__c=parentAccount.HoldingCompany__c;
            acc.Broker_Hierarchy_updated_By__c=parentAccount.Broker_Hierarchy_updated_By__c;
            //acc.Validation_Rule_Time_Stamp__c=parentAccount.Validation_Rule_Time_Stamp__c;
            updateAccount.add(acc);
        }
        if(updateAccount.size()>0)
        {
          Database.update(updateAccount);  
        }
         else{
                for(Id accId:RestrictAccount)
                {
                    Account accObj=newMap.get(accId);
                    accObj.addError('The Brokerage Attributes (Brand, Holding Company) information is not editable on any of the Branch Office records');
                }

        }
    }
}