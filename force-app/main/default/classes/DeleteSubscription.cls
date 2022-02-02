/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will delete Relationship
**/
@RestResource(urlMapping='/DeleteSubscription/*')
global with sharing class DeleteSubscription {
    
    /**
    *  This method will create the relationships in salesforce
    *
    **/ 
    @HttpDelete
    global static void doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String id = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //validate relationship type 
        System.debug('id ---->' + id);
        System.debug('req.requestURI ---> ' + req.requestURI);
        Subscriptions__c s = [select id, contact__c from subscriptions__c where name=:id and Status__c = 'In Progress' limit 1];
         
        Contact c = [select id from Contact where id = :s.contact__c LIMIT 1];
        delete c;
        return;
    
    }

}