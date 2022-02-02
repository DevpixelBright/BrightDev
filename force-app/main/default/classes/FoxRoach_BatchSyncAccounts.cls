/***********************************************************************************************
*       Class Name      : FoxRoach_BatchSyncAccounts
*       Date            : 11/11/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Apex Class is used to sync the FoxRoach Accounts data with salesforce (Subscription and Contacts).
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       11/11/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_BatchSyncAccounts implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    map<string, Account> FoxRoachOfficeIdMap = new map<string, Account>();
    public FoxRoach_BatchSyncAccounts()
    {
        for(Account a : [SELECT Id, Name, Status__c, FoxRoach_OfficeID__c FROM Account WHERE FoxRoach_OfficeID__c != null]){
            FoxRoachOfficeIdMap.put(a.FoxRoach_OfficeID__c, a);
        }
    }
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
         string query = 'SELECT Id, Office__c, PhoneNumber__c, Address1__c, City__c, State__c, Zip__c, Country__c, Email__c,'+ 
             ' LastName__c, FirstName__c, FoxRoachID__c, Office_Name__c, Reason__c, Subscription_Sync_Status__c,'+
             ' Subscription_Sync_Type__c, Contact_Sync_Status__c, Office__r.Office_Id__c'+
             ' FROM FoxRoach_Account__c ORDER BY Office_Name__c';
        system.debug('query---'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FoxRoach_Account__c> foxAccounts)
    {
        //Limited Public Records Only
        list<string> FoxRoachIdList = new list<string>();
        map<string,FoxRoach_Account__c> foxAccountMap = new map<string, FoxRoach_Account__c>();
        
        
        list<FoxRoach_Account__c> FoxRoachAccounts = new list<FoxRoach_Account__c>();
        map<string,Subscriptions__c> foxIdSubMap = new map<string,Subscriptions__c>();
        map<string,string> contactIdFoxIdMap = new map<string,string>();
        map<id,Subscriptions__c> updateSubMap = new map<id, Subscriptions__c>();
        map<id,Contact> updateContactMap = new map<id, Contact>();
        
        for(FoxRoach_Account__c fAcc : foxAccounts)
        {
            if(!string.isBlank(fAcc.FoxRoachID__c))
            {
                FoxRoachIdList.add(fAcc.FoxRoachID__c);
                foxAccountMap.put(fAcc.FoxRoachID__c, fAcc);
            }
        }
        if(!FoxRoachIdList.isEmpty())
        {
            for(Subscriptions__c sub : [SELECT FoxRoachID__c, Status__c, Contact_Type__c, Contact__c, Private_Email__c, 
                                        Status_Change_Reason__c, Status_Change_Fee__c, Nickname__c, Related_Location_Broker_Office__r.FoxRoach_OfficeID__c,
                                        Related_Location_Broker_Office__r.Status__c, Related_Location_Broker_Office__c  
                                        FROM Subscriptions__c WHERE FoxRoachID__c IN :foxRoachIdList])
            {
                contactIdFoxIdMap.put(sub.Contact__c, sub.FoxRoachID__c);
                foxIdSubMap.put(sub.FoxRoachID__c, sub);
            }
        }
        for(FoxRoach_Account__c foxRacc : foxAccounts)
        {
            foxRacc.Reason__c = '';
            foxRacc.Subscription_Sync_Type__c = '';
            Subscriptions__c sub = foxIdSubMap.get(foxRacc.FoxRoachID__c);
            
            if(!FoxRoachOfficeIdMap.containskey(foxRacc.Office__r.Office_Id__c)){
                foxRacc.Subscription_Sync_Type__c = 'Office Not in SF-';
                if(foxIdSubMap.containsKey(foxRacc.FoxRoachID__c)){
                    sub.Status__c = 'Inactive';
                    sub.Status_Change_Reason__c = 'Terminated';
                }
            }
            else if(FoxRoachOfficeIdMap.get(foxRacc.Office__r.Office_Id__c).Status__c == 'Inactive'){
                foxRacc.Subscription_Sync_Type__c = 'Office Inactive in SF-';
                if(foxIdSubMap.containsKey(foxRacc.FoxRoachID__c)){
                    sub.Status__c = 'Inactive';
                    sub.Status_Change_Reason__c = 'Terminated';
                    sub.Related_Location_Broker_Office__c = FoxRoachOfficeIdMap.get(foxRacc.Office__r.Office_Id__c).Id;
                }
            }
            else if(foxIdSubMap.containsKey(foxRacc.FoxRoachID__c) && foxRacc.Office__r.Office_Id__c != sub.Related_Location_Broker_Office__r.FoxRoach_OfficeID__c)
            {
                sub.Related_Location_Broker_Office__c = FoxRoachOfficeIdMap.get(foxRacc.Office__r.Office_Id__c).Id;
                foxRacc.Subscription_Sync_Type__c = 'Office Changed-';
            }
            
            if(foxIdSubMap.containsKey(foxRacc.FoxRoachID__c)){
                if(sub.Status__c != 'Active'){
                    foxRacc.Subscription_Sync_Type__c += ' Subscription '+sub.Status__c;
                }
                updateSubMap.put(sub.id, sub);
            }
               
            if(foxIdSubMap.containsKey(foxRacc.FoxRoachID__c) && 
               FoxRoachOfficeIdMap.containskey(foxRacc.Office__r.Office_Id__c) && 
               FoxRoachOfficeIdMap.get(foxRacc.Office__r.Office_Id__c).Status__c == 'Active')
            {
                if(sub.Status__c == 'Active')
                {
                    if(sub.Contact_Type__c == 'Limited Public Records Only'){
                        updateSubMap.put(sub.id, FoxRoach_Utils.copySubscriptionData(foxRacc, sub));
                        updateContactMap.put(sub.Contact__c, FoxRoach_Utils.copyContactData(foxRacc, new Contact(Id=sub.Contact__c)));
                        foxRacc.Subscription_Sync_Type__c += ' Sync Active';
                    }else if(sub.Private_Email__c == foxRacc.Email__c){
                        sub.Status__c = 'Inactive';
                        updateSubMap.put(sub.id, sub);
                        foxRacc.Subscription_Sync_Type__c = ' Sync Inactive';
                    }else{
                        foxRacc.Subscription_Sync_Type__c = ' Not limited public record & Email changed';
                        //TO DO Notify Bright (When Agent in Reliance and SF is Active Not in Limited Office Not with same Email)
                    }
                }else if(sub.Status__c == 'Inactive' && sub.Contact_Type__c == 'Limited Public Records Only'){
                    sub.Status__c = 'Active';
                    sub.Status_Change_Reason__c = 'Reinstate';
                    sub.Status_Change_Fee__c = 'No Charge';
                    foxRacc.Subscription_Sync_Type__c = ' Sync Reinstate';
                    updateSubMap.put(sub.id, FoxRoach_Utils.copySubscriptionData(foxRacc, sub));
                    updateContactMap.put(sub.Contact__c, FoxRoach_Utils.copyContactData(foxRacc, new Contact(Id=sub.Contact__c)));
                }
            }
            
        }
          
        system.debug('updateSubMap--'+updateSubMap);
        system.debug('updateContactMap--'+updateContactMap);
        
        integer i=0;
        if(!updateContactMap.isEmpty())
        {
            list<Contact> consUpdate = updateContactMap.values();
            List<Database.SaveResult> contactUpdateResult= Database.update(consUpdate, false);
            i=0;
            for(Database.SaveResult ds : contactUpdateResult){
                if(ds.isSuccess()){
                    foxAccountMap.get(contactIdFoxIdMap.get(consUpdate[i].Id)).Contact_Sync_Status__c = 'Success';
                }else
                {
                    string error = '';
                    for (Database.Error e : ds.getErrors())
                    {
                        error += e.getMessage()+';';
                    }
                    foxAccountMap.get(contactIdFoxIdMap.get(consUpdate[i].Id)).Contact_Sync_Status__c = 'Failed';
                    foxAccountMap.get(contactIdFoxIdMap.get(consUpdate[i].Id)).Reason__c += error;
                }
                i++;
            }
        }
        
        if(!updateSubMap.isEmpty())
        {
            list<Subscriptions__c> subsUpdate = updateSubMap.values();
            List<Database.SaveResult> subUpdateResult= Database.update(subsUpdate, false);
            i=0;
            for(Database.SaveResult ds : subUpdateResult){
                if(ds.isSuccess()){
                    foxAccountMap.get(subsUpdate[i].FoxRoachID__c).Subscription_Sync_Status__c = 'Success';
                    //When Same Contact is used in Multiple Subscriptions
                    foxAccountMap.get(contactIdFoxIdMap.get(subsUpdate[i].Contact__c)).Contact_Sync_Status__c = 'Success';
                }else
                {
                    string error = '';
                    for (Database.Error e : ds.getErrors())
                    {
                        error += e.getMessage()+';';
                    }
                    foxAccountMap.get(subsUpdate[i].FoxRoachID__c).Subscription_Sync_Status__c = 'Failed';
                    foxAccountMap.get(subsUpdate[i].FoxRoachID__c).Reason__c += error;
                }
                i++;
            }
        }
        
        if(!foxAccounts.isEmpty())
        {
            update foxAccounts;//foxAccountMap.values();
        }
    }    
    public void finish(Database.BatchableContext bc)
    {
        Database.executeBatch(new FoxRoach_BatchDeactivateSubscriptions(), 10);
    }
}