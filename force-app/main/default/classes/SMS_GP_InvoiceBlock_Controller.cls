public class SMS_GP_InvoiceBlock_Controller {
    public SMS_GenericPaymentProcess_Controller parent { get; set; }
    
    public Boolean showPreview { get { return parent.showPreview; } }
    public Boolean showConfirmation { get { return parent.showConfirmation; } }

    public SMS_GenericPaymentInvoicing.InvoiceData Invoice { get { return parent.Invoice; } }

    public SMS_GP_InvoiceBlock_Controller() {}
}