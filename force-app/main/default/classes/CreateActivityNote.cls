/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will create Activity Note for Account, Contact and Subscription
**/
@RestResource(urlMapping='/CreateActivityNote/*')
global with sharing class CreateActivityNote {
    
    global class ResultMsg {
        String result;
    }
    /**
    *  HTTP Post Method
    *
    **/
    @HttpPost
    global static ResultMsg doPost(String relatedToID,String typeOfActivity,String description,String subject) {
            ResultMsg r = new ResultMsg();
            System.debug('relatedToID ->' +relatedToID);
            System.debug('typeOfActivity ->' +typeOfActivity);
            System.debug('description ->' +description);
            Task e = new Task();
            // Event e = new Event();
            e.Subject = subject;
            e.Description =description;
           // e.StartDateTime = Datetime.now();
            e.ActivityDate = System.today();
           // e.EndDateTime = DateTime.now().addMinutes(1);
            
            if ('ACCOUNT'.equals(typeOfActivity)){
                List <Account> a = [SELECT ID,OwnerId FROM Account WHERE NAME=:relatedToID];
                if (a.size() == 0){
                     r.result = 'Error!  The account id should be the broker office code.  Either the broker office code is invalid or it is not present in the CRM';
                     return r;
                } 
                System.debug('Account ID --> ' + a.get(0).id);
                e.OwnerId = a.get(0).OwnerId;
                e.WhatId = a.get(0).id;
            } else if ('CONTACT'.equals(typeOfActivity)) {
                List <Contact> c = [SELECT ID,OwnerId FROM Contact WHERE id=:relatedToID];
                if (c.size() == 0){
                     r.result = 'Error!  The contact id passed is invalid.  Pease pass the correct contact id';
                     return r;
                }
                e.OwnerId = c.get(0).OwnerId;
                e.WhoId = c.get(0).id;
            } else if ('SUBSCRIPTION'.equals(typeOfActivity)) {
                List <Subscriptions__C> c = [Select s.Id, s.Contact__r.OwnerId From Subscriptions__c s WHERE s.name =:relatedToID];
                if (c.size() == 0){
                    r.result = 'Error!  The subscription ID passed is invalid.  Please pass the correct subscription id';
                    return r;
                }
                e.OwnerId = c.get(0).Contact__r.OwnerId;
                e.WhatId = c.get(0).id;
                
            } else {
                r.result = 'Error!  The type of activity is not valid.  The valid types are Account, Contact or Subscription';
                return r;
            }
            
            upsert e;
            r.result = 'Success.  The activity Id is: ' + e.Id;
            return r;
            
    }
    
    static testMethod void testDoGet() {
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
         
        Account a = new Account();
        a.name = 'ADA1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.Zip__c = '20171';
        a.County__c = 'Fairfax';
        insert a;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.QAS_Mailing_County__c = 'Arlington';
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        
        insert c;
       
       License__c l = new License__c();
        l.Name = '123456';
        l.License_Expiration_Date__c = Date.today();
        l.License_State__c = 'VA';
        l.License_Type__c = 'Broker';
        //l.IsDeleted = false;
        l.Contact__c = c.id;
        insert l;
        
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = 'Test Subscription';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.License__c = l.id;
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.County__c = 'Fairfax';
        s.AgentKey__c = '123111';
        s.name = '123111';
        s.County__c = 'Fairfax';
        s.Related_Location_Broker_Office__c = a.id;
        s.Contact_Type__c = 'Agent';
        insert s;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/CreateActivityNote';  
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
            
            String description = 'Test';
            String relatedToID = 'ADA1234';
            String typeOfActivity = 'ACCOUNT';
        CreateActivityNote.ResultMsg result = CreateActivityNote.doPost(relatedToID,typeOfActivity,description,'subject');
        System.assert(result.result.contains('Success'));
        description = 'Test';
            relatedToID = 'Teste';
            typeOfActivity = 'ACCOUNT';
         result = CreateActivityNote.doPost(relatedToID,typeOfActivity,description,'subject');
         System.assert(result.result.contains('Error'));
         description = 'Test';
            relatedToID = 'test';
            typeOfActivity = 'test';
         result = CreateActivityNote.doPost(relatedToID,typeOfActivity,description,'subject');
        System.assert(result.result.contains('Error'));
        description = 'Test';
            relatedToID = c.id;
            typeOfActivity = 'CONTACT';
         result = CreateActivityNote.doPost(relatedToID,typeOfActivity,description,'subject');
        System.assert(result.result.contains('Success'));
        description = 'Test';
            relatedToID = 'Test';
            typeOfActivity = 'CONTACT';
        result = CreateActivityNote.doPost(relatedToID,typeOfActivity,description,'subject');
        System.assert(result.result.contains('Error'));
        description = 'Test';
            relatedToID = s.Name;
            typeOfActivity = 'SUBSCRIPTION'; 
         result = CreateActivityNote.doPost(relatedToID,typeOfActivity,description,'subject');
        //System.assert(result.result.contains('Success'));
        description = 'Test';
            relatedToID = 'Test';
            typeOfActivity = 'SUBSCRIPTION';
        result = CreateActivityNote.doPost(relatedToID,typeOfActivity,description,'subject');
        System.assert(result.result.contains('Error'));
        //System.assertEquals(0, ra.size());
      
 
  }

}