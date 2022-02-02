@Istest
public class testMrisApproveDeferredTrigger {


    public static testmethod void testTrigger(){

        Test.StartTest();
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
    
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
        
        Account b = new Account();
        b.name = 'TES1234';
        b.Account_Name__c = 'Test Account';
        b.City__c = 'Herndon';
        b.Zip__c = '22101';
        b.State__c = 'VA';
        b.Company_Type__c = 'Broker Office';
        b.Status__c = 'In Progress';
        b.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        b.parentid = a12.id;  
        b.County__c = 'Fairfax';
        insert b;
        
        MRIS_Application__c m = new MRIS_Application__c();
        m.State__c = 'VA';
        m.Status__c = 'Deferred';
        m.Salutation__c = 'Miss';
        m.First_Name__c = 'Justin';
        m.Last_Name__c = 'Padilla';
        m.Mobile_Phone__c = '(443) 739-0628';
        m.Primary_Phone__c = '(443)739-0628';
        m.Public_Email__c = 'smae@testmail.com';
        m.Type__c = 'Agent';
        m.Subscription_Type__c = 'Broker Staff ';
        m.Company_Code__c = a12.id;
        try{
          insert m;
        }catch(Exception e){
            System.debug('Errro:'+e);
        }
        
        m.Status__c = 'Approved';
        m.comments__c = 'this is a test';
        
        // insert m;
        upsert m;
        
        list<MRIS_Application__c> mList = [Select m.Status__c, m.deferred_date__c,m.Id From MRIS_Application__c m where m.Status__c = 'Approved'];
        
        System.assert(mList.size() == 1);  
        
        //This is for the Workflow that updates to date to current date
        m.Deferred_Date__c = Date.Today() - 1;
        m.License_Number__c ='TESt Licence';
        //update(m);
        
        m.status__c = 'Approved';
        
        mList = [Select m.Status__c, m.deferred_date__c,m.Id From MRIS_Application__c m where m.Status__c = 'Approved'];

        System.assert(mList.size() == 1);  
               
        Test.StopTest();
        
        
    }
}