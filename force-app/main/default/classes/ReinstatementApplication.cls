public class ReinstatementApplication {

    public String subscriptionId { get; set; }
    public Subscriptions__c subscription { get; set; }
    public License__c license { get; set; }
    public String brokerCode { get; set; }
    public Boolean isEdit { get; set; }
    public MRIS_Application__c newApplication { get; set; }
    public list<SelectOption> options {get; set;} 
    public String association { get; set; }
    public String associationName { get; set; }
    public Related_Association__c ra { get; set; }
    public Boolean showSubmitButton { get; set; }
    
    public Boolean viewAppButton{get; set;} 
    
    public ReinstatementApplication(){
        subscriptionId = ApexPages.currentPage().getParameters().get('Id');
        showSubmitButton = true;
        viewAppButton = false;
        verifySubscription();
        isEdit = false;
        newApplication = new MRIS_Application__c();
        ra = new Related_Association__c();        
    }
    
    /*
    public void verifyLicense(){
        try { 
            List<License__c> licenses = new List<License__c>();
            if(String.isNotBlank(license.Name) && String.isNotBlank(license.License_State__c) && String.isNotBlank(license.License_Type__c)) {         
                
                licenses = [SELECT Id, Name, License_Expiration_Date__c, License_State__c, License_Type__c
                            FROM License__c
                            WHERE  Name = :license.Name
                            AND    License_State__c = :license.License_State__c
                            AND    License_Type__c = :license.License_Type__c];
                            
                if(licenses.size() > 0){
                
                }
                else
                    throw New CustomException('No license found');
            }
            else
                throw new CustomException('Enter all license details');
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    */
    
    
    List<MRIS_Application__c> licenses { get; set; }
    public void verifySubscription(){
        try{
            licenses = new list<MRIS_Application__c>();
            if(String.isNotBlank(subscriptionId)){
                
                List<Subscriptions__c> subs = new List<Subscriptions__c>();
                subs = [SELECT Id, 
                        Name,
                        NRDS_ID__c,
                        Contact__c,
                        Contact_Type__c,
                        Subscription_Type__c,
                        Status__c,
                        Status_Change_Reason__c,
                        City__c,
                        State__c,
                        QAS_Mailing_County__c,
                        Zip__c,
                        Private_Email__c,
                        Primary_Phone__c,
                        Billing_Jurisdiction__c,
                        Mobile_Phone__c, Contact__r.Name, Contact__r.LastName,Contact__r.Email, Contact__r.FirstName,
                        Contact__r.City__c, Contact__r.Country__c, Contact__r.County__c, Contact__r.Zip__c, Contact__r.Suffix__c,
                        Contact__r.Middle_Name__c, Contact__r.Phone, Contact__r.Nickname__c,Date_Terminated__c,
                        Contact__r.Salutation, Contact__r.State__c, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Name, Service_Jurisdiction__c ,Related_Location_Broker_Office__r.Status__c
                        FROM   Subscriptions__c
                        WHERE  Name = :subscriptionId 
                       ];
                system.debug('------675765'+subs);
                       
                if(subs.size() > 0) {                    
                    subscription = new Subscriptions__c();
                    subscription = subs[0];
                    
                    if(subscription.Status__c == 'Active'){
                        showSubmitButton = false; 
                        throw new CustomException('Subscription is already active');
                    }
                    
                    if(subscription.Status__c == 'Inactive') {
                        
                        licenses = [SELECT Id, Name 
                                    FROM   MRIS_Application__c
                                    WHERE  Agent_Subscription_ID__c = :subscription.Id
                                    AND    Application_Type__c = 'Reinstatement' 
                                    AND    Status__c IN ('New','Approved')];
                    
                    }
                    else if(subscription.Status__c == 'In Progress') {
                        licenses = [SELECT Id, Name 
                                    FROM   MRIS_Application__c
                                    WHERE  Agent_Subscription_ID__c = :subscription.Id
                                    AND    Application_Type__c = 'New Agent' 
                                    AND    Status__c IN ('New','Approved')];
                                             
                    }
                    
                    system.debug('-----licenses out if---->'+licenses);
                    if(licenses.size() > 0 ){
                        system.debug('-----licenses inside if---->'+licenses);
                        viewAppButton = true;
                        showSubmitButton = false;
                        //throw new CustomException('Application is already exist');    
                    }
                    else
                        assignSubscriptionValues();        
                        
                    List<Subscription_License__c> subLicenses = [SELECT Id, Name, License__c, License__r.Name, License__r.License_State__c, License__r.License_Type__c, License__r.License_Expiration_Date__c FROM Subscription_License__c WHERE Subscription__c = :subscription.Id];
                    if(subLicenses.Size() > 0) {
                        license = new License__c();
                        license.Id = subLicenses[0].License__c;
                        license.Name = subLicenses[0].License__r.Name;
                        license.License_State__c = subLicenses[0].License__r.License_State__c;
                        license.License_Type__c = subLicenses[0].License__r.License_Type__c;
                        license.License_Expiration_Date__c = subLicenses[0].License__r.License_Expiration_Date__c;
                    }
                    else
                        throw new CustomException('No license associated with this Subscription. Please contact Customer Support for more details.');
                }
                else
                    throw new CustomException('No subscription found');
            }
        }
        catch(Exception e){
            showSubmitButton = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    
    public void assignSubscriptionValues() {
        newApplication = new MRIS_Application__c();
        newApplication.First_Name__c = subscription.Contact__r.FirstName;
        newApplication.Last_Name__c = subscription.Contact__r.LastName;
        newApplication.Salutation__c = subscription.Contact__r.Salutation;
        newApplication.Middle_Name__c = subscription.Contact__r.Middle_Name__c;
        newApplication.Nickname__c = subscription.Contact__r.Nickname__c;
        newApplication.Primary_Phone__c = subscription.Primary_Phone__c;
        newApplication.Private_Email__c = subscription.Private_Email__c;
        newApplication.NRDS_ID__c = subscription.NRDS_ID__c;
        newApplication.Suffix__c = subscription.Contact__r.Suffix__c;
         
        List<Related_Association__c> relAssociations = [SELECT Id, Association__c, Association__r.Name,Association_Name__c, Subscription__c, Status__c FROM Related_Association__c WHERE Subscription__c = :subscription.Id AND Primary__c = true AND Status__c = 'Active'];
        if(relAssociations.Size() > 0) {
            ra = relAssociations[0];
            association = ra.Association__c;
            associationName = ra.Association_Name__c;
        }                         
    }
    
    public PageReference submitApplication(){
        try{  
            system.debug('-----licenses out if---->'+licenses);
            
            if(licenses != null && licenses.size() > 0){
                system.debug('-----new app status---->'+licenses);
                PageReference pageRef = new PageReference('/apex/NewApplicationStatus?Id=' + licenses[0].Id);
                return pageRef;
            }            
            else{
                system.debug('----else block----');
            if(!isEdit)
                assignSubscriptionValues();
                      
            newApplication.Subscription_Type__c = subscription.Subscription_Type__c;
            newApplication.Type__c = subscription.Contact_Type__c; 
            newApplication.Agent_Subscription_ID__c = subscription.Id;                   
            
            newApplication.City__c = subscription.City__c;
            newApplication.Country__c = subscription.contact__r.Country__c;
            newApplication.County__c = subscription.QAS_Mailing_County__c;
            
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
            newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
            newApplication.License_Number__c = license.Name;
            newApplication.License_Expiration_Date__c = license.License_Expiration_Date__c;
            newApplication.License_State__c = license.License_State__c;
            newApplication.License_Type__c = license.License_Type__c;
           // newApplication.First_Name__c = subscription.contact__r.FirstName;
          //  newApplication.Last_Name__c = subscription.contact__r.LastName;
          //  newApplication.Middle_Name__c = subscription.contact__r.Middle_Name__c;
           newApplication.Mobile_Phone__c = subscription.contact__r.Phone;
            newApplication.Nickname__c = subscription.contact__r.Nickname__c;
            system.debug('*** brokerCode:' + brokerCode);
            
            if(String.isNotBlank(brokerCode)) {
                List<Account> selectedAccount = new List<Account>();
                if(subscription.Service_Jurisdiction__c != null && (subscription.Service_Jurisdiction__c == 'TREND' || subscription.Service_Jurisdiction__c == 'BRIGHT')) {
                selectedAccount = [SELECT Id 
                                       FROM   Account 
                                       WHERE  Status__c = 'Active'
                                       AND    (Primary_Service_Jurisdiction__c = 'TREND' OR Primary_Service_Jurisdiction__c = 'BRIGHT')
                                       AND    (Id = :brokerCode OR Name = :brokerCode OR Account_Name__c = :brokerCode)];
                }
                else {
                    selectedAccount = [SELECT Id 
                                       FROM Account 
                                       WHERE Status__c = 'Active'
                                       AND (Primary_Service_Jurisdiction__c = 'MRIS' OR Primary_Service_Jurisdiction__c = null) 
                                       AND (Id = :brokerCode OR Name = :brokerCode OR Account_Name__c = :brokerCode)];                
                }
                
                if(!(selectedAccount.Size() > 0)) {
                    subscription.Related_Location_Broker_Office__r.Name = brokerCode;
                    throw new CustomException('Related Location Broker office is inactive or not found');
                }    
                newApplication.Company_Code__c = selectedAccount[0].Id;
            }
            else {
                if(subscription.Related_Location_Broker_Office__r.Status__c != 'Active')
                    throw new CustomException('Related Location Broker office is Inactive');
                    
                newApplication.Company_Code__c = subscription.Related_Location_Broker_Office__c;
            }
                // newApplication.Primary_Phone__c = subscription.Primary_Phone__c;
                // newApplication.Private_Email__c = subscription.Private_Email__c;               
                 newApplication.Public_Email__c = subscription.contact__r.Email;
                // newApplication.Salutation__c = subscription.contact__r.Salutation;
                newApplication.Private_Phone__c = subscription.contact__r.Phone;
                newApplication.State__c = subscription.State__c;
                newApplication.Status__c = 'New';
                
            if(String.isNotBlank(subscription.Billing_Jurisdiction__c))
                newApplication.Billing_Jurisdiction__c = subscription.Billing_Jurisdiction__c;
            else
               newApplication.Billing_Jurisdiction__c = 'MRIS';
            
            if(String.isNotBlank(subscription.Service_Jurisdiction__c))
                newApplication.Service_Jurisdiction__c = subscription.Service_Jurisdiction__c;
            else 
                newApplication.Service_Jurisdiction__c = 'MRIS';             
            
            newApplication.Association_Board_Affiliation__c = association;
            newApplication.Zip__c = subscription.Zip__c;
            newApplication.Application_Type__c = 'Reinstatement';
            
            String asContact, borContact, agentContact;// cannot send to agent as he is not an user yet
            
            List<Relationship__c> listRelationship = [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, Subscription__r.Private_Email__c ,Broker_Office__r.status__c
                                                FROM   Relationship__c 
                                                WHERE  Broker_Office__c = :subscription.Related_Location_Broker_Office__c
                                                AND    Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                                AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                               ]; 
                
            for(Relationship__c relationship : listRelationship){
                
                //if(relationship.Broker_Office__r.status__c == 'Inactive'){
                //   throw new CustomException('Related Location Broker office is Inactive');
                //}
                if(relationship.Relationship_Type__c == 'Authorized Signer'){
                    asContact = relationship.Subscription__r.Contact__c;
                    //newApplication.AS_Email__c = relationship.Subscription__r.Private_Email__c;
                }
                else if(relationship.Relationship_Type__c == 'Broker Of Record'){
                    borContact = relationship.Subscription__r.Contact__c;
                    //newApplication.BOR_Email__c = relationship.Subscription__r.Private_Email__c;
                }                  
            }
           
            insert newApplication;
            
            PageReference pageRef = new PageReference('/apex/NewApplicationStatus?Type=New&Id=' + newApplication.Id);
            return pageRef;
            
            }
            
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;    
        } 
    }
    
    public void enableEditing() {
        isEdit = true;
        findAllAssociations();
        assignSubscriptionValues();
    }
    
    public void findAllAssociations() {
        options = new list<SelectOption>();
        if(subscription.Service_Jurisdiction__c == null)
            subscription.Service_Jurisdiction__c = 'MRIS';
        List<Account> associationAccounts = [SELECT Id, Name, Account_Name__c
                                             FROM   Account 
                                             WHERE  Type = 'Association' 
                                             AND    Status__c = 'Active' 
                                            // AND    (Primary_Service_Jurisdiction__c = :subscription.Service_Jurisdiction__c OR Secondary_Service_Jurisdiction__c = :subscription.Service_Jurisdiction__c)
                                             ORDER BY Account_Name__c ASC];
        options.add(new SelectOption('', '-- Choose --'));
        for(Account a : associationAccounts)
            options.add(new SelectOption(a.Id, a.Account_Name__c));
 
    }     
    
    public String searchTerm {get; set;}
    
    @RemoteAction
    public static List<Account> searchBroker(String searchTerm, String mlsName) {
        List<Account> accounts = new List<Account>();
        if(mlsName == 'TREND')
            accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'TREND\' OR Secondary_Service_Jurisdiction__c = \'TREND\') AND IsPersonAccount = false');
        else if(mlsName == 'BRIGHT')
            accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'BRIGHT\' OR Secondary_Service_Jurisdiction__c = \'BRIGHT\') AND IsPersonAccount = false');                       
        else
            accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'MRIS\' OR Primary_Service_Jurisdiction__c = NULL OR Secondary_Service_Jurisdiction__c = \'MRIS\') AND IsPersonAccount = false');
        
        return accounts;
    }        
    
    public class CustomException extends Exception{}

}