/***********************************************************************************************
*       Class Name      : FoxRoach_BatchDeactivateSubscriptions
*       Date            : 10/25/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Apex Class is used to deactivate the SF Subscriptions that are not active in FoxRoach.
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/25/2021                 Bala Krishna                  Initial Version  
************************************************************************************************/
public class FoxRoach_BatchDeactivateSubscriptions implements Database.Batchable<sObject> 
{
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string query = 'SELECT Id, Name, FoxRoachID__c, Status__c, Nickname__c, Private_Email__c, Contact__c, Contact_Type__c, Status_Change_Reason__c '+
            ' FROM Subscriptions__c WHERE FoxRoachID__c != null AND Status__c = \'Active\' ';
        system.debug('query---'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Subscriptions__c> scopeSubs)
    {
        list<string> foxRoachIdList = new list<string>();
        map<string,FoxRoach_Account__c> foxIdAccountMap = new map<string, FoxRoach_Account__c>();
        list<Subscriptions__c> inactiveSubscriptions = new list<Subscriptions__c>();
        
        for(Subscriptions__c sub : scopeSubs)
        {
            if(!string.isBlank(sub.FoxRoachID__c))
            {
                foxRoachIdList.add(sub.FoxRoachID__c);
            }
        }
        if(!foxRoachIdList.isEmpty())
        {
            for(FoxRoach_Account__c foxRacc : [SELECT Id, FoxRoachID__c FROM FoxRoach_Account__c WHERE FoxRoachID__c IN :foxRoachIdList])
            {
                foxIdAccountMap.put(foxRacc.FoxRoachID__c, foxRacc);
            }
        }
        for(Subscriptions__c sub : scopeSubs)
        {
            if(!string.isBlank(sub.FoxRoachID__c) && !foxIdAccountMap.containsKey(sub.FoxRoachID__c))
            {
                sub.Status__c = 'Inactive';
                sub.Status_Change_Reason__c = 'Terminated';
                inactiveSubscriptions.add(sub);
            }
        }
        system.debug('inactiveSubscriptions--'+inactiveSubscriptions);
        if(!inactiveSubscriptions.isEmpty())
        {
            update inactiveSubscriptions;
        }
    }    
    public void finish(Database.BatchableContext bc)
    {
        Database.executeBatch(new FoxRoach_BatchCreateSubscriptions(), 10);
    }
}