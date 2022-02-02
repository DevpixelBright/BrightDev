@isTest
private class ContactProcessingUtlity_Test {
    
    private static testMethod void doTestOne() {
       test.startTest();

       CornerstoneAddrUtility cau1 = new CornerstoneAddrUtility();
       cau1.addAddrs();        

       //CreTED ACCOUNT
        Account a12 = new Account();
        a12.OfficeKey__c = 'ABCD1234';
        a12.Name = 'ABCD1234';
        a12.Type = 'Appraiser';
        a12.Account_Name__c = 'ABCD1234';
        a12.Status__c = 'In Progress';
        a12.Phone = '2345678908';
        a12.Addl_Display_Name__c = 'xyz';
        a12.Box__c = NULL;
        a12.City__c = 'Herndon';
        a12.QAS_Mailing_Country__c = 'USA';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.State__c = 'VA';
        a12.QAS_Mailing_Street_Direction__c = 'N';
        a12.Street_Name__c = 'First';
        a12.Street_Number__c ='1275';
        a12.Street_Number_Suffix__c = NULL;
        a12.QAS_Mailing_Street_Type__c = 'ST';
        a12.Unit__c = '1';
        a12.Zip__c ='20002';
        a12.Zip_4__c = NULL;
        a12.QAS_Mailing_POBox__c = '1234';
        a12.QAS_Mailing_Record_Type__c = NULL;
        a12.Copy_Address_to_Billing__c = true;
        a12.QAS_Mailing_Record_Type__c = 'P';
               
        insert a12;
       
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
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        c1.County__c ='Fairfax';        
        insert c1;

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
        s1.Related_Location_Broker_Office__c = a12.Id;
        insert s1;
        
        Subscription_Role__c sr2= new Subscription_Role__c ();
        sr2.Role__c = 'Agent';
        sr2.Status__c = 'Active';
        sr2.sysPrRoleKey__c = '89752575199';
        sr2.Subscription__c = s1.id;
        insert sr2; 

        Subscription_Role__c sr3 = new Subscription_Role__c ();
        sr3.Role__c = 'Status Active';
        sr3.Status__c = 'Active';
        sr3.sysPrRoleKey__c = '89752575198';
        sr3.Subscription__c = s1.id;
        insert sr3;
        
        s1.AgentKey__C = '200003319147';
        s1.MDS_Status__C = 'Success';
        s1.Status__c = 'Active'; 
        update s1;
        
        c1.FirstName = 'test';
        c1.LastName = 'contact';
        c1.Primary_Subscription__c = s1.Id;
        update c1;
        
        
        //Create Subscription
        Subscriptions__c s2 = new Subscriptions__c();
        s2.Name = 'test2';
        s2.Status__c = 'In Progress';
        s2.Addl_Display_Name__c = 'xyz2';
        s2.Box__c = NULL;
        s2.City__c = 'Herndon';
        s2.QAS_Mailing_Country__c = 'USA';
        s2.QAS_Mailing_County__c = 'Fairfax';
        s2.State__c = 'VA';
        s2.QAS_Mailing_Street_Direction__c = 'N';
        s2.Street_Name__c = 'First';
        s2.Street_Number__c ='1275';
        s2.Street_Number_Suffix__c = NULL;
        s2.QAS_Mailing_Street_Type__c = 'ST';
        s2.Unit__c = '1';
        s2.QAS_Mailing_Unit_Type__c = 'SU';
        s2.Zip__c ='20002';
        s2.Zip_4__c = NULL;
        s2.QAS_Mailing_POBox__c = NULL;
        s2.QAS_Mailing_Record_Type__c = NULL;
        s2.Copy_Address_to_Billing__c = true;
        s2.QAS_Mailing_Record_Type__c = 'P';
        s2.Contact_Type__c = 'Broker';
        s2.Subscription_Type__c = 'Licensee';
        s2.County__c = 'Fairfax';
        s2.Contact__c = c1.id;
        s2.Related_Location_Broker_Office__c = a12.Id;
        insert s2;
        
        c1.Primary_Subscription__c = s2.Id;
        update c1;        

        test.stopTest();
    }    
    
