@isTest
public class testCopyAddressToBilling {

    public static testmethod void testTrigger(){
    
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
    
        Account a = new Account();
        a.CS_Office_Role_ID__c = 'New Office Role';
        a.Name = 'SAM123';
        a.Account_Name__c = 'Joe Smith';
        a.Type = 'Residential';
        a.Phone = '4231231234';
        a.Company_Type__c = 'Broker Office';
        a.Status__c = 'In Progress';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        
        a.Addl_Display_Name__c = 'addl display';
        a.Box__c = '123';
        a.Street_Name__c = 'Paul Marks';
        a.Street_Number__c = '532';
        a.Street_Number_Suffix__c = '2';
        a.Unit__c = '64';
        a.Zip_4__c = '7537';
        a.Zip__c = '92827';
        a.City__c = 'Herndon';
        a.State__c = 'VA';
        a.County__c = 'Fairfax';
        a.Country__c = 'UNITED STATES';
        a.Copy_Address_to_Billing__c = true;
        
        insert(a);
        
        a.Copy_Address_to_Billing__c = true;
        update(a);
        
       Contact c1 = new Contact();
        c1.Email = 'email@something.com';
        c1.FirstName = 'Test';
        c1.LastName = 'Contact';
        c1.Public_Email__c = 'email@something.com';
        c1.Salutation = 'Mr.';
        c1.City__c = 'Vienna';
        c1.Zip__c = '22182';
        c1.Addl_Display_Name__c = 'addl display';
        c1.Box__c = '123';
        c1.Street_Name__c = 'Paul Marks';
        c1.Street_Number__c = '532';
        c1.Street_Number_Suffix__c = '2';
        c1.Unit__c = '64';
        c1.Zip_4__c = '7537';
        c1.Zip__c = '92827';
        c1.City__c = 'Herndon';
        c1.State__c = 'VA';
        c1.County__c = 'Fairfax';
        c1.Country__c = 'UNITED STATES';
        c1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        c1.QAS_Mailing_County__c = 'Arlington';
        c1.Copy_Address_to_Billing__c = true;       
        insert c1;       
        
        
        
        
       
    }
}