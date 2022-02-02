@isTest
public class MARCOM_LandingPageControllerTest {
	
    @istest static void getTemplatesTest(){
        Email_Template_Category__c cat = new Email_Template_Category__c();
        cat.Name = 'test Data';
        insert cat;
        
        MARCOM_LandingPageController.getTemplates('Active','','','2020-01-01','2020-01-01','RETS');
        MARCOM_LandingPageController.getTemplates('Active',userinfo.getOrganizationId(),'','2020-01-01','2020-01-01','RETS');
        MARCOM_LandingPageController.wrapper wrap = MARCOM_LandingPageController.getTemplates('Active',userinfo.getOrganizationId(),'test','','','');
        MARCOM_LandingPageController.getConfigurations();
        MARCOM_LandingPageController.getPicklist();
        if(wrap != null && wrap.lTemplates != null && wrap.lTemplates.size() > 0){
            MARCOM_LandingPageController.getEmailDetails(wrap.lTemplates[0].Id);
        	MARCOM_LandingPageController.getNotes(wrap.lTemplates[0].Id);
        }
        id vftempalteId;
        for(sObject obj : wrap.lTemplates){
            if(string.valueof(obj.get('TemplateType')) == 'visualforce'){
                vftempalteId = string.valueof(obj.get('Id'));
            }
        }
        MARCOM_LandingPageController.getEmailDetails(vftempalteId);
        MARCOM_LandingPageController.getNotes(vftempalteId);
        //MARCOM_LandingPageController.pagination(4, 15);
    }
}