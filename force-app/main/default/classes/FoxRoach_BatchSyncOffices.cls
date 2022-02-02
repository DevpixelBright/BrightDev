/***********************************************************************************************
*       Class Name      : FoxRoach_BatchSyncOffices
*       Date            : 11/10/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Apex Class is used to sync the FoxRoach Offices with Salesforce Account.
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       11/10/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_BatchSyncOffices implements Database.Batchable<sObject> 
{
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string query = 'SELECT Name, Office_Id__c, FranchiseCode__c,Address1__c,Address2__c, City__c, StateOrProvince__c,Country__c,PostalCode__c,'+
            	'Sync_Type__c,Sync_Status__c, Reason__c  FROM FoxRoach_Office__c';
        system.debug('query---'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FoxRoach_Office__c> foxOffices)
    {
        list<string> foxOfficeNames = new list<string>();
        map<string,FoxRoach_Office__c> foxOffIdOfficeMap = new map<string, FoxRoach_Office__c>();
        for(FoxRoach_Office__c office : foxOffices)
        {
            if(!string.isBlank(office.Office_Id__c) && !string.isBlank(office.Name))
            {
                foxOfficeNames.add(office.Office_Id__c);
                foxOffIdOfficeMap.put(office.Office_Id__c, office);
            }
        }
        list<Account> sfAccounts = [SELECT Account_Name__c, FoxRoach_OfficeID__c, Street_Number__c, Street_Name__c, City__c, State__c, Zip__c, Zip_4__c, Country__c,
                                    Status__c FROM Account WHERE FoxRoach_OfficeID__c IN :foxOfficeNames];
        list<Account> accUpdate = new list<Account>();
        for(Account acc : sfAccounts){
            FoxRoach_Office__c foxAcc = foxOffIdOfficeMap.get(acc.FoxRoach_OfficeID__c);
            if(acc.Status__c == 'Active'){
                
                acc.Street_Number__c = foxAcc.Address1__c;
                acc.Street_Name__c = foxAcc.Address2__c;
                acc.City__c = foxAcc.City__c;
                acc.State__c = foxAcc.StateOrProvince__c;
                acc.Zip__c = foxAcc.PostalCode__c;
                //acc.Zip_4__c = foxAcc.PostalCode__c;
                acc.Country__c = foxAcc.Country__c;
                accUpdate.add(acc);
                foxAcc.Sync_Type__c = 'Active';
                //Reset reason to blank before sync update
                foxAcc.Reason__c = '';
            }else{
                foxAcc.Sync_Type__c = 'Inactive';
            }
        }

        if(accUpdate != null && accUpdate.size()>0){
            List<Database.SaveResult> accUpdateResult= Database.update(accUpdate, false);
            integer i=0;
            for(Database.SaveResult ds : accUpdateResult){
                if(ds.isSuccess()){
                    foxOffIdOfficeMap.get(accUpdate[i].FoxRoach_OfficeID__c).Sync_Status__c = 'Success';
                }else
                {
                    string error = '';
                    for (Database.Error e : ds.getErrors())
                    {
                        error += e.getMessage()+';';
                    }
                    foxOffIdOfficeMap.get(accUpdate[i].FoxRoach_OfficeID__c).Sync_Status__c = 'Fail';
                    foxOffIdOfficeMap.get(accUpdate[i].FoxRoach_OfficeID__c).Reason__c += error;
                }
                i++;
            }
        }
        if(sfAccounts != null && sfAccounts.size()>0){
            update foxOffIdOfficeMap.values();
        }
    }    
    public void finish(Database.BatchableContext bc)
    {
        Database.executeBatch(new FoxRoach_BatchDeleteAccounts());
    }
}