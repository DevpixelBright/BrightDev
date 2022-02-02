/***********************************************************************************************
*       Class Name      : FoxRoach_BatchDeleteAccounts
*       Date            : 10/20/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Apex Class is used to delete all old accounts from Salesforce Stagging
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/20/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_BatchDeleteAccounts implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        string query = 'SELECT Id FROM FoxRoach_Account__c';
        system.debug('--delete--query---'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FoxRoach_Account__c> records){
        delete records;
    }    
    public void finish(Database.BatchableContext bc){
        Database.executeBatch(new FoxRoach_BatchLoadAccounts(), 1);
    }
}