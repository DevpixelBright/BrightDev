public class CaseLinkerBatch_UnitTest {

    static Map<String,Entitlement> em = new Map<String,Entitlement>();
    
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
        acc.QAS_Mailing_County__c = 'Fairfax';
        acc.County__c = 'Fairfax';
        acc.Country__c = 'UNITED STATES';
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
        acc.County__c = 'Fairfax';
        acc.Country__c = 'UNITED STATES';
        return acc;
     }
    static testMethod void caseLinkerTest1()
    {
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
        
        List<Case> caseList =  new List<case>();
        
        Account a12 = new Account();
        a12.name = 'WDE1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '22101';
        a12.State__c = 'VA';
        a12.County__c = 'Fairfax';
        a12.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a12.Country__c = 'UNITED STATES'; 
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';      
        a12.company_type__c = 'Corporate Office';
        insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);
        
        Account b = defaultAccount();
        b.Company_Type__c = 'Broker Office';
        b.Status__c = 'In Progress';
        b.QAS_Mailing_County__c = 'Fairfax';
        b.County__c = 'Fairfax';     
        b.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        b.parentid = a12.id;
        
        insert b; 
        System.debug('Tester After b Insert ID: ---> ' + b.id);   
        
        Account ac =   createAccountWithAddress();
        ac.Company_Type__c = 'Broker Office';
        ac.Status__c = 'In Progress';
        ac.QAS_Mailing_County__c = 'Fairfax';
        ac.County__c = 'Fairfax'; 
        ac.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        ac.parentid = a12.id;
        
        insert ac; 
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
         c1.QAS_Mailing_County__c = 'Arlington';
        //c1.County__c = 'Baltimore City';
        c1.Zip__c = '21224';    
        c1.Professional_Designations__c='CPM';
        c1.Middle_Name__c ='Chip';
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        
        
        insert c1;

        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.AgentKey__c = '123456700';
        s1.Name = '1239090';
        //s1.City__c = 'Baltimore';
        //s1.County__c = 'Baltimore City';
        //s1.Zip__c = '21224';
        s1.Contact__c = c1.Id;
        s1.Related_Location_Broker_Office__c = b.id;
        s1.status__c = 'In Progress';
        s1.Contact_type__c = 'Vendor';
        s1.Subscription_Type__c = 'MRIS Vendor';
        s1.Addl_Display_Name__c = 'Test Display';
        s1.Mobile_Phone__c  = '2404569098';
        s1.Fax__c = '2402439878';
        s1.Home_Fax__c = '3012409090';
        s1.Agent_Office_Phone__c = '3013529000';
        s1.VM_Ext__c = '123';
        s1.Voicemail__c = '3013524343';
        s1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s1.County__c = 'Fairfax';
        s1.Website__c= 'www.tester.com';
        s1.Public_Email__c ='test@caseLinkerBatch.com';
        s1.Zip_4__c = '3549';
        s1.primary__c = true;
        insert(s1);

        s1.status__c = 'Active';
        update(s1);        
        
        Case ca = new Case();
        ca.Contact = c1;
        //ca.ContactPhone = c1.Phone;
        //ca.ContactEmail = c1.Email;
        ca.Origin = 'Email'; 
        ca.Description='from unit test';
        ca.Subject ='testing trigger';
        ca.Status='New';
        ca.ContactId = c1.Id;
        caseList.add(ca);
       // insert(ca);
        
        
        Case ca1 = new Case();
        //ca1.Contact = c1;
        //ca1.ContactPhone = c1.Phone;
        //ca1.ContactEmail = c1.Email;
        ca1.Origin = 'Email'; 
        ca1.Description='from unit test';
        ca1.Subject ='testing trigger';
        ca1.Status='New';
        caseList.add(ca1);
        //insert(ca1);            


        Case ca2 = new Case();
        ca2.Contact = c1;
        ca2.Origin = 'Email'; 
        ca2.Description='from unit test';
        ca2.Subject ='testing trigger';
        ca2.Status='New';
        ca2.SuppliedEmail ='test@caseLinkerBatch.com';
        caseList.add(ca2);
        //insert(ca1);            

       CaseLinkerBatch caseLinkObj = new CaseLinkerBatch();
      // caseLinkObj.process(new List<Case>{ca});
        caseLinkObj.process(caseList);      
     
     //Query the database for the newly inserted records.
     LIST<CASE> insertedCase = [SELECT Status, Description,Origin,Subject FROM Case Where Id  =:ca.id];
     
     //Assert that proper values are in the fields
     for(Case ci :insertedCase){
     System.assertEquals('Email', ci.Origin);
     System.assertEquals('from unit test',ci.Description);
     System.assertEquals('testing trigger',ci.Subject);
     }        
    }
