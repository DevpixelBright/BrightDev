//Swapna
public with sharing class EmailAsyncProcess {
    private static Map<String,Id> templateIdMap;
    private static Map<String,EmailTemplate> templateIdBodyMap;
    private static Map<string, list<Relationship__c>> bORRelationsMap = new Map<string, list<Relationship__c>>();
    private static Map<string, list<Relationship__c>> aSRelationsMap = new Map<string, list<Relationship__c>>();
    static Map<Id,set<Id>> brokerOfficesMap = new Map<Id, set<Id>>();
    private static String BOREmailId;
    private static Set<String> ASEmailIds;
    private static Map<String, String> mASEmailIds;
    private static set<String> ASFirstNames;
    private static String brokerOfficeCode;
    private static String BORName = '';
    private static Contact BORContact;
    private static Contact ASContact;
    private static String ASTemplateId;
    private static String BORTemplateId;
	    
	@future
    public Static void createSignleEmails(List<Id> teamIds, list<Id> brokerOffCodeList){
        fetchRelations(brokerOffCodeList);
        
        system.debug('teamIds==>'+teamIds);
        List<Email_Service__c> esList= new List<Email_Service__c>();
        for(Teams__c team:[SELECT Id,Team_Request_ID__c,Disband_Date__c,Disbanded_By_Name__c, Team_Lead__r.Name, Team_Name__c,Office_ID__c, Team_Option__c FROM Teams__c WHERE Id IN :teamIds]){
            brokerOfficeCode = team.Office_ID__c;
            findASEmailIds();
        	findBOREmailId();
        	setTemplateIds();
        	findTemplateIds('Requested');
            Email_Service__c es= new Email_Service__c();
            system.debug('teamIds==>'+team.Id);
        	es.what_Id__c=team.Id;
            if(team.Team_Lead__r.Name!=null)
            	es.Team_Lead_Name__c=team.Team_Lead__r.Name;
            if(team.Team_Name__c!=null)
            	es.Team_Name__c=team.Team_Name__c;
            if(team.Disband_Date__c!=null)
            	es.Disband_Date__c=team.Disband_Date__c;
            if(team.Disbanded_By_Name__c!=null)
            	es.Disband_By_Name__c=team.Disbanded_By_Name__c;
            es.Object_API_Name__c='Teams__c';
            if(BOREmailId!=null)
                es.To_address__c=BOREmailId;
            es.Team_Option__c=team.Team_Option__c;
            if(ASEmailIds != null && ASEmailIds.size() > 0){
                es.To_address__c=BOREmailId;
            }
            if(BORTemplateId!=null){
                es.TemplateId__c=BORTemplateId;
            }
            if(ASTemplateId!=null){
                es.TemplateId__c=ASTemplateId;
            }
            if(BORName!=null){
              es.BORName__c=BORName;  
            }
            
            system.debug('es==>'+es);
        	esList.add(es);  
        }
        system.debug('esList==>'+esList);
       Database.insert(esList);
 
        
    }
        public static void fetchRelations(list<Id> brokerOfficeIdList){
        system.debug('fetchRelations---');
        system.debug('brokerOfficeIdList==>'+brokerOfficeIdList);
        if(brokerOfficeIdList != null && brokerOfficeIdList.size()>0){
            
            
            List<Account> relatedAccounts = new List<Account>();
            brokerOfficesMap = new Map<Id, set<Id>>();
            relatedAccounts = [SELECT Id, Name, ParentId
                               FROM   Account
                               WHERE  (ParentId IN :brokerOfficeIdList OR Id IN :brokerOfficeIdList) AND Status__c = 'Active' 
                              ];
            
            List<String> officeIds = new List<String>();      
            system.debug('relatedAccounts==>'+relatedAccounts);
            for(Account a : relatedAccounts)
            {
                if(!brokerOfficesMap.containsKey(a.Id)){
                    brokerOfficesMap.put(a.Id, new set<Id>{a.Id});
                }
                brokerOfficesMap.get(a.Id).add(a.Id);
                if(a.ParentId != null){
                    brokerOfficesMap.get(a.Id).add(a.ParentId);
                    officeIds.add(a.ParentId);
                }
                officeIds.add(a.Id);
            }
            relatedAccounts = new List<Account>();
            relatedAccounts = [SELECT Id, Name, ParentId
                               FROM   Account
                               WHERE  (ParentId IN :officeIds OR Id IN :officeIds) AND Status__c = 'Active'
                              ];
            system.debug('relatedAccounts + officeIds==>'+relatedAccounts);
            for(Account a : relatedAccounts){
                if(!brokerOfficesMap.containsKey(a.Id)){
                    brokerOfficesMap.put(a.Id, new set<Id>{a.Id});
                }
                brokerOfficesMap.get(a.Id).add(a.Id);
                if(a.ParentId != null){
                    brokerOfficesMap.get(a.Id).add(a.ParentId);
                    officeIds.add(a.ParentId);
                }
                officeIds.add(a.Id);                
            }
            system.debug('****brokerOfficesMap'+brokerOfficesMap);
            List<Relationship__c> relationships = [SELECT Id,Name,Relationship_Type__c, Relationship_End_Date__c, Subscription__r.Contact__c,Subscription__r.Contact__r.FirstName, 
                                                   Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c,Broker_Office__c, 
                                                   Contact__r.BRIGHT_email_preferences_AGENT_TRANSFER__c, Contact__r.BRIGHT_email_preferences_APPLICATION__c
                                                   FROM   Relationship__c 
                                                   WHERE  Broker_Office__c IN :officeIds
                                                   AND    Relationship_Type__c = 'Broker Of Record'
                                                   AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                                  ];
            system.debug('Relationship__c==>'+relationships);
            //BOR Email
            for(Relationship__c relationship : relationships){
                if(brokerOfficesMap.containskey(relationship.Broker_Office__c)){
                    for(Id brokerOffId : brokerOfficesMap.get(relationship.Broker_Office__c)){
                        if(!bORRelationsMap.containskey(brokerOffId)){
                            bORRelationsMap.put(brokerOffId, new list<Relationship__c>());
                        }
                        bORRelationsMap.get(brokerOffId).add(relationship);
                    }
                }
            }
            system.debug('bORRelationsMap==>'+bORRelationsMap);
            //AS Email
            for(Relationship__c relationship : 
                [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, Subscription__r.Contact__r.FirstName, Subscription__r.Contact__r.Name,
                 Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c, Broker_Office__c 
                 FROM   Relationship__c 
                 WHERE  Broker_Office__c IN :brokerOfficeIdList
                 AND    Relationship_Type__c  = 'Authorized Signer'
                 AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )])
            {
                if(!aSRelationsMap.containsKey(relationship.Broker_Office__c)){
                    aSRelationsMap.put(relationship.Broker_Office__c, new list<Relationship__c>());
                }
                aSRelationsMap.get(relationship.Broker_Office__c).add(relationship);
            }
        }
            system.debug('aSRelationsMap==>'+aSRelationsMap);
    }
    
        private static void findASEmailIds(){
        system.debug('***findASEmailIds==>'+brokerOfficeCode);
        ASEmailIds = new Set<String>();
        ASFirstNames = new Set<String>();
        mASEmailIds = new Map<String, String>();
        if(aSRelationsMap.containskey(brokerOfficeCode)){
            for(Relationship__c relationship : aSRelationsMap.get(brokerOfficeCode)){
                if(!relationship.Subscription__r.ApplicationNotificationOptOut__c){
                    ASEmailIds.add(relationship.Subscription__r.Private_Email__c);                        
                    mASEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__r.Contact__r.Name);
                    if(String.isNotBlank(relationship.Subscription__r.Contact__r.FirstName)){
                        ASFirstNames.add(relationship.Subscription__r.Contact__r.FirstName);
                    }
                    ASContact = new Contact(Id=relationship.Subscription__r.Contact__c);
                }
            }
        }
        system.debug('***ASEmailIds: ' + ASEmailIds);
    }
    
    private static void findBOREmailId(){      
        system.debug('***findBOREmailId');
        List<Relationship__c> relationships = new List<Relationship__c>(); 
        if(brokerOfficesMap.containsKey(brokerOfficeCode)){
            for(Id officeId : brokerOfficesMap.get(brokerOfficeCode)){
                if(bORRelationsMap.containskey(officeId)){
                    relationships.addAll(bORRelationsMap.get(officeId));
                }
            }
        }
        //List<Relationship__c> relationships = bORRelationsMap.get(brokerOfficeCode);        
        if(relationships.size() > 0){
            BOREmailId = relationships[0].Subscription__r.Private_Email__c;   
            BORContact = new Contact(id=relationships[0].Subscription__r.Contact__c);
            BORName = relationships[0].Subscription__r.Contact__r.FirstName;
        }
        system.debug('**** BOREmailId: ' +  BOREmailId);
    }
    
    private static void setTemplateIds(){
        system.debug('***setTemplateIds');
        templateIdMap = new Map<String,String>();
        templateIdBodyMap = new Map<String, EmailTemplate>();
        List<String> templateNames = new List<String>{
            'Team_Lead_submit_request_sent_to_AS',
                'Team_Lead_submit_request_sent_to_BOR',
                'Email_to_AS_when_team_is_disbanded',
                'Email_to_BOR_when_team_is_disbanded',
                'Email_to_BOR_when_team_is_disbanded_by_BOR_AS',
                'Email_to_AS_when_team_is_disbanded_by_BOR_AS'
                };
                    for(EmailTemplate et : [SELECT Id, DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName IN :templateNames])
                {
                    templateIdMap.put(et.DeveloperName, et.Id);
                    templateIdBodyMap.put(et.Id, et);
                }
        system.debug('***templateNames'+templateNames);
    }
    
    private static void findTemplateIds(String status){
        if(status == 'Requested'){
            BORTemplateId = templateIdMap.get('Team_Lead_submit_request_sent_to_BOR');
            ASTemplateId = templateIdMap.get('Team_Lead_submit_request_sent_to_AS');
        } 
        if(status == 'System Disband'){
            BORTemplateId = templateIdMap.get('Email_to_BOR_when_team_is_disbanded');
            ASTemplateId = templateIdMap.get('Email_to_AS_when_team_is_disbanded');
        }
        else if(status == 'Broker Disband'){
            BORTemplateId = templateIdMap.get('Email_to_BOR_when_team_is_disbanded_by_BOR_AS');
            ASTemplateId = templateIdMap.get('Email_to_AS_when_team_is_disbanded_by_BOR_AS');
        }
    }
    
    
}