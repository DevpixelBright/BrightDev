@isTest(SeeAllData=false)
public class PrintEmailTemplateTest {
    static testMethod void sendEmailTest1(){
        List<EmailTemplate> lEmailTemp = [Select id from EmailTemplate where templatetype = 'html' limit 1];
        Test.startTest();
        Apexpages.currentpage().getparameters().put('id',lEmailTemp[0].id);
        PrintEmailTemplate ext = new PrintEmailTemplate();
        Test.stopTest();
    }
    
    static testMethod void sendEmailTest2(){
        List<EmailTemplate> lEmailTemp = [Select id from EmailTemplate where templatetype = 'custom' limit 1];
        Test.startTest();
        Apexpages.currentpage().getparameters().put('id',lEmailTemp[0].id);
        PrintEmailTemplate ext = new PrintEmailTemplate();
        Test.stopTest();
        
    }
    
    static testMethod void sendEmailTest3(){
        List<EmailTemplate> lEmailTemp = [Select id,HtmlValue,Markup,Subject from EmailTemplate where templatetype = 'visualforce' limit 1];
        Test.startTest();
        Apexpages.currentpage().getparameters().put('id',lEmailTemp[0].id);
        PrintEmailTemplate ext = new PrintEmailTemplate();
        List<BrandTemplate> bt = ext.brandList;
        Test.stopTest();
        
    }
}