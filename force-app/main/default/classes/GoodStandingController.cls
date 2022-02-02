public class GoodStandingController {
    Public string SubscriptionsId {get;set;}
    public Subscriptions__c Subscriptions{get;set;}
    Public GoodStandingController(){
        SubscriptionsId=ApexPages.currentPage().getParameters().get('subId');
        Subscriptions=[select id ,name,Contact__c,Contact__r.Name,Street_Number__c,Street_Name__c from Subscriptions__c where id=:SubscriptionsId];
       }
    @AuraEnabled(cacheable=false)
 public static string downloadWithPdf(ID subId){
        Subscriptions__c cs = [SELECT Id,Name,Contact__c FROM Subscriptions__c Where ID =:subId];
        contact cd = [SELECT Id,Name,Email FROM contact WHERE Id =:cs.Contact__c];
        PageReference pdf=Page.GoodStandingTemplate;
       
        //pdf.getParameters().put('subId', cs.AccountId);
     	pdf.getParameters().put('subId', cs.Id);
        
        Blob b;
     string newblobMessage;
        if (Test.IsRunningTest()){
            b=Blob.valueOf('UNIT.TEST');
        }
        else{
            b = pdf.getContent();
            system.debug('test-->'+pdf.getUrl());
            newblobMessage = EncodingUtil.base64Encode(b);
        }
     
        return newblobMessage; 
    }
}