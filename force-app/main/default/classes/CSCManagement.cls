public class CSCManagement {
    @future
    public Static void updateOwner(List<String> accountIds){        
        
        List<AccountShare> accountShares = new List<AccountShare>();
        
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Account> accounts = new List<Account>();
        Map<Id,AccountShare> mapAccountShare = new Map<Id,AccountShare>();
        Map<Id,List<Contact>> mapContacts = new Map<Id,List<Contact>>();
        Map<Id,List<Opportunity>> mapOpportunities = new Map<Id,List<Opportunity>>();
        Map<Id,Id> mapGroupAccountShare = new Map<Id,Id>();
        Map<Id,Id> mapGroupChildTerr = new Map<Id,Id>();
        Map<Id,Id> mapChildParent = new Map<Id,Id>();
        Map<Id,Id> mapParentTerr = new Map<Id,Id>();
        Map<Id,Id> mapTerritoryUser = new Map<Id,Id>();
        List<String> listAccountShareGroupIDs = new List<String>();
        List<String> listGrpRelatedIDs = new List<String>();
        List<String> listparentIDs = new List<String>();
        List<String> listchildparentIDs = new List<String>();
        List<String> activeBusinessAccountIds = new List<String>();
        
        User u = [SELECT Id, Name FROM User WHERE Name = 'Admin User'];
        List<RecordType> businessRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Business Account']; 
        
        for(Account a : [SELECT Id,Name 
                         FROM   Account 
                         WHERE  Id IN :accountIds 
                         AND    Status__c = 'Active' 
                         AND    RecordTypeId = :businessRecordType[0].Id]){
            activeBusinessAccountIds.add(a.Id);
        }
        
        accountIds = new List<String>();
        if(activeBusinessAccountIds.size() > 0)
            accountIds.addAll(activeBusinessAccountIds);         
        
        if(accountIds != null && accountIds.size() > 0){            
                       
            List<Contact> listcontacts =  [SELECT Id, OwnerId,AccountId FROM Contact WHERE AccountId IN : accountIds] ;
            
            for(Contact con : listcontacts ){
                system.debug('*****con **'+con);
                List<Contact> lstcontacts = new List<Contact>();
                if(mapContacts.containsKey(con.AccountID)){
                    lstcontacts.addAll(mapContacts.get(con.AccountID));
                    lstcontacts.add(con);
                    mapContacts.put(con.AccountID,lstcontacts);
                }else{
                    lstcontacts.add(con);
                    mapContacts.put(con.AccountID,lstcontacts);
                }
            }
            
            List<Opportunity> listopps = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE AccountId IN : accountIds] ;
            for(Opportunity opp : listopps ){
                system.debug('*****opp '+opp);
                List<Opportunity> lstOpportunity = new List<Opportunity>();
                if(mapOpportunities.containsKey(opp.AccountID)){
                    lstOpportunity.addAll(mapOpportunities.get(opp.AccountID));
                    lstOpportunity.add(opp);
                    mapOpportunities.put(opp.AccountID,lstOpportunity);
                }else{
                    lstOpportunity.add(opp);
                    mapOpportunities.put(opp.AccountID,lstOpportunity);
                }
                
            }
            
            accountShares = [SELECT AccountId,Id,RowCause,UserOrGroupId, UserOrGroup.Name 
                             FROM AccountShare 
                             WHERE RowCause IN ('Territory')
                             AND   AccountId  IN :accountIds
                            ];
            for(AccountShare accs : accountShares){
                mapAccountShare.put(accs.AccountId, accs);
                mapGroupAccountShare.put(accs.ID, accs.UserOrGroupId);
                listAccountShareGroupIDs.add(accs.UserOrGroupId);              
            }
            
            if(listAccountShareGroupIDs != null && listAccountShareGroupIDs.size() > 0){
                List<Group> listgroup = [Select Id, RelatedId from Group where Type = 'Territory' and Id IN :listAccountShareGroupIDs];
                
                for(Group grp : listgroup){
                    mapGroupChildTerr.put(grp.ID,grp.RelatedId);
                    listGrpRelatedIDs.add(grp.RelatedId);
                }
            }
            
            if(listGrpRelatedIDs != null && listGrpRelatedIDs.size() > 0){
                
                List<Territory2> childTerritory = [select id, name, ParentTerritory2Id from Territory2 where Id IN :listGrpRelatedIDs];
                for(Territory2 child : childTerritory){
                    mapChildParent.put(child.ID,child.ParentTerritory2Id);
                    listchildparentIDs.add(child.ParentTerritory2Id);
                }
                system.debug('****** listchildparentIDs'+listchildparentIDs);
            }
            
            
            if(listchildparentIDs != null && listchildparentIDs.size() > 0){
                
                List<Territory2> parentTerritory = [select id, name, ParentTerritory2Id from Territory2 where Id IN :listchildparentIDs];
                for(Territory2 parent : parentTerritory){
                    mapParentTerr.put(parent.ID,parent.Id);
                    listparentIDs.add(parent.Id);
                }
                system.debug('****** listparentIDs'+listparentIDs);
            }
            
            if(listparentIDs != null && listparentIDs.size()> 0){
                
                List<UserTerritory2Association> users = [SELECT Id, UserId, User.Name,Territory2Id FROM UserTerritory2Association WHERE Territory2Id IN : listparentIDs];
                for(UserTerritory2Association terruser : users){
                    mapTerritoryUser.put(terruser.Territory2Id, terruser.UserId);
                }
            }
            
        }
        
        for(Account account : [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]){
            Boolean isOwnerChanged = false;
            String ownerId = u.Id;
            String accountId = account.Id;
            String currentuser;
            
            
            if(mapAccountShare.containsKey(accountId)){
                AccountShare accShares = mapAccountShare.get(accountId);
                
                try{ 
                    system.debug('*** accShare: ' + accShares);
                    ID currentusergroupid = mapGroupAccountShare.get(accShares.ID);  
                    
                    ID currentgrouprelatedId = mapGroupChildTerr.get(currentusergroupid);
                    system.debug('*** currentgrouprelatedId: ' + currentgrouprelatedId);  
                    
                    
                    ID currentchild2ParentID = mapChildParent.get(currentgrouprelatedId);
                    system.debug('*** currentchild2ParentID: ' + currentchild2ParentID);   
                    
                    
                    ID currentparentID = mapParentTerr.get(currentchild2ParentID);
                    system.debug('*** currentparentID: ' + currentparentID); 
                    
                    system.debug('***** mapTerritoryUser '+mapTerritoryUser);
                    currentuser = mapTerritoryUser.get(currentparentID);
                    system.debug('*** currentuser: ' + currentuser);
                    
                    if(currentuser != null)
                        isOwnerChanged = true;
                }
                catch(Exception e){
                    system.debug('******Exception is'+e);
                    isOwnerChanged = false;                    
                } 
                
                if(isOwnerChanged)
                    ownerId = currentuser;                    
                
            }
            
            if(account.OwnerId != ownerId){
                account.OwnerId = ownerId;   
                
                if(mapContacts!=null && mapContacts.containsKey(accountId)){
                    List<Contact> contactList = mapContacts.get(accountId);
                    for(Contact con : contactList ){
                        if(con != null){
                            con.OwnerId = ownerId;
                            system.debug('*** Contact: ' + con);
                            contacts.add(con); 
                        }
                    }
                }
                
                if(mapOpportunities != null && mapOpportunities.containsKey(accountId)){
                    List<Opportunity> oppList = mapOpportunities.get(accountId);
                    for(Opportunity opp : oppList){
                        if(opp != null){
                            opp.OwnerId = ownerId;
                            system.debug('*** Opportunity: ' + opp);
                            opportunities.add(opp);
                        }
                    }
                }
                
                accounts.add(account);  
            }
        }
        system.debug('Accounts ***'+accounts);
        if(accounts != null && accounts.size()>0)
            Database.update(accounts, false);
        if(contacts != null && contacts.size()>0) 
            Database.update(contacts, false);
        if(opportunities != null && opportunities.size()>0)
            Database.update(opportunities, false);
        
    }
}