/***********************************************************************************************
*       Class Name      : FoxRoach_BatchLoadOffices
*       Date            : 10/20/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Apex Class is used to get the Ofiices from FoxRoach to Salesforce Stagging
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/20/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_BatchLoadOffices implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public FoxRoach_BatchLoadOffices()
    {
        //Create One Dummy Record to Enter into Excute block
        //insert new FoxRoach_Office__c(Name='Test Office',Office_Id__c='UniqueId');
    }
    public list<FoxRoach_Office__c> start(Database.BatchableContext bc) {
        //string query = 'SELECT Id, Name FROM FoxRoach_Office__c';
        //system.debug('query---'+query);
        return new list<FoxRoach_Office__c>{new FoxRoach_Office__c()};
    }
    public void execute(Database.BatchableContext bc, List<FoxRoach_Office__c> records){
        HttpResponse allOfficeResponse = FoxRoach_Callout.foxRoachCallout('', '/account/offices', 'GET');
        List<FoxRoach_Modal.Office> offices = (List<FoxRoach_Modal.Office>)JSON.deserialize(allOfficeResponse.getBody(), List<FoxRoach_Modal.Office>.class);
        system.debug('offices---size--'+offices.size());
        
        //Delete Old Offices
        records = [SELECT Id, Name FROM FoxRoach_Office__c];
        if(records != null && !records.isEmpty()){
            delete records;
        }
        
        list<FoxRoach_Office__c> newOffices = new list<FoxRoach_Office__c>();
        FoxRoach_Office__c newOffice;
        for(FoxRoach_Modal.Office eachOffice : offices)
        {
            newOffice = new FoxRoach_Office__c();
            newOffice.Name = eachOffice.name;
            newOffice.Office_Id__c = String.valueof(eachOffice.id);
            newOffice.FranchiseCode__c = eachOffice.franchiseCode;
            
            newOffice.Address1__c = eachOffice.address.address1;
            newOffice.Address2__c = eachOffice.address.address2;
            newOffice.City__c = eachOffice.address.city;
            newOffice.StateOrProvince__c = eachOffice.address.stateOrProvince;
            newOffice.PostalCode__c = eachOffice.address.postalCode;
            newOffice.Country__c = eachOffice.address.country;
            
            newOffices.add(newOffice);
        }
        if(newOffices.size()>0)
        {
            insert newOffices;
        }
    }    
    public void finish(Database.BatchableContext bc){
        Database.executeBatch(new FoxRoach_BatchSyncOffices());
    }
}