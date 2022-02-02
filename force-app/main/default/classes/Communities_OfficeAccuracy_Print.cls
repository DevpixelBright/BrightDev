public without sharing class Communities_OfficeAccuracy_Print {
    public String subId { get; set;}
    public List<Communities_OfficeAccuracy.OfficeAccuracyWrapper> result { get; set;}
    
    public Communities_OfficeAccuracy_Print()
    {
        try
        {
            subId = ApexPages.currentPage().getParameters().get('id');
            
            system.debug('subId---'+subId);
            result = new List<Communities_OfficeAccuracy.OfficeAccuracyWrapper>();
            result = Communities_OfficeAccuracy.getDetails(subId);
        }
        catch(Exception e){
            system.debug('--exception--->'+e.getMessage());
            system.debug('--StackTrace--->'+e.getStackTraceString());
        }      
    } 
}