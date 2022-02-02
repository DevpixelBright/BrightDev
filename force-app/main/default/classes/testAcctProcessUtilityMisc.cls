@isTest
public with sharing class testAcctProcessUtilityMisc {
  
   public static testmethod void testAcctProcessUtilityMisc() {       
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
        a13.name = 'ADA1334';
        a13.type = 'Residential';
        a13.Account_Name__c = 'Test Account';
        a13.City__c = 'Herndon';
        a13.Zip__c = '20171';
        a13.QAS_Mailing_County__c = 'Fairfax';
        a13.County__c = 'Fairfax';
        a13.Street_Type__c = '';
        a13.Billing_Street_Type__c = 'BLFS';
        a13.QAS_Mailing_Street_Type__c ='test';
        a13.Company_Type__c = 'Corporate Office';       
        insert a13;  
        
        System.debug('Tester Inserted A13 ID: ---> ' + a13.id);           
 
        Account a12 = new Account();
        a12.name = 'ADA1284';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';
        a12.Street_Type__c = '';
        a12.Billing_Street_Type__c = 'BLFS';
        a12.QAS_Mailing_Street_Type__c ='test';
        a12.Company_Type__c = 'Corporate Office';
        
        insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);    

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
        a.Company_Type__c = 'Corporate Office';
              
        insert a;       
      
        System.debug('Tester After a Insert ID: ---> ' + a.id);     
        
        Account a2 = new Account();
        a2.Name = 'CASE3216';
        a2.type = 'Residential';
        a2.Account_Name__c = 'Test Account';
        a2.City__c = 'Herndon';
        a2.Zip__c = '20171';
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.County__c = 'Fairfax';
        a2.Street_Type__c = '';
        a2.Billing_Street_Type__c = 'BLFS';
        a2.QAS_Mailing_Street_Type__c ='test';
        a2.Company_Type__c = 'Corporate Office';	
        
        insert a2; 
        System.debug('Tester After a2 Insert ID: ---> ' + a2.id);       
        
        
  
        Relationship__c rr = new Relationship__c();
        rr.Relationship_Type__c = 'Corporate';
        //rr.Subscription__c =   s1.id;
        rr.Related_Account__c = a13.id;
        rr.MDS_Status__c = 'Success';
        rr.Broker_Office__c = a.id;
        //rr.Contact__c = s1.Contact__c;
  		rr.Relationship_End_Date__c  = null; 
        insert rr;
       System.debug('Tester   Relationship__c  rr Insert ID: ---> ' + rr.id); 
       
       
   
        Relationship__c rr2 = new Relationship__c();
        rr2.Relationship_Type__c = 'Corporate';
        //rr.Subscription__c =   s1.id;
        rr2.Related_Account__c = a.id;
        rr2.MDS_Status__c = 'Success';
        rr2.Broker_Office__c = a13.id;
        //rr.Contact__c = s1.Contact__c;
  		rr2.Relationship_End_Date__c  = null; 
        insert rr2;
       System.debug('Tester   Relationship__c  rr2 Insert ID: ---> ' + rr2.id);       
              
        
        /*Related_Association__c r1 = new Related_Association__c();
        r1.Broker_Code__c = a.id;
        //r1.Association_Name__c ='Corporate';
        r1.Primary__c = true;
        r1.Association__c = a13.id;   
        r1.Status__c = 'Active';
                    
        insert r1;
        System.debug('Tester After r1 Insert ID: ---> ' + r1.id);      
        
        
       Related_Association__c r2 = new Related_Association__c();
        r2.Broker_Code__c = a13.id;
        r2.Primary__c = true;
        r2.Association__c = a2.id;
        r2.Status__c = 'Active';        
        insert r2;   
        
        //create a 3rd like 2 but have assoc officekey null worth 2 lines see line 520
        
         System.debug('Tester After r2 Insert ID: ---> ' + r2.id);    */           
   
 
        
        test.stopTest();
              
       // myAcct.valueS = s1.id;
       // myAcct.valueC = c1.id;
        
    }
}