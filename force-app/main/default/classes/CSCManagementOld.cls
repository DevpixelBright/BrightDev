public class CSCManagementOld{
    @future
    public Static void updateOwner(List<String> accountIds){
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        User u = [SELECT Id, Name FROM User WHERE Name = 'Admin User'];     
        
        for(Account account : [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]){
            String accountId = account.Id;
            List<AccountShare> accountShares = new List<AccountShare>();
            accountShares = [SELECT AccountId,Id,RowCause,UserOrGroupId, UserOrGroup.Name 
                             FROM AccountShare 
                             WHERE RowCause IN ('Territory','TerritoryManual')
                             AND   AccountId = :accountId
                            ];
            Boolean isOwnerChanged = false;
            String ownerId = u.Id;
            if(accountShares.size() > 0){
                AccountShare accShare = accountShares[0];
                UserTerritory2Association users;
                try{
                    system.debug('*** accShare: ' + accShare);
                    Group grp = [Select Id, RelatedId from Group where Type = 'Territory' and Id = :accShare.UserOrGroupId];
                    system.debug('*** group: ' + grp.RelatedId);  
                    Territory2 childTerritory = [select id, name, ParentTerritory2Id from Territory2 where Id = :grp.RelatedId];
                    Territory2 parentTerritory = [select id, name, ParentTerritory2Id from Territory2 where Id = :childTerritory.ParentTerritory2Id]; 
                    system.debug('*** childTerritory: ' + childTerritory.Name);
                    system.debug('*** parentTerritory : ' + parentTerritory.Name);
                    users = [SELECT Id, UserId, User.Name FROM UserTerritory2Association WHERE Territory2Id = :parentTerritory.Id];
                    system.debug('*** UserTerritory2Association: ' + users.User.name);
                    
                    isOwnerChanged = true;
                }
                catch(Exception e){
                    isOwnerChanged = false;                    
                } 
                
                if(isOwnerChanged)
                    ownerId = users.UserId;                    
                
                account.OwnerId = ownerId;               
                for(Contact con : [SELECT Id, OwnerId FROM Contact WHERE AccountId = :accountId]){
                    con.OwnerId = ownerId;
                    system.debug('*** Contact: ' + con);
                    contacts.add(con);    
                }                
                
                for(Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE AccountId = :accountId]){
                    opp.OwnerId = ownerId;
                    system.debug('*** Opportunity: ' + opp);
                    opportunities.add(opp);    
                } 
                
                accounts.add(account);                                  
            }
            else{
                account.OwnerId = ownerId;               
                for(Contact con : [SELECT Id, OwnerId FROM Contact WHERE AccountId = :accountId]){
                    con.OwnerId = ownerId;
                    system.debug('*** Contact: ' + con);
                    contacts.add(con);    
                }                
                
                for(Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE AccountId = :accountId]){
                    opp.OwnerId = ownerId;
                    system.debug('*** Opportunity: ' + opp);
                    opportunities.add(opp);    
                } 
                
                accounts.add(account); 
            }            
        }
        
        update accounts;
        update contacts;
        update opportunities;
    }
}