@isTest
private class SMS_GP_InvoiceBlock_Controller_Test {

    private static testMethod void doTestOne(){ 
        try {
        SMS_GP_InvoiceBlock_Controller controller = new SMS_GP_InvoiceBlock_Controller();
        SMS_GenericPaymentProcess_Controller parent = controller.parent;
        Boolean preview = controller.showPreview;
        Boolean showConfirmation = controller.showConfirmation;
        SMS_GenericPaymentInvoicing.InvoiceData data = controller.Invoice;
        }
        catch(Exception e) {
        
        } 
    }

}