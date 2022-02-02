@isTest 
public class testCreatePortalUser {

    public static testmethod void testTrigger(){
    CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
       cau.addAddrs();  

       
       Account a12 = new Account();
       a12.name = 'ADA1234';
       a12.type = 'Residential';
       a12.Account_Name__c = 'Test Account';
       a12.City__c = 'Herndon';
       a12.Zip__c = '20171';
       a12.QAS_Mailing_County__c = 'Fairfax';
       a12.County__c = 'Fairfax';
       a12.Street_Type__c = '';
       a12.Billing_Street_Type__c = 'BLFS';
       a12.QAS_Mailing_Street_Type__c ='test';
       a12.company_type__c = 'Corporate Office';
       insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);   
    
        Account acc = new Account();
        acc.Name = 'TEST321';
        acc.Account_Name__c = 'Testing Account';
        acc.type = 'Residential';
        acc.Company_Type__c = 'Broker Office';
        acc.Shareholder_Board__c = 'No';
        acc.Street_Number__c = '6824';
        acc.Street_Name__c = 'Dean';
        acc.Zip__c = '22101';
        acc.City__c = 'Herndon';
        acc.State__c = 'VA';
        acc.County__c = 'Fairfax';
        acc.Country__c = 'UNITED STATES';
        acc.Phone = '5559991234';
        acc.ParentId = a12.id;
        acc.QAS_Mailing_County__c = 'Fairfax';
       acc.County__c = 'Fairfax';
       acc.Street_Type__c = '';
       acc.Billing_Street_Type__c = 'BLFS';
       acc.QAS_Mailing_Street_Type__c ='test';
        insert(acc);
        
        System.debug('account ---> ' + acc);
        
        Contact c = new Contact();
        c.LastName = 'Lansdale';
        c.Status__c = 'Active';
        c.Phone = '4123214323';
        c.Public_Email__c = 'bsmith@rainmaker-llc.com';
        c.Account = acc;
        c.Zip__c = '20171';
        c.City__c = 'Herndon';
        c.County__c = 'Fairfax';
        c.Country__c = 'UNITED STATES';
        c.AccountId = acc.id;
         
        insert(c);
        


        System.debug('contact ---> ' + c);
        
        Subscriptions__c s = new  Subscriptions__c();
        //s.Name = 'Test Subscription';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.Public_Email__c = 'abc@test.com';
        s.Related_Location_Broker_Office__c = acc.id;  
        s.Contact_Type__c = 'Agent';
        s.Subscription_Type__c = 'Broker Staff';
        s.QAS_Mailing_Unit_Type__c = 'SU';
        s.Zip_4__c = NULL;
        s.QAS_Mailing_POBox__c = NULL;
        s.QAS_Mailing_Record_Type__c = NULL;
        s.Copy_Address_to_Billing__c = true;
        s.QAS_Mailing_Record_Type__c = 'P';
        s.Contact_Type__c = 'Broker';
        s.Subscription_Type__c = 'Licensee';
        s.County__c = 'Fairfax';
        insert(s);

        System.debug('subscription ---> ' + s);    
        
        s.Status__c = 'Active';
        s.AgentKey__c = '123';
      //  s.Primary__c = true;
        update s;
        
        s.AgentKey__c = null;
        update s;
        
        try{
        s.AgentKey__c = '321';
        update s;
        }catch(Exception e)
        {
            System.assertNotEquals(e, null);
        }
    }
}