@istest
public class SMS_DataArchive_WS_Test {

    public static testMethod void doTestOne() {
    
        /* Custom setting */
        SMS_DataArchive_Days__c daSettings = new SMS_DataArchive_Days__c();
        daSettings.Name = 'Case';
        daSettings.Archive_Days__c = 1;
        daSettings.Retry_Days__c = 2;
        daSettings.Retry_Times__c = 3;
        insert daSettings;
        
        daSettings = new SMS_DataArchive_Days__c();
        daSettings.Name = 'Task';
        daSettings.Archive_Days__c = 1;
        daSettings.Retry_Days__c = 2;
        daSettings.Retry_Times__c = 3;
        insert daSettings;      
    
        List<Case> casesList = new List<Case>();
        for (Integer i=0; i<10; i++) {
            Case c = new Case();
            c.Origin = 'MRIS Connect';
            c.Subject = 'Submission of MRIS Connect Case'; 
            casesList.add(c);      
        }     
        insert casesList;    
    
        List<Case> cList = [SELECT Id FROM Case];
        List<String> recordIds = new List<String>();
        for (Case c : cList) {
            recordIds.add(c.Id);
        }
        SMS_DataArchive_WS.dataArchive(recordIds);   
    }
    
    public static testMethod void doTestTwo() {    
    
        List<Case> casesList = new List<Case>();
        for (Integer i=0; i<10; i++) {
            Case c = new Case();
            c.Origin = 'MRIS Connect';
            c.Subject = 'Submission of MRIS Connect Case'; 
            casesList.add(c);      
        }     
        insert casesList;    
    
        List<Case> cList = [SELECT Id FROM Case];
        List<String> recordIds = new List<String>();
        for (Case c : cList) {
            recordIds.add(c.Id);
        }
        
         SMS_DataArchive_Delete deleteBatch = new SMS_DataArchive_Delete('Case', recordIds);
         Database.executeBatch(deleteBatch, 100);       
    }    

}