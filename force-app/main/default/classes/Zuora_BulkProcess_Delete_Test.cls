@istest(SeeAllData = true)
private class Zuora_BulkProcess_Delete_Test{
    private static testMethod void doTestOne(){
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2c92c085644612a101645a0fd3214822');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        List<Zuora_Bulk_Process__c> zRecords = new List<Zuora_Bulk_Process__c>();
        
        for(Integer i = 0; i < 55; i++){
            Zuora_Bulk_Process__c zRecord = new Zuora_Bulk_Process__c();
            zRecord.Zuora_Id__c = '2c92c085644612a101645a0fd3214822';
            zRecord.Status__c = 'In Progress';
            zRecords.add(zRecord);
        }
        
        insert zRecords;
        
        String query = 'SELECT Id,Name, Zuora_Id__c, Status__c, Status_Message__c, zObject_Type__c FROM Zuora_Bulk_Process__c WHERE Status__c = \'In Progress\' LIMIT 52';
        Zuora_BulkProcess_Delete zBulkProcess =  new Zuora_BulkProcess_Delete(query, 'Amendment');
        Database.executeBatch(zBulkProcess);
    }
    
    private static testMethod void doTestTwo(){
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2c92c085644612a101645a0fd3214822');
        preDefinedValues.put('Success', 'false');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        List<Zuora_Bulk_Process__c> zRecords = new List<Zuora_Bulk_Process__c>();
        
        for(Integer i = 0; i < 55; i++){
            Zuora_Bulk_Process__c zRecord = new Zuora_Bulk_Process__c();
            zRecord.Zuora_Id__c = '2c92c085644612a101645a0fd3214822';
            zRecord.Status__c = 'In Progress';
            zRecords.add(zRecord);
        }
        
        insert zRecords;
        
        String query = 'SELECT Id,Name, Zuora_Id__c, Status__c, Status_Message__c, zObject_Type__c FROM Zuora_Bulk_Process__c WHERE Status__c = \'In Progress\' LIMIT 52';
        Zuora_BulkProcess_Delete zBulkProcess =  new Zuora_BulkProcess_Delete(query, 'Amendment');
        Database.executeBatch(zBulkProcess);
    }
}