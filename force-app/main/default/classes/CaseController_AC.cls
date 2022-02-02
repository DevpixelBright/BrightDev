//CaseController_AC.apxc

public with sharing class CaseController_AC
{
@AuraEnabled
public static List<Case> getCases()
{
return [SELECT Id, CaseNumber, Status, OwnerId, Subscription_ID__c, ContactId, ProductId, Category__c, Subject, CreatedDate FROM Case LIMIT 100] ;
}

// This method used for reterived  the list of cases records based on the search string

@AuraEnabled
public static List<Case> getByName(String searchKey) 
{
     return[SELECT Id, CaseNumber, Status, OwnerId, Subscription_ID__c, ContactId, ProductId, Category__c, Subject, CreatedDate FROM Case WHERE Status = :searchKey LIMIT 100];  
}
}