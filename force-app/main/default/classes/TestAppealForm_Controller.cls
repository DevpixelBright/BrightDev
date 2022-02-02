public class TestAppealForm_Controller {          
    
    @AuraEnabled
    public static List<Compliance_Fine__c> formController() {                
                        
        String FineId = '4557765';
        system.debug('fineId:-' + FineId);
                    	            
       /*fineId = ApexPages.currentPage().getParameters */
            
            List<SObject> complianceFine = [Select  Id, Name, Date_of_Fine__c, Fine_Amount__c, 
                                                       Subscription__c,Broker_Of_Record__c,
                                                       Full_Address__c, Agent_Name__c,Subscription_ID__c,                                                       		  
                                                       MLS_Number__c,Violation__c,
                                                       Violation_Customer__c,Violation_Type_ID__c                                                              
                                                       From Compliance_Fine__c	 
                                                       Where Subscription_ID__c =: FineId ];        	
        	//system.debug('object--' + complianceFine);        	
        	return complianceFine;
    }
    
    @AuraEnabled
    public static void submitAppealForm() {
        try {
            List<QueueSobject> queueIds = [SELECT Id, QueueId
                                           FROM QueueSobject
                                           WHERE SobjectType = 'Case'
                                           AND Queue.DeveloperName = 'Appeals'
                                          ];
            Case newcase = new Case();
            newcase.OwnerId = queueIds[0].QueueId;
            newcase.Origin = 'Fine Appeal Form';
            newcase.Status = 'Not Started';              
                        
            //insert newcase;
        }
        catch(Exception e) {
            
        }
    }
        
}