global without sharing class Communities_NewCase_Controller {
    
    
    public string selDepartments{get; set;}
    
    public List<SelectOption> getItems() {
        
        List<SelectOption> options = new List<SelectOption>();
        Map<String,RETS_Vendor_Case_Departments__c> allDepts = new Map<String,RETS_Vendor_Case_Departments__c>();
        allDepts = RETS_Vendor_Case_Departments__c.getAll();
        
        for(RETS_Vendor_Case_Departments__c dep : allDepts.values()){
             options.add(new SelectOption(dep.name, dep.name));
        }
        return options;
    }
    
    
    
       
    public Communities_NewCase_Controller() {
        
        
        
        
        String department = apexpages.currentpage().getparameters().get('department');
        newCase = new Case();
        newCase.Status = 'Not Started'; 
        if(String.isNotBlank(department)){
            if(department == 'AP')        
                newCase.Department__c = 'Accuracy & Policy';
        }
        
        attach = new Attachment();
        attachments = new List<Attachment>();  
        showAttach = true; 
        testAttch = new List<test>();
    }
    
    
    
    private String currentUserId;
    private Boolean hasContact;
    private User currentUser;
    
    private Integer listsize = 10;
    public Integer resultSize { get; set; }
    
    public String filterValue { get; set; }
    public String filterType { get; set; }
    public Boolean filter { get; set; }
    
    public String filterValue1 { get; set; }
    public String filterType1 { get; set; }    
    
    public Case newCase { get; set; }
    public Attachment attach { get; set; }
    public List<Attachment> attachments { get; set; }
    public Boolean showAttach { get; set; }
    public string complianceRecordType { get; set; }
    
    public List<test> testAttch { get; set; }
    public String searchKey { get; set; }
    
   
    
     public List<String> departments{
        get{
            Schema.DescribeFieldResult field = Case.Department__c.getDescribe();
            List<Schema.PicklistEntry> values = field.getPicklistValues();
            departments = new List<String>();
            for(Schema.PicklistEntry e : values) {
                departments.add(e.getValue());
            }
            return departments;
        }
        
        set;
    }
    //public string seletedSubscription {get; set;}
	public string subscriptionOptions { get {
        //subscriptionOptions = new List<SelectOption>();         
        //String subId = apexpages.currentpage().getparameters().get('id');
        
        currentUserId = System.UserInfo.getUserId();
        User currentUser = [SELECT Id, Name, ContactId
                       FROM   User 
                       WHERE  id = :currentUserId];        
        
        List<Subscriptions__c> subscriptionList = new  List<Subscriptions__c>();
        
       /* if(String.isNotBlank(subId)){
            subscriptionList = [SELECT Id, Name FROM Subscriptions__c WHERE Name = :subId];
        }
        else*/
            subscriptionList = [SELECT Id, Name FROM Subscriptions__c WHERE Contact__c = :currentUser.ContactId AND Status__c = 'Active'];
        
        if(subscriptionList.Size() > 0)
            subscriptionOptions = subscriptionList[0].Name;
        
            
        return subscriptionOptions;
    }
    set;}
    
    
    public List<String> status{
        get{
            Schema.DescribeFieldResult field = Case.Status.getDescribe();
            List<Schema.PicklistEntry> values = field.getPicklistValues();
            status = new List<String>();
            for(Schema.PicklistEntry e : values) {
                status.add(e.getValue());
            }
            return status;
        }
        
        set;
    }
    
             
    
    
    public string displayName {get; set;}
    public Communities_NewCase_Controller(ApexPages.StandardSetController controller) {
        
        newCase = new Case();
        newCase.Status = 'Not Started'; 
        
    }
    
    public void refresh(){
        filter = true;
    }
    
    
    @RemoteAction
    global static String attachFile(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
        if(attachmentId == '' || attachmentId == null){
            Attachment att = new Attachment(
                ParentId = parentId,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            insert att;
            return att.Id;
        }
        else{
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }                     
    }
    
    @RemoteAction
    global static String remoteCreateCase(String dept, String subject, String description, string subName){
        
        system.debug('---subName--->'+subName);
        string subId;
        if(subName != null){
            list<Subscriptions__c> lstSubs = [Select Id from Subscriptions__c where Name =: subName];
            system.debug('--lstSubs--->'+lstSubs);
            subId = lstSubs[0].Id;
        }
        
        
        case newCase1 = new Case();
        newCase1.Origin = 'Account & Settings'; 
        newCase1.Subject = subject;            
        newCase1.MRIS_Connect_Description__c = description;
        //newCase1.Department__c = dept;
		if(subId != null)
        	newCase1.Subscription_ID__c = subId;
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        newCase1.setOptions(dmlOpts);
        
        insert newCase1;
        
        return newCase1.Id;
    }    
    
    public PageReference updateSearchKey(){
       searchKey = ApexPages.currentPage().getParameters().get('updatedKey');
        system.debug('searchKey');
        return null;
    }
    
    public class CustomException extends Exception {}
    
}