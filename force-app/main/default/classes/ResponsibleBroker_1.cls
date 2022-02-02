public class ResponsibleBroker_1 {
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

    
    public ResponsibleBroker_1(){
        lRBListview = new Map<String,RBListview>();
        subscriberSelected = '';
        isEdit = false;
        assignOfficeDisable = false;
        lOffice = new List<officeRecord>();
        disabled = true;
        termsDisabled = false;
        subscriptionId = ApexPages.currentPage().getParameters().get('id');
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

        if(relationships.Size() == 0)
            throw new CustomException('You do not have permission to access this page');
        
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
        lOffice = new List<officeRecord>();
        if(subscriberSelected != ''){
            subscriber = mSubLic.get(subscriberSelected);
            for(RBListview RBList : lRBListview.values()){
                
            }
            for(Account oAcc : [SELECT id, Name, Account_Name__c, Status__c, State__c, City__c FROM Account WHERE (id IN: offices OR ParentId IN: offices) AND State__c =: subscriber.License_State__c AND Status__c = 'Active']){
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
        isEdit = false;
       
       List<Relationship__c> lRelationship = new List<Relationship__c>();
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
      if(!lRelationship.isEmpty()){
         try{
          insert lRelationship;
         }catch(DMLException ex){
             errorMessage = 'A responsible broker is already assigned';
         }catch(exception ex){
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
                          State__c
                           FROM Relationship__c 
                           WHERE Relationship_Type__c = 'Responsible Broker' 
                           AND Status__c = 'Active'
                           AND Subscription__r.Status__c = 'Active'
                           AND Subscription__c != null
                           AND (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                           AND (Broker_Office__r.ParentId = :offices OR Broker_Office__c = :offices)];
        
        Set<string>rel = new Set<String>();
        for(Relationship__c oRel : lRelationship){
            sRel.add(oRel.Subscription__r.Name + oRel.State__c);
            rel.add(oRel.Subscription__c);
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
                                                       License__r.Contact__r.Phone,
                                                       License__r.Contact__r.Email,
                                                       License__r.License_Expiration_Date__c,
                                                       License_Contact_Name__c, 
                                                       License__r.Contact__c,
                                                       License_Type__c, 
                                                       License_State__c, 
                                                       Subscription__c,
                                                       Subscription__r.name,
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
                //mSubLic.remove(oSubLic.Id);
                subLic.add(oSubLic);
            }
        }
        
        for(Relationship__c oRel : lRelationship){
            if(lRBListview.containsKey(oRel.Subscription__r.Name + oRel.State__c)){
                lRBListview.get(oRel.Subscription__r.Name + oRel.State__c).addRelation(oRel);
            }
        }
        
        RelationshipStr = JSON.serialize(lRBListview.values());
        //subLic = mSubLic.values();
    }
    
    public void modifyResponsibleBroker(){
        //updateValues();
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
    }
    
    
}