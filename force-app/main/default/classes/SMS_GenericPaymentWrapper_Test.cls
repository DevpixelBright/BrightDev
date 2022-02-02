@isTest
public class SMS_GenericPaymentWrapper_Test {
    public static testMethod void SMS_GenericPaymentWrapper_Test() {
        try {
            PageReference pageRef = Page.SMS_GenericPaymentWrapper;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('token', 'test');
            SMS_GenericPaymentWrapper_Controller controller = new SMS_GenericPaymentWrapper_Controller();
            
            ApexPages.currentPage().getParameters().put('token', '');
            SMS_GenericPaymentWrapper_Controller controller1 = new SMS_GenericPaymentWrapper_Controller();        
        }
        catch(Exception ex) {
        
        }
    }
}