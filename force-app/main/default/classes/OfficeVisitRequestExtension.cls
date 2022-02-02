public class OfficeVisitRequestExtension {
private final OfficeVisitRequest__c ofvr;
Contact c;
Contact cnt;
User u;
User usr;
user camp;
Account a;
Subscriptions__c s;
Related_Association__c ra;
String RequestCreator='';
//String raname='';


public OfficeVisitRequestExtension(ApexPages.StandardController stdController) {
    this.ofvr = (OfficeVisitRequest__c)stdController.getRecord();

   if(ofvr.CreatedbyId ==null){ 
     usr = [SELECT Id, Name, ContactId, FederationIdentifier FROM User where id = :UserInfo.getUserId() LIMIT 1];
     ofvr.name='Office Visit Request for '+usr.Name;
     cnt = [SELECT Id, Name, AccountId, Email, Account.Account_Name__c, Account.Account_CAM_Owner__c, Phone, Primary_Subscription__c FROM Contact where id = :usr.ContactId LIMIT 1];
     camp = [SELECT Id, Name, Email FROM User where Name = :cnt.Account.Account_CAM_Owner__c LIMIT 1];
     
     ofvr.SubscriptionId__c=cnt.Primary_Subscription__c;
     ofvr.AccountId__c=cnt.AccountId;
     ofvr.Email__c=cnt.email;
     ofvr.Phone__c=cnt.phone;
     ofvr.Brokerage_Firm__c=cnt.Account.Account_Name__c;
     //ofvr.Account_CAM__c=camp.id;
     // ofvr.OwnerId=camp.id;
     RequestCreator=usr.name;
    }
    else{
    user ruser = [SELECT Id, Name, ContactId, FederationIdentifier FROM User where id = :ofvr.CreatedById LIMIT 1];
    RequestCreator=ruser.Name; }

}


    public String getRequestCreator() {
      return RequestCreator;
    }

public String getAgentInfo() {
u = [SELECT Id, Name, ContactId, FederationIdentifier FROM User where id = :UserInfo.getUserId() LIMIT 1];
c = [SELECT Id, Name, AccountId, Primary_Subscription__c FROM Contact where id = :u.ContactId LIMIT 1];
s = [SELECT Id, Name  FROM Subscriptions__c where id = :c.Primary_Subscription__c LIMIT 1];
a = [SELECT Id, Name  FROM Account where id = :c.AccountId LIMIT 1];


//ra = [SELECT Id, Name  FROM Related_Association__c where (Association__c = :c.AccountId AND Subscription__c =:s.Id) LIMIT 1];
//if(ra != null) raname = ra.Name;
//return 'Agent info:'+ u.Name+', Contact Id:'+u.ContactId + ', AccountId:'+c.AccountId+', Pr Sub:'+c.Primary_Subscription__c +', Sb name:'+s.name +', Account Name:'+a.Name+', Ass name:'+raname;

return 'Created by:'+RequestCreator+', Agent info:'+ u.Name+', Contact Id:'+u.ContactId + ', AccountId:'+c.AccountId+', Pr Sub:'+c.Primary_Subscription__c +', Sb name:'+s.name +', Account Name:'+a.Name;

}


}