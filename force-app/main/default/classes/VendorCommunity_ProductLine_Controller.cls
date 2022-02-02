public class VendorCommunity_ProductLine_Controller {
    
    //private enum zTermStatus { PastTerm, Current, FutureTerm, UNDEF } 
 
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public String cancelUrl { get; private set; }
    public Boolean debugMode { get; private set; }
    public String displayName { get; private set; } // To capture the value for markUserId
    
    public Boolean isBillingInfo{set; get;}
    
    public VendorCommunity_ProductLine_Controller() {
        initialLoad = true;
        hasError = false;
        
        String debug = ApexPages.currentPage().getParameters().get('debug');
            
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
        
        cancelUrl = Label.MRIS_Communities_URL + 'VendorCommunity_ManageVendor';
        
    	accountId = ApexPages.currentPage().getParameters().get('id');
        displayName = accountId;
    	
        subProducts = new list<RETS_Sub_Products__c>();
    }
    
	public string accountId;
	public list<RETS_Sub_Products__c> subProducts {get; set;}  
	public void getRetsSubProducts(){
		
		initialLoad = false;
        hasError = false;
        try{
			subProducts = [Select id, Name From RETS_Sub_Products__c Where Vendor_Product__r.name =: accountId];
			
			if(subProducts.size() < 1){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account does not have Subproducts'));
				return;			
			}
        }
        catch (Exception e) {
            isBillingInfo = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            hasError = true;
        }
		
	}

    public Class CustomException extends Exception {}
}