@isTest 
private class QAScombinedAccountTrigger_Test {
    
    private static testMethod void doTestOne() {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account testAccount = new Account();
        testAccount.OfficeKey__c = 'ABCD1234';
        testAccount.Name = 'ABCD1234';
        testAccount.Type = 'Appraiser';
        testAccount.Account_Name__c = 'ABCD1234';
        testAccount.Status__c = 'In Progress';
        testAccount.Phone = '2345678908';
        testAccount.Addl_Display_Name__c = 'xyz';
        testAccount.Box__c = NULL;
        testAccount.City__c = 'Herndon';
        testAccount.QAS_Mailing_Country__c = 'USA';
        testAccount.QAS_Mailing_County__c = 'Fairfax';
        testAccount.State__c = 'VA';
        testAccount.QAS_Mailing_Street_Direction__c = 'N';
        testAccount.Street_Name__c = 'First';
        testAccount.Street_Number__c ='1275';
        testAccount.Street_Number_Suffix__c = NULL;
        testAccount.QAS_Mailing_Street_Type__c = 'ST';
        testAccount.Unit__c = '1';
        testAccount.Zip__c ='20002';
        testAccount.Zip_4__c = NULL;
        testAccount.QAS_Mailing_POBox__c = '1234';
        testAccount.QAS_Mailing_Record_Type__c = NULL;
        testAccount.Copy_Address_to_Billing__c = true;
        testAccount.QAS_Mailing_Record_Type__c = 'P';
               
        insert testAccount;
        
        testAccount.Status__c = 'Active'; 
        update testAccount;  
        
        testAccount.Status__c = 'Inactive'; 
        update testAccount;        
    }
    
    private static testMethod void doTestTwo() {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account testAccount = new Account();
        testAccount.OfficeKey__c = 'ABCD1234';
        testAccount.Name = 'ABCD1234';
        testAccount.Type = 'Appraiser';
        testAccount.Account_Name__c = 'ABCD1234';
        testAccount.Status__c = 'In Progress';
        testAccount.Phone = '2345678908';
        testAccount.Addl_Display_Name__c = 'xyz';
        testAccount.Box__c = NULL;
        testAccount.City__c = 'Herndon';
        testAccount.QAS_Mailing_Country__c = 'USA';
        testAccount.QAS_Mailing_County__c = 'Fairfax';
        testAccount.State__c = 'VA';
        testAccount.QAS_Mailing_Street_Direction__c = 'N';
        testAccount.Street_Name__c = 'First';
        testAccount.Street_Number__c ='1275';
        testAccount.Street_Number_Suffix__c = NULL;
        testAccount.QAS_Mailing_Street_Type__c = 'ST';
        testAccount.QAS_Billing_Street_Type__c = 'APT,APT';
        testAccount.QAS_Billing_Street_Direction__c = 'N';
        testAccount.QAS_Billing_County__c = 'Fairfax';
        testAccount.QAS_Billing_Country__c = 'USA';
        testAccount.QAS_Billing_Record_Type__c = 'P';
        testAccount.Unit__c = '1';
        testAccount.Zip__c ='20002';
        testAccount.Zip_4__c = NULL;
        testAccount.QAS_Mailing_POBox__c = '1234';
        testAccount.QAS_Mailing_Record_Type__c = NULL;
        testAccount.Copy_Address_to_Billing__c = false;
        testAccount.QAS_Mailing_Record_Type__c = 'P';
        testAccount.QAS_Billing_POBox__c = '2222';
        testAccount.QAS_Billing_Unit_Type__c = 'APT';
               
        insert testAccount; 
    } 
    
    private static testMethod void doTestThree() {
        try {
            Account a = new Account();
            a.QAS_Mailing_POBox__c = 'test';
            a.Copy_Address_to_Billing__c = false;
            a.QAS_Billing_POBox__c = 'test';
            a.QAS_Mailing_Unit_Type__c = 'APT';            
            insert a;
        }
        catch(Exception e) {
        
        }
    }       
}