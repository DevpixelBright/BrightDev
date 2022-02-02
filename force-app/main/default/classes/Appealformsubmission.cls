public class Appealformsubmission {
    
    @AuraEnabled
    public static void submitAppealForm() {
    List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Appeals'];
            
            Case oCase = new Case();
            oCase.OwnerId = queueIds[0].Id;
            oCase.Status = 'Not Started';
            oCase.MLS__c = 'BRIGHT';
            Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Compliance Appeals Case').getRecordTypeId();
            oCase.recordTypeId = recordTypeId;
            system.debug('****oCase'+oCase);
            
            insert oCase;
}
}