    private static testMethod void doTestTwo() {
       test.startTest();

       CornerstoneAddrUtility cau1 = new CornerstoneAddrUtility();
       cau1.addAddrs();        

       //CreTED ACCOUNT
        Account a12 = new Account();
        a12.OfficeKey__c = 'ABCD1234';
        a12.Name = 'ABCD1234';
        a12.Type = 'Appraiser';
        a12.Account_Name__c = 'ABCD1234';
        a12.Status__c = 'In Progress';
        a12.Phone = '2345678908';
        a12.Addl_Display_Name__c = 'xyz';
        a12.Box__c = NULL;
        a12.City__c = 'Herndon';
        a12.QAS_Mailing_Country__c = 'USA';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.State__c = 'VA';
        a12.QAS_Mailing_Street_Direction__c = 'N';
        a12.Street_Name__c = 'First';
        a12.Street_Number__c ='1275';
        a12.Street_Number_Suffix__c = NULL;
        a12.QAS_Mailing_Street_Type__c = 'ST';
        a12.Unit__c = '1';
        a12.Zip__c ='20002';
        a12.Zip_4__c = NULL;
        a12.QAS_Mailing_POBox__c = '1234';
        a12.QAS_Mailing_Record_Type__c = NULL;
        a12.Copy_Address_to_Billing__c = true;
        a12.QAS_Mailing_Record_Type__c = 'P';
               
        insert a12;
       
        //Create a Contact
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Jimmy';
        c1.LastName = 'Parks';
        c1.Status__c = 'Active';
        c1.Phone = '443-739-0628';
        c1.City__c = 'Balimore';
        c1.State__c = 'MD';
        c1.Zip__c = '21224';    
        c1.Professional_Designations__c='CPM';
        c1.Middle_Name__c ='Chip';
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        c1.County__c ='Fairfax';        
        insert c1;
        
        List<Subscriptions__c> subList = new List<Subscriptions__c>();

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
        s1.Related_Location_Broker_Office__c = a12.Id;

        Subscriptions__c s2 = new Subscriptions__c();
        s2.Name = 'test2';
        s2.Status__c = 'In Progress';
        s2.Addl_Display_Name__c = 'xyz2';
        s2.Box__c = NULL;
        s2.City__c = 'Herndon';
        s2.QAS_Mailing_Country__c = 'USA';
        s2.QAS_Mailing_County__c = 'Fairfax';
        s2.State__c = 'VA';
        s2.QAS_Mailing_Street_Direction__c = 'N';
        s2.Street_Name__c = 'First';
        s2.Street_Number__c ='1275';
        s2.Street_Number_Suffix__c = NULL;
        s2.QAS_Mailing_Street_Type__c = 'ST';
        s2.Unit__c = '1';
        s2.QAS_Mailing_Unit_Type__c = 'SU';
        s2.Zip__c ='20002';
        s2.Zip_4__c = NULL;
        s2.QAS_Mailing_POBox__c = NULL;
        s2.QAS_Mailing_Record_Type__c = NULL;
        s2.Copy_Address_to_Billing__c = true;
        s2.QAS_Mailing_Record_Type__c = 'P';
        s2.Contact_Type__c = 'Broker';
        s2.Subscription_Type__c = 'Licensee';
        s2.County__c = 'Fairfax';
        s2.Contact__c = c1.id;
        s2.Related_Location_Broker_Office__c = a12.Id;
        
        Subscriptions__c s3 = new Subscriptions__c();
        s3.Name = 'test3';
        s3.Status__c = 'In Progress';
        s3.Addl_Display_Name__c = 'xyz2';
        s3.Box__c = NULL;
        s3.City__c = 'Herndon';
        s3.QAS_Mailing_Country__c = 'USA';
        s3.QAS_Mailing_County__c = 'Fairfax';
        s3.State__c = 'VA';
        s3.QAS_Mailing_Street_Direction__c = 'N';
        s3.Street_Name__c = 'First';
        s3.Street_Number__c ='1275';
        s3.Street_Number_Suffix__c = NULL;
        s3.QAS_Mailing_Street_Type__c = 'ST';
        s3.Unit__c = '1';
        s3.QAS_Mailing_Unit_Type__c = 'SU';
        s3.Zip__c ='20002';
        s3.Zip_4__c = NULL;
        s3.QAS_Mailing_POBox__c = NULL;
        s3.QAS_Mailing_Record_Type__c = NULL;
        s3.Copy_Address_to_Billing__c = true;
        s3.QAS_Mailing_Record_Type__c = 'P';
        s3.Contact_Type__c = 'Broker';
        s3.Subscription_Type__c = 'Licensee';
        s3.County__c = 'Fairfax';
        s3.Contact__c = c1.id;
        s3.Related_Location_Broker_Office__c = a12.Id;                

        subList.add(s1);
        subList.add(s2);
        subList.add(s3);
        insert subList;
        
        Subscription_Role__c sr2= new Subscription_Role__c ();
        sr2.Role__c = 'Agent';
        sr2.Status__c = 'Active';
        sr2.sysPrRoleKey__c = '89752575199';
        sr2.Subscription__c = subList[0].id;
        insert sr2; 

        Subscription_Role__c sr3 = new Subscription_Role__c ();
        sr3.Role__c = 'Status Active';
        sr3.Status__c = 'Active';
        sr3.sysPrRoleKey__c = '89752575198';
        sr3.Subscription__c = subList[0].id;
        insert sr3;
        
        s1.AgentKey__C = '200003319147';
        s1.MDS_Status__C = 'Success';
        s1.Status__c = 'Active'; 
        update s1;
        
        c1.FirstName = 'test';
        c1.LastName = 'contact';
        c1.Primary_Subscription__c = subList[0].Id;
        update c1;
        
        
        Subscription_Role__c sr4 = new Subscription_Role__c ();
        sr4.Role__c = 'Status Active';
        sr4.Status__c = 'Active';
        sr4.sysPrRoleKey__c = '89752575197';
        sr4.Subscription__c = subList[1].id;
        insert sr4; 
        

        Subscription_Role__c sr5 = new Subscription_Role__c ();
        sr5.Role__c = 'Status Duplicate';
        sr5.Status__c = 'Active';
        sr5.sysPrRoleKey__c = '89752575196';
        sr5.Subscription__c = subList[2].id;
        insert sr5;                 
        
        c1.Primary_Subscription__c = subList[1].id;
        update c1;        
        test.stopTest();
    }       
}