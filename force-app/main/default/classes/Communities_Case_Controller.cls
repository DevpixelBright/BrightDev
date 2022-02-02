global without sharing class Communities_Case_Controller {
    
    public RETS_Product_Order__c productOrd {get; set;}
    public String Dept {get;set;}
    public Communities_Case_Controller() {
        String department = apexpages.currentpage().getparameters().get('department');
        String Orderid = apexpages.currentpage().getparameters().get('orderid');
        dept = department;
        newCase = new Case();
        newCase.Status = 'Not Started'; 
        if(String.isNotBlank(department)){
            if(department == 'VA')        
                newCase.Department__c = 'Vendor Authorization';
           else if(department == 'OFFMLS')
                newCase.Department__c = 'Off-MLS Listings';
        }
        
            
        if(String.isNotBlank(orderid)){
            List<RETS_Product_Order__c> orders = new List<RETS_Product_Order__c>();
             orders = [SELECT Id, Name, url__c FROM RETS_Product_Order__c WHERE Name = :orderid];
            if(!orders.isEmpty())
                productOrd = orders[0];
        }                           
            
        attach = new Attachment();
        attachments = new List<Attachment>();  
        showAttach = true; 
        testAttch = new List<test>();
    }
    
    private String currentUserId;
    private Boolean isSubscriber;
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
    public String complianceRecordType { get; set; }
    
    public List<test> testAttch { get; set; }
     
    public List<Case> subscriberCases { 
        get{
            subscriberCases = casesResult.getRecords();
            return subscriberCases;
        } set; 
    }
    
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
    
    public String createCaseSelDepart { get; set;}
    public List<SelectOption> createCaseDeparts{
        get{
            Schema.DescribeFieldResult field = Case.Department__c.getDescribe();
            List<Schema.PicklistEntry> values = field.getPicklistValues();
            List<SelectOption> options = new List<SelectOption>();      
            
            String department = apexpages.currentpage().getparameters().get('department');
            string kbArticle = apexpages.currentPage().getparameters().get('kb');
            
            newCase = new Case();
            newCase.Status = 'Not Started'; 
            
            if(String.isNotBlank(department)){
                if(department == 'VA'){       
                    newCase.Department__c = 'Vendor Authorization';
                    options.add(new SelectOption('Vendor Authorization','Vendor Authorization'));
                }
                else if(department == 'OffMLS'){
                newCase.Department__c = 'Off-MLS Listings';
                options.add(new SelectOption('Off-MLS Listings','Off-MLS Listings'));
                }
            }
            else if(String.isNotBlank(kbArticle)){
                options.add(new Selectoption('Knowledge Article', 'Knowledge Article'));
                newCase.Department__c = 'Knowledge Article';
            }
            else{
                options.add(new SelectOption('None','--None--'));
                options.add(new SelectOption('General MLS System Support','General MLS System Support'));
                List<String> departments = new List<String>{'Billing','Data Licensing','Incorrect Listing Data','Incorrect Public Records Data','Policy Questions','Syndication Sites (REALTOR.com, Zillow, etc.)','Subscription Changes','XactSite/Sphere Pro','Off-MLS Listings'};          
                departments.sort();
                for(String dlst : departments){
                    options.add(new Selectoption(dlst, dlst));
                }
                                            
                /*for(schema. e : values) {
                    if(e.getValue().toLowerCase() != 'sales')
                        options.add(new SelectOption(e.getValue(),e.getValue()));
                }*/
            }
            
            
            return options;
        }
        set;
    }
    
    public List<SelectOption> complianceTypes {get{
        complianceTypes = new List<SelectOption>();
        complianceTypes.add(new SelectOption('','--None--'));
        complianceTypes.add(new SelectOption('Compliance','Compliance'));
        complianceTypes.add(new SelectOption('Report a Violation','Report a Violation')); 
        complianceTypes.add(new SelectOption('Appeals','Appeals'));
        return complianceTypes;
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
    public String searchKey { get; set; }
    public PageReference updateSearchKey(){
       searchKey = ApexPages.currentPage().getParameters().get('updatedKey');
        system.debug('searchKey');
        return null;
    }
    
    private ApexPages.StandardSetController casesResult { 
        get{
            DateTime last18months = system.now().addMonths(-18);
            String query;
            String contactId;
            if(casesResult == null){
                String userId = System.UserInfo.getUserId();
                if(isSubscriber){
                    contactId = currentUser.ContactId;
                    
                    query = 'SELECT Id,Department__c,CaseNumber,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case WHERE ContactId = :contactId AND CreatedDate >= :last18months ORDER BY CreatedDate DESC';
                    //query = 'SELECT Id,Department__c,CaseNumber,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case WHERE CreatedById = \'' + userId + '\' ORDER BY CreatedDate DESC';                                                                
                    
                }
                else
                    query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c, Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case ORDER BY CreatedDate DESC';                                
                
                List<Case> queryCases = [SELECT Id,Department__c,CaseNumber,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate,ListingAgentName__c,BrokerageName__c,PropertyAddress__c FROM Case WHERE CreatedById = :userId ORDER BY CreatedDate DESC];
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
                    
                    if(isSubscriber){
                        contactId = currentUser.ContactId;
                        String userId = System.UserInfo.getUserId();
                        query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate,ListingAgentName__c,BrokerageName__c,PropertyAddress__c FROM Case' + filterString + ' AND ContactId = :contactId AND CreatedDate >= :last18months ORDER BY CreatedDate DESC'; 
                        //query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate FROM Case' + filterString + ' AND CreatedById = :userId ORDER BY CreatedDate DESC';                                                                   
                    }
                    else
                        query = 'SELECT Id,CaseNumber,Department__c,Description, MRIS_Connect_Description__c,Account.Name,Subscription_ID__r.Name,Contact.Name,Contact.Phone,Contact.Email,Product__c,Category__c,MLS_Number__c,Origin,Status,CreatedDate,ClosedDate,ListingAgentName__c,BrokerageName__c,PropertyAddress__c FROM Case' + filterString + ' ORDER BY CreatedDate DESC';
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
    
    public Communities_Case_Controller(ApexPages.StandardSetController controller) {
    
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
            isSubscriber = true;      
        else
            isSubscriber = false; 
        
        newCase = new Case();
        newCase.Status = 'Not Started'; 
 
    }
    
    public void refresh(){
        filter = true;
    }
    
    public List<SelectOption> subscriptionOptions { get {
        subscriptionOptions = new List<SelectOption>();         
        String subId = apexpages.currentpage().getparameters().get('id');
        
        currentUserId = System.UserInfo.getUserId();
        User currentUser = [SELECT Id, Name, ContactId
                       FROM   User 
                       WHERE  id = :currentUserId];        
        
        List<Subscriptions__c> subscriptionList = new  List<Subscriptions__c>();
        
        if(String.isNotBlank(subId)){
            subscriptionList = [SELECT Id, Name FROM Subscriptions__c WHERE Name = :subId];
        }
        else
            subscriptionList = [SELECT Id, Name FROM Subscriptions__c WHERE Contact__c = :currentUser.ContactId AND Status__c = 'Active'];
        
        if(subscriptionList.Size() == 1)
            subscriptionOptions.add(new SelectOption(subscriptionList[0].Id, subscriptionList[0].Name));
        else {
            subscriptionOptions.add(new SelectOption('','--Select--'));  
            for (Subscriptions__c subscription : subscriptionList)
                subscriptionOptions.add(new SelectOption(subscription.Id, subscription.Name));
        }     
            
        return subscriptionOptions;
    }
    set;}  
    /*
    public PageReference createCase() { 
        try {
            
            if (String.isBlank(newCase.Subscription_ID__c))
                throw new CustomException('Please select Subscription');
            
            if (String.isBlank(newCase.Department__c))
                throw new CustomException('Please select Department');
            
            if (String.isBlank(newCase.Description))
                throw new CustomException('Please enter Description');
                
            if (newCase.Department__c == 'Compliance') {
                if (String.isBlank(complianceRecordType))
                    throw new CustomException('Please select Issue Type');
            }
                
            
            if (String.isNotBlank(complianceRecordType)) {
                String query = 'SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = \'Case\'';
                if (complianceRecordType == 'Compliance')
                    query = query + ' AND DeveloperName = \'Compliance_Case\'';
                else if (complianceRecordType == 'Report a Violation')
                    query = query + ' AND DeveloperName = \'Compliance_Violation_Case\'';
                else if (complianceRecordType == 'Appeals')
                    query = query + ' AND DeveloperName = \'Compliance_Appeals_Case\'';
                
                RecordType recType = Database.query(query);
                newCase.RecordTypeId = recType.Id;
            }

            Subscriptions__c subscription = [SELECT Id, Name, Related_Location_Broker_Office__c, Contact__c, Primary_Phone__c, Private_Email__c FROM Subscriptions__c WHERE Id = :newCase.Subscription_ID__c]; 
            newCase.Origin = 'MRIS Connect';
            newCase.Subject = 'Submission of MRIS Connect Case';        
            newCase.Subscription_ID__c = subscription.Id;
            newCase.AccountId = subscription.Related_Location_Broker_Office__c; 
            newCase.ContactId = subscription.Contact__c;

newCase.MRIS_Connect_Description__c = newCase.Description;
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            newCase.setOptions(dmlOpts);
                                 
            insert newCase;
            
            for(Attachment att : attachments)
                att.ParentId = newCase.Id;
            
            insert attachments;
            
            //CaseTeamMember UserTeamMember = new CaseTeamMember();
            //UserTeamMember.MemberId = currentUser.ContactId;
            //UserTeamMember.ParentId = newCase.Id;
            //insert UserTeamMember;                                       
            
            return new PageReference('/apex/Communities_Cases_View');
           
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
            if (String.isNotBlank(newCase.Id))
                delete newCase;
            //delete attachments;
            return null;
        }
        
    }
    */
    @RemoteAction
    global static String attachFile(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue, string department){
        
        if(attachmentId == '' || attachmentId == null){
            Attachment att = new Attachment(
                
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            system.debug(att.Body);
            if(department == 'Off-MLS Listings'){
                Off_MLS_Evidence__c off = new Off_MLS_Evidence__c();
                off.FileName__c = fileName;
                off.Evidence__c = parentId;
                insert off;
                att.ParentId = off.Id;
            }else{
                att.ParentId = parentId;
            }
            
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
    global static String remoteCreateCase(String subId, String dept, String issue, String description, String mls, String prop, String listAgent, String brok){
            case newCase1 = new Case();
            
            if (String.isNotBlank(issue)) {
                String query = 'SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = \'Case\'';
                if (issue== 'Compliance')
                    query = query + ' AND DeveloperName = \'Compliance_Case\'';
                else if (issue == 'Report a Violation')
                    query = query + ' AND DeveloperName = \'Compliance_Violation_Case\'';
                else if (issue == 'Appeals')
                    query = query + ' AND DeveloperName = \'Compliance_Appeals_Case\'';
                 
                
                RecordType recType = Database.query(query);
                newCase1.RecordTypeId = recType.Id;
            }  
        
        if (dept == 'Off-MLS Listings'){
            Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Center Case').getRecordTypeId(); 
            newCase1.RecordTypeId = recordTypeId;
            newCase1.Origin = 'Bright Account & Settings';
            newCase1.Product__c = 'Off MLS Listings';
        }
                   
            
            Subscriptions__c subscription = [SELECT Id, Service_Jurisdiction__c, Name, Related_Location_Broker_Office__c, Contact__c, Primary_Phone__c, Private_Email__c FROM Subscriptions__c WHERE Id = :subId]; 
            if(subscription.Service_Jurisdiction__c == 'TREND') {
                newCase1.Origin = 'TREND Account & Settings'; //'TREND Connect';
                newCase1.Subject = 'Submission of Bright Account & Settings Case';            
            }
            else if(subscription.Service_Jurisdiction__c == 'MRIS'){
                newCase1.Origin = 'MRIS Account & Settings'; //'MRIS Connect';
                newCase1.Subject = 'Submission of Bright Account & Settings Case';
            }
            else if(subscription.Service_Jurisdiction__c == 'BRIGHT'){
                newCase1.Origin = 'Bright Account & Settings'; //'MRIS Connect';
                newCase1.Subject = 'Submission of Bright Account & Settings Case'; //'Submission of MRIS Connect Case';
            }
            newCase1.Subscription_ID__c = subscription.Id;
            newCase1.AccountId = subscription.Related_Location_Broker_Office__c; 
            newCase1.ContactId = subscription.Contact__c;
            newCase1.MRIS_Connect_Description__c = description;
            newCase1.Department__c = dept;
            newCase1.MLS_Number__c = mls;
            newCase1.MLS__c=subscription.Service_Jurisdiction__c;
            newCase1.ListingAgentName__c = listAgent;
            newCase1.BrokerageName__c = brok;
			newCase1.PropertyAddress__c = prop;            
            
                        
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            newCase1.setOptions(dmlOpts);
                                 
            insert newCase1;
            
            return newCase1.Id;
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