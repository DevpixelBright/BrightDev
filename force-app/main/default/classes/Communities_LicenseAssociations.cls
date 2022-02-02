public class Communities_LicenseAssociations {
    
    public String subscriptionId { get; set; }
    public List<License__c> licenses { get; set; }
    public License__c primaryLicense { get; set; }
    public License__c newLicense { get; set; }
    public License__c removedLicense { get; set; }
    public Subscriptions__c subscription { get; set; }
    public String licenseSelected { get; set; }
    public String licenseSelectedForDelete { get; set; }
    public String associationSelected { get; set; }
    public String errorMessage {get;set;}
    public List<Subscription_License__c> subLicenses { get; set; }
    public List<String> states{get; set; }
    public License_Association_MLS__c MLSObj { get; set; }
    public Case oCase { get; set; }
    public String state { get; set; }
    public String MLS {get; set;}
    
    
    public List<Related_Association__c> associations { get; set; }
    public Related_Association__c newAssociation { get; set; }
    public Related_Association__c primaryAssociation { get; set; }
    
    public Boolean isEditAssociation { get; set; }
    //public Boolean isAddAssociation { get; set; }
    //public Boolean isSaveAssociation { get; set; }
    
    public Boolean isEditLicense { get; set; }
    public Boolean isDeleteLicense { get; set; }
    public Boolean isSuccessMessage { get; set; }
    public Boolean isErrorMessage { get; set; }
    
    public Boolean message { get; set; }
    public Boolean licenseMessage { get; set; }
    public Boolean associationMessage { get; set; }
    public Boolean designationMessage { get; set; }
    
    public list<SelectOption> options {get; set;}
    public String displayName { get; set; } 
    
    public String oldLicenseName { get; set; }
    public String oldLicenseState { get; set; }
    public String oldLicenseType { get; set; }
    public String oldAssociationID { get; set; }
    
    public list<SelectOption> stateOptions {get; set;}
    public list<SelectOption> leftstateMLSOptions {get; set;}
    public list<String> leftselectedMLSOptions {get; set;}
    public list<SelectOption> rightstateMLSOptions {get; set;}
    public list<String> rightselectedMLSOptions {get; set;}
    
    public integer picklistlength {get; set;}
    public String selectedState { get; set; }
    public Boolean termsDisabled {get;set;}
    
    public void loadStateOptions(){
        system.debug('*** selectedState: ' + selectedState);
        List<License_Association_MLS__c> MLSList = new List<License_Association_MLS__c >();
        MLSList = [SELECT 	Id,
                   Name,
                   MLS__c,
                   State__c
                   FROM License_Association_MLS__c
                   WHERE State__c = :selectedState];
        List<String> mlsNames = new List<String>();
        leftstateMLSOptions = new list<SelectOption>();
        Set<String> rightOptions = new Set<String>();
        system.debug('addition----'+subscription.Contact__r.AdditionalMLS__c);
        
        if(rightstateMLSOptions != null && rightstateMLSOptions.size() > 0){
            for(SelectOption so: rightstateMLSOptions) {
                rightOptions.add(so.getValue());
            }
        }
        
        
        for(License_Association_MLS__c m : MLSList){
            if(!rightOptions.contains(m.MLS__c))
                leftstateMLSOptions.add(new SelectOption(m.MLS__c, m.MLS__c));
        }  
        termsDisabled = false;
    }
    
    
    public void selectOptionClick(){
        termsDisabled = false;
        if(leftselectedMLSOptions.size() > 0){
            for(String BJ : leftselectedMLSOptions){
                system.debug('--BJ--'+BJ);
                rightstateMLSOptions.add(new SelectOption(BJ, BJ));
                Integer i = leftstateMLSOptions.indexOf(new SelectOption(BJ, BJ));
                if(i != -1)
                    leftstateMLSOptions.remove(i);      
            }
        }
        rightstateMLSOptions.sort();
        leftstateMLSOptions.sort();
        leftselectedMLSOptions = new List<String>();
        rightselectedMLSOptions = new List<String>();
    }
    
    public void unselectOptionClick(){
        termsDisabled = false;
        System.debug('***termsDisabled'+termsDisabled);
        if(rightselectedMLSOptions.size() > 0){
            for(String BJ : rightselectedMLSOptions){
                system.debug('--BJ--'+BJ);
                leftstateMLSOptions.add(new SelectOption(BJ, BJ));                
                Integer i = rightstateMLSOptions.indexOf(new SelectOption(BJ, BJ));
                if(i != -1)
                    rightstateMLSOptions.remove(i);      
            }
        }
        rightstateMLSOptions.sort();
        leftstateMLSOptions.sort();
        leftselectedMLSOptions = new List<String>();
        rightselectedMLSOptions = new List<String>();
    }
    
    
    public Communities_LicenseAssociations(){
        try {
            termsDisabled = true;
            List<License_Association_MLS__c> MLSList = new List<License_Association_MLS__c >();
            MLSList = [SELECT
                       Name,
                       MLS__c,
                       State__c
                       FROM License_Association_MLS__c];
            List<String> mlsNames = new List<String>();
            for(License_Association_MLS__c m : MLSList){
                mlsNames.add(m.MLS__c);
            }
            Set<String> states = new Set<String>();
            stateOptions = new List<SelectOption>(); 
            for(License_Association_MLS__c m :MLSList){
                selectedState = m.State__c;
                states.add(m.State__c);
            }
            for(string stateOpt :states){
                stateOptions.add(new SelectOption(stateOpt, stateOpt));
            }
            
            resetMessageFalgs();  
            
            subscriptionId =  Apexpages.currentpage().getparameters().get('sid');
            system.debug('subscriptionId*****'+subscriptionId);
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID');            
            
            associations = new List<Related_Association__c>();
            newAssociation = new Related_Association__c();                                                          
            primaryAssociation = new Related_Association__c();
            
            licenses = new List<License__c>();
            primaryLicense = new License__c();
            newLicense = new License__c();
            
            subscriptions();
            licenses();
            associations();
            findAllAssociations();
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }  
    }
    
    public void resetMessageFalgs() {
        isEditLicense = false;
        isEditAssociation = false; 
        licenseMessage = false;
        associationMessage = false;
        designationMessage = false;
        message = false;   
    }
    
    public void subscriptions() {       
        List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
        subscriptions = [SELECT Id,
                         Name, 
                         Contact__r.Name, 
                         Contact__r.Professional_Designations__c, 
                         Date_Terminated__c, 
                         Status_Change_Reason__c, 
                         Subscription_Type__c, 
                         Contact_Type__c, 
                         Contact__c,
                         Status__c, 
                         License__r.Name, 
                         License__r.License_State__c, 
                         License__r.License_Expiration_Date__c,
                         Primary_Subscription_Association__r.Association_Name__c,
                         Related_Location_Broker_Office__r.Name,
                         Contact__r.PrimaryMLS__c,Contact__r.MLS_State__c,
                         Contact__r.MLS_State_Options__c,
                         Contact__r.AdditionalMLS__c,
                         Service_Jurisdiction__c,
                         Billing_Jurisdiction__c,
                         TREND_Login_Name__c,
                         BRIGHT_LoginName__c
                         FROM   Subscriptions__c
                         WHERE  Name = :subscriptionId];
        
        if (subscriptions.size() == 0)
            throw new CustomException('Invalid MRIS Subscription ID');         
        
        subscription = subscriptions[0];
        if(subscription.Service_Jurisdiction__c != null && subscription.Service_Jurisdiction__c == 'TREND' && subscription.TREND_Login_Name__c != null)
            displayName = 'TREND: ' + subscription.TREND_Login_Name__c + ' - ' + subscription.Name;
        else if(subscription.Service_Jurisdiction__c != null && subscription.Service_Jurisdiction__c == 'BRIGHT' && subscription.BRIGHT_LoginName__c != null)
            displayName = 'BRIGHT: ' + subscription.BRIGHT_LoginName__c + ' - ' + subscription.Name;
        else
            displayName = subscription.Name;
        
        List <String> mlss = new List<String>();
        if(String.isNotBlank(subscription.Contact__r.MLS_State__c))
            mlss = subscription.Contact__r.MLS_State__c.split(';');
        
        rightstateMLSOptions = new List<SelectOption>(); 
        for(String mls : mlss){
            rightstateMLSOptions.add(new SelectOption(mls, mls)); 
        }
        
        //Map<String, License_Association_MLS__c> mcs = License_Association_MLS__c.getAll();
        //List<License_Association_MLS__c> cusList = License_Association_MLS__c.getAll().values();
        list<string> rightOptions = new list<string>();
        if(!string.isBlank(subscription.Contact__r.AdditionalMLS__c))
            for(string mlsOpt : subscription.Contact__r.AdditionalMLS__c.split(';'))
        {
            rightstateMLSOptions.add(new SelectOption(mlsOpt,mlsOpt));
            rightOptions.add(mlsOpt);
        }
        leftstateMLSOptions = new list<SelectOption>();
        for(License_Association_MLS__c m : [SELECT MLS__c, State__c FROM License_Association_MLS__c WHERE State__c = :selectedState]){
            if(selectedState == m.State__c && !rightOptions.contains(m.MLS__c))
                leftstateMLSOptions.add(new SelectOption(m.MLS__c, m.MLS__c));
        } 
        
    }
    
    public void licenses() {
        licenses = new List<License__c>();
        List<Subscription_License__c> subLicenses = [SELECT Id, License__c FROM Subscription_License__c WHERE Subscription__c = :subscription.Id AND SoftDelete__c != 'Yes'];
        if(subLicenses.Size() > 0) {
            List<String> licenseIds = new List<String>();
            for(Subscription_License__c subLicense : subLicenses) 
                licenseIds.add(subLicense.License__c);    
            
            licenses = [SELECT Id, Contact__c, License_Expiration_Date__c, License_State__c, Name, License_Type__c
                        FROM License__c WHERE Id = :licenseIds];
        }    
    }
    
    public void associations() {
        associations = [SELECT Id,Name, Association_Name__c, Association__r.Name, Subscription__c, Start_Date__c, End_Date__c, Status__c, Primary__c FROM Related_Association__c 
                        WHERE Subscription__c = :subscription.Id];
        System.debug('*** associations:' + associations );    
    }    
    
    public void addLicense(){
        isEditLicense = true;
        isEditAssociation = false;
        newLicense = new License__c();
        if(String.isBlank(licenseSelected)) 
            newLicense = new License__c();
        else {
            for(License__c license : licenses) {
                if(license.Id == licenseSelected){
                    newLicense = license;
                    oldLicenseName = license.Name;
                    oldLicenseState = license.License_State__c;
                    oldLicenseType = license.License_Type__c;
                }
            }
        } 
    }
    
    public void removeLicense() {
        isDeleteLicense = true;
    }
    
    public void removeOnConfirm(){
        try{
            isDeleteLicense = false;
            List<License__c> lLicense = new List<License__c>();
            List<Subscription_License__c> lsubLicense = new List<Subscription_License__c>();
            List<Subscription_License__c> subLicenses = [SELECT Id, License__c,SoftDelete__c,Subscription__c,License_Type__c,License_Expiration_Date__c,License_State__c,License_Name__c  FROM Subscription_License__c WHERE License__c = :licenseSelectedForDelete];
            for(Subscription_License__c sublicense : subLicenses) {
                sublicense.SoftDelete__c = 'Yes';
                lsubLicense.add(sublicense);
            }
            License__c olicense = new License__c();
            olicense.Id = licenseSelectedForDelete;
            olicense.SoftDeleted__c = 'Yes';
            lLicense.add(olicense);
            if(!lLicense.isEmpty()) 
                update lLicense;
            if(!lsubLicense.isEmpty()) 
                update lsubLicense;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'License Removed', 'This license you selected is now removed from the system.'));
            isSuccessMessage = true;
            licenses();
        }catch(exception ex){
            isErrorMessage = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + 'An error has occurred and the license has not been removed. A support case has been created. We will contact you as soon as its resolved.'));
            errorMessage = ex.getMessage();
            List<Subscription_License__c> subLicenses = [SELECT Id, License__c,SoftDelete__c,Subscription__c,License_Type__c,License_Expiration_Date__c,License_State__c,License_Name__c  FROM Subscription_License__c WHERE License__c = :licenseSelectedForDelete];
            List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Processing'];
            Case oCase = new Case();
            oCase.OwnerId = queueIds[0].Id;
            Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Center Case').getRecordTypeId();
            oCase.recordTypeId = recordTypeId;
            oCase.Subscription_ID__c = subscription.Id;
            oCase.Origin ='Email';
            oCase.Status = 'Not Started';
            oCase.MLS__c = 'BRIGHT';
            oCase.ContactId = subscription.Contact__c;
            oCase.Product__c = 'Accounts & Settings';
            if(subLicenses[0].License_Name__c != '' && subLicenses[0].License_Type__c != '' && subLicenses[0].License_State__c != '' && subLicenses[0].License_Expiration_Date__c != null ){
                oCase.Description = 'License Number - ' + subLicenses[0].License_Name__c + ', ' + 'License Type - ' +  subLicenses[0].License_Type__c + ', ' + 'License Expiration Date - ' +  subLicenses[0].License_Expiration_Date__c + ', ' + 'License State - ' +  subLicenses[0].License_State__c ;
            }
            oCase.Subject = 'Subscriber has checked \'License is no longer valid\'';
            insert oCase;
            
        }
    }
    
    public void closeModal(){
        isErrorMessage = false;
        isSuccessMessage = false;
        isDeleteLicense = false;
        licenses();
    }
    
    public void saveLicense() {
        try {
            System.debug('*** saveLicense: ' + newLicense);
            
            List<License__c> listLicenses = [SELECT Id, Name FROM License__c
                                             WHERE Name = :newLicense.Name
                                             AND License_State__c = :newLicense.License_State__c
                                             AND License_Type__c = :newLicense.License_Type__c
                                             AND SoftDeleted__c != 'Yes'];
            
            if(newLicense.Id == null) {
                if(listLicenses.size() > 0){
                    throw new CustomException('Error: The license information entered already exists in the system.');
                }
                newLicense.Contact__c = subscription.Contact__c;
                insert newLicense;
                
                Subscription_License__c subLicense = new Subscription_License__c();
                subLicense.Subscription__c = subscription.Id;
                subLicense.License__c = newLicense.Id;
                insert subLicense;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'New License Added', 'A new license has been added to the system.'));
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'', ''));
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'', 'A new license has been added to the system.'));
            }
            else {
                if(listLicenses.size() > 0){
                    for(License__c lic : listLicenses){
                        if(lic.Id != newLicense.Id)
                            throw new CustomException('Error: The license information entered already exists in the system.');
                    }
                }
                update newLicense;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'License Updated:','The Expiration date for this license has been updated.'));
            }
            
            isEditLicense = false;
            licenses();   
        }
        catch(DmlException e) {
            System.debug('DmlException caught: ' + e.getMessage()); 
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public void saveProfessionalDesignations() {
        try {
            List<String> pd = subscription.Contact__r.Professional_Designations__c.split(';');
            if(pd.size() > 5){
                throw new CustomException('Only 5 Professional Designations can be added');
            }
            Contact c = new Contact();
            c.Id = subscription.Contact__c;
            system.debug('*** Professional_Designations__c:' + subscription.Contact__r.Professional_Designations__c);
            c.Professional_Designations__c = subscription.Contact__r.Professional_Designations__c;
            update c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'SUCCESS: ','Professional Designations updated successfully'));
            subscriptions();
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }
    
    public void saveMLS() {
        try {
            string commaList='';
            string commaStateList='';
            List<String> tempLst = new List<String>();
            set<String> stateLst = new set<String>();
            if(rightstateMLSOptions != null && rightstateMLSOptions.size()>0){
                for(SelectOption m : rightstateMLSOptions){
                    tempLst.add(m.getvalue());
                }
                
                system.debug('tempLst----'+tempLst);
                commaList = string.join(tempLst, ';');
                
                list<License_Association_MLS__c> MLSListTemp = [SELECT State__c FROM License_Association_MLS__c
                                                                WHERE MLS__c IN :tempLst];
                
                for(License_Association_MLS__c m : MLSListTemp){
                    stateLst.add(m.State__c);
                } 
                commaStateList = string.join(new List<String>(stateLst), ';');
            }    
            Contact c = new Contact();
            c.Id = subscription.Contact__c;
            c.MLS_State_Options__c = commaStateList;
            c.AdditionalMLS__c = commaList;
            system.debug('c----'+c);
            update c;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'SUCCESS:','Your additional MLS information has been updated.'));
            termsDisabled = true;
            subscriptions();
            
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + e.getMessage()));
        }    
    }
    
    public void findAllAssociations() {
        options = new list<SelectOption>();
        
        List<Account> associationAccounts = [SELECT Id, Name, Account_Name__c FROM Account WHERE Type = 'Association' AND Status__c = 'Active' ORDER BY Account_Name__c ASC];
        for(Account a : associationAccounts)
            options.add(new SelectOption(a.Id, a.Account_Name__c));
    }     
    
    public void addAssociation(){
        isEditAssociation = true;
        isEditLicense = false;
        newAssociation = new Related_Association__c();
        if(String.isBlank(associationSelected)) 
            newAssociation = new Related_Association__c();
        else {
            for(Related_Association__c association : associations) {
                if(association.Id == associationSelected) {
                    oldAssociationID = association.Association__c;
                    newAssociation  = association;
                    newAssociation.Start_Date__c =  date.newinstance(newAssociation.Start_Date__c.year(), newAssociation.Start_Date__c.month(), newAssociation.Start_Date__c.day());
                }    
            }
        }     
    }
    
    public void saveAssociation(){
        System.debug('***' + newAssociation);
        try {
            System.debug('*** saveAssociation: ' + newAssociation);
            
            
            List<Related_Association__c>  listAssociation =   [ SELECT Id,Name 
                                                               FROM Related_Association__c 
                                                               WHERE Subscription__c = :subscription.Id
                                                               AND Association__c=: newAssociation.Association__c];
            
            system.debug('*************** Association List *************'+ listAssociation);
            if(newAssociation.Id == null || String.isBlank(newAssociation.Id)) {
                if(listAssociation.size() > 0){
                    throw new CustomException('Selected association already exists for the subscription');
                }
                newAssociation.Subscription__c = subscription.Id;
                insert newAssociation;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'SUCCESS: ','Association created successfully'));
            }
            else {
                system.debug('****************** oldAssociationID ***********'+ oldAssociationID);
                system.debug('****************** newAssociationID ***********'+ newAssociation.Association__c);
                if(oldAssociationID != newAssociation.Association__c ){
                    if(listAssociation.size() > 0){
                        throw new CustomException('Selected association already exists for the subscription');
                    }
                }
                
                update newAssociation;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'SUCCESS: ','Association updated successfully'));
            }
            
            
            /* If new association is primary flip previous one as secondary */
            List<Related_Association__c> existingPrimary = new List<Related_Association__c>();
            if(newAssociation.Primary__c) {
                for(Related_Association__c association : associations) {
                    if(association.Primary__c && association.Id != newAssociation.Id) {
                        association.Primary__c = false;
                        existingPrimary.add(association);
                    }                        
                }
                
                subscription.Primary_Subscription_Association__c = newAssociation.Id;
                
            }
            if((subscription.Subscription_Type__c == 'Licensee/Non Realtor') || (subscription.Subscription_Type__c == 'Realtor/Non Shareholder')){
                subscription.Subscription_Type__c = 'Realtor/Shareholder';
            }
            update subscription;
            
            
            if(existingPrimary.Size() > 0)
                update existingPrimary;                         
            
            isEditAssociation = false;
            associations();   
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }        
    }
    
    
    
    
    public class CustomException extends Exception {}
}