@isTest
private class CampaignOwnerOnInsertTest {

    @isTest static void test_method_one() {
        Campaign c= new Campaign();
        c.Name ='test';
        c.IsActive=true;
        c.Type='office Meeting';
        insert c;

        Feedback__c f = new Feedback__c();
        f.Campaign__c = c.Id;
       
        Id CampaignOwnerId = [SELECT Id, OwnerId FROM Campaign WHERE Id=:c.Id].OwnerId;

        test.startTest();

        insert f;


        Id FeedbackOwnerid = [SELECT Id, OwnerId FROM Feedback__c WHERE Id=:f.Id].OwnerId;

        system.assertEquals(CampaignOwnerId, FeedbackOwnerid);

        test.stopTest();
    }

}