@isTest
public class SMS_GenericPaymentPortal_Test {
    public static testMethod void SMS_GenericPaymentPortal_Test() {
        try {
            PageReference pageRef = Page.SMS_GenericPaymentPortal;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('token', 'test');
            SMS_GenericPaymentPortal_Controller controller = new SMS_GenericPaymentPortal_Controller ();
            
            ApexPages.currentPage().getParameters().put('token', '');
            SMS_GenericPaymentPortal_Controller controller1 = new SMS_GenericPaymentPortal_Controller ();        
        }
        catch(Exception ex) {
        
        }
    }       
}