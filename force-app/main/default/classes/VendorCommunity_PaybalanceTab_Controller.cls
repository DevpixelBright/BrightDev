public class VendorCommunity_PaybalanceTab_Controller {
    public string accountId {get; set;}
    public VendorCommunity_PaybalanceTab_Controller(){
    	accountId = Apexpages.currentPage().getParameters().get('id');
    }
    public pagereference test(){
    	pagereference ref = new pagereference('/'+accountId);
    	//ref.pageredirect(true);
    	return ref;
    }
}