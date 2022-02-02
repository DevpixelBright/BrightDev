//Apex Class: samplePagerCtrl.apxc

public class ClassCaseDistributionv2 {
   @AuraEnabled
 public static CasePagerWrapper fetchCase(Decimal pageNumber ,Integer recordToDisply) {
      Integer pageSize = recordToDisply;
      Integer offset = ((Integer)pageNumber - 1) * pageSize;
    
    // create a instance of wrapper class.
    CasePagerWrapper obj =  new CasePagerWrapper();
    // set the pageSize,Page(Number), total records and cases List(using OFFSET)   
        obj.pageSize = pageSize;
        obj.page = (Integer) pageNumber;
        obj.total = [SELECT count() FROM Case];
    obj.cases = [SELECT Id, CaseNumber, Status, ProductId, OwnerId, Subscription_ID__c, ContactId, Category__c, Subject, CreatedDate FROM Case WHERE Status='Deferred' ORDER BY CaseNumber LIMIT :recordToDisply OFFSET :offset];
    // return the wrapper class instance .
    //obj.cases = [SELECT Id, CaseNumber,Status,ProductId,OwnerId,Subscription_ID__c,ContactId,Category__c,Subject,CreatedDate FROM Case ORDER BY CaseNumber];
        return obj;
     }
    
 // create a wrapper class with @AuraEnabled Properties    
 public class CasePagerWrapper {
    @AuraEnabled public Integer pageSize {get;set;}
    @AuraEnabled public Integer page {get;set;}
    @AuraEnabled public Integer total {get;set;}
    @AuraEnabled public List<Case> cases {get;set;}
   }
}