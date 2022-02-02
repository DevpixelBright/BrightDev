public class SMS_GenericPaymentWrapper_Controller {
    
    public String iframeUrl { get; private set; }
    
    public SMS_GenericPaymentWrapper_Controller() {
        String token = ApexPages.currentPage().getParameters().get('token');

        if (String.isBlank(token))
            throw new CustomException('Invalid Request');

        token = EncodingUtil.urlEncode(token, 'UTF-8');
		string id = ApexPages.currentPage().getParameters().get('id');
        //iframeUrl = '/SMS/SMS_GenericPaymentProcess?token=' + token;
        iframeUrl = '/SMS/SMS_GenericPaymentProcess?id='+id+'&token=' + token;
        string type = ApexPages.currentPage().getParameters().get('type');
        if( type != null && type == 'brokerage' )
            iframeUrl += '&type=brokerage';
        else if ( type != null && type == 'vendor' )
            iframeUrl += '&type=vendor';
    }

   public class CustomException extends Exception {}
    
}