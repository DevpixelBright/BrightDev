@isTest()
public with sharing class testSubscriptionUtilRuleInactive {
    private static Account defaultAccount() {
        Account acc = new Account();
        acc.Name = 'TESW321';
        acc.Account_Name__c = 'Testing Account';
        acc.type = 'Residential';
        acc.Company_Type__c = 'Branch Office';
        acc.Shareholder_Board__c = 'None';
        acc.Street_Number__c = '6824';
        acc.Street_Name__c = 'Dean';
        //acc.Street_Type__c = 'DRIVE, DR';
        acc.Zip__c = '22101';
        acc.City__c = 'Herndon';
        acc.State__c = 'VA';
        acc.County__c = 'Fairfax';
        acc.Country__c = 'UNITED STATES';
        acc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        acc.Phone = '5559991234';
        return acc;
     }
     
     private static Account createAccountWithAddress() {
    
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
    
        Account acc = new Account();
        acc.Street_Number__c = '68242';
        acc.Street_Name__c = 'Dean2';
        //acc.Street_Type__c = 'DRIVE, DR';
        
        acc.Name = 'TEST321';
        acc.Account_Name__c = 'Testing Account2';
        acc.type = 'Residential';
        acc.Company_Type__c = 'Branch Office';       
        acc.Zip__c = '22101';
        acc.City__c = 'Herndon';
        acc.State__c = 'VA';
        acc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        acc.County__c = 'Fairfax';
        acc.Country__c = 'UNITED STATES';
        return acc;
     }
     
      public static void sleep(Integer millis) {
        Integer start = System.Now().millisecond();
        while(System.Now().millisecond() <  start + millis);
     }   
     
     public static testmethod void testSubscriptionUtilInactive() {
        
        
        Test.StartTest();
        
        CornerstoneAddrUtility cau1 = new CornerstoneAddrUtility();
        cau1.addAddrs();     
        
        
           
           
        CornerstoneMappings__c cm191 = new CornerstoneMappings__c();
        cm191.TypeName__c = 'Status Inactive';
        cm191.CornerStoneID__c = ' 50000016002';
        insert cm191;           
           
         CornerstoneMappings__c cm19 = new CornerstoneMappings__c();
        cm19.TypeName__c = 'Status Active';
        cm19.CornerStoneID__c = ' 50000016001';
        insert cm19;      

        CornerstoneMappings__c cm13 = new CornerstoneMappings__c();
        cm13.TypeName__c = 'Broker Office';
        cm13.CornerStoneID__c = ' 10041844140';
        insert cm13;
        
        
        
        CornerstoneMappings__c cm14 = new CornerstoneMappings__c();
        cm14.TypeName__c = 'MRIS Vendor';
        cm14.CornerStoneID__c = ' 50000131624';
        insert cm14;       
        
        CornerstoneMappings__c cm15 = new CornerstoneMappings__c();
        cm15.TypeName__c = 'MRIS';
        cm15.CornerStoneID__c = ' 50000900598';
        insert cm15; 
       
         CornerstoneMappings__c cm1 = new CornerstoneMappings__c();
        cm1.TypeName__c = 'Association';
        cm1.CornerStoneID__c = '10234163875';
        insert cm1;
        
        CornerstoneMappings__c cm2 = new CornerstoneMappings__c();
        cm2.TypeName__c = 'Branch Office';
        cm2.CornerStoneID__c = '10041844141';
        insert cm2;
        
        
        CornerstoneMappings__c cm3 = new CornerstoneMappings__c();
        cm3.TypeName__c = 'Office';
        cm3.CornerStoneID__c = '10000065693';
        insert cm3;    
        
        CornerstoneMappings__c cm4 = new CornerstoneMappings__c();
        cm4.TypeName__c = 'Stockholder';
        cm4.CornerStoneID__c = '50000016059';
        insert cm4;        
        
        CornerstoneMappings__c cm5 = new CornerstoneMappings__c();
        cm5.TypeName__c = 'Agent';
        cm5.CornerStoneID__c = '10391959693';
        insert cm5;        
        
        CornerstoneMappings__c cm6 = new CornerstoneMappings__c();
        cm6.TypeName__c = 'Edit';
        cm6.CornerStoneID__c = '10244895319';
        insert cm6;        
            
        CornerstoneMappings__c cm7 = new CornerstoneMappings__c();
        cm7.TypeName__c = 'Lister';
        cm7.CornerStoneID__c = '10244895320';
        insert cm7; 
        
        CornerstoneMappings__c cm8 = new CornerstoneMappings__c();
        cm8.TypeName__c = 'Search';
        cm8.CornerStoneID__c = '10244895323';
        insert cm8;     
        
        CornerstoneMappings__c cm9 = new CornerstoneMappings__c();
        cm9.TypeName__c = 'Realtor/Shareholder';
        cm9.CornerStoneID__c = '50000131634';
        insert cm9;    
        
        
        CornerstoneMappings__c cm10 = new CornerstoneMappings__c();
        cm10.TypeName__c = 'System-MRIS';
        cm10.CornerStoneID__c = '50001337575';
        insert cm10;        
           
            
        CornerstoneMappings__c cm11 = new CornerstoneMappings__c();
        cm11.TypeName__c = 'Status Duplicate';
        cm11.CornerStoneID__c = '50000016003';
        insert cm11;         
 
        Map<ID,CornerstoneMappings__c> mappings = new  Map<ID,CornerstoneMappings__c>([SELECT id, TypeName__c,CornerstoneID__c FROM CornerstoneMappings__c where TypeName__c in ('Office', 'Association', 'Stockholder','Branch Office')]);
        System.debug('Map Totals ---->' + mappings.size());       
        
        Account a12 = new Account();
        a12.name = 'WDE1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '22101';
        a12.State__c = 'VA';
        a12.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a12.County__c = 'Fairfax';
        a12.Country__c = 'UNITED STATES';       
        a12.company_type__c = 'Corporate Office';
        insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);
        
        Account b = defaultAccount();
        b.Company_Type__c = 'Broker Office';
        b.Status__c = 'In Progress';
        b.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        b.parentid = a12.id;
        
        
        insert b; 
        System.debug('Tester After b Insert ID: ---> ' + b.id);   
        
        Account ac =   createAccountWithAddress();
        ac.Company_Type__c = 'Broker Office';
        ac.Status__c = 'In Progress';
        ac.parentid = a12.id;
        
        //insert ac; 
        System.debug('Tester Afterac Insert ID: ---> ' + ac.id);            
        
          //Create a Contact
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Jimmy';
        c1.LastName = 'Parks';
        c1.Status__c = 'Active';
        //c1.Public_Email__c = 'jparks@rainmaker-llc.com';
        //c1.Email = 'jparks@rainmaker-llc.com';
        c1.Phone = '443-739-0628';
        c1.City__c = 'Balimore';
        c1.State__c = 'MD';
        //c1.County__c = 'Baltimore City';
        c1.Zip__c = '21224';    
        c1.Professional_Designations__c='CPM';
        c1.Middle_Name__c ='Chip';
        c1.QAS_Mailing_County__c = 'Arlington';
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        
        
        
        insert c1;

        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.AgentKey__c = '123456700';
        s1.Name = '1239090';
        s1.status__c = 'In Progress';
        //s1.City__c = 'Baltimore';
        //s1.County__c = 'Baltimore City';
        //s1.Zip__c = '21224';
        s1.Contact__c = c1.Id;
        s1.Related_Location_Broker_Office__c = b.id;
        s1.Contact_type__c = 'Vendor';
        s1.Subscription_Type__c = 'MRIS Vendor';
        s1.Addl_Display_Name__c = 'Test Display';
        //s1.Box__c = 'PO Box';
        s1.Mobile_Phone__c  = '2404569098';
        s1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s1.Public_Email__c = 'jpuckett@aol.com';
        s1.Fax__c = '2402439878';
        s1.Home_Fax__c = '3012409090';
        s1.County__c = 'Fairfax';
        s1.Agent_Office_Phone__c = '3013529000';
        s1.Pager__c = '3012409898';
        //s1.Date_Reinstated__c = today;
        //s1.State__c = 'MD';
        //s1.Street_Type__c = 'ROAD, RD';
        //s1.Street_Direction__c ='S, SOUTH';
        //s1.Unit__c ='STE, SUITE';
        s1.VM_Ext__c = '123';
        s1.Voicemail__c = '3013524343';
        s1.Website__c= 'www.tester.com';
        s1.Zip_4__c = '3549';
      //  s1.primary__c = true;
        insert(s1);

        s1.status__c = 'Active';
        update(s1);
        
        //sleep(98);        
        
        Relationship__c rr = new Relationship__c();
        rr.Relationship_Type__c = 'Broker Office';
        rr.Subscription__c = s1.id;
        rr.Related_Account__c = ac.id;
        rr.MDS_Status__c = 'Success';
        rr.Broker_Office__c = b.id;
        //insert rr;
        
        Relationship__c rr2 = new Relationship__c();
        rr2.Relationship_Type__c = 'Data Provider';
        rr2.Subscription__c = s1.id;
        rr2.Related_Account__c = ac.id;
        rr2.MDS_Status__c = 'Success';
        //rr2.Broker_Office__c = b.id;
        //insert rr2;
        
        
        Subscription_Role__c sr2= new Subscription_Role__c ();
        sr2.Role__c = 'Agent';
        sr2.Status__c = 'Active';
        sr2.sysPrRoleKey__c = '89752575199';
        sr2.Subscription__c = s1.id;
        sr2.Role__c = 'Status Inactive';
        
        insert sr2;
        
        Subscription_Role__c sr1 = new Subscription_Role__c ();
        sr1.Role__c = 'Applied Video';
        sr1.Status__c = 'Active';
        sr1.sysPrRoleKey__c = '89752575777';
        sr1.Subscription__c = s1.id;
        sr1.Role__c = 'Status Inactive';
        insert sr1;     
        
        
    
        
        //update Subscription  ('RULE28');
        s1.Status_Change_Reason__c = 'Reinstate';
        s1.Status_Change_Fee__c = 'No Charge';
        s1.status__c = 'InActive';
        //s1.primary__c = false;  
        update s1;   
        //Class.SFQPConnectorUtility.process: line 24, column 1  Null
 
 
         sr1.Status__c = 'Active';
         update sr1;
         
         sr2.Status__c = 'Active';
         update sr2;             
        
        //update Subscription  ('RULE28');
        s1.Status_Change_Reason__c = 'Reinstate';
        s1.Status_Change_Fee__c = 'No Charge';
        s1.status__c = 'Active';
        //s1.primary__c = false;  
        update s1;                      

        
        test.StopTest();
     }
}