/*
    static testMethod void caseLinkerTest2()
    {
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
        
        List<Case> caseList =  new List<case>();
        
        Account a12 = new Account();
        a12.name = 'WDE1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '22101';
        a12.State__c = 'VA';
        a12.County__c = 'Fairfax';
        a12.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a12.Country__c = 'UNITED STATES'; 
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';      
        a12.company_type__c = 'Corporate Office';
        insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);
        
        Account b = defaultAccount();
        b.Company_Type__c = 'Broker Office';
        b.Status__c = 'In Progress';
        b.QAS_Mailing_County__c = 'Fairfax';
        b.County__c = 'Fairfax';     
        b.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        b.parentid = a12.id;
        
        insert b; 
        System.debug('Tester After b Insert ID: ---> ' + b.id);   
        
        Account ac =   createAccountWithAddress();
        ac.Company_Type__c = 'Broker Office';
        ac.Status__c = 'In Progress';
        ac.QAS_Mailing_County__c = 'Fairfax';
        ac.County__c = 'Fairfax'; 
        ac.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        ac.parentid = a12.id;
        
        insert ac; 
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
         c1.QAS_Mailing_County__c = 'Arlington';
        //c1.County__c = 'Baltimore City';
        c1.Zip__c = '21224';    
        c1.Professional_Designations__c='CPM';
        c1.Middle_Name__c ='Chip';
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        
        
        insert c1;

        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.AgentKey__c = '123456700';
        s1.Name = '1239090';
        s1.Contact__c = c1.Id;
        s1.Related_Location_Broker_Office__c = b.id;
        s1.status__c = 'In Progress';
        s1.Contact_type__c = 'Vendor';
        s1.Subscription_Type__c = 'MRIS Vendor';
        s1.Addl_Display_Name__c = 'Test Display';
        s1.Mobile_Phone__c  = '2404569098';
        s1.Fax__c = '2402439878';
        s1.Home_Fax__c = '3012409090';
        s1.Agent_Office_Phone__c = '3013529000';
        s1.VM_Ext__c = '123';
        s1.Voicemail__c = '3013524343';
        s1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s1.County__c = 'Fairfax';
        s1.Website__c= 'www.tester.com';
        s1.Public_Email__c ='test@caseLinkerBatch.com';
        s1.Zip_4__c = '3549';
        s1.primary__c = true;
        insert(s1);

        s1.status__c = 'Active';
        update(s1);
        
        //Create Subscription
        Subscriptions__c s2 = new Subscriptions__c();
        s2.AgentKey__c = '1234567001';
        s2.Name = '12390901';
        s2.Contact__c = c1.Id;
        s2.Related_Location_Broker_Office__c = b.id;
        s2.status__c = 'In Progress';
        s2.Contact_type__c = 'Vendor';
        s2.Subscription_Type__c = 'MRIS Vendor';
        s2.Addl_Display_Name__c = 'Test Display';
        s2.Mobile_Phone__c  = '2404569098';
        s2.Fax__c = '2402439878';
        s2.Home_Fax__c = '3012409090';
        s2.Agent_Office_Phone__c = '3013529000';
        s2.VM_Ext__c = '123';
        s2.Voicemail__c = '3013524343';
        s2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s2.County__c = 'Fairfax';
        s2.Website__c= 'www.tester.com';
        s2.Public_Email__c ='test@caseLinkerBatch.com';
        s2.Zip_4__c = '3549';
        insert(s2);
        
        s2.status__c = 'Active';
        update(s2);
        
        Case ca = new Case();
        ca.Contact = c1;
        //ca.ContactPhone = c1.Phone;
        //ca.ContactEmail = c1.Email;
        ca.Origin = 'Email'; 
        ca.Description='from unit test';
        ca.Subject ='testing trigger';
        ca.Status='New';
        ca.ContactId = c1.Id;
        caseList.add(ca);
       // insert(ca);
        
        
        Case ca1 = new Case();
        //ca1.Contact = c1;
        //ca1.ContactPhone = c1.Phone;
        //ca1.ContactEmail = c1.Email;
        ca1.Origin = 'Email'; 
        ca1.Description='from unit test';
        ca1.Subject ='testing trigger';
        ca1.Status='New';
        caseList.add(ca1);
        //insert(ca1);            


        Case ca2 = new Case();
        ca2.Contact = c1;
        ca2.Origin = 'Email'; 
        ca2.Description='from unit test';
        ca2.Subject ='testing trigger';
        ca2.Status='New';
        ca2.SuppliedEmail ='test@caseLinkerBatch.com';
        caseList.add(ca2);
        //insert(ca1);            
        
       CaseLinkerBatch caseLinkObj = new CaseLinkerBatch();
      // caseLinkObj.process(new List<Case>{ca});
        caseLinkObj.process(caseList);
     //Query the database for the newly inserted records.
     LIST<CASE> insertedCase = [SELECT Status, Description,Origin,Subject FROM Case Where Id  =:ca.id];
     //Assert that proper values are in the fields
     for(Case ci :insertedCase){
     System.assertEquals('Email', ci.Origin);
     System.assertEquals('from unit test',ci.Description);
     System.assertEquals('testing trigger',ci.Subject);
     }
    }
*/    
}