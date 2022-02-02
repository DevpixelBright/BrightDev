trigger ListingProtectLockPeriod on Account (before insert,before update) 
{
    System.debug('ListingProtectLockPeriod Entry : Number of Queries used in this apex code so far: ' + Limits.getQueries());
    if (Utils.BypassValidationrules())return;    
    System.debug('ListingProtectLockPeriod : Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
    if(Trigger.isInsert) 
    {       
        for (Account a:Trigger.new) 
        {
            if((a.Listing_Protect_Program__c == true))
            {
                a.Last_Election_Opt_In_Out__c = system.Today();    
            }
        }
    }
    else
    {
        for (Account a:Trigger.new) 
        {
            if(Trigger.oldMap.get(a.id).Listing_Protect_Program__c != a.Listing_Protect_Program__c )
            {
                if(a.Listing_Protect_UnLock_Date__c > System.today())
                {
                    a.Listing_Protect_Program__c.addError('You cannot change a broker’s selection for the ListingProtect program during the lockdown period. You will be able to change the ListingProtect election for this broker starting on ' + a.Listing_Protect_UnLock_Date__c.format() );    
                }
                else
                {
                    a.Last_Election_Opt_In_Out__c = System.Today();
                }
            }
                       
        } 
    }
    
    System.debug('ListingProtectLockPeriod Final : Number of Queries used in this apex code so far: ' + Limits.getQueries());
}