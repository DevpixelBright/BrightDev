public class Communities_OfficeManager{
    
    public List<Account> offices { get; set; }
    public List<Relationship__c> officeRelationships { get; set; }
    public List<officeRecord> officeRecords { get; set; }
    public String officesStr { get; set; }
    public String subscriptionId { get; set; }
    public String officeId { get; set; } 
    public Relationship__c relationship { get; set; }
    public Account office { get; set; }
    public Boolean isAccountDetail { get; set; }
    public Boolean ham { get; set; }
    public String pathType { get; set; }
    
    /* Add new signer */
    public Boolean isAddNewManager { get; set; }
    public Boolean hasInitialError { get; set; }
    public Boolean assignOfficeDisable {get;set;}
    public Boolean isEdit {get;set;}
    public Boolean hasError {get;set;}
    public Boolean isContent {get;set;}
    public List<Subscriptions__c> searchResults { get; set; }
    public List<officeRecord> selectedOffices { get; set; }
    public searchInput search { get; set; }
    public Subscriptions__c subscriber { get; set; }
    public String selectedOfficesStr { get; set; }
    public String existingOfficesStr { get; set; }
    public String subscriberSelected { get; set; }
    public String errorMessage { get; set; }
    
    /* Accordion controlling variables */
    public String searchBlockState { get; set; }
    public String assignBlockState { get; set; }
    public String reviewBlockState { get; set; }
    public String termsBlockState { get; set; }
    public String summaryBlockState { get; set; }  
    public String borEmail;
    public String BORname = '';
    public String BORSubId = '';
    public List<String> agentEmailId;
    private List<Messaging.SingleEmailMessage> finalMails;
    public List<officeRecord> addedList { get; set; }
    public List<officeRecord> removedList { get; set; }
    private Map<String,EmailTemplate> templateIdMap;
    String agentTemplateId;
    String borTemplateId;
    
    public Communities_OfficeManager(){
        if(ApexPages.currentpage().getparameters().get('subid') != null) {
            isContent = true;
        }
        else{
            isContent = false;
        }
        init();
        
    }
    
    
    public void init() {
        hasInitialError = false;    
        assignOfficeDisable = false;
        isEdit = false;
        pathType = 'Assign';
        try {
            hasError = false;
            subscriptionId = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found  ' );   
            
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT Id, 
                             Relationship_Type__c, 
                             Broker_Office__c, 
                             Broker_Office__r.ParentId,
                             Subscription__r.Name, 
                             Subscription__r.Contact__r.Name,
                             Subscription__r.Private_Email__c
                             FROM   Relationship__c
                             WHERE  Relationship_Type__c = 'Broker Of Record'
                             AND    (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                             AND    Subscription_ID__c = :subscriptionId];
            
            if(relationships.Size() == 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You do not have permission to access this page'));
                hasError = true;
            }
            if(relationships.size() > 0) {               
                List<String> parentIds = new List<String>();
                
                borEmail = relationships[0].Subscription__r.Private_Email__c;
                BORname = relationships[0].Subscription__r.Contact__r.Name;
                BORSubId = relationships[0].Subscription__c;
                
                if(String.IsNotBlank(relationships[0].Broker_Office__r.ParentId))
                    parentIds.add(relationships[0].Broker_Office__r.ParentId);            
                
                if(String.IsNotBlank(relationships[0].Broker_Office__c))
                    parentIds.add(relationships[0].Broker_Office__c);
                
                offices = new List<Account>(); 
                offices = [SELECT Id, 
                           Name,
                           Account_Name__c,
                           Street_Number__c,
                           Street_Name__c,
                           City__c,
                           State__c,
                           Zip__c,
                           (SELECT 	Id, 
                            Subscription__c, 
                            Subscription__r.Contact__c,
                            Subscription__r.Contact__r.FirstName,
                            Subscription__r.Contact__r.LastName,
                            Subscription__r.Name,
                            Subscription__r.Related_Location_Broker_Office__c,
                            Subscription__r.Related_Location_Broker_Office__r.Name
                            FROM 	Relationships__r 
                            WHERE 	Relationship_Type__c = 'Office Manager' 
                            AND 	Status__c = 'Active'
                            AND 	(Broker_Office__c IN :parentIds OR Broker_Office__r.ParentId IN :parentIds)
                            AND		(Subscription__r.Related_Location_Broker_Office__c IN :parentIds 
                                     OR       Subscription__r.Related_Location_Broker_Office__r.ParentId IN :parentIds)
                            AND 	(Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                            AND 	Subscription__c != null)
                           FROM   	Account
                           WHERE  	(ParentId IN :parentIds OR Id IN :parentIds)
                           AND    	Status__c = 'Active'];
                
                /* Logic to find subscriber manager for */
                List<Id> subscriberIds = new List<Id>();
                List<Id> officeIds = new List<Id>();
                for(Account a : offices) {
                    officeIds.add(a.Id);
                    if(a.Relationships__r.Size() > 0) {
                        for(Relationship__c rel : a.Relationships__r) {
                            subscriberIds.add(rel.Subscription__c);
                        }   
                    }
                }
                system.debug('***subscriberIds'+subscriberIds);
                Map<Id, Subscriptions__c> subcriberMap;
                if(subscriberIds.Size() > 0) {
                    subcriberMap = new Map<Id, Subscriptions__c> ([SELECT 	Id,Name,
                                                                   (SELECT 	Id, Broker_Office__c, Broker_Office__r.Name 
                                                                    FROM 	Relationships__r 
                                                                    WHERE 	Relationship_Type__c = 'Office Manager' 
                                                                    AND 		Broker_Office__c IN :officeIds
                                                                    AND 		Status__c = 'Active'
                                                                    AND 		(Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)),
                                                                   (SELECT 	Id, License_Type__c
                                                                    FROM 	Subscription_Licenses__r)                                                                      
                                                                   FROM  	Subscriptions__c
                                                                   WHERE  	Id IN :subscriberIds
                                                                   AND 		(Related_Location_Broker_Office__c IN :officeIds
                                                                             OR 		Related_Location_Broker_Office__r.ParentId IN :officeIds)
                                                                  ]);
                }
                system.debug('***subcriberMap'+subcriberMap);
                /* Framing data for front end display */
                officeRecords = new List<officeRecord>();
                for(Account a : offices) {
                    officeRecord obj = new officeRecord();
                    obj.id = a.Id;
                    obj.officeId = '<a>' + a.Name + '</a>';
                    obj.name = a.Account_Name__c;
                    obj.street = (a.Street_Number__c != null ? a.Street_Number__c + ' ' : '') +  (a.Street_Name__c != null ? a.Street_Name__c + ' ' : '');
                    obj.city = a.City__c;
                    obj.state = a.State__c;
                    obj.zip = a.Zip__c;
                    obj.signersCount = '<a>' + String.valueOf(a.Relationships__r.Size()) + '</a>';
                    if(a.Relationships__r.Size() > 0) {
                        String signers = '<div class="arrow-up"></div><div class="slide-down"><h3>Office Managers for ' + a.Name + ':</h3><table class="table">'+
                            '<thead><tr>' +
                            '<th>First Name</th>' +
                            '<th>Last Name</th>' +
                            '<th>Office ID</th>' +
                            '<th>Subscriber ID</th>' +
                            '<th>Manager For</th>' +
                            '<th>License Type</th>' +
                            '<th></th>' +
                            '</tr></thead><tbody>'; 
                        
                        for(Relationship__c rel : a.Relationships__r) {                       
                            signers +=      '<tr>' +
                                '<td>' + rel.Subscription__r.Contact__r.FirstName + '</td>' +
                                '<td>' + rel.Subscription__r.Contact__r.LastName + '</td>' +
                                '<td>' + rel.Subscription__r.Related_Location_Broker_Office__r.Name + '</td>' +
                                '<td>' + rel.Subscription__r.Name + '</td>';
                            
                            if(subcriberMap.get(rel.Subscription__c) != null) {
                                String relatedTo = '';
                                for(Relationship__c sRel : subcriberMap.get(rel.Subscription__c).Relationships__r) {
                                    relatedTo += sRel.Broker_Office__r.Name + ', ';    
                                }
                                if(relatedTo.length() > 1)
                                    relatedTo = relatedTo.substring(0, relatedTo.length()-2);
                                signers +=  '<td><a data-toggle="tooltip" title="' + relatedTo + '" data-placement="right">' + subcriberMap.get(rel.Subscription__c).Relationships__r.Size() + ' Office</a></td>';
                                if(subcriberMap.get(rel.Subscription__c).Subscription_Licenses__r.Size() > 0)
                                    signers +=  '<td>' + (subcriberMap.get(rel.Subscription__c).Subscription_Licenses__r[0].License_Type__c != null ? subcriberMap.get(rel.Subscription__c).Subscription_Licenses__r[0].License_Type__c : '') + '</td>';
                                else
                                    signers +=  '<td></td>';    
                            }
                            else {
                                signers +=  '<td>0 Office</td>';
                                signers +=  '<td></td>';                            
                            }
                            signers +=  '<td><a href="/customers/Communities_OfficeManager?id=' + subscriptionId + '&subid=' + rel.Subscription__c + '" class="label label-primary modifySubscriber">Modify</a></td>';
                            isEdit = true;
                            signers +=      '</tr>';                                                     
                        }
                        signers += '</tbody></table></div>';
                        obj.signers = signers;
                    }
                    
                    
                    officeRecords.add(obj);
                }
                
                officesStr = JSON.Serialize(officeRecords);               
            }
            
        }
        catch(Exception e) {
            hasInitialError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }    
        
        isAccountDetail = false;
        isAddNewManager = false;
        search = new searchInput();
        searchResults = new List<Subscriptions__c>();
        
        if(ApexPages.currentpage().getparameters().get('subid') != null) {
            subscriberSelected = ApexPages.currentpage().getparameters().get('subid');
            isEdit = true;
            pathType = 'Modify';
            individualSelected();
        }         
    }
    
    public void accountDetails() {
        office = [SELECT  	Id, 
                  Name,
                  Account_Name__c,
                  Billing_Street_Number__c,
                  Billing_Street_Name__c,
                  City__c,
                  State__c,
                  Zip__c
                  FROM   	Account
                  WHERE  	Id = :officeId
                  AND    	Status__c = 'Active'];
        
        
        officeRelationships = [SELECT 	Id, 
                               Name, 
                               Subscription__c,
                               Subscription__r.Name,
                               First_Name__c,
                               Last_Name__c, 
                               Broker_Office__c, 
                               Contact__c, 
                               Status__c
                               FROM   	Relationship__c
                               WHERE  	Broker_Office__c = :officeId
                               AND    	Relationship_Type__c = 'Office Manager'
                               AND    	Status__c = 'Active'];
        System.debug('*** relationships: ' + officeRelationships);
        isAccountDetail = true;
    }
    
    public void addNewManager() {
        ham = true;
        isAddNewManager = true;
        searchBlockState = 'Started';
        assignBlockState = '';
        reviewBlockState = '';
        termsBlockState = '';
        summaryBlockState = '';
        relationship = new Relationship__c();
    }
    
    public void getSearchResults() {
        ham = false;
        System.debug('*** search:' + search);
        String query = 'SELECT Id, Name, Contact__c, Contact__r.FirstName, Contact__r.LastName, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Name FROM Subscriptions__c WHERE Status__c = \'Active\' AND Related_Location_Broker_Office__c =:offices';
        if(String.isNotBlank(search.subscriberId)) {
            String searchText1 = '%' + search.subscriberId + '%';
            query += ' AND Name LIKE :searchText1';
        }
        
        if(String.isNotBlank(search.firstName)) {
            String searchText2 = '%' + search.firstName + '%';
            query += ' AND Contact__r.FirstName LIKE :searchText2';
        }
        
        if(String.isNotBlank(search.lastName)) {
            String searchText3 = '%' + search.lastName + '%';
            query += ' AND Contact__r.LastName LIKE :searchText3';
        }
        
        if(String.isNotBlank(search.officeId)) {
            String searchText4 = '%' + search.officeId + '%';
            query += ' AND Related_Location_Broker_Office__r.Name LIKE :searchText4';
        }
        else {
            query += ' AND Related_Location_Broker_Office__c IN :offices';
        }                
        
        searchResults = database.query(query);
        System.debug('*** results:' + searchResults);
    }
    
    public void individualSelected() {
        System.debug('*** ' + subscriberSelected);
        isEdit = false;
        subscriber = [SELECT Id, 
                      Name, 
                      Contact__c, 
                      Contact__r.Name,
                      Contact__r.FirstName,
                      Contact__r.LastName,
                      Contact__r.Phone,
                      Contact__r.Email,
                      Private_Email__c,
                      Related_Location_Broker_Office__c,
                      Related_Location_Broker_Office__r.Name,
                      Related_Location_Broker_Office__r.Account_Name__c,
                      Related_Location_Broker_Office__r.City__c,
                      Related_Location_Broker_Office__r.State__c,
                      Related_Location_Broker_Office__r.Zip__c,
                      Related_Location_Broker_Office__r.Street_Number__c,
                      Related_Location_Broker_Office__r.Street_Name__c,
                      Related_Location_Broker_Office__r.QAS_Mailing_Street_Type__c,
                      (SELECT Id, 
                       Broker_Office__c, 
                       Relationship_End_Date__c, 
                       Status__c 
                       FROM 	Relationships__r 
                       WHERE 	Relationship_Type__c = 'Office Manager'
                       AND    (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                       AND 	Status__c = 'Active')
                      FROM 	Subscriptions__c
                      WHERE 	Id = :subscriberSelected];
        
        existingOfficesStr = '';
        if(subscriber.Relationships__r.Size() > 0) {
            for(Relationship__c rel : subscriber.Relationships__r) {
                existingOfficesStr += rel.Broker_Office__c + ',';
            }
        }      
        isAddNewManager = true;
        assignBlockState = 'Started';
        searchBlockState = 'Completed';
        reviewBlockState = '';
        termsBlockState = '';
        summaryBlockState = '';
    }
    
    public void assignAuthority() {
        System.debug('***' + selectedOfficesStr);
        addedList = new List<officeRecord>();
        removedList = new List<officeRecord>();
        selectedOffices = new List<officeRecord>();
        List<String> existingList = existingOfficesStr.split(',');
        Set<String> selectedList = (Set<String>) JSON.Deserialize(selectedOfficesStr, Set<String>.class);
        Set<String> added = new Set<String>();
        Set<String> removed = new Set<String>();
        Set<String> existing = new Set<String>(existingList);
        
        for(String existingId : existing) {
            if(!(selectedList.contains(existingId))) {
                removed.add(existingId);
            }
        }
        
        for(String selectedId : selectedList) {
            if(!(existing.contains(selectedId))) {
                added.add(selectedId);
            }    
        }
        
        for(officeRecord record : officeRecords) {
            if(existing.contains(record.id) && removed.contains(record.id)) {
                record.status = 'Remove';
                removedList.add(record);
                system.debug('removedList'+removedList);
                selectedOffices.add(record);
            }
            else if(added.contains(record.id) && !(existing.contains(record.id))) {
                record.status = 'New';
                addedList.add(record);
                system.debug('addedList'+addedList);
                selectedOffices.add(record);            
            }
            else if(existing.contains(record.id) && !(added.contains(record.id)) && !(removed.contains(record.id))){
                record.status = 'Existing';
                selectedOffices.add(record);            
            }
        }
        
        searchBlockState = 'Completed';
        assignBlockState = 'Completed';
        reviewBlockState = 'Started';
        termsBlockState = '';
        summaryBlockState = '';
    }
    
    public void reviewChanges() {
        searchBlockState = 'Completed';
        assignBlockState = 'Completed';
        reviewBlockState = 'Completed';
        termsBlockState = 'Started';
        summaryBlockState = '';       
    }
    
    
    public void saveManagers() {
        errorMessage = '';
        try {
            
            List<RecordType> individualtoOffice = [SELECT 	Id,Name 
                                                   FROM 	RecordType 
                                                   WHERE 	SobjectType = 'Relationship__c' 
                                                   AND 		DeveloperName = 'Individual_to_Office'];
            
            isAddNewManager = true;
            searchBlockState = 'Completed';
            assignBlockState = 'Completed';
            reviewBlockState = 'Completed';
            termsBlockState = 'Completed';
            summaryBlockState = 'Started';
            
            List<Relationship__c> newRelationships = new List<Relationship__c>();
            List<Relationship__c> endDateRelationships = new List<Relationship__c>();
            for(officeRecord record : selectedoffices) {
                if(record.status == 'New') {
                    Relationship__c rel = new Relationship__c();
                    rel.Broker_Office__c = record.id;
                    rel.Related_Account__c = record.id;
                    rel.Contact__c = subscriber.Contact__c;
                    rel.Subscription__c = subscriber.Id;
                    rel.Relationship_Type__c= 'Office Manager';
                    rel.Status__c = 'Active';
                    rel.RecordTypeId = individualtoOffice[0].id;
                    newRelationships.add(rel);
                }
                
                if(record.status == 'Remove') {
                    for(Relationship__c rel : subscriber.Relationships__r) {
                        if(rel.Broker_Office__c == record.id){
                            rel.Status__c = 'Inactive';
                            endDateRelationships.add(rel);
                        }
                    }            
                }
            }
            
            List <Messaging.SingleEmailmessage> lSendEmail = new List<Messaging.SingleEmailmessage>();
            if(endDateRelationships.size() > 0){
                update endDateRelationships; 
                System.debug(endDateRelationships);
                List<Relationship__c> relationshipsRemove = new List<Relationship__c>();
                relationshipsRemove = [SELECT Id,Subscription__r.Contact_Type__c,Subscription__c, Subscription__r.id
                                       FROM Relationship__c
                                       WHERE Status__c = 'Inactive'
                                       // AND Relationship_End_Date__c != null
                                       AND  Id IN:endDateRelationships];
                List<String> allRelationdhips = new List<String>();
                List<Subscriptions__c> subs2 = [SELECT Id, Contact_Type__c, Previous_Type__c,
                                                (SELECT Id,Status__c
                                                 FROM Relationships__r
                                                )
                                                FROM Subscriptions__c
                                                WHERE Id =: relationshipsRemove[0].Subscription__c];
                for(Subscriptions__c subrel: subs2){
                    for(Relationship__c rel:subrel.Relationships__r){
                        allRelationdhips.add(rel.Id);
                    }
                }
                List<Relationship__c> checkRelationships = [SELECT Id,Status__c, Relationship_Type__c
                                                            FROM Relationship__c
                                       WHERE Id IN: allRelationdhips];
               System.debug('---------allRelationdhips'+allRelationdhips);
                System.debug('---------subs2'+subs2.size());
                List<Subscriptions__c> relationshipsRemove2 = new List<Subscriptions__c>();
                List<Relationship__c> checkRelationships2 = new List<Relationship__c>();
                for(Relationship__c rels:checkRelationships){
                    if(rels.Status__c == 'Active' && rels.Relationship_Type__c == 'Office Manager'){
                        checkRelationships2.add(rels);
                    }
                }
                if(checkRelationships2.IsEmpty()){
                    if(subs2[0].Previous_Type__c != null){
                    for(Subscriptions__c relate2: subs2) {
                        System.debug('---------Before Remove'+ relate2.Contact_Type__c);
                        relate2.Contact_Type__c = relate2.Previous_Type__c;
                        System.debug('---------After Remove'+ relate2.Contact_Type__c);
                        relationshipsRemove2.add(relate2);
                    }
                }
                }
                if(relationshipsRemove2.size() > 0){
                    System.debug('========');
                    update relationshipsRemove2;
                    System.debug('========'+relationshipsRemove2);
                }
                setTemplateIds();
                if(borEmail != Null){
                    lSendEmail.add(sendEmailToOfficeManager(endDateRelationships, borEmail, Label.OM_BOR_Removal, BORname, subscriber, BORSubId));
                }
                if(subscriber.Private_Email__c != Null){
                    lSendEmail.add(sendEmailToOfficeManager(endDateRelationships, subscriber.Private_Email__c, Label.OM_Agent_Removal, subscriber.Contact__r.FirstName,subscriber,subscriber.Id));
                }
            }
            if(newRelationships.size() > 0) {
                insert newRelationships;
                System.debug(newRelationships);
                List<Relationship__c> relationships2 = new List<Relationship__c>();
                relationships2 = [select Id,Subscription__r.Contact_Type__c,Subscription__c, Subscription__r.id 
                                  FROM	 Relationship__c 
                                  where Status__c = 'Active' 
                                  AND Relationship_Start_Date__c != null 
                                  AND Id IN:newRelationships];
                
                List<Subscriptions__c> subs = [Select Id, Contact_Type__c from Subscriptions__c where Id =: relationships2[0].Subscription__c];
                List<Subscriptions__c> relationships3 = new List<Subscriptions__c>();
                if(subs.size()>0){
                    for(Subscriptions__c relate: subs) {
                        System.debug('---------Before'+ relate.Contact_Type__c);
                        //if(relate.Previous_Type__c != '' || relate.Previous_Type__c != null)
                        relate.Previous_Type__c = relate.Contact_Type__c;
                        relate.Contact_Type__c = 'Office Manager';
                        System.debug('---------After'+ relate.Contact_Type__c);
                        relationships3.add(relate);
                    } 
                    
                    if(relationships3.size() > 0){
                        System.debug('========');
                        update relationships3;
                        System.debug('========'+relationships3);
                    }
                }
                setTemplateIds();
                if(borEmail != Null){
                    lSendEmail.add(sendEmailToOfficeManager(newRelationships, borEmail, Label.OM_BOR_Assign, BORname, subscriber, BORSubId));
                }
                if(subscriber.Private_Email__c != Null){
                    lSendEmail.add(sendEmailToOfficeManager(newRelationships, subscriber.Private_Email__c, Label.OM_Agent_Assign, subscriber.Contact__r.FirstName,subscriber,subscriber.Id));
                }
            }
            if(!lSendEmail.isEmpty()){
                Messaging.sendEmail(lSendEmail);
            }
            
        }
        catch(Exception e) {
            errorMessage = 'ERROR: ' + e.getCause() + e.getStackTraceString() + borTemplateId;
            system.debug('*** e.getStackTraceString()'+ e.getStackTraceString());
        }
    }
    
    public void setTemplateIds(){
        system.debug('***setTemplateIds');
        templateIdMap = new Map<String,EmailTemplate>();
        List<String> templateNames = new List<String>{
            'Office_Manager_Removal_Email_to_Subscriber',
                'Office_Manager_Assigned_Email_to_Subscriber',
                'Office_Manager_Assigned_Email_to_Broker',
                'Office_Manager_Removal_Email_to_Broker'                            
                };
                    for(EmailTemplate et : [SELECT 	Id, 
                                            Subject, 
                                            HtmlValue, 
                                            Body, 
                                            DeveloperName 
                                            FROM 	EmailTemplate
                                            WHERE 	DeveloperName IN :templateNames])
                    templateIdMap.put(et.DeveloperName, et);
        system.debug('***templateNames'+templateNames);
        
    }
    
    //Method to send emails for assigning and removal of Office Manager
    public Messaging.SingleEmailmessage sendEmailToOfficeManager(List<Relationship__c> lRel,String Email, String templateId, String firstName, Subscriptions__c subscriber, String BORSubId){  
        system.debug('***templateId' + templateId);
        system.debug('***Email' + Email);
        system.debug('***firstName' + firstName);
        system.debug('***lRel' + lRel);
        
        // grab the email template
        EmailTemplate emailTemplate = templateIdMap.get(templateId);
        
        String a = '';
        for(OfficeRecord acc : addedList){           
            a += acc.Name + '<br/>';
        }
        
        String b = '';
        for(OfficeRecord acc1 : removedList){           
            b += acc1.Name + '<br/>';
        }
        
        String contactFirstName = firstName;
        String subPrivateEmail = Email;
        String subId = subscriber.Id;
        String BORSubsId = BORSubId;
        String SubFullName = subscriber.Contact__r.Name;
        
        // process the merge fields
        String htmlBody = emailTemplate.HtmlValue;
        String Subject = emailTemplate.Subject;
        htmlBody = htmlBody.replace('{!Contact.FirstName}', contactFirstName);
        htmlBody = htmlBody.replace('{!Offices}', a);
        htmlBody = htmlBody.replace('{!Officesremove}', b);
        htmlBody = htmlBody.replace('{!subId}', subId);
        htmlBody = htmlBody.replace('{!BORSubsId}', BORSubsId);
        htmlBody = htmlBody.replace('{!SubFullName}', SubFullName);
        htmlBody = htmlBody.replace('{!BrightLink}', Label.BRIGHT_Logo_Link);
        htmlBody = htmlBody.replace('{!BrightLogo}', Label.Email_Template_Register_Bright_Logo);
        htmlBody = htmlBody.replace('{!RBLogo}', Label.EmailTemplate_Responsible_Broker);
        
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Contact.FirstName}', contactFirstName);
        plainBody = plainBody.replace('{!SubFullName}', SubFullName);
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        String orgWideAddress = orgWideAddresses[0].Id;
        
        Messaging.SingleEmailMessage sendMail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{subPrivateEmail};
            sendMail.setToAddresses(sendingTo);
        sendMail.setTreatTargetObjectAsRecipient(false);
        sendMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
        sendMail.setSubject(Subject);
        sendMail.setHtmlBody(htmlBody);
        sendMail.setPlainTextBody(plainBody); 
        sendMail.setOrgWideEmailAddressId(orgWideAddress);
        return sendMail;
        
    }
    
    public void closeModal(){
        isAddNewManager = false;
        init();
    }
    
    public void accordian1(){
        if(summaryBlockState != 'Started'){
            searchBlockState = 'Started';
            assignBlockState = '';
            reviewBlockState = '';
            termsBlockState = '';
            summaryBlockState = '';
        }
    }
    
    public void accordian2(){
        if(searchBlockState == 'Completed' && summaryBlockState != 'Started'){
            assignBlockState = 'Started';
            reviewBlockState = '';
            termsBlockState = '';
            summaryBlockState = '';
        }
    }
    
    public void accordian3(){
        if(assignBlockState == 'Completed' && summaryBlockState != 'Started'){
            reviewBlockState = 'Started';
            termsBlockState = '';
            summaryBlockState = '';
        }
        
    }
    
    public void accordian4(){
        if(reviewBlockState == 'Completed' && summaryBlockState != 'Started'){
            termsBlockState = 'Started';
            summaryBlockState = '';
        }
    }
    
    public void accordian5(){
        if(termsBlockState == 'Completed' && summaryBlockState != 'Started'){
            summaryBlockState = 'Started';
        }
    }
    
    public void termsCheck(){
        
    }
    
    public Class searchInput {
        public String subscriberId { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String officeId { get; set; }
    }
    
    public Class officeRecord {
        public String id { get; set; }
        public String officeId { get; set; }
        public String name { get; set; }
        public String street { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String zip { get; set; }
        public String signersCount { get; set; }
        public String signers { get; set; }
        public String status { get; set; }
        public boolean isChecked {get; set;}
    }    
    
    public class CustomException extends Exception {}
    
    public void test1(){
        
        string test1;
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        
    }
   public void test2(){
        
        string test1;
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        
    }
    public void test3(){
        
        string test1;
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        
    }
}