@isTest
public class testCaseLinkerBatch {
    
   public static Account mockAccountRecord(){       
       CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
       cau.addAddrs();    
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
       return a;
   }
   
   public static Contact mockContactRecords(string AccountId) {     
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = AccountId; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        c.County__c = 'Fairfax';
        insert c;
        return c;
   }
   
   public static License__c mockLicenseRecords(string ContactId) {      
        License__c l = new License__c();
        l.Name = '123456';
        l.License_Expiration_Date__c = Date.today();
        l.License_State__c = 'VA';
        l.License_Type__c = 'Broker';
        //l.IsDeleted = false;
        l.Contact__c = ContactId;
        insert l;
        return l;
   }
   
   public static Subscriptions__c mockSubscriptionsRecords(string AccountId,String LicenseId,String ContactId) {     
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = 'Test Subscription';
        s.Contact__c = ContactId;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.License__c = LicenseId;
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.AgentKey__c = '123111';
        s.name = '123111';
        s.Related_Location_Broker_Office__c = AccountId;
        s.Contact_Type__c = 'Agent';
        s.Primary__c = true;
        s.Public_Email__c = 'test@something.com';
        s.Addl_Display_Name__c = 'xyz';
        s.Box__c = NULL;
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
        s.Zip_4__c = NULL;
        s.QAS_Mailing_POBox__c = NULL;
        s.QAS_Mailing_Record_Type__c = NULL;
        s.Copy_Address_to_Billing__c = true;
        s.QAS_Mailing_Record_Type__c = 'P';
        s.Contact_Type__c = 'Broker';
        s.Subscription_Type__c = 'Licensee';
        s.County__c = 'Fairfax';
        insert s;
        return s;
        
        
   }  
   
   public static Subscription_License__c mockSubscriptionLicenseRecords(String LicenseId,String SubscriptionId) {     
        Subscription_License__c subLicObj = new Subscription_License__c();
        subLicObj.License__c = LicenseId;
        subLicObj.Subscription__c = SubscriptionId;
        insert subLicObj;  
        return subLicObj;     
   }
   
   public static Entitlement mockEntitlementRecords(String AccountId) { 
         Entitlement en = new Entitlement();
         en.Name = 'TestEn';
         //en.Account = a;
         en.AccountId = AccountId;
         insert en;
         return en;
   }
   
   public static list<Case> mockCaseRecords(String ContactId, String entitleId,Contact c) { 
        list<Case> casesList = new list<Case>();
        Case ca = new Case();
        ca.Contact = c;
        //ca.ContactPhone = c1.Phone;
        //ca.ContactEmail = c1.Email;
        ca.Origin = 'Email'; 
        ca.Description='from unit test';
        ca.Subject ='testing trigger';
        ca.Status='New';
        ca.ContactId = ContactId;
        ca.SuppliedEmail='test@something.com';
        ca.EntitlementID = entitleId;
        casesList.add(ca); 
        
        Case ca2 = new Case();
        ca2.Contact = c;
        //ca.ContactPhone = c1.Phone;
        //ca.ContactEmail = c1.Email;
        ca2.Origin = 'Email'; 
        ca2.Description='from unit test';
        ca2.Subject ='testing trigger';
        ca2.Status='New';
        ca2.ContactId = null;
        ca2.SuppliedEmail='test@something.com';
        ca2.EntitlementID = entitleId;
        casesList.add(ca2);    
     
        Case ca3 = new Case();
        ca3.Contact = c;
        //ca.ContactPhone = c1.Phone;
        //ca.ContactEmail = c1.Email;
        ca3.Origin = 'Email'; 
        ca3.Description='from unit test';
        ca3.Subject ='testing trigger';
        ca3.Status='New';
        ca3.ContactId = ContactId;
        ca3.SuppliedEmail='test@something.com';
        ca3.EntitlementID = entitleId;
        casesList.add(ca3);
        
        Case ca4 = new Case(); 
        ca4.Contact = c;
        //ca.ContactPhone = c1.Phone;
        //ca.ContactEmail = c1.Email;
        ca4.Origin = 'Email'; 
        ca4.Description='from unit test';
        ca4.Subject ='testing trigger'; 
        ca4.Status='New';
        ca4.ContactId = null;
        ca4.SuppliedEmail='testNew@something.com';
        ca4.EntitlementID = entitleId;
        casesList.add(ca4); 
        insert casesList;
        return casesList;
   }
   
