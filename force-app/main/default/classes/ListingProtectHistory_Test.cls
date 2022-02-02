@isTest 
public class ListingProtectHistory_Test
{
    static testMethod void testDoTest() 
    {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
         
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
        
        Listing_Protect_Program_History__c coyrightHistory = new Listing_Protect_Program_History__c();
        coyrightHistory.Office_ID__c = a.id;
        coyrightHistory.BOR_Email_ID__c = 'email@something.com';
        coyrightHistory.BOR_Initials__c = 'SR';
        coyrightHistory.BOR_Name__c  = 'Test Name';
        coyrightHistory.Current_Selection__c = 'Opt In';
        coyrightHistory.Previous_Selection__c = 'Opt Out';
        insert coyrightHistory;
        
        coyrightHistory.Previous_Selection__c = 'Opt In';
        try { update coyrightHistory; }
        catch(Exception e){}
        
        try { delete coyrightHistory; }
        catch(Exception e){}        
        
    }
}