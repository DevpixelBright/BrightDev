trigger ListingProtectHistoryPreventChanges on Listing_Protect_Program_History__c (before update,before delete) 
{
    if(Trigger.isUpdate)
    {
        for(Listing_Protect_Program_History__c history : trigger.new)
        {
            history.addError('Listing Protect Program History record can not be edited');
        }    
    }
    else
    {
        for(Listing_Protect_Program_History__c history : trigger.old)
        {
            history.addError('Listing Protect Program History record can not be deleted');
        }
    } 
}