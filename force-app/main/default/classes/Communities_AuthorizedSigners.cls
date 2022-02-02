public class Communities_AuthorizedSigners {
    
    public String officeId { get; set; } 
    public List<Account> offices { get; set; }
    public String officesStr { get; set; }
    public Account office { get; set; }
    public List<Relationship__c> officeRelationships { get; set; }
    public Relationship__c relationship { get; set; }
    public Boolean isAccountDetail { get; set; }
    public List<officeRecord> officeRecords { get; set; }
    public String subscriptionId { get; set; }
    
    /* Add new signer */
    public Boolean isAddNewSigner { get; set; }
    public searchInput search { get; set; }
    public List<Subscriptions__c> searchResults { get; set; }        
    public String subscriberSelected { get; set; }
    public Subscriptions__c subscriber { get; set; }
    public String selectedOfficesStr { get; set; }
    public String existingOfficesStr { get; set; }
    public List<officeRecord> selectedOffices { get; set; }
    public String errorMessage { get; set; }
    public Boolean hasInitialError { get; set; }
    
    /* Accordion controlling variables */
    public String searchBlockState { get; set; }
    public String assignBlockState { get; set; }
    public String reviewBlockState { get; set; }
    public String termsBlockState { get; set; }
    public String summaryBlockState { get; set; }    
    
    public Communities_AuthorizedSigners() {
        hasInitialError = false;    
        try {
            subscriptionId = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found  ' );   
            
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, 
                                     Relationship_Type__c, 
                                     Broker_Office__c, 
                                     Broker_Office__r.ParentId,
                                     Subscription__r.Name, 
                                     Subscription__r.Contact__r.Name  
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record')
                             AND     (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                             AND     Subscription_ID__c = :subscriptionId];
            
            if(relationships.size() > 0) {               
                List<String> parentIds = new List<String>();
                
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
                                  (SELECT Id, 
                                          Subscription__c, 
                                          Subscription__r.Contact__c,
                                          Subscription__r.Contact__r.FirstName,
                                          Subscription__r.Contact__r.LastName,
                                          Subscription__r.Name,
                                          Subscription__r.Related_Location_Broker_Office__c,
                                          Subscription__r.Related_Location_Broker_Office__r.Name
                                   FROM Relationships__r 
                                   WHERE Relationship_Type__c = 'Authorized Signer' 
                                   AND Status__c = 'Active'
                                   AND (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                                   AND Subscription__c != null)
                           FROM   Account
                           WHERE  (ParentId IN :parentIds OR Id IN :parentIds)
                           AND    Status__c = 'Active'];
                           
                /* Logic to find subscriber signer for */
                List<Id> subscriberIds = new List<Id>();
                for(Account a : offices) {
                    if(a.Relationships__r.Size() > 0) {
                        for(Relationship__c rel : a.Relationships__r) {
                            subscriberIds.add(rel.Subscription__c);
                        }   
                    }
                }
                
                Map<Id, Subscriptions__c> subcriberMap;
                if(subscriberIds.Size() > 0) {
                    subcriberMap = new Map<Id, Subscriptions__c> ([SELECT Id, 
                                                                         Name,
                                                                         (SELECT Id, Broker_Office__c, Broker_Office__r.Name 
                                                                          FROM Relationships__r 
                                                                          WHERE Relationship_Type__c = 'Authorized Signer' 
                                                                          AND Status__c = 'Active'
                                                                          AND (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)),
                                                                         (SELECT Id, License_Type__c
                                                                          FROM Subscription_Licenses__r)                                                                      
                                                                  FROM   Subscriptions__c
                                                                  WHERE  Id IN :subscriberIds]);
                }
                
                /* Framing data for front end display */
                officeRecords = new List<officeRecord>();
                for(Account a : offices) {
                   officeRecord obj = new officeRecord();
                   obj.id = a.Id;
                   obj.officeId = '<a>' + a.Name + '</a>';
                   obj.name = a.Account_Name__c;
                   obj.street = a.Street_Number__c + ' ' + a.Street_Name__c;
                   obj.city = a.City__c;
                   obj.state = a.State__c;
                   obj.zip = a.Zip__c;
                   obj.signersCount = '<a>' + String.valueOf(a.Relationships__r.Size()) + '</a>';
                   if(a.Relationships__r.Size() > 0) {
                       String signers = '<div class="arrow-up"></div><div class="slide-down"><h3>Authorized Signers for ' + a.Name + ':</h3><table class="table">'+
                                            '<thead><tr>' +
                                                '<th>First Name</th>' +
                                                '<th>Last Name</th>' +
                                                '<th>Office ID</th>' +
                                                '<th>Subscriber ID</th>' +
                                                '<th>Signer For</th>' +
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
                                    signers +=  '<td>' + subcriberMap.get(rel.Subscription__c).Subscription_Licenses__r[0].License_Type__c + '</td>';
                                else
                                    signers +=  '<td></td>';    
                            }
                            else {
                                signers +=  '<td>0 Office</td>';
                                signers +=  '<td></td>';                            
                            }
                            signers +=  '<td><a href="/customers/Communities_AuthorizedSigners?id=' + subscriptionId + '&subid=' + rel.Subscription__c + '" class="label label-primary modifySubscriber">Modify</a></td>';
                            signers +=      '</tr>';                                                     
                       }
                       signers += '</tbody></table></div>';
                       obj.signers = signers;
                   }
                   else
                       obj.signers = '';
                       
                   officeRecords.add(obj);
                }
                           
                officesStr = JSON.Serialize(officeRecords);               
            }
            else
                throw new CustomException('We’re sorry, but you do not appear to have access to this page.');  
        }
        catch(Exception e) {
            hasInitialError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }    
        
        isAccountDetail = false;
        isAddNewSigner = false;
        search = new searchInput();
        searchResults = new List<Subscriptions__c>();
        
        if(ApexPages.currentpage().getparameters().get('subid') != null) {
            subscriberSelected = ApexPages.currentpage().getparameters().get('subid');
            individualSelected();
        }         
    }

    public void accountDetails() {
        office = [SELECT  Id, 
                          Name,
                          Account_Name__c,
                          Billing_Street_Number__c,
                          Billing_Street_Name__c,
                          City__c,
                          State__c,
                          Zip__c
                   FROM   Account
                   WHERE  Id = :officeId
                   AND    Status__c = 'Active'];
        
               
        officeRelationships = [SELECT Id, 
                                Name, 
                                Subscription__c,
                                Subscription__r.Name,
                                First_Name__c,
                                Last_Name__c, 
                                Broker_Office__c, 
                                Contact__c, 
                                Status__c
                         FROM   Relationship__c
                         WHERE  Broker_Office__c = :officeId
                         AND    Relationship_Type__c = 'Authorized Signer'
                         AND    Status__c = 'Active'];
        System.debug('*** relationships: ' + officeRelationships);
        isAccountDetail = true;
    }
    
    public void addNewSigner() {
        isAddNewSigner = true;
        searchBlockState = 'Started';
        relationship = new Relationship__c();
    }
    
    public void getSearchResults() {
        System.debug('*** search:' + search);
        String query = 'SELECT Id, Name, Contact__c, Contact__r.FirstName, Contact__r.LastName, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Name FROM Subscriptions__c WHERE Status__c = \'Active\'';
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
        
        subscriber = [SELECT Id, 
                             Name, 
                             Contact__c, 
                             Contact__r.FirstName,
                             Contact__r.LastName,
                             Contact__r.Phone,
                             Contact__r.Email,
                             Related_Location_Broker_Office__c,
                             Related_Location_Broker_Office__r.Name,
                             Related_Location_Broker_Office__r.Account_Name__c,
                             Related_Location_Broker_Office__r.City__c,
                             Related_Location_Broker_Office__r.State__c,
                             Related_Location_Broker_Office__r.Zip__c,
                             Related_Location_Broker_Office__r.Street_Number__c,
                             Related_Location_Broker_Office__r.Street_Name__c,
                             Related_Location_Broker_Office__r.QAS_Mailing_Street_Type__c,
                             (SELECT Id, Broker_Office__c, Relationship_End_Date__c, Status__c 
                              FROM Relationships__r 
                              WHERE Relationship_Type__c = 'Authorized Signer'
                              AND     (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                              AND Status__c = 'Active')
                      FROM Subscriptions__c
                      WHERE Id = :subscriberSelected];
                      
        existingOfficesStr = '';
        if(subscriber.Relationships__r.Size() > 0) {
            for(Relationship__c rel : subscriber.Relationships__r) {
                existingOfficesStr += rel.Broker_Office__c + ',';
            }
        }      
        isAddNewSigner = true;
        assignBlockState = 'Started';
        searchBlockState = 'Completed';
    }
    
    public void assignAuthority() {
        System.debug('***' + selectedOfficesStr);
        selectedOffices = new List<officeRecord>();
        Set<String> selectedList = (Set<String>) JSON.Deserialize(selectedOfficesStr, Set<String>.class);
        Set<String> added = new Set<String>();
        Set<String> removed = new Set<String>();
        List<String> existingList = existingOfficesStr.split(',');
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
                selectedOffices.add(record);
            }
            else if(added.contains(record.id) && !(existing.contains(record.id))) {
                record.status = 'New';
                selectedOffices.add(record);            
            }
            else if(existing.contains(record.id) && !(added.contains(record.id)) && !(removed.contains(record.id))){
                record.status = 'Existing';
                selectedOffices.add(record);            
            }
        }
                
        isAddNewSigner = true;
        reviewBlockState = 'Started';
        assignBlockState = 'Completed';
    }
    
    public void reviewChanges() {
        isAddNewSigner = true;
        termsBlockState = 'Started';
        reviewBlockState = 'Completed';       
    }
    

    public void saveSigners() {
        errorMessage = '';
        try {
            
            List<RecordType> individualtoOffice = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Relationship__c' AND DeveloperName = 'Individual_to_Office'];
            
            isAddNewSigner = true;
            summaryBlockState = 'Started';
            termsBlockState = 'Completed';
            
            List<Relationship__c> newRelationships = new List<Relationship__c>();
            List<Relationship__c> endDateRelationships = new List<Relationship__c>();
            for(officeRecord record : selectedoffices) {
                if(record.status == 'New') {
                    Relationship__c rel = new Relationship__c();
                    rel.Broker_Office__c = record.id;
                    rel.Related_Account__c = record.id;
                    rel.Contact__c = subscriber.Contact__c;
                    rel.Subscription__c = subscriber.Id;
                    rel.Relationship_Type__c= 'Authorized Signer';
                    rel.Status__c = 'Active';
                    rel.RecordTypeId = individualtoOffice[0].id;
                    
                    //insert rel;
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
            
            if(endDateRelationships.size() > 0)
                update endDateRelationships;            
            
            if(newRelationships.size() > 0) {
                newRelationships[0].Created_Source__c = 'Connect';
                insert newRelationships;
            }
                

        }
        catch(Exception e) {
            errorMessage = 'ERROR: ' + e.getMessage();
        }
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
    }    

    public class CustomException extends Exception {}
}