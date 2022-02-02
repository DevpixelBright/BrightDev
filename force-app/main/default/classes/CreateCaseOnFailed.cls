public with sharing class CreateCaseOnFailed {
    
    //Update the corresponding Salesforce record
    
    public static void createCase(Account acc) {
        acc.Status__c = 'Incomplete';
        update(acc);
        List<QueueSobject> processing = getQueue();
        
        //create('Account', processing, acc);
        if(processing.size() != 0)
        {
            Case c = new Case();
            c.Account = acc;
            c.Origin = 'SalesForceErrors@MRIS.net';
            c.Subject = 'MRIS Status for Account ' + acc.name + ' is \'Failed\'.';
            c.OwnerId = processing[0].QueueId; 
            c.Description = 'Account information: ' + acc + '\n'; 
                    
            
            insert(c);
         }
    }    

    public static void createCaseForSub(Subscriptions__c sub) {
    
        sub.Status__c = 'Incomplete';
        update(sub);
        
         List<QueueSobject> processing = getQueue();
    
        if(processing.size() != 0)
        {
            Case c = new Case();
            
            c.Subscription_ID__c = sub.id;
            c.Account = [SELECT id FROM Account WHERE id =: sub.Related_Location_Broker_Office__c];
            c.Origin = 'SalesForceErrors@MRIS.net';
            c.Subject = 'MRIS Status for Subscription ' + sub.name + ' is \'Failed\'.';
            c.OwnerId = processing[0].QueueId; 
            c.Contact = [SELECT id FROM Contact WHERE id =: sub.Contact__c LIMIT 1][0];
            c.Description = 'Subscription information: ' + sub;
            insert(c);
        }
    }
    
    public static void createCaseForRel(List<Relationship__c> relationships) {
        List<QueueSobject> processing = getQueue();
        if(processing.size() != 0){
            Map<String,Account> brokerOffices = new Map<String,Account>();
            Map<String,Contact> contacts = new Map<String,Contact>();
            
            List<String> brokerOfficeIds = new List<String>();
            List<String> contactIds = new List<String>();
            List<Case> cases = new List<Case>();
            
            for(Relationship__c relationship : relationships){
                if(String.isNotBlank(relationship.Broker_Office__c))
                    brokerOfficeIds.add(relationship.Broker_Office__c);
                if(String.isNotBlank(relationship.Contact__c))
                    contactIds.add(relationship.Contact__c);                
            }
            
            if(brokerOfficeIds.size()>0)
                brokerOffices = new Map<String,Account>([SELECT Id FROM Account WHERE Id IN :brokerOfficeIds]);
            if(contactIds.size()>0)
                contacts = new Map<String,Contact>([SELECT Id FROM Contact WHERE Id IN :contactIds]);
                
            for(Relationship__c relationship : relationships){
                Case c = new Case(); 
                c.Origin = 'SalesForceErrors@MRIS.net';
                c.Subject = 'MRIS Status for Relationship ' + relationship.Name + ' is \'Failed\'.';
                c.OwnerId = processing[0].QueueId;     
                c.Description = 'Relationship information: ' + relationship;  
                
                if(String.isNotBlank(relationship.Broker_Office__c))   
                    c.Account = brokerOffices.get(relationship.Broker_Office__c);                          
                if(String.isNotBlank(relationship.Contact__c))   
                    c.Contact = contacts.get(relationship.Contact__c);
                if(String.isNotBlank(relationship.Subscription__c))   
                    c.Subscription_ID__c = relationship.Subscription__c;
                
                cases.add(c);
            }
            
            insert cases;
        }
    }
    
    public static void createCaseForSubAssc(List<Related_Association__c> subscriptionAssociations) {
        List<QueueSobject> processing = getQueue();
        if(processing.size() != 0){
            List<Case> cases = new List<Case>();
            for(Related_Association__c subscriptionAssociation : subscriptionAssociations){
                Case c = new Case();
                c.Subscription_ID__c = subscriptionAssociation.Subscription__c;
                
                if (String.isNotBlank(subscriptionAssociation.Subscription_ID__c))
                  c.AccountId = subscriptionAssociation.Broker_Code__c;
                else
                  c.AccountId = subscriptionAssociation.Association__c;
                  
                c.Origin = 'SalesForceErrors@MRIS.net';
                c.Subject = 'MRIS Status for Subscription Association ' + subscriptionAssociation.name + ' is \'Failed\'.';
                c.OwnerId = processing[0].QueueId; 
                c.Description = 'Subscription Association information: ' + subscriptionAssociation;
                cases.add(c);                
            }
            
            insert cases;
        }
    }
    
    public static List<QueueSobject> getQueue(){
        return [SELECT QueueSobject.SobjectType,QueueSobject.QueueId
                FROM   QueueSobject
                WHERE  QueueSobject.SobjectType = 'Case'
                AND    QueueSobject.Queue.Name = 'Level 3' LIMIT 1];
    }

}