public class VendorCommunity_Controller {

    public VendorCommunity_Controller() {
    }
    
    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
    
    public class CustomException extends Exception {}
}