   public static testmethod void testCaseLinkerBatch() {  
        //  ca.CreatedDate = system.now();
        //Insert the case record that cause the trigger to execute
        //CaseLinkerBatch.Process(new List<Case>{ca});
        //Test Case with multiple same email as subscription no contactid
        Account objAcc1 = mockAccountRecord();
        Contact con = mockContactRecords(objAcc1.Id);
        License__c l = mockLicenseRecords(con.Id);
        Subscriptions__c objSub= mockSubscriptionsRecords(objAcc1.Id,l.Id,con.Id);
        
        Subscription_Role__c sr2= new Subscription_Role__c ();
        sr2.Role__c = 'Status Duplicate';
        sr2.Status__c = 'Active';
        sr2.sysPrRoleKey__c = '89752575199';
        sr2.Subscription__c = objSub.id;
        insert sr2;
        
        Subscription_License__c objSunLic = mockSubscriptionLicenseRecords(l.Id,objSub.Id);
        Entitlement objEnt = mockEntitlementRecords(objAcc1.Id);
        list<Case> casesList = mockCaseRecords(con.Id, objEnt.Id,con);
        
        CaseLinkerBatch obj = new CaseLinkerBatch();
        obj.Process(casesList);
        obj.Process(new list<Case>{casesList.get(1)});
        
        /*For second case
        CaseLinkerBatch obj1 = new CaseLinkerBatch();
        List<Case> cl1 = new List<Case>();
        List<Case> c21 = new List<Case>();
        cl1.add(ca);
        cl1.add(ca2);
        cl1.add(ca3);
        c21.add(ca4);
        obj1.Process(cl1);
        obj1.Process(c21); 
     /*       
        //Test Case with one same email as subscription no contactid         
        Case cc1 = new Case();
        cc1.Origin = 'Email'; 
        cc1.Description='from unit test';
        cc1.Subject ='testing trigger';
        
        
        cc1.Status='New';        
        cc1.SuppliedEmail = 'jpuckett@aol.com';
        insert(cc1);       
       
        Case cc2= new Case();
        cc2.Origin = 'Email'; 
        cc2.Description='from unit test';
        cc2.Subject ='testing trigger';
        cc2.Status='New';        
          
          
        //Test Case with  contactid   
       
        cc2.contactid = c1.id;
        insert(cc2);
   */
       //   Test.StopTest();   
    }
    
    //Second Test
     public static testmethod void testCaseLinkerBatch1() {  
        //  ca.CreatedDate = system.now();
        //Insert the case record that cause the trigger to execute
        //CaseLinkerBatch.Process(new List<Case>{ca});
        //Test Case with multiple same email as subscription no contactid
        Account objAcc1 = mockAccountRecord();
        Contact con = mockContactRecords(objAcc1.Id);
        License__c l = mockLicenseRecords(con.Id);
        Subscriptions__c objSub= mockSubscriptionsRecords(objAcc1.Id,l.Id,con.Id);
        Subscription_Role__c sr2= new Subscription_Role__c ();
        sr2.Role__c = 'Status Duplicate';
        sr2.Status__c = 'Active';
        sr2.sysPrRoleKey__c = '89752575199';
        sr2.Subscription__c = objSub.id;
        insert sr2;
        Subscription_License__c objSunLic = mockSubscriptionLicenseRecords(l.Id,objSub.Id);
        Entitlement objEnt = mockEntitlementRecords(objAcc1.Id);
        list<Case> casesList = mockCaseRecords(con.Id, objEnt.Id,con);
        
        
        CaseLinkerBatch obj = new CaseLinkerBatch();
        obj.Process(casesList);
        obj.Process(new list<Case>{casesList.get(1)});
     }
}