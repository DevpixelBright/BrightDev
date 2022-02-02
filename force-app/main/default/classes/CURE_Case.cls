public with sharing class CURE_Case {

    public ApexPages.StandardSetController caseSetController{ get;set;} 
    public List<SelectOption> filterId { get;set; }
    public String selectedView { get; set; }    
    
    Public List<Case> recentCases { get; set; }
    Public List<Report> caseReports {get;set;}

    public CURE_Case(ApexPages.StandardController controller) {
        caseSetController = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT id,CaseNumber FROM Case]));
        filterId = new List<SelectOption>();
         
        for(SelectOption option : caseSetController.getListViewOptions())             
            filterId.add(option);
        
        recentCases = [SELECT id,CaseNumber,Subject,CreatedDate,Priority FROM Case LIMIT 5];
        
        caseReports = [SELECT id,Name FROM Report WHERE Name like '%case%' LIMIT 5];
    }
    
    public PageReference listView() {
        PageReference listPage = new PageReference('/500?fcf='+selectedView.left(15));
        return listPage;
    }
    
    public PageReference newCase() {
        PageReference newPage = new PageReference('/apex/CURERequestHome');
        return newPage;
    }
}