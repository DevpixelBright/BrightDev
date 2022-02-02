public class SMS_GenericPaymentPortal_Controller {
    
    public String iframeDomain { get; private set; }
    public String iframeUrl { get; private set; }
    public String redirectUrl { get; private set; }
    public String cancelUrl { get; private set; }
    
    public SMS_GenericPaymentPortal_Controller() {
        String token = ApexPages.currentPage().getParameters().get('token');

        if (String.isBlank(token))
            throw new CustomException('Invalid Request');

        token = EncodingUtil.urlEncode(token, 'UTF-8');

        iframeDomain = URL.getSalesforceBaseUrl().toExternalForm();
        
        String path = URL.getSalesforceBaseUrl().toExternalForm() + '/SMS/SMS_GenericPaymentPortal';        
        path = EncodingUtil.urlEncode(path, 'UTF-8');
   
        iframeUrl = iframeDomain + '/SMS/SMS_GenericPaymentWrapper?token=' + token + '#' + path;             

        redirectUrl = ApexPages.currentPage().getParameters().get('redirect');
        cancelUrl = ApexPages.currentPage().getParameters().get('cancel');
    }

   public class CustomException extends Exception {}
}