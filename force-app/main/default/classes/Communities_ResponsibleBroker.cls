public class Communities_ResponsibleBroker {
    public Boolean hasBOR { get; set; }
    public Boolean hasInitialError { get; private set; }
    public String subscriptionId { get; set; }
    public String subscriberSelected {get;set;}
    public Boolean isAddNewResponsibleBroker {get;set;}
    public String searchBlockState {get;set;}
    public String assignBlockState {get;set;}
    public String reviewBlockState {get;set;}
    public String termsBlockState {get;set;}
    public String summaryBlockState {get;set;}
    public String errorMessage {get;set;}
    public Subscription_License__c subscriber { get; set; }
    private set<id> offices = new set<id>();
    private Map<String,String> templateIdMap;
    
    public Map<Id,Subscription_License__c> mSubLic = new Map<Id,Subscription_License__c>();
    public List<Subscription_License__c> subLic {get;set;}
    public List<officeRecord> lOffice {get;set;}
    public Boolean disabled {get;set;}
    public Boolean termsDisabled {get;set;}
    public List<Relationship__c> lRelationship {get;set;}
    public String RelationshipStr {get;set;}
    public Map<String,RBListview> lRBListview {get;set;}
    public String BORname = '';
    public Boolean isEdit {get;set;}
    public Boolean assignOfficeDisable {get;set;}
    public Boolean hasError { get; set; }
    
    
    public Communities_ResponsibleBroker(){ 
        lRBListview = new Map<String,RBListview>();
        try{
        subscriberSelected = '';
        isEdit = false;
        hasError = false;
        assignOfficeDisable = false;
        lOffice = new List<officeRecord>();
        disabled = true;
        termsDisabled = false;
        subscriptionId = ApexPages.currentPage().getParameters().get('id');
            system.debug('*****subscriptionId'+subscriptionId);
        if (String.IsBlank(subscriptionId))
            throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found' );   
        
        List<Relationship__c> relationships = new List<Relationship__c>();
        relationships = [SELECT  Id, 
                         Relationship_Type__c, 
                         Broker_Office__c,
                         Broker_Office__r.ParentId,
                         Broker_Office__r.Name,
                         Subscription__r.Name, 
                         Subscription__r.Contact__r.Name  
                         FROM    Relationship__c
                         WHERE   Relationship_Type__c = 'Broker Of Record'
                         AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                         AND     Subscription__r.Name  = : subscriptionId]; 
        
        if(relationships.Size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You do not have permission to access this page'));
            //throw new CustomException('You do not have permission to access this page');
        	hasError = true;
        }
        BORname = relationships[0].Subscription__r.Contact__r.Name;
        Set<String> subIds = new Set<String>();
        for(Relationship__c oRelation : relationships) {
            offices.add(oRelation.Broker_Office__c);
            if(oRelation.Broker_Office__r.ParentId != null){
                offices.add(oRelation.Broker_Office__r.ParentId);
            }
            subIds.add(oRelation.Subscription__r.Name);
            if(oRelation.Relationship_Type__c  == 'Broker Of Record')
                hasBOR = true;
        }
        updateValues();       
    }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getStackTraceString()));
        }
        
    }
    
    //method used to invoke modal window
    public void addNewResponsibleBroker(){
        updateValues();
        isAddNewResponsibleBroker = true;
        searchBlockState = 'Started';
        assignBlockState = '';
        reviewBlockState = '';
        termsBlockState = '';
        summaryBlockState = '';
        lOffice = new List<officeRecord>();
        subscriberSelected = '';
        disabled = true;
        termsDisabled = false;
    }
    
    public void individualSelected(){
            errorMessage = '';
            lOffice = new List<officeRecord>();
            List<Account> acc = New List<Account>();
            set <Id> subIds = New set <Id>();
            
            if(subscriberSelected != ''){
                subscriber = mSubLic.get(subscriberSelected);
                for(RBListview oRB: lRBListview.values()){
                    if(oRB.subRecId == subscriberSelected){
                        for(Relationship__c oRel: oRB.lRelationship){
                            subIds.add(oRel.Broker_Office__c); 
                        }
                    } 
                }
                if(isEdit == true){
                    acc = [SELECT id, Name, Account_Name__c, Status__c, State__c, City__c FROM Account WHERE Id IN: subIds AND State__c =: subscriber.License_State__c AND Status__c = 'Active'];
                }else{
                    acc = [SELECT id, Name, Account_Name__c, Status__c, State__c, City__c FROM Account WHERE (Id IN: offices OR ParentId IN: offices) AND State__c =: subscriber.License_State__c AND Status__c = 'Active'];
                }
                for(Account oAcc : acc){
                    officeRecord offRec = new officeRecord();
                    offRec.oAccount = oAcc;
                    offRec.check = true;
                    lOffice.add(offRec);
                    
                }
                
                isAddNewResponsibleBroker = true;
                assignBlockState = 'Started';
                searchBlockState = 'Completed';
                reviewBlockState = '';
                termsBlockState = '';
                summaryBlockState = '';
            }
    }
    
    
    public void assignAuthority(){
        searchBlockState = 'Completed';
        assignBlockState = 'Completed';
        reviewBlockState = 'Started';
        termsBlockState = '';
        summaryBlockState = '';
    }
    
    public void reviewChanges(){
        searchBlockState = 'Completed';
        assignBlockState = 'Completed';
        reviewBlockState = 'Completed';
        termsBlockState = 'Started';
        summaryBlockState = '';
    }
    
    
    public void saveSigners(){
        searchBlockState = 'Completed';
        assignBlockState = 'Completed';
        reviewBlockState = 'Completed';
        termsBlockState = 'Completed';
        summaryBlockState = 'Started';
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        if(isEdit == false){
            Id recordTypeId =Schema.SObjectType.Relationship__c.getRecordTypeInfosByName().get('Individual to Office').getRecordTypeId();
            
            for(officeRecord offRec: lOffice){
                if(offRec.check == true){
                    Relationship__c rel = new Relationship__c();
                    rel.State__c = subscriber.License_State__c;
                    rel.Relationship_Type__c = 'Responsible Broker';
                    rel.Status__c = 'Active';
                    rel.Relationship_Start_Date__c = System.now();
                    rel.Broker_Office__c = offRec.oAccount.Id;
                    rel.Subscription__c = subscriber.Subscription__c;
                    rel.Contact__c = subscriber.License__r.Contact__c;
                    rel.RecordTypeId = recordTypeId;
                    rel.Decision__c = 'Assigned by ' + BORname + ', ' + System.today().Month() + '/' + System.today().Day() + '/' + System.today().year();
                    lRelationship.add(rel);
                }
            }
        }
        else {
            for(RBListview oRB: lRBListview.values()){
                if(oRB.subRecId == subscriberSelected){
                    for(Relationship__c oRel: oRB.lRelationship){
                        oRel.Status__c = 'Inactive';
                        oRel.Relationship_End_Date__c = System.Today();
                        oRel.Decision__c = 'Removed by ' + BORname + ', ' + System.today().Month() + '/' + System.today().Day() + '/' + System.today().year();
                        lRelationship.add(oRel);
                    }
                } 
            }
        }
        if(!lRelationship.isEmpty()){
            try{
                upsert lRelationship;
                sendEmailToResponsibleBroker(lRelationship,subscriber,BORname, isEdit);
            }catch(DMLException ex){
                errorMessage = 'Only one Responsible Broker can be assigned per state.';
            }
            catch(exception ex){
                errorMessage = ex.getMessage();
            }
        }
    }
    
    public void closeModal(){
        isAddNewResponsibleBroker = false;
        isEdit = false;
        assignOfficeDisable = false;
        updateValues();
    }
    
    public void dummy(){
        disabled = false;
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
    
    
    public void updateValues(){
        subLic = new List<Subscription_License__c>();
        lRBListview = new Map<String,RBListview>();
        Set<String> sRel = new Set<String>();
        lRelationship = [SELECT Id,
                         Subscription__r.Name,
                         Broker_Office__c,
                         Broker_Office__r.Name,
                         Decision__c,
                         State__c,
                         Status__c,
                         Relationship_End_Date__c
                         FROM Relationship__c 
                         WHERE Relationship_Type__c = 'Responsible Broker' 
                         AND Subscription__r.Status__c = 'Active'
                         AND Subscription__c != null
                         AND (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                         AND (Broker_Office__r.ParentId = :offices OR Broker_Office__c = :offices)];
        
        Set<string>rel = new Set<String>();
        for(Relationship__c oRel : lRelationship){
            if(oRel.Status__c == 'Active'){
                sRel.add(oRel.Subscription__r.Name + oRel.State__c);
                rel.add(oRel.Subscription__c);
            }
        }
        
        
        
        mSubLic = new Map<Id,Subscription_License__c>([SELECT Id, 
                                                       Name, 
                                                       License__r.name,
                                                       Subscription__r.Related_Location_Broker_Office__r.Name,
                                                       Subscription__r.Related_Location_Broker_Office__r.Account_Name__c,
                                                       Subscription__r.Related_Location_Broker_Office__r.State__c,
                                                       Subscription__r.Related_Location_Broker_Office__r.Zip__c,
                                                       Subscription__r.Related_Location_Broker_Office__r.City__c,
                                                       Subscription__r.Related_Location_Broker_Office__r.Street_Name__c,
                                                       Subscription__r.Related_Location_Broker_Office__r.Street_Number__c,
                                                       Subscription__r.Contact__r.FirstName,
                                                       Subscription__r.Contact__c,
                                                       License__r.Contact__r.Phone,
                                                       License__r.Contact__r.Email,
                                                       License__r.License_Expiration_Date__c,
                                                       License_Contact_Name__c, 
                                                       License__r.Contact__c,
                                                       License_Type__c, 
                                                       License_State__c, 
                                                       Subscription__c,
                                                       Subscription__r.name,
                                                       Subscription__r.Primary_Phone__c,
                                                       Subscription__r.Private_Email__c
                                                       FROM Subscription_License__c
                                                       WHERE Subscription__r.Status__c = 'Active'
                                                       AND License__r.License_Type__c = 'Broker' 
                                                       AND SoftDelete__c != 'Yes'
                                                       AND (Subscription__r.Related_Location_Broker_Office__r.ParentId = :offices OR Subscription__r.Related_Location_Broker_Office__c = :offices)
                                                       AND Subscription__r.Contact_Type__c IN ('Agent', 'Broker', 'Office Manager')
                                                       AND Subscription__r.Subscription_Type__c IN ('Realtor/Shareholder', 'Realtor/Non Shareholder', 'Licensee/Non Realtor')]);
        
        for(Subscription_License__c oSubLic : mSubLic.values()){
            lRBListview.put(oSubLic.Subscription__r.name + oSubLic.License_State__c, new RBListview(oSubLic));
            if(!sRel.contains(oSubLic.Subscription__r.name + oSubLic.License_State__c)){
                subLic.add(oSubLic);
            }
        }
        
        for(Relationship__c oRel : lRelationship){
            if(lRBListview.containsKey(oRel.Subscription__r.Name + oRel.State__c)){
                if(oRel.Status__c == 'Active'){
                    lRBListview.get(oRel.Subscription__r.Name + oRel.State__c).addRelation(oRel);
                }else if(oRel.Status__c == 'Inactive' && lRBListview.get(oRel.Subscription__r.Name + oRel.State__c).lRelationship.size() == 0){
                    lRBListview.get(oRel.Subscription__r.Name + oRel.State__c).addDecision(oRel);
                }
            }
        }
        
        RelationshipStr = JSON.serialize(lRBListview.values());
    }
    
    public void modifyResponsibleBroker(){
        isEdit = true;
        individualSelected();
        isAddNewResponsibleBroker = true;
        searchBlockState = 'Completed';
        assignBlockState = 'Started';
        reviewBlockState = '';
        termsBlockState = '';
        summaryBlockState = '';
        disabled = true;
        termsDisabled = false;
    }
    
    //Method to send email for assigning and removal of Responsible Broker
    public void sendEmailToResponsibleBroker(List<Relationship__c> lRel,Subscription_License__c subscriber, String BORName, Boolean isEdit){  

        String a = '';
        for(OfficeRecord acc : lOffice){           
            a += acc.oAccount.Name + ', ';
        }      
        String withoutLastComma = a.substring( 0, a.length( ) - ', '.length( ) );       
        String b = BORName;
        String contactFirstName = subscriber.Subscription__r.Contact__r.FirstName;
        String subPrivateEmail = subscriber.Subscription__r.Private_Email__c;
        String subId = subscriber.Subscription__c;
        String conId = subscriber.Subscription__r.Contact__c;
        
		// grab the email template
        string emailBody = (isEdit)?'Responsible_Broker_Removal_Notification_Email':'New_Responsible_Broker_Assignment_Email_for_Subscriber';
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName =: emailBody];
        
        // process the merge fields
        String htmlBody = emailTemplate.HtmlValue;
        String Subject = emailTemplate.Subject;
    	htmlBody = htmlBody.replace('{!Contact.FirstName}', contactFirstName);
    	htmlBody = htmlBody.replace('{!BORName}', b);
        htmlBody = htmlBody.replace('{!Offices}', withoutLastComma);
        htmlBody = htmlBody.replace('{!subId}', subId);
        htmlBody = htmlBody.replace('{!BrightLink}', Label.BRIGHT_Logo_Link);
        htmlBody = htmlBody.replace('{!BrightLogo}', Label.Email_Template_Register_Bright_Logo);
        htmlBody = htmlBody.replace('{!RBLogo}', Label.EmailTemplate_Responsible_Broker);
        
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Contact.FirstName}', contactFirstName);
        plainBody = plainBody.replace('{!BORName}', b);
        plainBody = plainBody.replace('{!Offices}', withoutLastComma);
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        String orgWideAddress = orgWideAddresses[0].Id;
        
        Messaging.SingleEmailMessage sendMail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{subPrivateEmail};
        sendMail.setToAddresses(sendingTo);
        //sendMail.setWhatId(subId);
        sendMail.setTreatTargetObjectAsRecipient(false);
        sendMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
        sendMail.setSubject(Subject);
        sendMail.setHtmlBody(htmlBody);
    	sendMail.setPlainTextBody(plainBody); 
        sendMail.setOrgWideEmailAddressId(orgWideAddress);

        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {sendMail});

 }
    
    public class CustomException extends Exception {}
     
    
    public Class officeRecord {
        public Boolean check {get;set;}
        public Account oAccount {get;set;}
    }   
    
    public class RBListview {
        public String subRecId {get;set;}
        public String Name {get;set;}
        public String SubId {get;set;}
        public String State {get;set;}
        public String Decision {get;set;}
        public List<String> officeIds {get;set;}
        public List<Relationship__c> lRelationship {get;set;}
        public Integer index {get;set;}
        
        public RBListview(Subscription_License__c oSubLic){
            this.subRecId = oSubLic.Id;
            this.Name = oSubLic.License_Contact_Name__c;
            this.SubId = oSubLic.Subscription__r.name;
            this.State = oSubLic.License_State__c;
            lRelationship = new List<Relationship__c>();
            index = 0;
        }
        
        public void addRelation(Relationship__c oRel){
            this.lRelationship.add(oRel);
            this.Decision = (oRel.Decision__c != null)?oRel.Decision__c:'';
            index = lRelationship.size();
        }
        
        public void addDecision(Relationship__c oRel){
            this.Decision = (oRel.Decision__c != null)?oRel.Decision__c:'';
        }
        
    }
}