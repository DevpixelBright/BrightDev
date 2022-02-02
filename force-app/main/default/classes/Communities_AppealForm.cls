public without Sharing class Communities_AppealForm {
    
    @AuraEnabled
    public static Compliance_Fine__c getDetails(String violationId){        
        List<Compliance_Fine__c> complianceFine = [Select  Id, Name, Date_of_Fine__c, Fine_Amount__c, 
                                                   Subscription__c, Subscription__r.name,Broker_Of_Record__c,Agent_Name__r.Name,
                                                   Full_Address__c, Agent_Name__c,Subscription_ID__c,Subscription__r.Related_Location_Broker_Office__r.Account_Name__c,
                                                   Subscription__r.Related_Location_Broker_Office__c,Subscription__r.Contact__c,Subscription__r.Related_Location_Broker_Office__r.Name,
                                                   MLS_Number__c,Violation__c, Violation_Number_Formatted__c,Subscription__r.City__c, Subscription__r.State__c, 
                                                   Violation_Customer__c,Violation_Type_ID__c, Subscription__r.Primary_Phone__c, Subscription__r.Private_Email__c                                                                
                                                   From Compliance_Fine__c	 
                                                   Where Name =:violationId ];        	
        if(!complianceFine.isEmpty()){
            return complianceFine[0];    
        }
        return null; 
        
    }
    
    @AuraEnabled
    public static String saveAppealCase(Compliance_Fine__c fine, String reason){
        try{
            List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Appeals'];
            
            Case oCase = new Case();
            oCase.OwnerId = queueIds[0].Id;
            oCase.Subject = 'Appeals Form';
            oCase.Origin = 'Fine Appeal Form';
            oCase.Status = 'Not Started';
            oCase.MLS__c = 'BRIGHT';
            oCase.Reason_for_Appeal__c = reason;
            oCase.MLS_Number__c = fine.MLS_Number__c;
            oCase.PropertyAddress__c  = fine.Full_Address__c;
            oCase.Subscription_ID__c = fine.Subscription__c;
            oCase.ContactId = fine.Subscription__r.Contact__c;
            oCase.AccountId = fine.Subscription__r.Related_Location_Broker_Office__c;
            oCase.Phone_Number__c = fine.Subscription__r.Primary_Phone__c;
            oCase.Private_Email__c = fine.Subscription__r.Private_Email__c;
            oCase.Type_of_Violation__c = fine.Violation__c;
            oCase.Violation_Number__c = fine.Name;
            Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Compliance Appeals Case').getRecordTypeId();
            oCase.recordTypeId = recordTypeId;
            insert oCase; 
            
            List <Subscriptions__c> Subs = [SELECT Id,Name from Subscriptions__c WHERE Id =: oCase.Subscription_ID__c];
            string violationNumber = oCase.Violation_Number__c.replaceAll('-.*','');
            List <Compliance_Fine__c> compFine = [SELECT Id,Status__c,Notification_Type__c,Subscription__c,Compliance_Violation__c,MLS_Number__c  
                                                  FROM Compliance_Fine__c 
                                                  WHERE Subscription__c IN: Subs 
                                                  AND Status__c = 'Pending'
                                                  AND (Notification_Type__c = 'Fine Notice' 
                                                       OR Notification_Type__c = 'Subsequent Fine Notice'
                                                       OR Notification_Type__c = 'Immediate Fine Notice'
                                                       OR Notification_Type__c = 'Immediate Fine Notice (Agent Violation)'
                                                       OR Notification_Type__c = 'Fine Notice (Agent Violation)'
                                                      )
                                                 AND  Compliance_Violation__r.Name =: violationNumber];
            List<Compliance_Fine__c> lFine = new List<Compliance_Fine__c>(); 
            for(Compliance_Fine__c compFines : compFine){
                    compFines.Status__c = 'Under Appeal';
                    lFine.add(compFines);
            }
            if(lFine.size() > 0){
                update lFine;
            }
            
            return oCase.Id;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getStackTraceString());
        }
        
        
    }
    
    @AuraEnabled
    public static String attachFile2(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
        Attachment att = new Attachment(
            
            Body = EncodingUtil.Base64Decode(base64BlobValue),
            Name = fileName,
            ContentType = contentType
        );
        system.debug(att.Body);
        att.ParentId = parentId;
        insert att;
        return att.Id;
    }
}