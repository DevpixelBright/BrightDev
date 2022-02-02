@isTest
private class SMS_SubEmailUpdate_Test{

    private static testMethod void doTestOne(){
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs(); 
        
        Account account = new Account();
        account.Name = 'TEST567';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        insert account; 
        
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.Id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;
    
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.Name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Private_Email__c = 'test1@test.com';
        insert subscription; 
        
        //subscription.Status__c = 'Active';
        
        List<Subscriptions__c> subscriptions = [SELECT Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];

        Account personAccount = [SELECT id,Name FROM Account WHERE Contact__c = :contact.id];
                    
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = account.Id;
        billingAccount.Name = personAccount.Name;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subscription.Name;
        insert billingAccount;
        
        Zuora__Subscription__c zSubscription = new Zuora__Subscription__c();  
        zSubscription.Name = 'Zuora Sub Name';
        zSubscription.Zuora__CustomerAccount__c = billingAccount.Id;
        insert zSubscription;
        
        Zuora__SubscriptionProductCharge__c   subscriptionProductCharge = new Zuora__SubscriptionProductCharge__c();
        subscriptionProductCharge.Name = 'Initial Fee';
        subscriptionProductCharge.Zuora__Zuora_Id__c = '2c92c0f844f280310144f8dd32d72314';
        subscriptionProductCharge.Private_Email__c = 'someone@test.com';
        subscriptionProductCharge.Zuora__Subscription__c = zSubscription.id;
        insert subscriptionProductCharge;
        
        Zuora__PaymentMethod__c    paymentMethod = new  Zuora__PaymentMethod__c();
        paymentMethod.Name = 'a0WK00000023IYZ';
        paymentMethod.Zuora__BillingAccount__c = billingAccount.Id;
        paymentMethod.Private_Email__c = 'someone@test.com';
        insert paymentMethod;
        
        Teams__c ts = new Teams__c();
        //ts.Name = 'Team Name';
        ts.Team_Name__c = 'Team Name';
        ts.Team_Lead_Sub_ID__c = subscription.Name;
        ts.Office_ID__c = account.Id; 
        ts.Team_Lead_Email__c = 'test@testlead.com';
        insert ts;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Team_Name__c = ts.Id;
        tm.Team_Member_Sub_ID__c = subscription.Name;
        tm.Team_Lead_Sub_ID__c = subscription.Name;
        tm.Team_Member_Email__c = 'test@test.com';
        tm.Team_Lead_Email__c = 'test@testlead.com';
        tm.Updated_Date__c = system.today();
        //tm.Status_of_Invitation__c = 'Pending';
        insert tm;
        
        ts.Invitation_Status__c = 'Approved';
            update ts;
        
        tm.Team_Member_Email__c = 'test@test.com';
        tm.Status_of_Invitation__c = 'Accepted';
        update tm;
        
        subscription.Private_Email__c = 'test2@test.com';
        update subscription;
        //SMS_SubEmailUpdate.updatePrivateEmail(subscriptions[0].Name,'newemail@test.com');
    }
    
}