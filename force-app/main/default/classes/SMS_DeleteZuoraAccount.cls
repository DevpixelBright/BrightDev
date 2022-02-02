public class SMS_DeleteZuoraAccount {
    @future(callout = true)
    public static void deleteZuoraAccount(List<String> personAccountIds) {
        System.Debug('*** personAccountIds : ' + personAccountIds);
        if(personAccountIds.size() > 0) {
            Map<String,Set<String>> personZAccIds = new Map<String,Set<String>>();
            List<String> zAccountIds = new List<String>();
            Set<String> zDeletedAccIds = new Set<String>(); 
            Set<String> personAccountIds_task = new Set<String>();
            List<Account> personAccounts_del = new List<Account>(); 
            List<Task> personAccounts_task = new List<Task>();
            
            String query = 'SELECT Id, Name, CrmId FROM Account WHERE ';
            Integer i = 0;
            for (String personAccountId : personAccountIds) {
                if (i != 0) 
                    query += ' OR ';
                
                query += 'crmId = \'' + personAccountId + '\'';
                i++;
                
                if(!personZAccIds.containsKey(personAccountId))
                    personZAccIds.put(personAccountId, new Set<String>());                
                
            }
            System.Debug('*** Account query : ' + query );
            System.Debug('*** personZAccIds : ' + personZAccIds);
            
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            List<Zuora.zObject> zAccounts =  zUtilInstance.zquery(query);
            System.Debug('*** zAccounts : ' + zAccounts);
            
            if (zAccounts.Size() > 0) {   
                for (Zuora.zObject zAccount : zAccounts) {
                    String personAccountId = (String)zAccount.getValue('CrmId');
                    String zAccountId = (String)zAccount.getValue('Id');
                    if(!personZAccIds.containsKey(personAccountId))
                        personZAccIds.put(personAccountId, new Set<String>());
                
                    personZAccIds.get(personAccountId).add(zAccountId);                
                
                    List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery('SELECT Id, AccountId, Name FROM Subscription WHERE AccountId = \'' + zAccountId + '\'');
                    system.debug('*** zSubscriptions size : ' + zSubscriptions.size());
                    if(!(zSubscriptions.Size() > 0))             
                        zAccountIds.add(zAccountId); 
                    else 
                        personAccountIds_task.add(personAccountId);
                }
                
                if(zAccountIds.size() > 0) { 
                    system.debug('*** to be deleted zAccountIds :' + zAccountIds);
                    system.debug('*** to be deleted personAccountIds_task :' + personAccountIds_task);
                    List<Zuora.zApi.DeleteResult> zDeleteResult = zUtilInstance.zdelete('Account',zAccountIds);
                    System.Debug('*** zDeleteResult :' + zDeleteResult );
                     
                    for (Zuora.zApi.DeleteResult result : zDeleteResult ){
                        if (result.Success)        
                            zDeletedAccIds.add(result.Id);
                    }
                    system.debug('*** zDeletedAccIds :' + zDeletedAccIds);
                     
                }
                
                if(zDeletedAccIds.size() > 0) {
                    for(String personAccountId : personZAccIds.keyset()){
                        if(zDeletedAccIds.containsAll(personZAccIds.get(personAccountId))){
                            Account personAccount = new Account();
                            personAccount.id = personAccountId;
                            personAccounts_del.add(personAccount);
                        }
                        else
                            personAccountIds_task.add(personAccountId);
                    }
                }
                system.debug('*** to be deleted personAccounts ' + personAccounts_del + ': size :' + personAccounts_del.size() );
                system.debug('*** personAccountIds_task :' + personAccountIds_task);
                for(String personAccountId : personAccountIds_task){
                    system.debug('*** Task personAccountId :' + personAccountId);
                    Task tsk = new Task();
                    tsk.WhatId = personAccountId;
                    tsk.Subject = 'To be Deleted';
                    tsk.description = 'Atempt to delete person account failed due to subscriptions on the related zAccounts( '+ personZAccIds.get(personAccountId) +')';
                    personAccounts_task.add(tsk);    
                }
                insert personAccounts_task;
                system.debug('*** personAccounts_task : ' + personAccounts_task);
                
                if(personAccounts_del.size() > 0)
                    delete personAccounts_del;
            }
        }
    }
    
    public Class CustomException extends Exception {}            

}