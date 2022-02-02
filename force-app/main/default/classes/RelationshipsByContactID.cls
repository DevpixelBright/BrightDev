/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return all the Relationship information based on the contactID information.  
* If no contactID information is found,  salesforce returns an empty return structure 
**/
@RestResource(urlMapping='/GetRelationshipsByContactID/*')
global with sharing class RelationshipsByContactID {
    
    /**
    *  HTTP Get Method
    *
    **/
    @HTTPGet
    global static List<Relationship__c> doGet(){
        System.debug('RestContext ---> '+ RestContext.request);
        System.debug('RestContext ---> '+ RestContext.response);
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
         System.debug('uri ---> ' + req.params);
        
       
        Map <String,String> urlValues = req.params;
        String contact_Id;
        String role;
         System.debug('Contact ID ' + contact_Id);
         System.debug('uri ---> ' + req.params);
          contact_Id = urlValues.get('contactID');
            role = urlValues.get('role');
        System.debug('Contact ID........ ' + contact_Id);
        //Contact con = [SELECT name, id FROM Contact WHERE Primary_Subscription_ID__c =: contact_id][0];
        
        //System.debug('list of contacts: ' +con.size());
        
        //System.debug('contact name:'+con[0].name);
        List <Relationship__c> rels = new List <Relationship__c>();
        if (Utils.isNotNull(role)) {
       rels = [Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__r.Zip__c, r.Subscription__r.Zip_4__c, r.Subscription__r.Website__c, r.Subscription__r.VM_Ext__c, r.Subscription__r.Unit__c, r.Subscription__r.Unit_Type__c, r.Subscription__r.Subscription_Type__c, 
        r.Subscription__r.Street_Type__c, r.Subscription__r.Street_Number__c, r.Subscription__r.Street_Number_Suffix__c, r.Subscription__r.Street_Name__c, r.Subscription__r.Street_Direction__c, r.Subscription__r.Status__c, r.Subscription__r.Status_Change_Reason__c, 
        r.Subscription__r.Status_Change_Fee__c, r.Subscription__r.State__c, r.Subscription__r.SFDC_Application__c, r.Subscription__r.Related_Location_Broker_Office__c, r.Subscription__r.Public_Email__c, r.Subscription__r.PrismSubscriptionID__c, 
        r.Subscription__r.Primary__c, r.Subscription__r.Primary_Phone__c, r.Subscription__r.PrimarySubNum__c, r.Subscription__r.Pager__c, r.Subscription__r.Mobile_Phone__c, r.Subscription__r.License__c, r.Subscription__r.Home_Fax__c, r.Subscription__r.Fax__c, r.Subscription__r.Deleted__c, 
        r.Subscription__r.Date_Terminated__c, r.Subscription__r.Date_Reinstated__c, r.Subscription__r.Date_Joined__c, r.Subscription__r.Date_Billing_Begins__c, r.Subscription__r.County__c, r.Subscription__r.Country__c, r.Subscription__r.Copy_Address_to_Billing__c, 
        r.Subscription__r.Contact_Type__c, r.Subscription__r.City__c, r.Subscription__r.Box__c, r.Subscription__r.Billing_Zip__c, r.Subscription__r.Billing_Zip_4__c, r.Subscription__r.Billing_Unit_Type__c, r.Subscription__r.Billing_Unit_Number__c, r.Subscription__r.Billing_Street_Type__c, 
        r.Subscription__r.Billing_Street_Suffix__c, r.Subscription__r.Billing_Street_Number__c, r.Subscription__r.Billing_Street_Name__c, r.Subscription__r.Billing_Street_Direction__c, r.Subscription__r.Billing_State__c, r.Subscription__r.Billing_County__c, r.Subscription__r.Billing_Country__c, 
        r.Subscription__r.Billing_City__c, r.Subscription__r.Billing_Box__c, r.Subscription__r.Billing_Addl_Display_Name__c, r.Subscription__r.Agent_Office_Phone__c, r.Subscription__r.AgentRealPingID__c, r.Subscription__r.AgentKey__c, r.Subscription__r.Addl_Display_Name__c, 
        r.Subscription__r.Contact__c, r.Subscription__r.LastActivityDate, r.Subscription__r.SystemModstamp, r.Subscription__r.LastModifiedById, r.Subscription__r.LastModifiedDate, r.Subscription__r.CreatedById, r.Subscription__r.CreatedDate, r.Subscription__r.Name, r.Subscription__r.IsDeleted, 
        r.Subscription__r.Id, r.Subscription__c, r.Relationship_Type__c, r.Relationship_Start_Date__c , r.Relationship_End_Date__c, r.Related_Account__c, r.PrismRelationshipID__c, r.Personal_Assistant__r.Name, r.Personal_Assistant__r.Id, r.Personal_Assistant__c, 
        r.Personal_Assistant_Sub_ID__r.AgentKey__c, r.Personal_Assistant_Sub_ID__r.Name, r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Name, r.MDS_Status__c, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Id, r.CreatedDate, r.CreatedById, 
        r.Contact__r.PrimarySubIDRollup__c, r.Contact__r.Date_Terminated__c, r.Contact__r.Date_Joined__c, r.Contact__r.Date_Billing_Begins__c, r.Contact__r.Zip__c, r.Contact__r.Zip_4__c, r.Contact__r.Website__c, r.Contact__r.Voicemail__c, r.Contact__r.VM_Ext__c, r.Contact__r.VIP__c, 
        r.Contact__r.Unit__c, r.Contact__r.Unit_Type__c, r.Contact__r.TaleoContactID__c, r.Contact__r.Suffix__c, r.Contact__r.Street_Type__c, r.Contact__r.Street_Number__c, r.Contact__r.Street_Number_Suffix__c, r.Contact__r.Street_Name__c, r.Contact__r.Street_Direction__c, r.Contact__r.Status__c, 
        r.Contact__r.State__c, r.Contact__r.Public_Email__c, r.Contact__r.Professional_Designations__c, r.Contact__r.PrismContactID__c, r.Contact__r.PrismAddressID__c, r.Contact__r.PrismAccountID__c, r.Contact__r.Primary_Subscription_ID__c, r.Contact__r.Primary_Contact__c, 
        r.Contact__r.PIN__c, r.Contact__r.Nickname__c, r.Contact__r.NRDS_ID__c, r.Contact__r.Middle_Name__c, r.Contact__r.Home_Fax__c, r.Contact__r.Extension__c, r.Contact__r.Disabilities__c, r.Contact__r.County__c, r.Contact__r.Country__c, r.Contact__r.Copy_Address_to_Billing__c, 
        r.Contact__r.City__c, r.Contact__r.Categories__c, r.Contact__r.Box__c, r.Contact__r.Billing_Zip__c, r.Contact__r.Billing_Zip_4__c, r.Contact__r.Billing_Unit_Type__c, r.Contact__r.Billing_Unit_Number__c, r.Contact__r.Billing_Street_Type__c, r.Contact__r.Billing_Street_Number__c, 
        r.Contact__r.Billing_Street_Number_Suffix__c, r.Contact__r.Billing_Street_Name__c, r.Contact__r.Billing_Street_Direction__c, r.Contact__r.Billing_State__c, r.Contact__r.Billing_County__c, r.Contact__r.Billing_Country__c, r.Contact__r.Billing_City__c, r.Contact__r.Billing_Box__c, 
        r.Contact__r.Billing_Addl_Display_Name__c, r.Contact__r.Agent_Office_Phone__c, r.Contact__r.Addl_Display_Name__c, r.Contact__r.JigsawContactId, r.Contact__r.Jigsaw, r.Contact__r.EmailBouncedDate, r.Contact__r.EmailBouncedReason, r.Contact__r.LastCUUpdateDate, 
        r.Contact__r.LastCURequestDate, r.Contact__r.LastActivityDate, r.Contact__r.SystemModstamp, r.Contact__r.LastModifiedById, r.Contact__r.LastModifiedDate, r.Contact__r.CreatedById, r.Contact__r.CreatedDate, r.Contact__r.OwnerId, r.Contact__r.Description, r.Contact__r.LeadSource, 
        r.Contact__r.Department, r.Contact__r.Title, r.Contact__r.Email, r.Contact__r.ReportsToId, r.Contact__r.OtherPhone, r.Contact__r.MobilePhone, r.Contact__r.Fax, r.Contact__r.Phone, r.Contact__r.Name, r.Contact__r.Salutation, r.Contact__r.FirstName, r.Contact__r.LastName, 
        r.Contact__r.AccountId, r.Contact__r.MasterRecordId, r.Contact__r.IsDeleted, r.Contact__r.Id, r.Contact__c, r.Broker_Office__r.Zip__c, r.Broker_Office__r.Zip_4__c, r.Broker_Office__r.Unit__c, r.Broker_Office__r.Unit_Type__c, r.Broker_Office__r.Trading_As__c, 
        r.Broker_Office__r.Street_Type__c, r.Broker_Office__r.Street_Number__c, r.Broker_Office__r.Street_Number_Suffix__c, r.Broker_Office__r.Street_Name__c, r.Broker_Office__r.Street_Direction__c, r.Broker_Office__r.Status__c, r.Broker_Office__r.State__c, 
        r.Broker_Office__r.Shareholder_Board__c, r.Broker_Office__r.PrismCompanyOffice__c, r.Broker_Office__r.PrismCompanyCode__c, r.Broker_Office__r.PrismAddressID__c, r.Broker_Office__r.PrismAccountID__c, r.Broker_Office__r.PIN__c, r.Broker_Office__r.OfficeKey__c, 
        r.Broker_Office__r.Num_Active_Subs__c, r.Broker_Office__r.Num_Active_Office_Sec_NC__c, r.Broker_Office__r.Date_Terminated__c, r.Broker_Office__r.Date_Joined__c, r.Broker_Office__r.County__c, r.Broker_Office__r.Country__c, r.Broker_Office__r.Copy_Address_to_Billing__c, 
        r.Broker_Office__r.Company_Type__c, r.Broker_Office__r.City__c, r.Broker_Office__r.Box__c, r.Broker_Office__r.Billing_Zip__c, r.Broker_Office__r.Billing_Zip_4__c, r.Broker_Office__r.Billing_Unit_Type__c, r.Broker_Office__r.Billing_Unit_Number__c, 
        r.Broker_Office__r.Billing_Street_Type__c, r.Broker_Office__r.Billing_Street_Number__c, r.Broker_Office__r.Billing_Street_Number_Suffix__c, r.Broker_Office__r.Billing_Street_Name__c, r.Broker_Office__r.Billing_Street_Direction__c, r.Broker_Office__r.Billing_State__c, 
        r.Broker_Office__r.Billing_County__c, r.Broker_Office__r.Billing_Country__c, r.Broker_Office__r.Billing_City__c, r.Broker_Office__r.Billing_Box__c, r.Broker_Office__r.Billing_Addl_Display_Name__c, r.Broker_Office__r.Addl_Display_Name__c, r.Broker_Office__r.Account_Name__c, 
        r.Broker_Office__r.JigsawCompanyId, r.Broker_Office__r.Jigsaw, r.Broker_Office__r.IsCustomerPortal, r.Broker_Office__r.LastActivityDate, r.Broker_Office__r.SystemModstamp, r.Broker_Office__r.LastModifiedById, r.Broker_Office__r.LastModifiedDate, r.Broker_Office__r.CreatedById, 
        r.Broker_Office__r.CreatedDate, r.Broker_Office__r.OwnerId, r.Broker_Office__r.Rating, r.Broker_Office__r.Description, r.Broker_Office__r.Website, r.Broker_Office__r.Fax, r.Broker_Office__r.Phone, r.Broker_Office__r.BillingCountry, r.Broker_Office__r.BillingPostalCode, 
        r.Broker_Office__r.BillingState, r.Broker_Office__r.BillingCity, r.Broker_Office__r.BillingStreet, r.Broker_Office__r.ParentId, r.Broker_Office__r.Type, r.Broker_Office__r.Name, r.Broker_Office__r.MasterRecordId, r.Broker_Office__r.IsDeleted, r.Broker_Office__r.Id, r.Broker_Office__c From 
        Relationship__c r where r.Contact__C = :contact_Id and r.Status__c='Active' and r.Relationship_Type__c = :role];
        } else {
            rels = [Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__r.Zip__c, r.Subscription__r.Zip_4__c, r.Subscription__r.Website__c, r.Subscription__r.VM_Ext__c, r.Subscription__r.Unit__c, r.Subscription__r.Unit_Type__c, r.Subscription__r.Subscription_Type__c, 
        r.Subscription__r.Street_Type__c, r.Subscription__r.Street_Number__c, r.Subscription__r.Street_Number_Suffix__c, r.Subscription__r.Street_Name__c, r.Subscription__r.Street_Direction__c, r.Subscription__r.Status__c, r.Subscription__r.Status_Change_Reason__c, 
        r.Subscription__r.Status_Change_Fee__c, r.Subscription__r.State__c, r.Subscription__r.SFDC_Application__c, r.Subscription__r.Related_Location_Broker_Office__c, r.Subscription__r.Public_Email__c, r.Subscription__r.PrismSubscriptionID__c, 
        r.Subscription__r.Primary__c, r.Subscription__r.Primary_Phone__c, r.Subscription__r.PrimarySubNum__c, r.Subscription__r.Pager__c, r.Subscription__r.Mobile_Phone__c, r.Subscription__r.License__c, r.Subscription__r.Home_Fax__c, r.Subscription__r.Fax__c, r.Subscription__r.Deleted__c, 
        r.Subscription__r.Date_Terminated__c, r.Subscription__r.Date_Reinstated__c, r.Subscription__r.Date_Joined__c, r.Subscription__r.Date_Billing_Begins__c, r.Subscription__r.County__c, r.Subscription__r.Country__c, r.Subscription__r.Copy_Address_to_Billing__c, 
        r.Subscription__r.Contact_Type__c, r.Subscription__r.City__c, r.Subscription__r.Box__c, r.Subscription__r.Billing_Zip__c, r.Subscription__r.Billing_Zip_4__c, r.Subscription__r.Billing_Unit_Type__c, r.Subscription__r.Billing_Unit_Number__c, r.Subscription__r.Billing_Street_Type__c, 
        r.Subscription__r.Billing_Street_Suffix__c, r.Subscription__r.Billing_Street_Number__c, r.Subscription__r.Billing_Street_Name__c, r.Subscription__r.Billing_Street_Direction__c, r.Subscription__r.Billing_State__c, r.Subscription__r.Billing_County__c, r.Subscription__r.Billing_Country__c, 
        r.Subscription__r.Billing_City__c, r.Subscription__r.Billing_Box__c, r.Subscription__r.Billing_Addl_Display_Name__c, r.Subscription__r.Agent_Office_Phone__c, r.Subscription__r.AgentRealPingID__c, r.Subscription__r.AgentKey__c, r.Subscription__r.Addl_Display_Name__c, 
        r.Subscription__r.Contact__c, r.Subscription__r.LastActivityDate, r.Subscription__r.SystemModstamp, r.Subscription__r.LastModifiedById, r.Subscription__r.LastModifiedDate, r.Subscription__r.CreatedById, r.Subscription__r.CreatedDate, r.Subscription__r.Name, r.Subscription__r.IsDeleted, 
        r.Subscription__r.Id, r.Subscription__c, r.Relationship_Type__c, r.Relationship_Start_Date__c, r.Relationship_End_Date__c, r.Related_Account__c, r.PrismRelationshipID__c, r.Personal_Assistant__r.Name, r.Personal_Assistant__r.Id, r.Personal_Assistant__c, 
        r.Personal_Assistant_Sub_ID__r.AgentKey__c, r.Personal_Assistant_Sub_ID__r.Name, r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Name, r.MDS_Status__c, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Id, r.CreatedDate, r.CreatedById, 
        r.Contact__r.PrimarySubIDRollup__c, r.Contact__r.Date_Terminated__c, r.Contact__r.Date_Joined__c, r.Contact__r.Date_Billing_Begins__c, r.Contact__r.Zip__c, r.Contact__r.Zip_4__c, r.Contact__r.Website__c, r.Contact__r.Voicemail__c, r.Contact__r.VM_Ext__c, r.Contact__r.VIP__c, 
        r.Contact__r.Unit__c, r.Contact__r.Unit_Type__c, r.Contact__r.TaleoContactID__c, r.Contact__r.Suffix__c, r.Contact__r.Street_Type__c, r.Contact__r.Street_Number__c, r.Contact__r.Street_Number_Suffix__c, r.Contact__r.Street_Name__c, r.Contact__r.Street_Direction__c, r.Contact__r.Status__c, 
        r.Contact__r.State__c, r.Contact__r.Public_Email__c, r.Contact__r.Professional_Designations__c, r.Contact__r.PrismContactID__c, r.Contact__r.PrismAddressID__c, r.Contact__r.PrismAccountID__c, r.Contact__r.Primary_Subscription_ID__c, r.Contact__r.Primary_Contact__c, 
        r.Contact__r.PIN__c, r.Contact__r.Nickname__c, r.Contact__r.NRDS_ID__c, r.Contact__r.Middle_Name__c, r.Contact__r.Home_Fax__c, r.Contact__r.Extension__c, r.Contact__r.Disabilities__c, r.Contact__r.County__c, r.Contact__r.Country__c, r.Contact__r.Copy_Address_to_Billing__c, 
        r.Contact__r.City__c, r.Contact__r.Categories__c, r.Contact__r.Box__c, r.Contact__r.Billing_Zip__c, r.Contact__r.Billing_Zip_4__c, r.Contact__r.Billing_Unit_Type__c, r.Contact__r.Billing_Unit_Number__c, r.Contact__r.Billing_Street_Type__c, r.Contact__r.Billing_Street_Number__c, 
        r.Contact__r.Billing_Street_Number_Suffix__c, r.Contact__r.Billing_Street_Name__c, r.Contact__r.Billing_Street_Direction__c, r.Contact__r.Billing_State__c, r.Contact__r.Billing_County__c, r.Contact__r.Billing_Country__c, r.Contact__r.Billing_City__c, r.Contact__r.Billing_Box__c, 
        r.Contact__r.Billing_Addl_Display_Name__c, r.Contact__r.Agent_Office_Phone__c, r.Contact__r.Addl_Display_Name__c, r.Contact__r.JigsawContactId, r.Contact__r.Jigsaw, r.Contact__r.EmailBouncedDate, r.Contact__r.EmailBouncedReason, r.Contact__r.LastCUUpdateDate, 
        r.Contact__r.LastCURequestDate, r.Contact__r.LastActivityDate, r.Contact__r.SystemModstamp, r.Contact__r.LastModifiedById, r.Contact__r.LastModifiedDate, r.Contact__r.CreatedById, r.Contact__r.CreatedDate, r.Contact__r.OwnerId, r.Contact__r.Description, r.Contact__r.LeadSource, 
        r.Contact__r.Department, r.Contact__r.Title, r.Contact__r.Email, r.Contact__r.ReportsToId, r.Contact__r.OtherPhone, r.Contact__r.MobilePhone, r.Contact__r.Fax, r.Contact__r.Phone, r.Contact__r.Name, r.Contact__r.Salutation, r.Contact__r.FirstName, r.Contact__r.LastName, 
        r.Contact__r.AccountId, r.Contact__r.MasterRecordId, r.Contact__r.IsDeleted, r.Contact__r.Id, r.Contact__c, r.Broker_Office__r.Zip__c, r.Broker_Office__r.Zip_4__c, r.Broker_Office__r.Unit__c, r.Broker_Office__r.Unit_Type__c, r.Broker_Office__r.Trading_As__c, 
        r.Broker_Office__r.Street_Type__c, r.Broker_Office__r.Street_Number__c, r.Broker_Office__r.Street_Number_Suffix__c, r.Broker_Office__r.Street_Name__c, r.Broker_Office__r.Street_Direction__c, r.Broker_Office__r.Status__c, r.Broker_Office__r.State__c, 
        r.Broker_Office__r.Shareholder_Board__c, r.Broker_Office__r.PrismCompanyOffice__c, r.Broker_Office__r.PrismCompanyCode__c, r.Broker_Office__r.PrismAddressID__c, r.Broker_Office__r.PrismAccountID__c, r.Broker_Office__r.PIN__c, r.Broker_Office__r.OfficeKey__c, 
        r.Broker_Office__r.Num_Active_Subs__c, r.Broker_Office__r.Num_Active_Office_Sec_NC__c, r.Broker_Office__r.Date_Terminated__c, r.Broker_Office__r.Date_Joined__c, r.Broker_Office__r.County__c, r.Broker_Office__r.Country__c, r.Broker_Office__r.Copy_Address_to_Billing__c, 
        r.Broker_Office__r.Company_Type__c, r.Broker_Office__r.City__c, r.Broker_Office__r.Box__c, r.Broker_Office__r.Billing_Zip__c, r.Broker_Office__r.Billing_Zip_4__c, r.Broker_Office__r.Billing_Unit_Type__c, r.Broker_Office__r.Billing_Unit_Number__c, 
        r.Broker_Office__r.Billing_Street_Type__c, r.Broker_Office__r.Billing_Street_Number__c, r.Broker_Office__r.Billing_Street_Number_Suffix__c, r.Broker_Office__r.Billing_Street_Name__c, r.Broker_Office__r.Billing_Street_Direction__c, r.Broker_Office__r.Billing_State__c, 
        r.Broker_Office__r.Billing_County__c, r.Broker_Office__r.Billing_Country__c, r.Broker_Office__r.Billing_City__c, r.Broker_Office__r.Billing_Box__c, r.Broker_Office__r.Billing_Addl_Display_Name__c, r.Broker_Office__r.Addl_Display_Name__c, r.Broker_Office__r.Account_Name__c, 
        r.Broker_Office__r.JigsawCompanyId, r.Broker_Office__r.Jigsaw, r.Broker_Office__r.IsCustomerPortal, r.Broker_Office__r.LastActivityDate, r.Broker_Office__r.SystemModstamp, r.Broker_Office__r.LastModifiedById, r.Broker_Office__r.LastModifiedDate, r.Broker_Office__r.CreatedById, 
        r.Broker_Office__r.CreatedDate, r.Broker_Office__r.OwnerId, r.Broker_Office__r.Rating, r.Broker_Office__r.Description, r.Broker_Office__r.Website, r.Broker_Office__r.Fax, r.Broker_Office__r.Phone, r.Broker_Office__r.BillingCountry, r.Broker_Office__r.BillingPostalCode, 
        r.Broker_Office__r.BillingState, r.Broker_Office__r.BillingCity, r.Broker_Office__r.BillingStreet, r.Broker_Office__r.ParentId, r.Broker_Office__r.Type, r.Broker_Office__r.Name, r.Broker_Office__r.MasterRecordId, r.Broker_Office__r.IsDeleted, r.Broker_Office__r.Id, r.Broker_Office__c From 
        Relationship__c r where r.Contact__C = :contact_Id and r.Status__c='Active'];
        }
        //Relationship__c r where r.Contact__C = :con.id];
        
        System.debug('rels size: ' + rels.size());
        

    return rels;
}
    static testMethod void testDoGet() {
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
         
        /*Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.Phone = '4231231242';
        a.City__c = 'Herndon';
        a.State__c = 'VA';
        a.County__c = 'Fairfax';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.Country__c = 'UNITED STATES';
        a.Zip__c = '20171';
        insert a;*/
        
       Account a = new Account();
       a.name = 'ADA1234';
       a.type = 'Residential';
       a.Account_Name__c = 'Test Account';
       a.City__c = 'Herndon';
       a.Zip__c = '20171';
       a.QAS_Mailing_County__c = 'Fairfax';
       a.County__c = 'Fairfax';
       a.Street_Type__c = '';
       a.Billing_Street_Type__c = 'BLFS';
       a.QAS_Mailing_Street_Type__c ='test';
       insert a;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        c.Primary_Subscription_ID__c = '777789';
        c.Status__c='Active';
        c.County__c ='Fairfax';
        insert c;
       
       License__c l = new License__c();
        l.Name = '123456';
        l.License_Expiration_Date__c = Date.today();
        l.License_State__c = 'VA';
        l.License_Type__c = 'Broker';
        //l.IsDeleted = false;
        l.Contact__c = c.id;
        insert l;
        
   		Subscriptions__c s = new Subscriptions__c();
        s.Name = 'test';
        s.Status__c = 'In Progress';
        s.Addl_Display_Name__c = 'xyz';
        s.Box__c = NULL;
        s.City__c = 'Herndon';
        s.QAS_Mailing_Country__c = 'USA';
        s.QAS_Mailing_County__c = 'Fairfax';
        s.State__c = 'VA';
        s.QAS_Mailing_Street_Direction__c = 'N';
        s.Street_Name__c = 'First';
        s.Street_Number__c ='1275';
        s.Street_Number_Suffix__c = NULL;
        s.QAS_Mailing_Street_Type__c = 'ST';
        s.Unit__c = '1';
        s.QAS_Mailing_Unit_Type__c = 'SU';
        s.Zip__c ='20002';
        s.Zip_4__c = NULL;
        s.QAS_Mailing_POBox__c = NULL;
        s.QAS_Mailing_Record_Type__c = NULL;
        s.Copy_Address_to_Billing__c = true;
        s.QAS_Mailing_Record_Type__c = 'P';
        s.Contact_Type__c = 'Broker';
        s.Subscription_Type__c = 'Licensee';
        s.County__c = 'Fairfax';
        s.Contact__c = c.id;
		insert s;
        
        Relationship__c rel = new Relationship__c();
        rel.Contact__c = c.id;
        rel.Broker_Office__c = c.name;
        rel.Subscription__c = s.id;
        rel.Relationship_Type__c = 'Franchisor';
        insert rel;
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addParameter('contactID',c.id);
        req.addParameter('role',null);
        System.debug('primary sub: ' + c.Primary_Subscription_ID__c + '.');
        System.debug('compare to: 777789' + '.');
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetRelationshipsByContactID/';
        //req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetRelationshipsByContactID/123456';
        //req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetRelationshipsByContactID/' + c.Primary_Subscription_ID__c;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
        List<Relationship__c> ra = RelationshipsByContactID.doGet();
        //System.debug('contact id: ' + c.id + ' rels?: ' + ra.size() + ' what rel?: ' + ra[0].Relationship_Type__c);// + ' one rel type: ' + ra[0].Relationship_Type__c);
        //System.assertEquals(1, ra.size());
      
 
  }
  
}