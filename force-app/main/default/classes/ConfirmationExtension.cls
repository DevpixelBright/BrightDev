public with sharing class ConfirmationExtension {
    /*
    Developer: Justin Padilla
    Class Description: This class extension is used by all of the onboarding signup forms and provides
    the confirmation page for all Subscription Types. The confirmation of this page returns a confirmed
    message to the calling onboarding form causing that calling page to save the user's input data  
    */
    public String SubscriptionType{get;set;}
    public String SubscriptionFee{get;set;}
    public String SubscriptionQuarterlyFee{get;set;}
    
    public ConfirmationExtension(Apexpages.StandardController controller)
    {
        SubscriptionType = 'INVALID';
        SubscriptionFee = 'INVALID';
        SubscriptionQuarterlyFee = 'INVALID';
        //Get the Type of License
        if (Apexpages.currentPage().getParameters().get('license') != null)
        {
            String SubType = Apexpages.currentPage().getParameters().get('license');
            if (SubType == '1')
            {
                SubscriptionType = 'Licensed Appraiser/Non Realtor';
                SubscriptionFee = '$250.00';
                SubscriptionQuarterlyFee = '$213.00';
            }
            else if (SubType == '2')
            {
                SubscriptionType = 'Realtor/Appraiser Non-Shareholder';
                SubscriptionFee = '$250.00';
                SubscriptionQuarterlyFee = '$213.00';
            }
            else if (SubType == '3')
            {
                SubscriptionType = 'Realtor/Appraiser Shareholder';
                SubscriptionFee = '$250.00';
                SubscriptionQuarterlyFee = '$123.00';
            }
            else if (SubType == '4')
            {
                SubscriptionType = 'Personal Assistant Appraiser';
                SubscriptionFee = '$0.00';
                SubscriptionQuarterlyFee = '$123.00';    
            }
            else if (SubType == '5')
            {
                SubscriptionType = 'Office Secretary';
                SubscriptionFee = '$0.00';
                SubscriptionQuarterlyFee = '$123.00';    
            }
            else if (SubType == '6')
            {
                SubscriptionType = 'Office Secretary/No Charge';
                SubscriptionFee = '$0.00';
                SubscriptionQuarterlyFee = '$0.00'; 
            }
            else if (SubType == '7')
            {
                SubscriptionType = 'Personal Assistant';
                SubscriptionFee = '$0.00';
                SubscriptionQuarterlyFee = '$123.00';
            }
            else if (SubType == '8')
            {
                SubscriptionType = 'Licensed Real Estate Agent';
                SubscriptionFee = '$250.00';
                SubscriptionQuarterlyFee = '$213.00';
            }
            else if (SubType == '9')
            {
                SubscriptionType = 'Realtor/Non-Shareholder';
                SubscriptionFee = '$250.00';
                SubscriptionQuarterlyFee = '$213.00';
            }
            else if (SubType == '10')
            {
                SubscriptionType = 'Realtor/Shareholder';
                SubscriptionFee = '$250.00';
                SubscriptionQuarterlyFee = '$123.00';
            }
        }
    }
    static testMethod void testConfirmationExtension()
    {
        MRIS_Application__c application = new MRIS_Application__c();
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(application);
        ConfirmationExtension page1 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','1');
        ConfirmationExtension page2 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','2');
        ConfirmationExtension page3 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','3');
        ConfirmationExtension page4 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','4');
        ConfirmationExtension page5 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','5');
        ConfirmationExtension page6 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','6');
        ConfirmationExtension page7 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','7');
        ConfirmationExtension page8 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','8');
        ConfirmationExtension page9 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','9');
        ConfirmationExtension page10 = new ConfirmationExtension(controller);
        Apexpages.currentPage().getParameters().put('license','10');
        ConfirmationExtension page11 = new ConfirmationExtension(controller);
    }
}