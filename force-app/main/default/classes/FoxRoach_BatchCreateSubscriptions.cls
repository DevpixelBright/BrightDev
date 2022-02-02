/***********************************************************************************************
*       Class Name      : FoxRoach_BatchCreateSubscriptions
*       Date            : 10/28/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Apex Class is used to create subscriptions for active FoxRoach data not present in salesforce.
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/28/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_BatchCreateSubscriptions implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string query = 'SELECT Id, Office__c, PhoneNumber__c, Address1__c, City__c, State__c, Zip__c, Country__c, Email__c,'+ 
            ' LastName__c, FirstName__c, FoxRoachID__c, Office_Name__c, Office__r.Office_Id__c, Reason__c, Subscription_Sync_Status__c, Subscription_Sync_Type__c, Contact_Sync_Status__c'+
            ' FROM FoxRoach_Account__c ORDER BY Office__r.Office_Id__c';
        system.debug('query---'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FoxRoach_Account__c> scopeFoxRoachAccs)
    {
        list<string> foxRoachIdList = new list<string>();
        set<string> foxRoachOfficeList = new set<string>();
        map<string,FoxRoach_Account__c> foxIdAccountMap = new map<string,FoxRoach_Account__c>();
        map<string,Subscriptions__c> foxIdSubscriptionMap = new map<string,Subscriptions__c>();
        map<string,Account> officeNameAccountMap = new map<string,Account>();
        map<string,Contact> foxIdContactCreateMap = new map<string,Contact>();
        map<string,Subscriptions__c> foxIdSubscriptionCreateMap = new map<string,Subscriptions__c>();
        map<string,string> emailFoxIdMap = new map<string,string>();
        
        //list<Related_Agent__c> newRelatedAgents = new list<Related_Agent__c>();
        
        for(FoxRoach_Account__c fAcc : scopeFoxRoachAccs)
        {
            if(!string.isBlank(fAcc.FoxRoachID__c))
            {
                FoxRoachIdList.add(fAcc.FoxRoachID__c);
                foxRoachOfficeList.add(fAcc.Office__r.Office_Id__c);
                foxIdAccountMap.put(fAcc.FoxRoachID__c, fAcc);
            }
        }
        
        if(!FoxRoachIdList.isEmpty())
        {
            for(Subscriptions__c sub : [SELECT FoxRoachID__c FROM Subscriptions__c WHERE FoxRoachID__c IN :foxRoachIdList])
            {
                foxIdSubscriptionMap.put(sub.FoxRoachID__c, sub);
            }
        }
        
        if(!foxRoachOfficeList.isEmpty())
        {
            for(Account acc : [SELECT Account_Name__c, FoxRoach_OfficeID__c, Name, Street_Number__c, Street_Name__c, Street_Type__c, Street_Number_Suffix__c, Street_Direction__c, 
                               Unit_Type__c, Unit__c, Addl_Display_Name__c, Box__c, Zip__c, Zip_4__c, City__c, State__c, County__c, 
                               Country__c, QAS_Mailing_Country__c, QAS_Mailing_County__c, QAS_Mailing_Street_Direction__c, 
                               QAS_Mailing_Street_Type__c, QAS_Mailing_Unit_Type__c, QAS_Mailing_POBox__c, QAS_Mailing_Record_Type__c, 
                               Billing_Street_Number__c, Billing_Street_Name__c, Billing_Street_Type__c, 
                               Billing_Street_Direction__c, Billing_Unit_Type__c, Billing_Box__c, Billing_Addl_Display_Name__c, 
                               Billing_Zip__c, Billing_Zip_4__c, Billing_City__c, Billing_State__c, Billing_County__c, Billing_Country__c, 
                               QAS_Billing_Country__c, QAS_Billing_County__c, QAS_Billing_Street_Direction__c, QAS_Billing_Street_Type__c, 
                               QAS_Billing_Unit_Type__c, QAS_Billing_POBox__c, QAS_Billing_Record_Type__c FROM Account 
                               WHERE FoxRoach_OfficeID__c IN :foxRoachOfficeList])
            {
                officeNameAccountMap.put(acc.FoxRoach_OfficeID__c, acc);
            }
        }
        system.debug('officeNameAccountMap--size---'+officeNameAccountMap.size());
        
        for(string foxId : foxIdAccountMap.keyset())
        {
            if(!foxIdSubscriptionMap.containskey(foxId) && officeNameAccountMap.containskey(foxIdAccountMap.get(foxId).Office__r.Office_Id__c))
            {
                emailFoxIdMap.put(foxIdAccountMap.get(foxId).Email__c, foxId);
                foxIdAccountMap.get(foxId).Subscription_Sync_Type__c = 'Sync Create';
                foxIdContactCreateMap.put(foxId, createContact(foxIdAccountMap.get(foxId), officeNameAccountMap.get(foxIdAccountMap.get(foxId).Office__r.Office_Id__c)));
                foxIdSubscriptionCreateMap.put(foxId, createSubscription(foxIdAccountMap.get(foxId), officeNameAccountMap.get(foxIdAccountMap.get(foxId).Office__r.Office_Id__c)));
            }
        }
        integer i=0;
        if(!foxIdContactCreateMap.isEmpty())
        {
            //Contact already exsist with email then use same
            set<string> contactEmails = emailFoxIdMap.keyset();
            for(Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :contactEmails]){
                foxIdContactCreateMap.get(emailFoxIdMap.get(c.Email)).Id = c.Id;
            }
            list<Contact> conCreate = foxIdContactCreateMap.values();
            list<Database.UpsertResult> conCreateResult = Database.upsert(conCreate, false);
            i=0;
            for(Database.UpsertResult ds : conCreateResult){
                if(ds.isSuccess()){
                    string foxId2 = emailFoxIdMap.get(conCreate[i].Email);
                    foxIdContactCreateMap.get(foxId2).Id = ds.getId();
                    foxIdAccountMap.get(foxId2).Contact_Sync_Status__c = ds.isCreated() ? 'Success Created' : 'Success Updated';
                }else
                {
                    string error = '';
                    for (Database.Error e : ds.getErrors())
                    {
                        error += e.getMessage()+';';
                    }
                    foxIdAccountMap.get(emailFoxIdMap.get(conCreate[i].Email)).Contact_Sync_Status__c = 'Failed';
                    foxIdAccountMap.get(emailFoxIdMap.get(conCreate[i].Email)).Reason__c += error;
                }
                i++;
            }
        }
        if(!foxIdSubscriptionCreateMap.isEmpty())
        {
            //Create Subscriptions for Created Contacts
            list<Subscriptions__c> subCreate = new list<Subscriptions__c>();
            for(string foxId : foxIdSubscriptionCreateMap.keyset())
            {
                if(foxIdContactCreateMap.get(foxId).Id != null){
                    foxIdSubscriptionCreateMap.get(foxId).Contact__c = foxIdContactCreateMap.get(foxId).Id;
                    subCreate.add(foxIdSubscriptionCreateMap.get(foxId));
                }
            }
            
            list<Database.SaveResult> subCreateResult = Database.insert(subCreate, false);
            i=0;
            for(Database.SaveResult ds : subCreateResult){
                if(ds.isSuccess()){
                    foxIdAccountMap.get(emailFoxIdMap.get(subCreate[i].Private_Email__c)).Subscription_Sync_Status__c = 'Success';
                }else
                {
                    string error = '';
                    for (Database.Error e : ds.getErrors())
                    {
                        error += e.getMessage()+';';
                    }
                    foxIdAccountMap.get(emailFoxIdMap.get(subCreate[i].Private_Email__c)).Subscription_Sync_Status__c = 'Failed';
                    foxIdAccountMap.get(emailFoxIdMap.get(subCreate[i].Private_Email__c)).Reason__c += error;
                }
                i++;
            }
        }
        if(foxIdAccountMap != null && foxIdAccountMap.size()>0){
            update foxIdAccountMap.values();
        }
        /*
        Related_Agent__c ra;
        for(string foxId : foxIdSubscriptionCreateMap.keyset())
        {
            ra = new Related_Agent__c();
            ra.Personal_Assistant_Sub_ID__c = foxIdSubscriptionCreateMap.get(foxId).Id;
            ra.Personal_Assistant__c = foxIdSubscriptionCreateMap.get(foxId).Contact__c;
            ra.Status__c = 'In Progress';
            newRelatedAgents.add(ra);            
        }
        if(!newRelatedAgents.isEmpty())
        {
            insert newRelatedAgents;
        }
        */
    }    
    public void finish(Database.BatchableContext bc)
    { 
        FoxRoach_Utils.updateLogAddAttachment(new FoxRoach_Sync_Log__c());
    }
    
    Contact createContact(FoxRoach_Account__c fAcc, Account a)
    {
        Contact c  = new Contact();
        
        c.FirstName = fAcc.FirstName__c;
        c.LastName = fAcc.LastName__c;
        //c.Middle_Name__c = application.Middle_Name__c;
        c.Phone = fAcc.PhoneNumber__c;//.right(10);
        c.MobilePhone = fAcc.PhoneNumber__c;//.right(10);
        //c.Salutation = application.Salutation__c;
        //c.Voicemail__c = application.Voicemail__c;
        //c.VM_Ext__c = application.VM_Ext__c;
        c.Nickname__c = fAcc.FirstName__c;
        //c.Home_Fax__c = application.Home_Fax__c;
		c.AccountId = a.Id;
        c.Email = fAcc.Email__c;
        c.Public_Email__c = fAcc.Email__c;
        //c.Website__c = application.Website__c;
        //c.NRDS_ID__c = application.NRDS_ID__c;
        //c.Professional_Designations__c = application.Professional_Designations__c;
        //c.Disabilities__c = application.Disabilities__c;
        c.Status__c = 'In Progress';
        //c.Agent_Office_Phone__c = Application.Agent_Office_Phone__c;
        
        c.city__c = fAcc.City__c;
        c.Zip__c = fAcc.Zip__c;
        c.County__c = fAcc.Country__c;
        c.QAS_Mailing_County__c = fAcc.Country__c;
        
        //Mailing Address
        c.Street_Number__c = a.Street_Number__c;
        c.Street_Name__c = a.Street_Name__c;
        c.Street_Type__c = a.Street_Type__c;
        c.Street_Number_Suffix__c = a.Street_Number_Suffix__c;
        c.Street_Direction__c = a.Street_Direction__c;
        c.Unit_Type__c = a.Unit_Type__c;
        c.Unit__c = a.Unit__c;
        c.Addl_Display_Name__c = a.Addl_Display_Name__c;
        c.Box__c = a.Box__c;
        c.Zip__c = a.Zip__c;
        c.Zip_4__c = a.Zip_4__c;
        //c.Fax = application.Agent_Office_Fax__c;
        //c.Home_Fax__c = application.Home_Fax__c;
        c.City__c = a.City__c;
        c.State__c = a.State__c;
        c.County__c = a.County__c;
        c.Country__c = a.Country__c;
        c.QAS_Mailing_Country__c = a.QAS_Mailing_Country__c; 
        c.QAS_Mailing_County__c = a.QAS_Mailing_County__c; 
        c.QAS_Mailing_Street_Direction__c = a.QAS_Mailing_Street_Direction__c; 
        c.QAS_Mailing_Street_Type__c = a.QAS_Mailing_Street_Type__c; 
        c.QAS_Mailing_Unit_Type__c = a.QAS_Mailing_Unit_Type__c; 
        c.QAS_Mailing_POBox__c = a.QAS_Mailing_POBox__c;
        c.QAS_Mailing_Record_Type__c = a.QAS_Mailing_Record_Type__c;
        
        //Billing Address
        c.Billing_Street_Number__c = a.Billing_Street_Number__c;
        c.Billing_Street_Name__c = a.Billing_Street_Name__c;
        c.Billing_Street_Type__c = a.Billing_Street_Type__c; 
        c.Street_Number_Suffix__c = a.Street_Number_Suffix__c;               
        c.Billing_Street_Direction__c = a.Billing_Street_Direction__c;
        c.Billing_Unit_Type__c = a.Billing_Unit_Type__c;
        c.Billing_Box__c = a.Billing_Box__c;
        c.Billing_Addl_Display_Name__c = a.Billing_Addl_Display_Name__c;
        c.Billing_Zip__c = a.Billing_Zip__c;
        c.Billing_Zip_4__c = a.Billing_Zip_4__c;
        c.Zip_4__c = a.Zip_4__c;
        c.Billing_City__c = a.Billing_City__c;
        c.Billing_State__c = a.Billing_State__c;
        c.Billing_County__c = a.Billing_County__c;
        c.Billing_Country__c = a.Billing_Country__c;
        c.QAS_Billing_Country__c = a.QAS_Billing_Country__c; 
        c.QAS_Billing_County__c = a.QAS_Billing_County__c;
        c.QAS_Billing_Street_Direction__c = a.QAS_Billing_Street_Direction__c;
        c.QAS_Billing_Street_Type__c = a.QAS_Billing_Street_Type__c;
        c.QAS_Billing_Unit_Type__c = a.QAS_Billing_Unit_Type__c;
        c.QAS_Billing_POBox__c = a.QAS_Billing_POBox__c;
        c.QAS_Billing_Record_Type__c = a.QAS_Billing_Record_Type__c;
        
        c.Service_Jurisdiction__c = 'BRIGHT';                
        c.AddressValidationStatus__c = 'Not Required';
        
        return c;
    }
    
    Subscriptions__c createSubscription(FoxRoach_Account__c fAcc, Account a)
    {
        Subscriptions__c s = new Subscriptions__c();
        //s.SFDC_Application__c = application.Id;
        s.FoxRoachID__c = fAcc.FoxRoachID__c;
        s.Contact_Type__c = 'Limited Public Records Only';
        s.City__c = fAcc.City__c;
        s.Zip__c = fAcc.Zip__c;
        s.County__c = a.County__c;
        s.QAS_Mailing_County__c = a.QAS_Mailing_County__c;
		s.Related_Location_Broker_Office__c = a.Id;
        s.Subscription_Type__c = '';
        s.Public_Email__c = fAcc.Email__c;
        s.Primary_Phone__c = fAcc.PhoneNumber__c;//.right(10);
        s.Mobile_Phone__c = fAcc.PhoneNumber__c;//.right(10);
        s.Status__c = 'In Progress';
        s.Private_Email__c = fAcc.Email__c;
        //s.Home_Fax__c = application.Home_Fax__c;
        //s.Voicemail__c = application.Voicemail__c;
        //s.VM_Ext__c = application.VM_Ext__c;
        //s.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
        //s.Fax__c = application.Agent_Office_Fax__c;
        //s.Home_Fax__c = application.Home_Fax__c;           
        //s.Website__c = application.Website__c;
        
        //s.NRDS_ID__c = application.NRDS_ID__c;
        
        //Mailing Address Account to Subscription
        s.Street_Number__c = a.Street_Number__c;
        s.Street_Name__c = a.Street_Name__c;
        s.Street_Type__c = a.Street_Type__c;
        s.Street_Number_Suffix__c = a.Street_Number_Suffix__c;
        s.Street_Direction__c = a.Street_Direction__c;
        s.Unit_Type__c = a.Unit_Type__c;
        s.Unit__c = a.Unit__c;
        s.Addl_Display_Name__c = a.Addl_Display_Name__c;
        s.Box__c = a.Box__c;
        s.Zip__c = a.Zip__c;
        s.Zip_4__c = a.Zip_4__c;
        s.City__c = a.City__c;
        
        s.State__c = a.State__c;
        s.County__c = a.County__c;
        s.Country__c = a.Country__c;
        s.QAS_Mailing_Country__c = a.QAS_Mailing_Country__c; 
        s.QAS_Mailing_County__c = a.QAS_Mailing_County__c; 
        s.QAS_Mailing_Street_Direction__c = a.QAS_Mailing_Street_Direction__c; 
        s.QAS_Mailing_Street_Type__c = a.QAS_Mailing_Street_Type__c; 
        s.QAS_Mailing_Unit_Type__c = a.QAS_Mailing_Unit_Type__c; 
        s.QAS_Mailing_POBox__c = a.QAS_Mailing_POBox__c;
        s.QAS_Mailing_Record_Type__c = a.QAS_Mailing_Record_Type__c; 
        
        //Billing Address Account to Subscription
        s.Billing_Street_Number__c = a.Billing_Street_Number__c;
        s.Billing_Street_Name__c = a.Billing_Street_Name__c;
        s.Billing_Street_Type__c = a.Billing_Street_Type__c; 
        s.Street_Number_Suffix__c = a.Street_Number_Suffix__c;               
        s.Billing_Street_Direction__c = a.Billing_Street_Direction__c;
        s.Billing_Unit_Type__c = a.Billing_Unit_Type__c;
        s.Billing_Box__c = a.Billing_Box__c;
        s.Billing_Addl_Display_Name__c = a.Billing_Addl_Display_Name__c;
        s.Billing_Zip__c = a.Billing_Zip__c;
        s.Billing_Zip_4__c = a.Billing_Zip_4__c;
        s.Zip_4__c = a.Zip_4__c;
        s.Billing_City__c = a.Billing_City__c;
        s.Billing_State__c = a.Billing_State__c;
        s.Billing_County__c = a.Billing_County__c;
        s.Billing_Country__c = a.Billing_Country__c;
        s.QAS_Billing_Country__c = a.QAS_Billing_Country__c; 
        s.QAS_Billing_County__c = a.QAS_Billing_County__c;
        s.QAS_Billing_Street_Direction__c = a.QAS_Billing_Street_Direction__c;
        s.QAS_Billing_Street_Type__c = a.QAS_Billing_Street_Type__c;
        s.QAS_Billing_Unit_Type__c = a.QAS_Billing_Unit_Type__c;
        s.QAS_Billing_POBox__c = a.QAS_Billing_POBox__c;
        s.QAS_Billing_Record_Type__c = a.QAS_Billing_Record_Type__c;
        
        
        s.AddressValidationStatus__c = 'Not Required';
        s.Service_Jurisdiction__c = 'BRIGHT';
        s.Billing_Jurisdiction__c = 'BRIGHT';
        
        return s;
    }
}