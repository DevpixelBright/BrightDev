public without sharing class SFQPConnectorUtility {
    
    //Update the corresponding Salesforce record
    public static void process(Map<ID,SFQPConnector__c> newConnectorMap, Map<ID,SFQPConnector__c> oldConnectorMap,List<SFQPConnector__c> newList){
        List<Id> accountIDs = new List<Id>();
        List<Id> relationshipIDs = new List<Id>();
        List<ID> subscriptionIDs = new List<Id>();
        List<ID> subscriptionRoleIDs = new List<Id>();
        List<ID> relatedAssociationsIDs = new List<Id>();
        Map<String,SFQPConnector__c> relatedIDMap = new Map<String,SFQPConnector__c>();

            for (SFQPConnector__c s: newList){
              System.debug('s.ObjectType__c --->' + s.ObjectType__c);
            System.debug('s.relatedid__c --->' + s.relatedid__c);
            System.debug('s.MessageSent__c --->' + s.MessageSent__c);
                System.debug(JSON.serialize(s));
                if (s.ObjectType__c != null) {
                if (s.ObjectType__c.startsWith('Account')){
                    accountIDs.add(s.relatedid__c);
                } else if(s.ObjectType__c.equals('Relationship__c')){
                    relationshipIDs.add(s.relatedid__c);
                } else if(s.ObjectType__c.equals('Subscription_Role__c')){
                    subscriptionRoleIDs.add(s.relatedid__c);
                } else if(s.ObjectType__c.startsWith('Subscription')) {
                    subscriptionIDs.add(s.relatedid__c);
                } else if(s.ObjectType__c.equals('Related_Association__c')){
                    relatedAssociationsIDs.add(s.relatedid__c);
                }
            }
                
                System.debug('s.relatedid__c ---> ' + s.relatedid__c);
                System.debug('s.QPStatus__c ---> ' + s.QPStatus__c);
                relatedIDMap.put(s.relatedid__c,s);
            } 
            
            List <Account> accountList = [SELECT Id, MDS_Status__c,CS_AccountTypeRole_ID__c, 
                                                 CS_Shareholder_ID__c,OfficeKey__c, CS_CompanyTypeRole_ID__c 
                                          FROM   Account 
                                          WHERE  Id IN :accountIDs];
            
            List <Relationship__c> relationshipList = [SELECT id, MDS_Status__c,SysPrRoleKey__c
                                            from Relationship__c where id in :relationshipIDs];
            
            List <Subscriptions__c> subscriptionList = [SELECT id, MDS_Status__c
                                             from Subscriptions__c where id in :subscriptionIDs];
            
            List <Subscription_Role__c> subscriptionRoleList = [SELECT id, Role__c, Status__c, Subscription__c, 
                                                                       Subscription__r.Primary__c, Subscription__r.Contact__r.Primary_Subscription__c,
                                                                       MDS_Status__c,SysPrRoleKey__c
                                                                FROM   Subscription_Role__c 
                                                                WHERE  id IN :subscriptionRoleIDs];
                                            
            List <Related_Association__c> relatedAssocList = [SELECT id, MDS_Status__c,SysPrRoleKey__c
            from Related_Association__c where id in :relatedAssociationsIDs];
        
            for (Account a: accountList){
                
                a.MDS_Status__c = relatedIDMap.get(a.id).QPStatus__c;
                if('Success'.equals(relatedIDMap.get(a.id).QPStatus__c)) {
                    if (relatedIDMap.get(a.id).QPMessage__c == '0') 
                        continue;
                    System.debug(relatedIDMap.get(a.id).ObjectType__c+' ---> '+relatedIDMap.get(a.id).QPMessage__c);
                    if('Account'.equals(relatedIDMap.get(a.id).ObjectType__c))
                        a.OfficeKey__c = relatedIDMap.get(a.id).QPMessage__c;
                    else if('AccountType'.equals(relatedIDMap.get(a.id).ObjectType__c))
                        a.CS_AccountTypeRole_ID__c = relatedIDMap.get(a.id).QPMessage__c;
                    else if('AccountCompanyType'.equals(relatedIDMap.get(a.id).ObjectType__c))
                        a.CS_CompanyTypeRole_ID__c = relatedIDMap.get(a.id).QPMessage__c;
                    else if('AccountRole'.equals(relatedIDMap.get(a.id).ObjectType__c))
                        a.CS_Office_Role_ID__c= relatedIDMap.get(a.id).QPMessage__c;
                    else if('AccountStockholder'.equals(relatedIDMap.get(a.id).ObjectType__c))
                        a.CS_Shareholder_ID__c= relatedIDMap.get(a.id).QPMessage__c;
                }
                    
            }
            
            List<Relationship__c> updatedRelationship = new List<Relationship__c>();
            for (Relationship__c r: relationshipList){
                
                r.MDS_Status__c = relatedIDMap.get(r.id).QPStatus__c;
                if('Success'.equals(relatedIDMap.get(r.id).QPStatus__c)) {
                    if (relatedIDMap.get(r.id).QPMessage__c == '0') {
                        continue;
                    }
                    r.SysPrRoleKey__c = relatedIDMap.get(r.id).QPMessage__c;
                }
                //update r;
                    
            }
            update relationshipList;            
            update accountList; 
            
            for(Subscriptions__c s: subscriptionList){
                s.MDS_Status__c = relatedIDMap.get(s.id).QPStatus__c;
                
                if('Success'.equals(relatedIDMap.get(s.id).QPStatus__c)) {
                    if (relatedIDMap.get(s.id).QPMessage__c == '0')
                        continue;
                    if('Subscription'.equals(relatedIDMap.get(s.id).ObjectType__c))
                        s.AgentKey__c = relatedIDMap.get(s.id).QPMessage__c;
                }
            }            
            
            Map<String,Boolean> subIdStatus = new Map<String,Boolean>();
            Map<String,String> conIdSubId = new Map<String,String>();
            
            for (Subscription_Role__c sr: subscriptionRoleList){
               if (('Status Active'.equals(sr.Role__c) || 'Status Duplicate'.equals(sr.Role__C)) && 'Active'.equals(sr.Status__C)) {
                    
                    if (!sr.Subscription__r.Primary__c && 'Status Active'.equals(sr.Role__c) && 'Active'.equals(sr.Status__C)) {
                        subIdStatus.put(sr.Subscription__c,true);
                        if (sr.Subscription__r.contact__r.Primary_Subscription__c != sr.Subscription__c)
                            conIdSubId.put(sr.Subscription__r.contact__c,sr.Subscription__c);
                    }
                    if (sr.Subscription__r.Primary__c && 'Status Duplicate'.equals(sr.Role__C) && 'Active'.equals(sr.Status__C)) 
                        subIdStatus.put(sr.Subscription__c,false);                 
               }
                sr.MDS_Status__c = relatedIDMap.get(sr.id).QPStatus__c;
                if('Success'.equals(relatedIDMap.get(sr.id).QPStatus__c)) {
                   if (relatedIDMap.get(sr.id).QPMessage__c != '0') 
                         sr.SysPrRoleKey__c = relatedIDMap.get(sr.id).QPMessage__c;
                }
            }
            
            
            List<Subscriptions__c> updatedSubscriptions = new List<Subscriptions__c>();
            List<Contact> updatedContacts = new List<Contact>();
            
            for(Subscriptions__c subscription : [SELECT Id,Primary__c FROM Subscriptions__c WHERE Id IN :subIdStatus.keyset()]){
                subscription.Primary__c = subIdStatus.get(subscription.Id);                
                updatedSubscriptions.add(subscription);
            }
            system.debug('*** updatedSubscriptions: ' + updatedSubscriptions);           
            
            
            for(Contact contact : [SELECT Id,Primary_Subscription__c FROM Contact WHERE Id IN :conIdSubId.keyset()]){
                contact.Primary_Subscription__c = conIdSubId.get(contact.Id);
                updatedContacts.add(contact);
            }
            system.debug('*** updatedContacts: ' + updatedContacts);
            
            update updatedContacts;
            update updatedSubscriptions;
            
            update subscriptionRoleList;
            update subscriptionList;
            
            Integer i=-1;
            for (Related_Association__c ra : relatedAssocList){
                i++;
                ra.MDS_Status__c = relatedIDMap.get(ra.id).QPStatus__c;
                if('Success'.equals(relatedIDMap.get(ra.id).QPStatus__c)) {
                    if (relatedIDMap.get(ra.id).QPMessage__c != '0') 
                        ra.SysPrRoleKey__c = relatedIDMap.get(ra.id).QPMessage__c;                    
                }               
            }
            update relatedAssocList;
    }
}