public with sharing Class CURE_Home {
    
    public User cureCustomer { get; set; }
    public List<Case> cases { get; set; }
    public Case newCase { get; set; }
    public Case viewCase { get; set; }
    public Attachment attachment { get;set; }
    
    public String viewCaseId { get; set; }
    public Boolean isCreateCase { get; set; }
    public Boolean isViewCase { get; set; }
    public Integer openCasesCount { get; set; }
    public Integer highCasesCount { get; set; }
    
    public CURE_Home() {
        cureCustomer = [SELECT Id,Name, ContactId, Contact.Name, Contact.Account.Name, Contact.Account.Parent.Name
                        FROM   User 
                        WHERE  Id = :UserInfo.getUserId()]; 
                             
        newCase = new Case();
        viewCase = new Case();
        isCreateCase = false;
        isViewCase = false; 
        loadCases();
        attachment = new Attachment(); 
    }
    
    public void loadCases() {
        cases = [SELECT Id, CaseNumber, Request_Type__c, Contact.FirstName, Contact.LastName, Status, Subject, CreatedDate FROM Case Limit 50];        
        openCasesCount = [SELECT COUNT() FROM Case WHERE Status = 'Not Started'];
        highCasesCount = [SELECT COUNT() FROM Case WHERE Priority = 'High'];
    }
    
    public void viewCase() {
        viewCase = [SELECT Id, CaseNumber, Subject, Description,
                    Category_Resource__c,
                    Component_Function__c,
                    CURE_Customer__c,
                    CURE_Group__c,
                    Environment__c,
                    Expedite__c,
                    Impact_VIP__c,
                    Planned_Production_Release_Date__c,
                    Planned_Test_Release_Date__c,
                    Problem__c,
                    Problem_short_description__c,
                    Reload_Data_Refresh__c,
                    Reload_Details__c,
                    Request_State__c,
                    Request_Type__c,
                    Requirements_Attached__c,
                    Resolution_Detail__c,
                    Resolution_State__c,
                    Testing_Details__c,
                    Testing_Resource__c,
                    Urgency_Critical_Business_Time__c,
                    VersionOne_Reference_ID__c,
                    Wait_State__c FROM Case WHERE Id = :viewCaseId];
        isViewCase = true;       
    }
    
    public void createTicket() {
        isCreateCase = true;
    }
    
    public void editTicket() {
        newCase = viewCase;
        isViewCase = false; 
        isCreateCase = true;
    }
    
    public void submitCase() {
        try {
            if(newCase.Id == null) {
                newCase.Origin = 'CURE Community';
                insert newCase;
            }
            else
                update newCase;
            
            if(attachment.Name != null) {
                attachment.ParentId = newCase.Id;
                insert attachment;
            }            
            
            if(newCase.Id == null) 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, newCase.CaseNumber + ' - New ticket submitted successfully'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, newCase.CaseNumber + ' - Ticket submitted successfully'));             
            
            newCase = new Case();
            isCreateCase = false;
            loadCases();
        }
        catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
}