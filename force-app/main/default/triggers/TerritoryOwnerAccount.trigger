trigger  TerritoryOwnerAccount on Account (after insert, after update) {
    List<String> accountIds = new List<String>();
    List<RecordType> businessRecordType = [SELECT Id, Name 
                                           FROM   RecordType 
                                           WHERE  SobjectType = 'Account' 
                                           AND    Name = 'Business Account'];

    if(trigger.isUpdate){
        for(Account account : trigger.new){
              if(!account.IsPersonAccount && account.Status__c == 'Active' && account.RecordTypeId == businessRecordType[0].Id){
                String accountId = account.Id;        
                if((account.QAS_Mailing_County__c != trigger.oldMap.get(accountId).QAS_Mailing_County__c) ||
                  	(account.State__c != trigger.oldMap.get(accountId).State__c) ||
					(account.Status__c != trigger.oldMap.get(accountId).Status__c) ||
					(account.Zip__c != trigger.oldMap.get(accountId).Zip__c) 
                  )
                  
                    accountIds.add(accountId);
              }
        }            
    }
    else{        
        for(Account account : trigger.new){
            if(!account.IsPersonAccount && account.Status__c == 'Active' && account.RecordTypeId == businessRecordType[0].Id){
               String accountId = account.Id;        
                accountIds.add(accountId);
             }
        }            
    }
    
    if(accountIds.size() > 0)
        CSCManagement.updateOwner(accountIds);
           
}