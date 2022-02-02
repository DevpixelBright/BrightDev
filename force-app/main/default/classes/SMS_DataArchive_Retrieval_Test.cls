@isTest
public class SMS_DataArchive_Retrieval_Test{
    public static testMethod void testOne(){
        SMS_DynamoDB_Config__c dbConfig = new SMS_DynamoDB_Config__c();
        dbConfig.Name = 'Case';
        dbConfig.Data_Type__c = 'S';
        dbConfig.Hash_Key__c = 'Hash_Key__c';
        dbConfig.Secondary_Index__c = 'Secondary_Index__c';
        dbConfig.Table_Name__c = 'Table_Name__c';
        
        insert dbConfig;
        
        SMS_DynamoDB_Config__c dbConfig1 = new SMS_DynamoDB_Config__c();
        dbConfig1.Name = 'Task';
        dbConfig1.Data_Type__c = 'S';
        dbConfig1.Hash_Key__c = 'Hash_Key__c';
        dbConfig1.Secondary_Index__c = 'Secondary_Index__c';
        dbConfig1.Table_Name__c = 'Table_Name__c';
        
        insert dbConfig1;
        
        SMS_DynamoDB__c settings = new SMS_DynamoDB__c();
        settings.Name = 'Default';
        settings.Access_Key__c = 'AWSAccessKeyId';
        settings.Secret_Access_Key__c = 'AWSAccessKeySecret';
        settings.Region__c = 'AWSRegion';
        
        insert settings;
        
        PageReference pageRef = Page.SMS_DataArchive_Retrieval;
        pageRef.getParameters().put('id', '125635');
        Test.setCurrentPage(pageRef);
        
        SMS_DataArchive_Retrieval_Controller controller = new SMS_DataArchive_Retrieval_Controller();
        controller.fileName = 'Cases';
        controller.createCSV();
    }
}