@isTest
private class CampaignOwnerRealtyTrackOnInsertTest {

    @isTest static void test_method_one() {
        Campaign c= new Campaign();
        c.Name ='test';
        c.IsActive=true;
        c.Type='office Meeting';
        insert c;

        MRIS_RealtyTrac_Survey__c f = new MRIS_RealtyTrac_Survey__c();
        f.Campaign__c = c.Id;
       
        Id CampaignOwnerId = [SELECT Id, OwnerId FROM Campaign WHERE Id=:c.Id].OwnerId;

        test.startTest();

        insert f;


        Id FeedbackOwnerid = [SELECT Id, OwnerId FROM MRIS_RealtyTrac_Survey__c WHERE Id=:f.Id].OwnerId;

        system.assertEquals(CampaignOwnerId, FeedbackOwnerid);

        test.stopTest();
    }

}