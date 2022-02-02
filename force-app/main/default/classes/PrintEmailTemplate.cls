public class PrintEmailTemplate {
    
    public List<EmailTemplate> tempList{get;set;}
    public List<BrandTemplate> brandList{get;set;}
    public List<String> lstUrls {get;set;}
    public string recordId {get;set;}
    
    public PrintEmailTemplate(){
        recordId = ApexPages.currentPage().getParameters().get('id');
        lstUrls = (recordId.split(','));
        tempList=new List<EmailTemplate>();
        tempList=[SELECT Id,Name,Subject,TemplateType,BrandTemplateId,Description,DeveloperName,HtmlValue,Body,Markup from EmailTemplate where Id IN :lstUrls ORDER BY Name];
        Set <Id> btIds =  new Set<Id>();
        for(EmailTemplate oEmail : tempList) {
            btIds.add(oEmail.BrandTemplateId);
        }
        
		Map<Id,BrandTemplate> emailTemp = new Map<Id, BrandTemplate>([SELECT Id,Name,Value from BrandTemplate WHERE Id IN: btIds]);

        for (EmailTemplate e : tempList){
            if(e.TemplateType == 'Custom'){
                Integer startIndex = e.HtmlValue.indexOf('<style type="text/css">');
                Integer endIndex = e.HtmlValue.indexOf('</style>');
                if(startIndex == 0){
                    e.HtmlValue = e.HtmlValue.substring(endIndex + 8);
                }
                else{
                    e.HtmlValue = e.HtmlValue;
                }
            }
            if(e.TemplateType == 'html'){
                e.HtmlValue = e.HtmlValue + emailTemp.get(e.BrandTemplateId).Value;
                e.HtmlValue = e.HtmlValue.replace('<![CDATA[',' ');
                e.HtmlValue = e.HtmlValue.replace(']]>',' ');
            }
            try{
                if(e.TemplateType == 'visualforce'){
                    e.Subject = e.Markup.substringAfter('<messaging:emailTemplate subject="').substringBefore('"');
                }    
            }catch(Exception ex){}
            try{
                if(e.TemplateType == 'visualforce' && e.HtmlValue == null){
                    String body = e.Markup.substringAfter('HtmlEmailBody');
                    e.HtmlValue = e.Markup.substringBetween('<messaging:htmlEmailBody >','</messaging:htmlEmailBody>');
                    if(e.HtmlValue == null || e.HtmlValue == ''){
                        e.HtmlValue = e.Markup.substringBetween('<messaging:HtmlEmailBody >','</messaging:HtmlEmailBody>');
                    }
                    e.HtmlValue = e.HtmlValue.substringAfterLast('</style>');
                }    
            }catch(Exception ex){}
            //e.HtmlValue = MARCOM_Util.processEmailBody(e.HtmlValue);
            e.Markup = null;
        }
    }
}