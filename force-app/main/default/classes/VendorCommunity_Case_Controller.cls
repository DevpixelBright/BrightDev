global without sharing class VendorCommunity_Case_Controller {
    
    
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
    
       
    public VendorCommunity_Case_Controller() {
        
        
        currentUserId = System.UserInfo.getUserId();
        
        currentUser = new User();
        currentUser = [SELECT Id,Name,
                       ContactId,
                       Contact.Name
                       FROM   User 
                       WHERE  id = :currentUserId
                      ];
        
        List<Contact> userContact = [SELECT  Id, Name, Account.Name
									FROM    Contact
									WHERE   Id =: currentUser.ContactId 
									And Status__c = 'Active' 
									And Account.Status__c = 'Active'
                                    And Account.Type = 'RETS'
									];
        
        if (userContact.size() == 0) return;
        displayName = userContact[0].Account.Name;
        
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
    
    public List<Case> subscriberCases { 
        get{
            subscriberCases = casesResult.getRecords();
            return subscriberCases;
        } set; 
    }
    
    public List<String> departments{
        get{
            Map<String,RETS_Vendor_Case_Departments__c> allDepts = new Map<String,RETS_Vendor_Case_Departments__c>();
            allDepts = RETS_Vendor_Case_Departments__c.getAll();
            departments = new List<String>();
            for(RETS_Vendor_Case_Departments__c dep : allDepts.values()){
                departments.add(dep.name);
            }
            return departments;
        } 
        set;
    }
    
    
    
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
    
    private ApexPages.StandardSetController casesResult { 
        get{
            DateTime last18months = system.now().addMonths(-18);
            String query;
            String contactId;
            if(casesResult == null){
                String userId = System.UserInfo.getUserId();
                if(hasContact){
                    contactId = currentUser.ContactId;
                    
                    query = 'SELECT Id,Department__c,CaseNumber,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case WHERE ContactId = :contactId AND CreatedDate >= :last18months ORDER BY CreatedDate DESC';
                    //query = 'SELECT Id,Department__c,CaseNumber,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case WHERE CreatedById = \'' + userId + '\' ORDER BY CreatedDate DESC';                                                                
                    
                }
                else
                    query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c, Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case ORDER BY CreatedDate DESC';                                
                
                List<Case> queryCases = [SELECT Id,Department__c,CaseNumber,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case WHERE CreatedById = :userId ORDER BY CreatedDate DESC];
                System.debug('*** query: ' + queryCases);
                System.debug('*** id:' + userId);
                system.debug('*** query :' + query ); 
                system.debug('*** currentUser :' + currentUser ); 
                casesResult = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                casesResult.setPageSize(listsize);
                resultSize = casesResult.getResultSize();
                if(casesResult.getResultSize() == 0)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Cases have been submitted for the past 18 months'));
                
            }
            else{
                
                system.debug('*** filterValue:' + filterValue + filterValue1);
                
                if(filter){
                    String filterString =  ' WHERE ';  
                    Boolean hasStatus = false;
                    if(filterValue != '') {
                        List<String> statusValues = filterValue.split(',');
                        filterString = filterString + ' Status =:statusValues';
                        hasStatus = true;
                    }
                    if(filterValue1 != '') {
                        if(hasStatus)
                            filterString = filterString + ' AND ';   
                        List<String> deptValues = filterValue1.split(',');
                        filterString = filterString + ' Department__c =:deptValues';
                    }                        
                    
                    System.debug('*** filterString : ' + filterString);
                    
                    if(hasContact){
                        contactId = currentUser.ContactId;
                        string userId = System.UserInfo.getUserId();
                        query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case' + filterString + ' AND ContactId = :contactId AND CreatedDate >= :last18months ORDER BY CreatedDate DESC'; 
                        //query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case' + filterString + ' AND CreatedById = :userId ORDER BY CreatedDate DESC';                                                                   
                    }
                    else
                        query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case' + filterString + ' ORDER BY CreatedDate DESC';
                    system.debug('*** query :' + query ); 
                    casesResult = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                    casesResult.setPageSize(listsize);
                    resultSize = casesResult.getResultSize();
                    if(casesResult.getResultSize() == 0)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No results found'));
                }
                
                filter = false;
                //system.debug('*** :' + ); 
                
            }
            return casesResult;            
        }
        set;    
    }
    
    public Integer pageNumber {
        get {
            if(totalPages == 0)
                return 0;
            return casesResult.getPageNumber(); }
        private set;
    }
    
    public Integer totalPages {
        get {        
            if (math.mod(casesResult.getResultSize(), listSize) > 0) 
                totalPages = casesResult.getResultSize()/listSize + 1;
            else 
                totalPages = (casesResult.getResultSize()/listSize);
            
            return totalPages;
        }
        private set;
    }
    
    public void first() { casesResult.first();}
    
    public void last() { casesResult.last();}
    
    public void previous(){ casesResult.previous();}
    
    public void next() { casesResult.next(); }   
    
    public string displayName {get; set;}
    public VendorCommunity_Case_Controller(ApexPages.StandardSetController controller) {
        
        currentUserId = System.UserInfo.getUserId();
        
        currentUser = new User();
        currentUser = [SELECT Id,Name,
                       ContactId,
                       Contact.Name
                       FROM   User 
                       WHERE  id = :currentUserId
                      ];
        
        filter = false;
        
        if(String.isNotBlank(currentUser.ContactId))
            hasContact = true;      
        else
            hasContact = false; 
        
        List<Contact> userContact = [SELECT  Id, Name, Account.Name
									FROM    Contact
									WHERE   Id =: currentUser.ContactId 
									And Status__c = 'Active' 
									And Account.Status__c = 'Active'
                                    And Account.Type = 'RETS'
									];
        
        if (userContact.size() == 0) return;
        displayName = userContact[0].Account.Name;
        
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
    global static String remoteCreateCase(String dept, String subject, String description){
        
        case newCase1 = new Case();

        newCase1.Origin = 'Vendor Account & Settings'; 
        newCase1.Subject = subject;            
        newCase1.MRIS_Connect_Description__c = description;
        newCase1.Department__c = dept;
        
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
    /*
public PageReference DeleteAttachment() {
String attachmentName = apexpages.currentpage().getparameters().get('AttachmentName');
for (Integer i=0; i<attachments.Size(); i++) {
if (attachments[i].Name == attachmentName)
attachments.remove(i);
}
return null;        
}      
public class test {
public String filename;
public String body;
}
*/
    public class CustomException extends Exception {}
    
}