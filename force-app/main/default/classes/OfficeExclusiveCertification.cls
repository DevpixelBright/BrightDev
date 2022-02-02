public without sharing class OfficeExclusiveCertification {
    @AuraEnabled
    public static List<officeExclusiveWrapper> getDataMethod(string subId)
    {
        system.debug('subId---'+subId);
        List<Relationship__c> relationships = new List<Relationship__c>();
        relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId, Broker_Office__r.Name,
                         Subscription__r.Name, Subscription__r.Contact__r.Name, Subscription__r.Contact__r.Id
                         FROM    Relationship__c
                         WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                         AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                         AND     Subscription_ID__c = :subId 
                        ];
        
        List<String> parentIds = new List<String>();
        List<String> asOffices = new List<String>();
        List<String> omOffices = new List<String>();
        List<String> officeIds =new List<String>();
        Boolean isBOR = false;
        String relationshipType = '';
        String officeId = '';
        
        for(Relationship__c relationship : relationships){
            system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
            system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
            
            if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                parentIds.add(relationship.Broker_Office__r.ParentId);            
            
            if(String.IsNotBlank(relationship.Broker_Office__c))
                parentIds.add(relationship.Broker_Office__c);
            
            if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                isBOR = true;
                
                relationshipType = relationship.Relationship_Type__c;
                officeId = relationship.Broker_Office__c;  
                
            } 
            else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                asOffices.add(relationship.Broker_Office__c);
            }
            else if(relationship.Relationship_Type__c == 'Office Manager'){
                omOffices.add(relationship.Broker_Office__c);
            }
        }
        if(!isBOR){
            if(asOffices.size() > 0){
                officeIds = new List<String>(asOffices);
                relationshipType = 'Authorized Signer';
            }
            else if(omOffices.size() > 0){
                officeIds = new List<String>(omOffices);
                relationshipType = 'Office Manager';
            }
        }
        else{
            List<Account> relatedAccounts = new List<Account>(); 
            relatedAccounts = [SELECT Id, ParentId, Name
                               FROM   Account
                               WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' 
                              ];
            officeIds = new List<String>();
            for(Account a : relatedAccounts){
                officeIds.add(a.Id);
                if(a.ParentId != null)
                    officeIds.add(a.ParentId);
            }
            system.debug('*****officeIds*****'+officeIds.size());
            system.debug('*****officeIds*****'+officeIds);
        }
        
        //------------
        List<officeExclusiveWrapper> offExcList = new List <officeExclusiveWrapper>();
        for(Office_Exclusive__c offExc: [SELECT Id, List_Office_ID__r.Name, List_Agent_ID__r.Name, List_Agent_Name__c, Property_Address__c,
                                         City__c, State__c, ZIP__c, CreatedDate, CreatedBy.Name FROM Office_Exclusive__c
                                         WHERE List_Agent_ID__r.Related_Location_Broker_Office__c =:officeIds]) 
        {
            offExcList.add(new officeExclusiveWrapper(offExc));
        }
        return 	offExcList;	        
       // return [SELECT Id, List_Office_ID__r.Name, List_Agent_ID__r.Name, List_Agent_Name__c, Property_Address__c,
        //        City__c, State__c, ZIP__c, CreatedDate, CreatedBy.Name from Office_Exclusive__c];
    }
    
    public class officeExclusiveWrapper{
        @AuraEnabled public string officeId {get; set;} 
        @AuraEnabled public string listAgentId {get; set;} 
        @AuraEnabled public string agentName{get; set;} 
        @AuraEnabled public string propertyAddress{get; set;} 
        @AuraEnabled public string city{get; set;} 
        @AuraEnabled public string state{get; set;} 
        @AuraEnabled public string zip{get; set;} 
        @AuraEnabled public date submittedOn {get; set;} 
        @AuraEnabled public string submittedOnStr {get; set;} 
        @AuraEnabled public string submittedBy {get; set;} 
        
        public officeExclusiveWrapper(Office_Exclusive__c oe)
        {
            this.officeId = oe.List_Office_ID__r.Name;
            this.listAgentId = oe.List_Agent_ID__r.Name;
            this.agentName = oe.List_Agent_Name__c;
            this.propertyAddress = oe.Property_Address__c;
            this.city = oe.City__c;
            this.state = oe.State__c;
            this.zip = oe.ZIP__c;
            this.submittedOn = date.valueof(oe.CreatedDate);
            this.submittedBy = oe.CreatedBy.Name;
            this.submittedOnStr = date.valueof(oe.CreatedDate).format();            
        }
    }
    
}