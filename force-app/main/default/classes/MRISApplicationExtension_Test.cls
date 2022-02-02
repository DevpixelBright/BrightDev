@isTest 
private class MRISApplicationExtension_Test{

    private static testMethod void doTestOne() {
Test.startTest();
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
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
        
        AggregateResult[] cntOfAccts = [Select  count(id) from CornerstoneMappings__c];
                for(AggregateResult ar : cntOfAccts ) {
                        System.debug('Account Totals:  '  + ar.get('expr0'));
                }
        
        Account a12 = new Account();
       a12.name = 'AGC1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';
        a12.Street_Type__c = '';
        a12.Billing_Street_Type__c = 'BLFS';
        a12.QAS_Mailing_Street_Type__c ='test';
        a12.Company_Type__c = 'Broker Office';
        a12.Type='Appraiser';
        insert a12;        
        
        //Create Test Accounts
        Account a1 = new Account();
        a1.name = 'ABC1234';
        a1.type = 'Residential';
        a1.Account_Name__c = 'Test Account';
        a1.City__c = 'Herndon';
        a1.Zip__c = '20171';
        a1.QAS_Mailing_County__c = 'Fairfax';
        a1.County__c = 'Fairfax';
        a1.Street_Type__c = '';
        a1.Billing_Street_Type__c = 'BLFS';
        a1.QAS_Mailing_Street_Type__c ='test';
        a1.parentid = a12.id;        
        insert(a1);
          
          
        Account a2 = new Account();
        a2.Name = 'TEST0002';
        a2.type = 'Residential';
        a2.Account_Name__c = 'Test Account';
        a2.City__c = 'Herndon';
        a2.Zip__c = '20171';
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.County__c = 'Fairfax';
        a2.Street_Type__c = '';
        a2.Billing_Street_Type__c = 'BLFS';
        a2.QAS_Mailing_Street_Type__c ='test';
        a2.parentid = a12.id;     
        insert(a2);
        
        
        /*Account a3 = new Account();
        a3.Name = 'TEST0003';
        a3.Account_Name__c = 'None Chosen';
        a3.Shareholder_Board__c = 'No';
        a3.Type = 'Association';
        a3.Status__c = 'Active';
        a3.City__c = 'Herndon';
        a3.Zip__c = '20171';
        a3.parentid = a12.id;       
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.County__c = 'Fairfax';
        a2.Street_Type__c = '';
        a2.Billing_Street_Type__c = 'BLFS';
        a2.QAS_Mailing_Street_Type__c ='test';
        insert(a3); */
        
        //Create a Contact
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Justin';
        c1.LastName = 'Padilla';
        c1.Status__c = 'Active';
        c1.Public_Email__c = 'jpadilla@rainmaker-llc.com';
        c1.Phone = '443-739-0628';
        c1.City__c = 'Herndon';
        c1.State__c = 'VA';
        c1.County__c = 'Fairfax';
        c1.Zip__c = '20171';            
        insert(c1);
         
        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.Name = 'test';
        s1.Status__c = 'In Progress';
        s1.Addl_Display_Name__c = 'xyz';
        s1.Box__c = NULL;
        s1.City__c = 'Herndon';
        s1.QAS_Mailing_Country__c = 'USA';
        s1.QAS_Mailing_County__c = 'Fairfax';
        s1.State__c = 'VA';
        s1.QAS_Mailing_Street_Direction__c = 'N';
        s1.Street_Name__c = 'First';
        s1.Street_Number__c ='1275';
        s1.Street_Number_Suffix__c = NULL;
        s1.QAS_Mailing_Street_Type__c = 'ST';
        s1.Unit__c = '1';
        s1.QAS_Mailing_Unit_Type__c = 'SU';
        s1.Zip__c ='20002';
        s1.Zip_4__c = NULL;
        s1.QAS_Mailing_POBox__c = NULL;
        s1.QAS_Mailing_Record_Type__c = NULL;
        s1.Copy_Address_to_Billing__c = true;
        s1.QAS_Mailing_Record_Type__c = 'P';
        s1.Contact_Type__c = 'Broker';
        s1.Subscription_Type__c = 'Licensee';
        s1.County__c = 'Fairfax';
        s1.Contact__c = c1.id;
        s1.primary__c = true;
        
        insert(s1);      
/*        
        //Create Subscription
        Subscriptions__c s2 = new Subscriptions__c();
        s2.AgentKey__c = '123456789';
        s2.Name = 'TEST';
        s2.City__c = 'Herndon';
        s2.County__c = 'Fairfax';
        s2.Zip__c = '20171';
        s2.Contact__c = c1.Id;
        insert(s2);
*/        
        Subscriptions__c sc = new Subscriptions__c();
        sc.Contact__c = c1.Id;
        sc.Name = '1234511';
        sc.Contact_Type__c = 'Agent';
        sc.Subscription_Type__c = 'Licensee';

        sc.Public_Email__c = 'email@something.com';
        sc.Status__c = 'In Progress';
        sc.Primary_Phone__c = '1231111643';
        sc.Public_Email__c = 'email@something.com';
        sc.Mobile_Phone__c = '1231112643';
        sc.City__c = 'Herndon';
        sc.Zip__c = '20171';
        sc.County__c = 'Fairfax';
        sc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc.Country__c = 'UNITED STATES';
        sc.State__c = 'VA';
        sc.Contact_Type__c = 'Agent';
        insert sc;
        
        
        MRIS_Application__c application = new MRIS_Application__c();
        Apexpages.StandardController controller = new Apexpages.StandardController(application);
        MRISApplicationExtension page = new MRISApplicationExtension(controller);
        page.getAppraiser();
        page.getRealtor();
        page.setAppraiserSelection(page.getAppraiserSelection());
        page.setRealtorSelection(page.getRealtorSelection());
        page.getAssociations();
        page.setAppraiserName(page.getAppraiserName());
                
        
        page.getshowAppraiser();
        page.getshowAppraiser2();
        page.setshowPDF(page.getshowPDF());
        page.getshowRealtor();
        page.getshortExpDate();
        
                
        page.setApplication(page.getApplication());
        page.setSubscription(); //No,No Personal Assistant
        page.setAppraiserSelection('Yes');
        page.setSubscription(); //Yes,No
        page.setRealtorSelection('Yes');
        page.setSubscription(); //Yes,Yes
        //Switch between share holder/non share holder
        page.selectedAssociation = 'TEST0001';
        page.setSubscription();
        page.selectedAssociation = 'TEST0002';
        page.setSubscription();
        
        page.setAppraiserSelection('No');
        page.setSubscription(); //No, Yes
             
        page.CompanyCode = 'TEST0001'; //Valid Account Name
        page.LookupCompanyCode();
        page.CompanyCode = ''; //Empty
        page.LookupCompanyCode();
        page.CompanyCode = 'Invalid'; //Invalid Account Name
        page.LookupCompanyCode();
               
        page.LookupAppraiserCode(); //null
        page.AppraiserCode = 'Invalid';
        page.LookupAppraiserCode(); //Invalid
        page.AppraiserCode = '123456789';
        page.LookupAppraiserCode(); //Valid
               
        application.First_Name__c = 'Justin';
        application.Last_Name__c = 'Padilla';
        application.Primary_Phone__c = '443-739-0628';
        application.Mobile_Phone__c = '443-739-0628';
        application.Public_Email__c = 'jpadilla@rainmaker-llc.com';
        // set Company_Code__c
        application.Company_Code__c = a12.Id;
        page.CompanyCode = 'TEST0001';
        page.LookupCompanyCode();
        page.Save();
               
        //Set Appraiser Selection back to yes
        page.setAppraiserSelection('Yes');
        page.Save();
        //Now set all months
        MRIS_Application__c app = page.getApplication();
        app.Date_Expires_Month__c = 'jan';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'feb';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'mar';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'april';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'may';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'june';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'july';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'aug';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'sept';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'oct';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'nov';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'dec';
        page.setApplication(app);
        page.Save();
        // set Company_Code__c
        app.Company_Code__c = a12.Id;
        page.setApplication(app);
        page.Save();

        //Set Year and Association
        app.Date_Expires_Year__c = '2015';              
        page.setApplication(app);
        page.selectedAssociation = 'TEST2';     
        page.Save();
        page.getshortExpDate();
        page.Print();       
        app = page.getApplication();
        System.debug('app..............'+app);
        //Test PDF Version
        app.Company_Code__c = a2.id;
        Apexpages.StandardController controller2 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);      
        System.debug('controller2.........'+controller2.getRecord().get('Company_Code__c'));
        try{
        MRISApplicationExtension page2 = new MRISApplicationExtension(controller2);
        //Test Different Subscription Types on PDF version
        app.Subscription_Type__c = 'Licensed Appraiser/Non Realtor';
        update(app);
        Apexpages.StandardController controller3 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
 //       MRISApplicationExtension page3 = new MRISApplicationExtension(controller3);
        
        app.Subscription_Type__c = 'Realtor/Appraiser Shareholder';
        update(app);
 //       Apexpages.StandardController controller4 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
 //       MRISApplicationExtension page4 = new MRISApplicationExtension(controller4);
        
        app.Subscription_Type__c = 'Personal Assitant to Appraiser';
        update(app);
 //       Apexpages.StandardController controller5 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
 //       MRISApplicationExtension page5 = new MRISApplicationExtension(controller5);
        
        }catch(exception e){}
        Test.stopTest();    
    }
    
}