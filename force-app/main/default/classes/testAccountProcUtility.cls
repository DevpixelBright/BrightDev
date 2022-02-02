@isTest()
public with sharing class testAccountProcUtility {
   
   public static testmethod void testAccountProcUtility() {       
        test.starttest();
        
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
        cm5.TypeName__c = 'Association Member';
        cm5.CornerStoneID__c = '10323920993';
        insert cm5;        
        
        CornerstoneMappings__c cm6 = new CornerstoneMappings__c();
        cm6.TypeName__c = 'RETS';
        cm6.CornerStoneID__c = '50000738089';
        insert cm6;        
            
        CornerstoneMappings__c cm7 = new CornerstoneMappings__c();
        cm7.TypeName__c = 'Vendor';
        cm7.CornerStoneID__c = '50000738092';
        insert cm7; 
        
        CornerstoneMappings__c cm8 = new CornerstoneMappings__c();
        cm8.TypeName__c = 'Association Member Primary';
        cm8.CornerStoneID__c = '50000016058';
        insert cm8;     
        
        CornerstoneMappings__c cm9 = new CornerstoneMappings__c();
        cm9.TypeName__c = 'Corporate';
        cm9.CornerStoneID__c = '50000738084';
        insert cm9;  
        
        CornerstoneMappings__c cm11 = new CornerstoneMappings__c();
        cm11.TypeName__c = 'Commercial';
        cm11.CornerStoneID__c = '50000738083';
        insert cm11;                   
              
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        

        
        Account a13 = new Account();
        a13.name = 'ABC133';
        //a12.type = 'Association';
        a13.Account_Name__c = 'Test Account';
        a13.City__c = 'Herndon';
        a13.Zip__c = '20171';
        a13.OfficeKey__c = 'TESS1234';        
        a13.CS_AccountTypeRole_ID__c = '';
        a13.status__c = 'Active';
        a13.type = 'Corporate';
        a13.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a13.Company_Type__c = 'Corporate Office';        
        a13.County__c = 'Fairfax';
        insert a13;  
        
        System.debug('Tester Inserted A13 ID: ---> ' + a13.id);           
 
        Account a12 = new Account();
        a12.name = 'ABC1234';
        a12.type = 'Association';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.OfficeKey__c = 'TESS1234';        
        a12.company_type__c = 'Corporate Office';
        //a12.Fax = '(301)234-5678';
        //a12.Phone = '(301)352-9090-1111';
        a12.PIN__c = '1234';
        a12.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a12.County__c = 'Fairfax';
        a12.Website = 'www.mywebsite.com';
        a12.Trading_As__c = 'TERW';
        a12.Box__c = 'BOW';
        
        insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);    

        Account a = new Account();
        a.Name = 'CASE321';
        a.Account_Name__c = 'Testing Account';
        a.type = 'Corporate';
        a.Company_Type__c = 'Corporate Office';
        a.OfficeKey__c = 'TETS1234';
        a.Shareholder_Board__c = 'None';
        a.Street_Number__c = '6824';
        a.Street_Name__c = 'Dean';
        //a.Street_Type__c = 'DRIVE, DR';
        a.Zip__c = '22101';
        a.City__c = 'Herndon';
        a.State__c = 'VA';
        a.County__c = 'Fairfax';
        a.Country__c = 'UNITED STATES';
        a.Phone = '5559991234';
        a.Company_Type__c = 
        a.Status__c = 'In Progress';
        a.parentid = a12.id;
        a.PIN__c = '1234';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.County__c = 'Fairfax';
        a.Website = 'www.mywebsite.com';
        a.Trading_As__c = 'TERW';
        a.Box__c = 'BOW';
             
        insert a; 
        System.debug('Tester After a Insert ID: ---> ' + a.id);     
        
        Account a2 = new Account();
        a2.Name = 'CASE3214';
        a2.OfficeKey__c = '909090';
        a2.Account_Name__c = 'Testing Account';
        a2.type = 'Corporate';
        a2.Company_Type__c = 'Corporate Office';
        a2.Shareholder_Board__c = 'None';
        a2.Street_Number__c = '6824';
        a2.Street_Name__c = 'Dean';
        //a.Street_Type__c = 'DRIVE, DR';
        a2.Zip__c = '22101';
        a2.City__c = 'Herndon';
        a2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a2.County__c = 'Fairfax';
        a2.State__c = 'VA';
        a2.County__c = 'Fairfax';
        a2.Country__c = 'UNITED STATES';
        a2.Phone = '5559991234';
        a2.Company_Type__c = 
        a2.Status__c = 'In Progress';

        
        insert a2; 
        System.debug('Tester After a2 Insert ID: ---> ' + a2.id);       
        
        Related_Association__c r1 = new Related_Association__c();
        r1.Broker_Code__c = a.id;
        r1.Primary__c = true;
        r1.Association__c = a12.id;   
        r1.Status__c = 'Active';
                    
        insert r1;
        System.debug('Tester After r1 Insert ID: ---> ' + r1.id);       
        
        
       Related_Association__c r2 = new Related_Association__c();
        r2.Broker_Code__c = a.id;
        r2.Primary__c = false;
        r2.Association__c = a12.id;
        r2.Status__c = 'Active';        
        insert r2;   
        
         System.debug('Tester After r2 Insert ID: ---> ' + r2.id);              
 
        Relationship__c rr = new Relationship__c();
        rr.Relationship_Type__c = 'Corporate';
        //rr.Subscription__c =   s1.id;
        rr.Related_Account__c = a12.id;
        rr.MDS_Status__c = 'Success';
        rr.Broker_Office__c = a.id;
        //rr.Contact__c = s1.Contact__c;
       
        insert rr;
       System.debug('Tester   Relationship__c  rr Insert ID: ---> ' + rr.id);    
              
        
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
        c1.County__c = 'Baltimore City';
        c1.Zip__c = '21224';    
        c1.Professional_Designations__c='CPM';
        c1.Middle_Name__c ='Chip';
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        
        
        insert c1;
        a.CS_Shareholder_ID__c ='1200002';        
        a.Shareholder_Board__c = 'No';
        update a;
        System.debug('Tester a update --->');
        
        a2.Shareholder_Board__c = 'Yes';
        update a2;
        System.debug('Tester a2 update --->');    
 
        a13.status__c = 'Inactive';     
        a13.type = 'Commercial';        
        a13.company_type__c = 'Broker Office'; 
        update a13;     
        
        a13.status__c = 'Active';       
        //a13.type = 'Commercial';        
        //a13.company_type__c = 'Broker Office'; 
        update a13; 
        
        test.stopTest();
              
       // myAcct.valueS = s1.id;
       // myAcct.valueC = c1.id;
        
    }
}