public without sharing class AccuracyIssuePdf_Controller {
    
    public String mlsNumber { get; set; } 
    public String propertyAddress { get; set; }
    public String fromName { get; set; } 
    public String topic { get; set; } 
    public String description { get; set; }
    public Case newcase {get; set;}
    public String caseId { get; set; }

    public AccuracyIssuePdf_Controller() {
        if(ApexPages.currentPage().getParameters().get('mls') != null)
            mlsNumber = ApexPages.currentPage().getParameters().get('mls');
        if(ApexPages.currentPage().getParameters().get('address') != null)
            propertyAddress = ApexPages.currentPage().getParameters().get('address');
        if(ApexPages.currentPage().getParameters().get('from') != null)
            fromName = ApexPages.currentPage().getParameters().get('from');  
        if(ApexPages.currentPage().getParameters().get('topic') != null)
            topic = ApexPages.currentPage().getParameters().get('topic');
        if(ApexPages.currentPage().getParameters().get('description') != null)
            description = ApexPages.currentPage().getParameters().get('description');
        System.debug('***' + ApexPages.currentPage().getParameters().get('caseId'));
        if(ApexPages.currentPage().getParameters().get('caseId') != null) {
        	newcase = [SELECT Id, Description,Report_a_Violation_Description__c FROM Case WHERE Id=: ApexPages.currentPage().getParameters().get('caseId')];
        System.debug('Desc'+newcase);
        }
    }
}