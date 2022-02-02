/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* Utility method to create relationships
**/
global with sharing class RelationshipUtility {
    
    /**
    * @param id
    * Update relationship -- End date
    */
    global static void updateRelationship(String id){
        System.debug('Update createRelationship');
       try {
         Related_Agent__c ra  = [select id, status__c, end_date__c from Related_Agent__C where ID = :id and status__c = 'Active' LIMIT 1];
            
            ra.status__c = 'Inactive';
            //ra.end_date__c = Date.today();
            upsert ra;  
       } catch (Queryexception ex) {
         try {
            Relationship__C r =     [select id, status__c, Relationship_End_Date__c from Relationship__C where ID = :id and status__c = 'Active' LIMIT 1];
             
            r.status__c = 'Inactive';
            //r.Relationship_End_Date__c = Date.today();
            upsert r;
         } catch  (Queryexception qxe) {
            
                Related_Association__c ra =     [select id, status__c, End_Date__c from Related_Association__c where ID = :id and status__c = 'Active' LIMIT 1];
         
                ra.status__c = 'Inactive';
                //ra.End_Date__c = Date.today();
                upsert ra;
            
         }
        }
       }
        
     
    
    global static Relationship createRelationship(Relationship rel){
        System.debug('Inside createRelationship');
        System.debug('RelationshipName' + rel.RelationshipName);
        if ('Related_Agent__c'.equals(rel.RelationshipName)) {
            return processRelatedAgent(rel);
        } else if ('Relationship__C'.equals(rel.RelationshipName)){
            return processRelationship(rel);
        } else if ('Related_Association__c'.equals(rel.RelationshipName)){
            return processSubscriptionRelationship(rel);
        } else { 
            rel.message = 'Invalid relationshipName ' + rel.relationshipName;
        }
        
        return rel;
    }
    
    private static Relationship processSubscriptionRelationship(Relationship rel){
        //Association & RelationshipType is always required
        //Subscription or Office must exist
        //Rest of the fields are optional
        
        if (Utils.isNull(rel.SFAssociationId)) {
            rel.message = 'SFAssociationId & RelationshipType is required.  Both cannot be null';
            return rel;
        }
        if (Utils.isNull(rel.Primary)) {
            rel.Primary = 'false';
        } else if (!Utils.isValidBoolean(rel.Primary)){
            rel.message = 'Invalid Primary type.  The valid values are "true" or "false"';
            return rel;
        }
         
        Related_Association__c relationship = new Related_Association__c();
        relationship.Broker_Code__c = rel.SFAccountID;
        
        
        relationship.Subscription__c = rel.SFSubscriptionID;
        relationship.Association__c = rel.SFAssociationId;
        relationship.Notes__c = rel.notes;
        relationship.Primary__c = Boolean.valueOf(rel.Primary);
        
        try {
            insert relationship;
        } catch (Exception ex){
            rel.message = 'Error occured while inserting.  Contact Salesforce administrator';
        }
        
        rel.message = 'Success';
        rel.id = relationship.id;
        return rel;
    }
    
    /**
    *  @param  rel Relationship
    *  @return Relationship This will contain the Relationship Id and the message details
    *  This method will create a subscription Relationship
    */
    private static Relationship processRelationship(Relationship rel){
        //SFAccountID & RelationshipType is always required
        //SFSubscriptionID or RelatedSFAccountID must exist
        //Rest of the fields are optional
        if (Utils.isNull(rel.SFAccountID) || Utils.isNull(rel.RelationshipType)) {
            rel.message = 'SFAccountID & RelationshipType is required';
            return rel;
        }
        
        if (Utils.isNull(rel.SFSubscriptionID)  && Utils.isNull(rel.RelatedSFAccountID)) {
            rel.message = 'Either SFSubscriptionID or RelatedSFAccountID is required.  Both cannot be null';
            return rel;
        }
        
         
        Relationship__c relationship = new Relationship__c();
        relationship.Broker_Office__c = rel.SFAccountID;
        relationship.Related_Account__c = rel.RelatedSFAccountID;
        
        List <RecordType> rList = [Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, 
            r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate,
             r.CreatedById, r.BusinessProcessId From RecordType r where r.sObjectType='Relationship__C'];
             
        for (RecordType r : rList) {
            if ('Office to Office'.equals(r.Name) && ''.equals(rel.SFSubscriptionID)) {
                relationship.RecordTypeId = r.id;
            } else if (!'Office to Office'.equals(r.Name) && !''.equals(rel.SFSubscriptionID)){
                relationship.RecordTypeId = r.id;
                relationship.Contact__c = [select Contact__c from subscriptionS__c where id=:rel.SFSubscriptionID LIMIT 1].Contact__c;
            }
        }
    
        if (rel.RelationshipType.equals('Personal Assitant')) {
            relationship.Personal_Assistant_Sub_ID__c = rel.SFSubscriptionID;
        } else {
            relationship.Subscription__c = rel.SFSubscriptionID;
        }
        System.debug('re.RelationshipStartDateTime ---> ' + rel.RelationshipStartDateTime);
        if (rel.RelationshipStartDateTime != null 
                || ''.equals(rel.RelationshipStartDateTime)) {
                    
            relationship.Relationship_Start_Date__c = DateTime.valueOf(rel.RelationshipStartDateTime);
        }
       
        System.debug('relationship.Relationship_Start_Date__c ---> ' + relationship.Relationship_Start_Date__c);
         
        relationship.Relationship_Type__c = rel.RelationshipType;
        try {
            Subscriptions__c sub = [SELECT contact__c from Subscriptions__c where id = :rel.SFSubscriptionID];
            relationship.Contact__c = sub.Contact__c;   
        } catch (Queryexception ex){
            
        }
        try {
            System.debug('relationship---->' + relationship);
            insert relationship;
        } catch (Exception ex){
            rel.message = 'Error occured while inserting.  Contact Salesforce administrator';
        }
        
        rel.message = 'Success';
        rel.id = relationship.id;
        System.debug('relationship---->' + relationship);
        return rel;
    }
    
    /**
    *  @param  rel Relationship
    *  @return Relationship This will contain the Relationship Id and the message details
    *  This method will create a Related Agent
    */
    private static Relationship processRelatedAgent (Relationship rel){
        //RelatedSFSubscriptionID & SFSubscriptionID is always required
        
        if (Utils.isNull(rel.SFSubscriptionID) || Utils.isNull(rel.RelatedSFSubscriptionID)) {
            rel.message = 'SFSubscriptionID & RelatedSFSubscriptionID is required';
            return rel;
        }
        
        Related_Agent__c relationship = new Related_Agent__c();
        relationship.Subscription__c = rel.SFSubscriptionID;
        relationship.Personal_Assistant_Sub_ID__c = rel.RelatedSFSubscriptionID;
        relationship.Notes__c = rel.notes;
         
        try {
            insert relationship;
        } catch (Exception ex){
            rel.message = 'Error occured while inserting.  Contact Salesforce administrator';
        }
        
        rel.message = 'Success';
        rel.id = relationship.id;
        return rel;
    }
    
 /*   
    @isTest
    static void testForcreateRelationship() {
    
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        insert a;
        
        Account a1 = new Account();
        a1.name = 'ABC1235';
        a1.type = 'Association';
        a1.Account_Name__c = 'Test Account';
        a1.City__c = 'Herndon';
        a1.Zip__c = '20171';
        insert a1;
        
        Account a2 = new Account();
        a2.name = 'ABC1236';
        a2.type = 'Association';
        a2.Account_Name__c = 'Test Account';
        a2.City__c = 'Herndon';
        a2.Zip__c = '20171';
        insert a2;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
         c.City__c = 'Herndon';
        c.Zip__c = '20171';
        insert c;
        
        Contact c1 = new Contact();
        c1.Email = 'email@something.com';
        c1.FirstName = 'Test';
        c1.LastName = 'Contact';
        c1.Public_Email__c = 'email@something.com';
        c1.AccountId = a1.id; 
        c1.Salutation = 'Mr.';
         c1.City__c = 'Herndon';
        c1.Zip__c = '20171';
        
        insert c1;
        
        Contact c2 = new Contact();
        c2.Email = 'email@something.com';
        c2.FirstName = 'Test';
        c2.LastName = 'Contact';
        c2.Public_Email__c = 'email@something.com';
        c2.AccountId = a2.id; 
        c2.Salutation = 'Mr.';
        c2.City__c = 'Herndon';
        c2.Zip__c = '20171';
        
        insert c2;
            
        Subscriptions__c sc = new Subscriptions__c();
        sc.Name = '1234511';
        sc.Contact_Type__c = 'Agent';
        sc.Subscription_Type__c = 'Licensee';
        sc.Related_Location_Broker_Office__c = a.id;
        sc.Public_Email__c = 'email@something.com';
        sc.Status__c = 'In Progress';
        sc.Primary_Phone__c = '1231111643';
        sc.Public_Email__c = 'email@something.com';
        sc.Mobile_Phone__c = '1231112643';
        sc.City__c = 'Herndon';
        sc.Zip__c = '20171';
        sc.County__c = 'Fairfax';
        sc.Country__c = 'UNITED STATES';
        sc.State__c = 'VA';
        sc.Contact__c = c.id;
        sc.Related_Location_Broker_Office__c = a.id;
        sc.Contact_Type__c = 'Agent';
        insert sc;
        
         Subscriptions__c sc3 = new Subscriptions__c();
        sc3.Name = '1234541';
        sc3.Contact_Type__c = 'Agent';
        sc3.Subscription_Type__c = 'Licensee';
        sc3.Related_Location_Broker_Office__c = a.id;
        sc3.Public_Email__c = 'email@something.com';
        sc3.Status__c = 'In Progress';
        sc3.Primary_Phone__c = '1231111643';
        sc3.Public_Email__c = 'email@something.com';
        sc3.Mobile_Phone__c = '1231112643';
        sc3.City__c = 'Herndon';
        sc3.Zip__c = '20171';
        sc3.County__c = 'Fairfax';
        sc3.Country__c = 'UNITED STATES';
        sc3.State__c = 'VA';
        sc3.Contact__c = c.id;
        sc3.Related_Location_Broker_Office__c = a.id;
        sc3.Contact_Type__c = 'Agent';
        insert sc3;
        
        Subscriptions__c sc1 = new Subscriptions__c();
        sc1.Name = '1234521';
        sc1.Contact_Type__c = 'Agent';
        sc1.Subscription_Type__c = 'Licensee';
        sc1.Related_Location_Broker_Office__c = a1.id;
        sc1.Public_Email__c = 'email@something.com';
        sc1.Status__c = 'In Progress';
        sc1.Primary_Phone__c = '1231111643';
        sc1.Public_Email__c = 'email@something.com';
        sc1.Mobile_Phone__c = '1231112643';
        sc1.City__c = 'Herndon';
        sc1.Zip__c = '20171';
        sc1.County__c = 'Fairfax';
        sc1.Country__c = 'UNITED STATES';
        sc1.State__c = 'VA';
        sc1.Contact__c = c1.id;
        sc1.Related_Location_Broker_Office__c = a.id;
        sc1.Contact_Type__c = 'Agent';
        insert sc1;
        
        Subscriptions__c sc2 = new Subscriptions__c();
        sc2.Name = '1234531';
        sc2.Contact_Type__c = 'Agent';
        sc2.Subscription_Type__c = 'Licensee';
        sc2.Related_Location_Broker_Office__c = a2.id;
        sc2.Public_Email__c = 'email@something.com';
        sc2.Status__c = 'In Progress';
        sc2.Primary_Phone__c = '1231111643';
        sc2.Public_Email__c = 'email@something.com';
        sc2.Mobile_Phone__c = '1231112643';
        sc2.City__c = 'Herndon';
        sc2.Zip__c = '20171';
        sc2.County__c = 'Fairfax';
        sc2.Country__c = 'UNITED STATES';
        sc2.State__c = 'VA';
        sc2.Contact__c = c2.id;
        sc2.Related_Location_Broker_Office__c = a.id;
        sc2.Contact_Type__c = 'Agent';
        insert sc2;
        
        
        
        Relationship rel  = new Relationship();
        rel.RelationshipName = 'Invalid Relationship';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Invalid relationshipName'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Agent__c';
        rel.SFSubscriptionID = sc1.Id;
        rel.RelatedSFSubscriptionID = sc2.Id;
        rel.notes = 'This is a test';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Agent__c';
        rel.RelatedSFSubscriptionID = sc2.Id;
        rel.notes = 'This is a test';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('SFSubscriptionID & RelatedSFSubscriptionID is required'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Relationship__C';
        rel.SFAccountID = a.id;
        rel.RelationshipType = 'Branch Office';
        rel.RelatedSFAccountID = a1.id;
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Relationship__C';
        rel.RelationshipType = 'Branch Office';
        rel.RelatedSFAccountID = a1.id;
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('SFAccountID & RelationshipType is required'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Relationship__C';
        rel.SFAccountID = a.id;
        rel.RelationshipType = 'Branch Office';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Either SFSubscriptionID or RelatedSFAccountID is required.'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFAccountID = a2.id;
        //rel.Subscription__c = sc1.id;
        rel.notes = 'Test Notes';
        rel.SFAssociationId = a2.id;
        rel.RelationshipType = 'Association';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFAssociationId = a2.id;
        rel.SFSubscriptionID = sc1.id;
        rel.notes = 'Test Notes';
        rel.RelationshipType = 'Apprisar';
        System.debug(RelationshipUtility.createRelationship(rel).message);
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFAssociationId = a2.id;
        rel.SFSubscriptionID = sc1.id;
        rel.notes = 'Test Notes';
        rel.RelationshipType = 'Apprisar';
        rel.Primary = 'adsfdasf';
        System.debug(RelationshipUtility.createRelationship(rel).message);
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Invalid Primary type.'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFSubscriptionID = sc1.id;
        rel.notes = 'Test Notes';
        rel.RelationshipType = 'Apprisar';
        rel.Primary = 'adsfdasf';
        System.debug(RelationshipUtility.createRelationship(rel).message);
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('SFAssociationId & RelationshipType is required'));
        
        
        
        
        
        
    }
*/
}