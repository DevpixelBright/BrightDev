/***********************************************************************************************
*       Class Name      : FoxRoach_BatchLoadAccounts
*       Date            : 10/20/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Apex Class is used to get all accounts from FoxRoach to Salesforce Stagging
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/20/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_BatchLoadAccounts implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string query = 'SELECT Id, Name, Office_Id__c FROM FoxRoach_Office__c';
        system.debug('query---'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FoxRoach_Office__c> records)
    {
        FoxRoach_Office__c office = records[0];
        HttpResponse officeAccountsResponse = FoxRoach_Callout.foxRoachCallout('{"officeID":"'+office.Office_Id__c+'"}','/account/search', 'POST');
        list<FoxRoach_Modal.Account> accounts = (List<FoxRoach_Modal.Account>)JSON.deserialize(officeAccountsResponse.getBody(), List<FoxRoach_Modal.Account>.class);
        
        list<FoxRoach_Account__c> newAccounts = new list<FoxRoach_Account__c>();
        FoxRoach_Account__c newAcc;
        for(FoxRoach_Modal.Account eachAccount : accounts)
        {
            newAcc = new FoxRoach_Account__c();
            newAcc.Name = string.valueof(eachAccount.id);
            newAcc.Address1__c = eachAccount.address.address1;
            newAcc.City__c = eachAccount.address.city;
            newAcc.Country__c = eachAccount.address.country;
            newAcc.State__c = eachAccount.address.stateOrProvince;
            newAcc.Zip__c = eachAccount.address.postalCode;
            newAcc.Office_Name__c = eachAccount.officeName;
            if(!string.isBlank(eachAccount.email)){
                newAcc.Email__c = eachAccount.email+'.invalid';
            }
            newAcc.FirstName__c = eachAccount.firstName;
            newAcc.FoxRoachID__c = string.valueof(eachAccount.id);
            newAcc.LastName__c = eachAccount.lastName;
            newAcc.Office__r = new FoxRoach_Office__c(Office_Id__c = string.valueof(eachAccount.officeID));
            if(eachAccount.phoneNumbers != null && eachAccount.phoneNumbers.size()>0){
                //newAcc.PhoneNumber__c = eachAccount.phoneNumbers[0].phoneNumber;
                newAcc.PhoneNumber__c = eachAccount.phoneNumbers[0].phoneNumber.replace(eachAccount.phoneNumbers[0].phoneNumber.right(3),'123');
            }
            newAccounts.add(newAcc);
        }
        
        if(newAccounts.size()>0)
        {
            insert newAccounts;
        }
    }    
    public void finish(Database.BatchableContext bc)
    {
        Database.executeBatch(new FoxRoach_BatchSyncAccounts(), 10); 
    }
}