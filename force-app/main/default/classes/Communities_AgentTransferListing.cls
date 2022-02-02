/*
LastModifiedBy : BLT India Team
*/

public without sharing class Communities_AgentTransferListing {

    public List<MRIS_Application__c> applications { get; set; }
    public Map<String,String> officeIds { get; set; }
    public String applicationId { get; set; }
    public MRIS_Application__c application { get; set; }
    public Boolean isViewApplication { get; set; }
    public string appId {get; set;}
    public string agentName {get; set;}
    public string originationOffice {get; set;}
    public string destinationOffice {get; set;}
    public string status {get; set;}
    public boolean searchResultsReturned {get; set;}    // depending on this, we display results or error message
    
    
    public list<selectOption> getapplicationStatuses() {       
        Schema.DescribeFieldResult desField = MRIS_Application__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> schemaPicklist = desField.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        for(Schema.PicklistEntry pickvalue : schemaPicklist){
            options.add(new SelectOption(pickvalue.getValue(), pickvalue.getValue()));
        }
        return options;
    }

    public Communities_AgentTransferListing() {
        try {

            /* List<User> currentUser = [SELECT   FederationIdentifier 
                                        FROM     User 
                                        WHERE    Id = :Userinfo.getUserId()
                                        ];
            if (currentUser.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 
            String subscriptionId = currentUser[0].FederationIdentifier;
            */

            searchResultsReturned = false;
            String subscriptionId = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found ');   

            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,
                             Subscription__r.Name, Subscription__r.Contact__r.Name, Broker_Office__r.Name
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription_ID__c = :subscriptionId
                            ];

            List<String> parentIds = new List<String>();
            Map<String,String> asOffices = new Map<String,String>();
            Boolean isBOR = false;

            for(Relationship__c relationship : relationships){
                system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
                system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
                
                if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                    parentIds.add(relationship.Broker_Office__r.ParentId);            
                
                if(String.IsNotBlank(relationship.Broker_Office__c))
                    parentIds.add(relationship.Broker_Office__c);
                
                if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                    isBOR = true;
                } 
                else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                    asOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                }
            } 
            if(!isBOR){
                if(asOffices.size() > 0){
                    officeIds = new Map<String,String>(asOffices);
                }                
            }
            else{
                List<Account> relatedAccounts = new List<Account>(); 
                relatedAccounts = [SELECT Id, Name
                                   FROM   Account
                                   WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' 
                                  ];

                officeIds = new Map<String,String>();
                
                for(Account a : relatedAccounts)
                    officeIds.put(a.Id, a.Name);
            }

            getApplications();
            isViewApplication = false;                                   
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }  
    }

    public void getApplications(){
        applications = [SELECT Id, 
                        Name, 
                        Status__c,
                        Agent_Subscription_ID__c,
                        Agent_Subscription_ID__r.Contact__r.FirstName,
                        Agent_Subscription_ID__r.Contact__r.LastName,  
                        Destination_Broker_Office__c, 
                        Destination_Broker_Office__r.Name,
                        Destination_Broker_Office__r.Account_Name__c,
                        Destination_Broker_Office__r.Street_Number__c,
                        Destination_Broker_Office__r.Street_Name__c,
                        Destination_Broker_Office__r.City__c,
                        Destination_Broker_Office__r.State__c,
                        Destination_Broker_Office__r.Zip__c,
                        Company_Code__c, 
                        Company_Code__r.Name,
                        Company_Code__r.Account_Name__c,
                        Company_Code__r.Street_Number__c,
                        Company_Code__r.Street_Name__c,
                        Company_Code__r.City__c,
                        Company_Code__r.State__c,
                        Company_Code__r.Zip__c,
                        CreatedDate,
                        Approved_Rejected_Status_Message__c
                        FROM   MRIS_Application__c 
                        WHERE  Application_Type__c = 'Agent Transfer' AND Destination_Broker_Office__c IN :officeIds.keyset() order by createdDate desc LIMIT 500 ];
    }

    public void viewApplication(){
        application = [SELECT  Id,                               
                       Name, 
                       Status__c,
                       Agent_Subscription_ID__c,
                       Agent_Subscription_ID__r.Contact__r.FirstName,
                       Agent_Subscription_ID__r.Contact__r.LastName, 
                       Destination_Broker_Office__c, 
                       Destination_Broker_Office__r.Name,
                       Destination_Broker_Office__r.Account_Name__c,
                       Destination_Broker_Office__r.Street_Number__c,
                       Destination_Broker_Office__r.Street_Name__c,
                       Destination_Broker_Office__r.City__c,
                       Destination_Broker_Office__r.State__c,
                       Destination_Broker_Office__r.Zip__c,
                       Company_Code__c, 
                       Company_Code__r.Name,
                       Company_Code__r.Account_Name__c,
                       Company_Code__r.Street_Number__c,
                       Company_Code__r.Street_Name__c,
                       Company_Code__r.City__c,
                       Company_Code__r.State__c,
                       Company_Code__r.Zip__c,
                       CreatedDate,
                       Approved_Rejected_Status_Message__c
                       FROM   MRIS_Application__c 
                       WHERE  Id = :applicationId
                      ];
        isViewApplication = true;
    }

    public void approve() { 
        try {
            System.debug('***' + application); 
            application.Approved_Rejected_Status_Message__c = 'Approved by ' + userInfo.getName() + ' on ' + DateTime.Now().format('MM/dd/yyyy HH:mm:ss');      
            application.Status__c = 'Approved';
            update application;
            
            Subscriptions__c sub = new Subscriptions__c();
            sub.Id = application.Agent_Subscription_ID__c;
            sub.Related_Location_Broker_Office__c = application.Destination_Broker_Office__c;
            update sub;
            
            application.Status__c = 'Completed';
            update application;
            
            isViewApplication = false;  
            getApplications();
        }
        catch(Exception e) {
            application.Comments__c = 'Error while approving :';
            update application;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString())); 
        } 
    } 

    public void reject() {
        application.Status__c = 'Reject';
        application.Approved_Rejected_Status_Message__c = 'Rejected by ' + userInfo.getName() + ' on ' + DateTime.Now().format('MM/dd/yyyy HH:mm:ss');
        update application;
        
        isViewApplication = false;
        getApplications();
    }
    
    
    /*search button functionality */
    public void searchApplications(){

        system.debug('---appId-->'+appId+'--agentName-->'+agentName+'--originationOffice--->'+originationOffice+'---destinationOffice-->'+destinationOffice+'--status--->'+status);
        searchResultsReturned = true;
        boolean emptySearchFilters = true;              // used to check whether search value is entered, if no search value is entered, all applications will be queried.   
        set<string> officeIdsSet = officeIds.keyset();

        string query = 'SELECT Id, Name, Status__c, Agent_Subscription_ID__c, Agent_Subscription_ID__r.Contact__r.FirstName, Agent_Subscription_ID__r.Contact__r.LastName, ';
                query += 'Destination_Broker_Office__c, Destination_Broker_Office__r.Name, Destination_Broker_Office__r.Account_Name__c, Destination_Broker_Office__r.Street_Number__c, ';
                query += 'Destination_Broker_Office__r.Street_Name__c, Destination_Broker_Office__r.City__c, Destination_Broker_Office__r.State__c, Destination_Broker_Office__r.Zip__c, ';
                query += 'Company_Code__c, Company_Code__r.Name, Company_Code__r.Account_Name__c, Company_Code__r.Street_Number__c, Company_Code__r.Street_Name__c, Company_Code__r.City__c, ';
                query += 'Company_Code__r.State__c, Company_Code__r.Zip__c, CreatedDate, Approved_Rejected_Status_Message__c FROM MRIS_Application__c ';
                query += 'WHERE Application_Type__c = \'Agent Transfer\' AND Destination_Broker_Office__c IN : officeIdsSet';

        if(appId != null && appId != '' && appId.trim() != ''){
            system.debug('---appId-->'+appId+'<---');
            query += ' And Name like \'%'+ appId + '%\'';
            emptySearchFilters = false;
        }
        if(agentName != null && agentName != '' && agentName.trim() != ''){
            system.debug('---agentName-->'+agentName+'<---');
            query += ' And ( Agent_Subscription_ID__r.Contact__r.FirstName like \'%'+ agentName + '%\' OR Agent_Subscription_ID__r.Contact__r.LastName like \'%'+ agentName +'%\')';
            emptySearchFilters = false;
        }
        if(originationOffice != null && originationOffice != '' && originationOffice.trim() != ''){
            system.debug('---originationOffice-->'+originationOffice+'<---');
            query += ' And Company_Code__r.Name like \'%'+ originationOffice +'%\'';
            emptySearchFilters = false;
        }
        if(destinationOffice != null && destinationOffice != '' && destinationOffice.trim() != ''){
            system.debug('---destinationOffice-->'+destinationOffice+'<---');
            query += ' And Destination_Broker_Office__r.Name like \'%'+destinationOffice+'%\'';
            emptySearchFilters = false;
        }
        if(status != null && status != '' && status.trim() != ''){
            system.debug('---status-->'+status+'<---');
            query += ' And Status__c like \'%'+ status +'%\'';
            emptySearchFilters = false;
        }

        query += ' order by createdDate desc LIMIT 500';
        system.debug('---query--->'+query);

        if( emptySearchFilters == false )
            applications = database.query(query);
        else
            getApplications();

        system.debug('---applications-->'+applications);
        system.debug('----searchResultsReturned--->'+searchResultsReturned);
        isViewApplication = false;
    }
    public class CustomException extends Exception {}    
}