public with sharing class TestVFPageClass {
    public list<Subscriptions__c> sub {get;set;}
    
    public TestVFPageClass() {
        sub = [Select Id, Name From Subscriptions__c Limit 1];
    }
}