@istest(seealldata = true)
public class BrightQuestionnaire_Controller_Test {
    private static testMethod void doTestOne() {
        try{
            PageReference pageRef = Page.BrightQuestionnaire;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('type', '');
            BrightQuestionnaire_Controller obj = new BrightQuestionnaire_Controller();
            obj.vendorName1 = 'Testvendor1';
            obj.vendorName2 = 'Testvendor2';
            obj.Product_offer_details ='Test';
            obj.Product_use  ='Test';
            obj.Broker_name  ='Test';
            obj.Broker_Information ='Test';
            obj.product_audience  = new List<String>{'Test'};
                obj.Is_login_required  ='Test';
            obj.authentication_methods ='Test';
            obj.monitoring_credentials  ='Test';
            obj.bright_data_usage  ='Test';
            obj.authenticate_broker='Test';
            obj.broker_services  ='Test';
            obj.data_pull_period  ='Test';
            obj.RETS_data_access  ='Test';
            obj.Is_data_shared ='Test';
            obj.Is_data_display_plugin  ='Test';
            obj.website_URL ='Test';
            obj.Primary_Contact_Name ='Test';
            obj.Primary_Contact_Phone_Number ='Test';
            obj.Primary_Contact_Email_Address  ='Test';
            obj.Technical_Contact_Name='Test';
            obj.Technical_Contact_Phone_Number ='Test';
            obj.Technical_Contact_Email_Address  ='Test';
            obj.Billing_Contact_Name='Test';
            obj.Billing_Contact_Phone_Number ='Test';
            obj.Billing_Contact_Email_Address  ='Test';
            obj.Administrative_Contact_Name='Test';
            obj.Administrative_Contact_Phone_Number ='Test';
            obj.Administrative_Contact_Email_Address ='Test';
            obj.shareDataStr1 ='Test';
            obj.shareDataStr2 ='Test';
            obj.otherInfoStr ='Test';
            obj.submitApplication();
        }catch(Exception e){}
    }
}