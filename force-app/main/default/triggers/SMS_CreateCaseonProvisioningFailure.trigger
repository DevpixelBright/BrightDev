trigger SMS_CreateCaseonProvisioningFailure on SMS_Provisioned_Product__c (after update) {
    //Profile userProfile = [SELECT id,Name FROM Profile WHERE id = :UserInfo.getProfileId()];     
    
    //if(userProfile.Name == 'API') {
           
        List<Case> provisionFailureCases = new List<Case>();
        Map<String,List<Case>> provisionFailureCasesMap = new Map<String,List<Case>>();
        
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'Provisioning Failures'
                                      ];
        
        for(SMS_Provisioned_Product__c provisionProduct : trigger.new){
            if((provisionProduct.Provisioned_Status__c == 'Error Pending Provisioned' && trigger.oldMap.get(provisionProduct.Id).Provisioned_Status__c == 'Pending Provisioned')|| 
               (provisionProduct.Provisioned_Status__c == 'Error Pending Deprovisioned' && trigger.oldMap.get(provisionProduct.Id).Provisioned_Status__c == 'Pending Deprovisioned')){
                Case c = new Case();
                c.Subscription_ID__c = provisionProduct.Subscription__c;
                c.Description = provisionProduct.Status_Message__c;
                c.Product__c = provisionProduct.Product_Type__c;
                //c.Contact = provisionProduct.Contact_Name__c;
                c.OwnerId = queueIds[0].QueueId;
                c.Status = 'Not Started';
                c.Case_Reason__c = 'Defect';
                
                if(!provisionFailureCasesMap.containsKey(provisionProduct.Subscription__c))
                    provisionFailureCasesMap.put(provisionProduct.Subscription__c,new List<Case>());
                
                provisionFailureCasesMap.get(provisionProduct.Subscription__c).add(c);
                
                //provisionFailureCases.add(c);  
            }
        }
        
        if(provisionFailureCasesMap.size() > 0) {
            List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
            subscriptions = [SELECT Id,Contact__r.Id 
                             FROM   Subscriptions__c
                             WHERE  Id in :provisionFailureCasesMap.keyset()
                            ];
                            
            for(Subscriptions__c sub : subscriptions){
                for(Case c : provisionFailureCasesMap.get(sub.Id)){
                    c.ContactId = sub.Contact__r.Id ;
                    provisionFailureCases.add(c); 
                }
            }
            insert provisionFailureCases;
        }
    //}
    
   if(Trigger.isAfter && Trigger.isUpdate){
            ErrorProvisionedHandler.provProd(Trigger.New);
        }
    
}