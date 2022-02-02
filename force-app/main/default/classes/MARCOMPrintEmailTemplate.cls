public class MARCOMPrintEmailTemplate {
    public static PageReference pg;
    public static string emailId;
    public static string url;
    
    @AuraEnabled
    public static List<EmailTemplate> getTemplateList(String url) {
        List<String> lstUrls = url.split(',');
        List<EmailTemplate> emailList = [SELECT Id,Name,Subject,TemplateType,Description,DeveloperName,HtmlValue,Body from EmailTemplate where Id IN :lstUrls];
        return emailList;
    }
    
}