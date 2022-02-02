@isTest
public class ListingProtectLockPeriod_Test
{
    static testMethod void testDoTest() 
    {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
        
        Listing_Protect_LockDown_Period__c lk = Listing_Protect_LockDown_Period__c.getOrgDefaults();
        Integer daysLocked = Integer.valueof(lk.No_of_Days__c);
        
        system.debug('*** Days Locked' + daysLocked); 
               
        Account a = new Account();
        a.Name = 'ADA1231';
        a.Type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.Company_Type__c = 'Broker Office';
        a.Listing_Protect_Program__c = true;
        insert a;
        
        a.Listing_Protect_Program__c = false;

        try
        {
            update a;
        }
        catch(Exception e)
        {
            a.Last_Election_Opt_In_Out__c = System.today().addDays(-daysLocked);
            update a;
        }
    }  
}