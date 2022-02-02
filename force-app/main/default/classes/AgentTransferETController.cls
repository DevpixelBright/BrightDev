public without sharing class AgentTransferETController {
    public ID recordId {get;set;}
    public String contacttype {get;set;}
    private List<Relationship__c> relationship { get; set; } 
    public List<Contact> FirstNames { get; set; } 
    public boolean brokerOfficeflag {get; set;}
    private List<ID> contactList { get; set; } 
    private List<Subscriptions__c> personalAssistants { get; set; } 
    private List<Contact> agentList { get; set; } 
    public List<String> officeIds {get; set;}
    public String mergeField { get; set; }
    
    
    public String getData(){
        
        String aplicationdata;
        MRIS_Application__c application=[SELECT ID,NAME,
                                         Destination_Broker_Office__c,Destination_Broker_Office__r.Name,
                                         Destination_Broker_Office__r.Account_Name__c,
                                         Destination_Broker_Office__r.City__c,
                                         Destination_Broker_Office__r.County__c,
                                         Destination_Broker_Office__r.Phone,
                                         Company_Code__c ,
                                         Company_Code__r.Name,
                                         Company_Code__r.Account_Name__c,
                                         Company_Code__r.City__c,
                                         Company_Code__r.County__c,
                                         Comments__c,
                                         Agent_Name__c,
                                         Application_Type__c
                                         FROM MRIS_Application__c
                                         WHERE ID =: recordId];
        
        if(mergeField == 'DesinationBroker'){
            aplicationdata = application.Destination_Broker_Office__r.Name+','+application.Destination_Broker_Office__r.Account_Name__c+','+
                           application.Destination_Broker_Office__r.City__c+' '+application.Destination_Broker_Office__r.County__c;
          
            
        }if(mergeField == 'OriginatingBroker'){
            aplicationdata = application.Company_Code__r.Name+','+application.Company_Code__r.Account_Name__c+','+
                           application.Company_Code__r.City__c+' '+application.Company_Code__r.County__c;
          
            
        }if(mergeField == 'DesinationBrokerPhone'){
            aplicationdata = application.Destination_Broker_Office__r.Phone;
              
        }if(mergeField == 'AgentFullName'){
            aplicationdata = application.Agent_Name__c;
            
        }
           
        return aplicationdata;
        
    }
    
    public List<Contact> getRelationship(){
        system.debug('******* Agent Trasnfer ET getRelationship()*****');
        relationship = new List<Relationship__c>();
        FirstNames = new List<Contact>();
        contactList = new List<ID>();
        personalAssistants = new List<Subscriptions__c>();
        agentList = new List<Contact>();
        
        MRIS_Application__c application=[SELECT ID,
                                         NAME,
                                         Destination_Broker_Office__c,
                                         Company_Code__c ,
                                         Comments__c,
                                         Agent_Subscription_ID__r.contact__c,
                                         Application_Type__c
                                         FROM MRIS_Application__c
                                         WHERE ID =: recordId];
        
        if(contacttype == 'Broker of Record'){
            findBORDetails(application);
        } else if(contacttype == 'Authorized Signer') {
            findASDetails(application);
        }  else if(contacttype == 'Office Manager'){
            findOMDetails(application);
        } else if(contacttype == 'PA'){
            findPADetails(application);
        }else if(contacttype == 'previousbrokers'){
            findAllPreviousBrokersDetails(application);
        }else if(contacttype == 'Agent'){
            findAgentDetails(application);
        }else if(contacttype == 'AllBrokers'){
            findAllDetails(application);
        }
        
        if(contacttype == 'Agent'){
            FirstNames.addAll(agentList);
        }else{
            
            if(contacttype == 'PA'){ 
                for(Subscriptions__c assistants: personalAssistants){
                    contactList.add(assistants.Contact__c);
                }
            }else {
                for(Relationship__c r : relationship ){
                    contactList.add(r.Subscription__r.Contact__c);
                }
            }
            if(contactList.size()>0){
                FirstNames = [SELECT ID,NAME,FIRSTNAME from Contact where id IN : contactList];
            }
            
        }
        system.debug('***relationship' + relationship);
        system.debug('***FirstNames' + FirstNames);
        return FirstNames;
    }
    private void findBORDetails(MRIS_Application__c application){      
        system.debug('******* findBORDetails*****');
        relationship = new List<Relationship__c>();
        String brokerofficecode = (application.Application_Type__c =='Agent Transfer')? application.Destination_Broker_Office__c :application.Company_Code__c;      
        relationship = BORUtilityClass.fetchBOR(new List<String>{brokerofficecode});
       	system.debug('***relationship' + relationship);
       
    }
    
    private void findASDetails(MRIS_Application__c application){     
        //relationship = new List<Relationship__c>();  
        String brokerofficecode = (application.Application_Type__c =='Agent Transfer')? application.Destination_Broker_Office__c :application.Company_Code__c;      
        if(application.Application_Type__c =='Agent Transfer' || application.Application_Type__c =='IDX and VOW Agent Request') {
            relationship = [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, 
                            Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c
                            FROM   Relationship__c 
                            WHERE  Broker_Office__c = :brokerofficecode
                            AND    Relationship_Type__c  = 'Authorized Signer'
                            AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                            AND    Subscription__r.ApplicationNotificationOptOut__c = false];
        }
    }
    
    private void findOMDetails(MRIS_Application__c application){  
        //relationship = new List<Relationship__c>();            
        relationship = [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, 
                        Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c
                        FROM   Relationship__c 
                        WHERE  Broker_Office__c = :application.Destination_Broker_Office__c
                        AND    Relationship_Type__c  = 'Office Manager'
                        AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                        AND    Subscription__r.ApplicationNotificationOptOut__c = false
                       ];   
        system.debug('******* relationship*****'+relationship);
    }
    private void findAllDetails(MRIS_Application__c application){     
        List<Relationship__c> relationship1 = new List<Relationship__c>();
        String brokerofficecode = (application.Application_Type__c =='Agent Transfer')? application.Destination_Broker_Office__c :application.Company_Code__c;      
        relationship1 = BORUtilityClass.fetchBOR(new List<String>{brokerofficecode});
        
        List<Relationship__c> relationship2 = new List<Relationship__c>();
        relationship2 = [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, 
                        Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c
                        FROM   Relationship__c 
                        WHERE  Broker_Office__c = :brokerofficecode
                        AND    Relationship_Type__c  IN ('Authorized Signer','Office Manager')
                        AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                        AND    Subscription__r.ApplicationNotificationOptOut__c = false
                       ];  
        relationship = new List<Relationship__c>();
        for(Relationship__c rel :relationship2){
        if(rel.Id != null)   
        relationship.add(rel);
        }
        relationship.addAll(relationship1);
        system.debug('******* relationship*****'+relationship);
    }
    
    
    private void findAllPreviousBrokersDetails(MRIS_Application__c application){     
        //relationship = new List<Relationship__c>(); 
                     
        relationship = [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, 
                        Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c
                        FROM   Relationship__c 
                        WHERE  Broker_Office__c = :application.Company_Code__c
                        AND    Relationship_Type__c  IN ('Authorized Signer','Broker of Record','Office Manager')
                        AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                        AND    Subscription__r.ApplicationNotificationOptOut__c = false
                       ];    
        system.debug('******* relationship*****'+relationship);
    }
    private void findAgentDetails(MRIS_Application__c application){     
        
        agentList = [SELECT Id,
                     Name,
                     FirstName,
                     Lastname 
                     from Contact 
                     where id =: application.Agent_Subscription_ID__r.contact__c];    
        
    }
    private void findPADetails(MRIS_Application__c application){     
        
        Set<String> selectedPASet = (Set<String>) JSON.Deserialize(application.Comments__c, Set<String>.class);
        
        system.debug('selectedPASet********'+selectedPASet);
        
        //Set<Related_Agent__c> personalAssistants = new Set<Related_Agent__c>();
        personalAssistants = [SELECT Id,
                              Name,
                              Contact__c,
                              Private_email__c,
                              contact__r.FirstName,
                              contact__r.LastName
                              FROM   Subscriptions__c
                              WHERE  ID IN : selectedPASet];           
        
    }
}