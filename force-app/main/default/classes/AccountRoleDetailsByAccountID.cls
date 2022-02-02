/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return all the Related Agent information based on the subscriptionID (AgentKey) information.  
* If no subscriptionID (AgentKey) information is found,  salesforce returns an empty return structure 
**/
@RestResource(urlMapping='/GetAccountRoleDetailsByAccountID/*')
global with sharing class AccountRoleDetailsByAccountID {
//put debug statements here and then run pingtest (log in as this user in build demo)
    global class GetAccountRoleDetailsByAccountID {
        
            Integer totalSize = 0;
            List <AccountContactRole> arList = new List<AccountContactRole>();
            List <Relationship__c> relatedOfficeList = new List<Relationship__c>();
            List <Relationship__c> brokerOfficeList =  new List<Relationship__c>();
            List <Related_Association__c> subscriptionAssociationAsAssociation =  new List<Related_Association__c>();
            List <Related_Association__c> subscriptionAssociationAsOffice =  new List<Related_Association__c>();
        
    }
  
   @HttpGet
   global static  GetAccountRoleDetailsByAccountID doGet() {
        System.debug('RestContext ---> '+ RestContext.request); 
        System.debug('RestContext ---> '+ RestContext.response);
        
        GetAccountRoleDetailsByAccountID gt = new GetAccountRoleDetailsByAccountID();
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('uri ---> ' + req.params);
        
       
        Map <String,String> urlValues = req.params;
        String accountID;
        String role;
        
        
            accountID = urlValues.get('accountID');
            role = urlValues.get('role');
            
       
        System.debug('accountID ' + accountID + '.');
        boolean isAssociation=false;
        boolean isAssociationMemberPrimary=false;
        System.debug('role ' + role + '.');
        if (Utils.isNotNull(role) && 
            (('Association Member'.equals(role)) || 'Association Member Primary'.equals(role))) {
            isAssociation = true;
            if ('Association Member Primary'.equals(role)) {
                isAssociationMemberPrimary = true;
            }
        }
        
        System.debug('isAssociation -->' + isAssociation);
        System.debug('isAssociationMemberPrimary -->' + isAssociationMemberPrimary);

        List <Account> acList = [SELECT ID FROM Account where Name = :accountID];
        
       
        
       if (acList.size() > 0) {
            List<AccountContactRole> aList = [Select a.SystemModstamp, a.Role, a.LastModifiedDate, a.LastModifiedById, a.IsPrimary, a.IsDeleted, a.Id, 
            a.CreatedDate, a.CreatedById, a.Contact.PrimarySubIDRollup__c, a.Contact.Date_Terminated__c, 
            a.Contact.Date_Joined__c, a.Contact.Date_Billing_Begins__c, a.Contact.Zip__c, a.Contact.Zip_4__c, 
            a.Contact.Website__c, a.Contact.Voicemail__c, a.Contact.VM_Ext__c, a.Contact.VIP__c, a.Contact.Unit__c, 
            a.Contact.Unit_Type__c, a.Contact.TaleoContactID__c, a.Contact.Suffix__c, a.Contact.Street_Type__c, 
            a.Contact.Street_Number__c, a.Contact.Street_Number_Suffix__c, a.Contact.Street_Name__c, a.Contact.Street_Direction__c, 
            a.Contact.Status__c, a.Contact.State__c, a.Contact.Public_Email__c, a.Contact.Professional_Designations__c, 
            a.Contact.PrismContactID__c, a.Contact.PrismAddressID__c, a.Contact.PrismAccountID__c, a.Contact.Primary_Subscription_ID__c, 
            a.Contact.Primary_Contact__c, a.Contact.PIN__c, a.Contact.Nickname__c, a.Contact.NRDS_ID__c, a.Contact.Middle_Name__c, 
            a.Contact.Home_Fax__c, a.Contact.Extension__c, a.Contact.Disabilities__c, a.Contact.County__c, a.Contact.Country__c, 
            a.Contact.Copy_Address_to_Billing__c, a.Contact.City__c, a.Contact.Categories__c, a.Contact.Box__c, 
            a.Contact.Billing_Zip__c, a.Contact.Billing_Zip_4__c, a.Contact.Billing_Unit_Type__c, a.Contact.Billing_Unit_Number__c, 
            a.Contact.Billing_Street_Type__c, a.Contact.Billing_Street_Number__c, a.Contact.Billing_Street_Number_Suffix__c, 
            a.Contact.Billing_Street_Name__c, a.Contact.Billing_Street_Direction__c, a.Contact.Billing_State__c, a.Contact.Billing_County__c, 
            a.Contact.Billing_Country__c, a.Contact.Billing_City__c, a.Contact.Billing_Box__c, a.Contact.Billing_Addl_Display_Name__c, 
            a.Contact.Agent_Office_Phone__c, a.Contact.Addl_Display_Name__c, a.Contact.JigsawContactId, a.Contact.Jigsaw, 
            a.Contact.EmailBouncedDate, a.Contact.EmailBouncedReason, a.Contact.LastCUUpdateDate, a.Contact.LastCURequestDate, 
            a.Contact.LastActivityDate, a.Contact.SystemModstamp, a.Contact.LastModifiedById, a.Contact.LastModifiedDate, 
            a.Contact.CreatedById, a.Contact.CreatedDate, a.Contact.OwnerId, a.Contact.Description, a.Contact.LeadSource, 
            a.Contact.Department, a.Contact.Title, a.Contact.Email, a.Contact.ReportsToId, a.Contact.OtherPhone, a.Contact.MobilePhone, 
            a.Contact.Fax, a.Contact.Phone, a.Contact.Name, a.Contact.Salutation, a.Contact.FirstName, a.Contact.LastName, 
            a.Contact.AccountId, a.Contact.MasterRecordId, a.Contact.IsDeleted, a.Contact.Id, a.ContactId, a.AccountId 
            From AccountContactRole a where a.accountID  = :acList.get(0).id];
            System.debug('account id of acList.get(0): ' + acList.get(0).id);
            if (acList != null){
                gt.arList.addAll(aList);
                gt.totalSize += aList.size();   
            }
        
            
           if (Utils.isNotNull(role)) { 
            gt.relatedOfficeList.addAll([Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Relationship_Type__c, 
                r.Relationship_Start_Date__c, r.Relationship_End_Date__c, r.Related_Account__c, 
                r.PrismRelationshipID__c, r.Personal_Assistant__c, r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Name, 
                r.MDS_Status__c, r.LastModifiedDate, 
                r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id, r.CreatedDate, 
                r.CreatedById, r.Contact__c, r.Broker_Office__c From Relationship__c r where r.related_account__c = :acList.get(0).id and r.Relationship_Type__c = :role and r.status__c = 'Active']);
           } else {
                gt.relatedOfficeList.addAll([Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Relationship_Type__c, 
                r.Relationship_Start_Date__c, r.Relationship_End_Date__c, r.Related_Account__c, 
                r.PrismRelationshipID__c, r.Personal_Assistant__c, r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Name, 
                r.MDS_Status__c, r.LastModifiedDate, 
                r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id, r.CreatedDate, 
                r.CreatedById, r.Contact__c, r.Broker_Office__c From Relationship__c r where r.related_account__c = :acList.get(0).id and r.Status__c = 'Active']);
           }
              System.debug('gt.relatedOfficeList size: ' + gt.relatedOfficeList.size());
            gt.totalSize += gt.relatedOfficeList.size();
            if (Utils.isNotNull(role)) { 
            gt.brokerOfficeList.addAll([Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Relationship_Type__c, 
                r.Relationship_Start_Date__c, r.Relationship_End_Date__c, r.Related_Account__c, 
                r.PrismRelationshipID__c, r.Personal_Assistant__c, r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Name, 
                r.MDS_Status__c, r.LastModifiedDate, 
                r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id, r.CreatedDate, 
                r.CreatedById, r.Contact__c, r.Broker_Office__c From Relationship__c r where r.Broker_Office__c = :acList.get(0).id and r.status__C='Active' and r.Relationship_Type__c = :role]);
                             
            } else {
                gt.brokerOfficeList.addAll([Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Relationship_Type__c, 
                r.Relationship_Start_Date__c, r.Relationship_End_Date__c, r.Related_Account__c, 
                r.PrismRelationshipID__c, r.Personal_Assistant__c, r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Name, 
                r.MDS_Status__c, r.LastModifiedDate, 
                r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id, r.CreatedDate, 
                r.CreatedById, r.Contact__c, r.Broker_Office__c From Relationship__c r where r.Broker_Office__c = :acList.get(0).id and r.status__C='Active']);
            }
             System.debug('gt.brokerOfficeList size: ' + gt.brokerOfficeList.size());
            gt.totalSize += gt.brokerOfficeList.size();
              if (Utils.isNotNull(role) && isAssociation) { 
                    if (isAssociationMemberPrimary) {
                        GT.SUBSCRIPTIONASSOCIATIONASASSOCIATION.ADDALL([SELECT R.SYSTEMMODSTAMP, R.SUBSCRIPTION__C, R.PRISMRELBOARDID__C, 
                        R.PRIMARY__C, R.OWNERID, R.NOTES__C, R.NAME, R.LASTMODIFIEDDATE, 
                        R.LASTMODIFIEDBYID, R.LASTACTIVITYDATE, R.ISDELETED, R.IMPORT_SOURCE__C, 
                        R.IMPORT_ID__C, R.ID, R.CREATEDDATE, R.CREATEDBYID, R.BROKER_CODE__C, 
                        R.ASSOCIATION__C FROM RELATED_ASSOCIATION__C R WHERE R.ASSOCIATION__C = :ACLIST.GET(0).ID AND R.STATUS__C='Active' AND R.PRIMARY__C = :true]);              
                    } else {
                        GT.SUBSCRIPTIONASSOCIATIONASASSOCIATION.ADDALL([SELECT R.SYSTEMMODSTAMP, R.SUBSCRIPTION__C, R.PRISMRELBOARDID__C, 
                        R.PRIMARY__C, R.OWNERID, R.NOTES__C, R.NAME, R.LASTMODIFIEDDATE, 
                        R.LASTMODIFIEDBYID, R.LASTACTIVITYDATE, R.ISDELETED, R.IMPORT_SOURCE__C, 
                        R.IMPORT_ID__C, R.ID, R.CREATEDDATE, R.CREATEDBYID, R.BROKER_CODE__C, 
                        R.ASSOCIATION__C FROM RELATED_ASSOCIATION__C R WHERE R.ASSOCIATION__C = :ACLIST.GET(0).ID AND R.STATUS__C='Active' AND R.PRIMARY__C = false]);
                    }
            
              } else  if (Utils.isNull(role)) {
                 gt.subscriptionAssociationAsAssociation.addAll([Select r.SystemModstamp, r.Subscription__c, r.PrismRelBoardID__c, 
                        r.Primary__c, r.OwnerId, r.Notes__c, r.Name, r.LastModifiedDate, 
                        r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, 
                        r.Import_ID__c, r.Id, r.CreatedDate, r.CreatedById, r.Broker_Code__c, 
                        r.Association__c From Related_Association__c r where r.Association__c = :acList.get(0).id and r.status__C='Active']);
              }
              System.debug('gt.subscriptionAssociationAsAssociation size: ' + gt.subscriptionAssociationAsAssociation.size());           
            gt.totalSize += gt.subscriptionAssociationAsAssociation.size();
              if (Utils.isNotNull(role) && isAssociation) {   
                if (isAssociationMemberPrimary) {       
                    gt.subscriptionAssociationAsOffice.addAll([Select r.SystemModstamp, r.Subscription__c, r.PrismRelBoardID__c, 
                                r.Primary__c, r.OwnerId, r.Notes__c, r.Name, r.LastModifiedDate, 
                                r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, 
                                r.Import_ID__c, r.Id, r.CreatedDate, r.CreatedById, r.Broker_Code__c, 
                                r.Association__c From Related_Association__c r where r.Broker_Code__c = :acList.get(0).id and r.status__C='Active' and r.Primary__c = true]);
                } else {
                    gt.subscriptionAssociationAsOffice.addAll([Select r.SystemModstamp, r.Subscription__c, r.PrismRelBoardID__c, 
                                r.Primary__c, r.OwnerId, r.Notes__c, r.Name, r.LastModifiedDate, 
                                r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, 
                                r.Import_ID__c, r.Id, r.CreatedDate, r.CreatedById, r.Broker_Code__c, 
                                r.Association__c From Related_Association__c r where r.Broker_Code__c = :acList.get(0).id and r.status__C='Active' and r.Primary__c = false]);
                }
              
              } else if (Utils.isNull(role)) {
                gt.subscriptionAssociationAsOffice.addAll([Select r.SystemModstamp, r.Subscription__c, r.PrismRelBoardID__c, 
                        r.Primary__c, r.OwnerId, r.Notes__c, r.Name, r.LastModifiedDate, 
                        r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, 
                        r.Import_ID__c, r.Id, r.CreatedDate, r.CreatedById, r.Broker_Code__c, 
                        r.Association__c From Related_Association__c r where r.Broker_Code__c = :acList.get(0).id and r.status__C='Active']);
              }
              System.debug('gt.subscriptionAssociationAsOffice size: ' + gt.subscriptionAssociationAsOffice.size());                        
            gt.totalSize += gt.subscriptionAssociationAsOffice.size();  
        }
        
        return gt; 
    }
    
  /*
    
 
    static  void testDoGet() {
        
            
         
        Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Vienna';
        a.Zip__c = '22182';
        insert a;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
         c.City__c = 'Vienna';
        c.Zip__c = '22182';
        
        insert c;
       
       License__c l = new License__c();
        l.Name = '123456';
        l.License_Expiration_Date__c = Date.today();
        l.License_State__c = 'VA';
        l.License_Type__c = 'Broker';
        //l.IsDeleted = false;
        l.Contact__c = c.id;
        insert l;
        
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = 'Test Subscription';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.License__c = l.id;
        s.City__c = 'Vienna';
        s.Zip__c = '22182';
        s.County__c = 'Fairfax';
        insert s;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/AccountRoleDetailsByAccountID?accountID=ABC1234';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
        //GetAccountRoleDetailsByAccountID gt = AccountRoleDetailsByAccountID.doGet();
        GetAccountRoleDetailsByAccountID gt = AccountRoleDetailsByAccountID.doGet();
        
        
        System.assertEquals(0, gt.totalSize);
        
         req.requestURI = 'https://cs10.salesforce.com/services/apexrest/AccountRoleDetailsByAccountID/accountID=AB21234&role=adfsd%20dasfasdf';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
         gt = AccountRoleDetailsByAccountID.doGet();
        
        
        System.assertEquals(0, gt.totalSize);
        
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/AccountRoleDetailsByAccountID?accountID=BLT1&role=Association%20Member%20Primary';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
         gt = AccountRoleDetailsByAccountID.doGet();
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/AccountRoleDetailsByAccountID?accountID=BLT1&role=Association%20Member';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
         gt = AccountRoleDetailsByAccountID.doGet();
        
        
        //System.assertEquals(0, gt.totalSize);
      
 
  }*/
}