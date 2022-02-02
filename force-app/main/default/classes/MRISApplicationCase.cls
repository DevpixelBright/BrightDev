public class MRISApplicationCase {
    /*
    Developer: Justin Padilla
    Class Description: This class is used for Case operations when a MRIS Application Object is saved
    This class is called from both MRISApplicationExtension and MRISApplicationExtension2   
    */
    public static void Create(MRIS_Application__c application)
    {
        //Gather Processing Queue for Case Owner Assignment
        List<QueueSobject> processing = new List<QueueSobject>();
        processing = [SELECT
        QueueSobject.Id,
        QueueSobject.SobjectType,
        QueueSobject.QueueId
        FROM QueueSobject
        WHERE QueueSobject.SobjectType = 'Case'
        AND QueueSobject.Queue.Name = 'Processing' LIMIT 1];
        if (processing.size() <= 0)
        {
            //No Queue found
            return;
        }
        else
        {
            Boolean reinstatement = IsReinstatementApp(application);

            //Create a Case for this application
            Case c = new Case();
            c.Origin = 'WebApp';
            c.AccountId = application.Company_Code__c;
            
            if(reinstatement)
            {
                c.Subject = 'Reinstatement/Secondary ID application';
                c.Subscription_ID__c = FindSubscriptionId(application);
            }
            else
            {
                c.Subject = 'On-Boarding Application';
            }
            
            c.Status = 'Not Started';            
            c.OwnerId = processing[0].QueueId;
            c.MRIS_Application__c = application.Id;
            insert(c);
        }
    }
    
    public static Boolean IsReinstatementApp(MRIS_Application__c app)
    {
        if(app.RecordTypeId == null)
        {
            return false;
        }
        RecordType rt = [select Id, DeveloperName from RecordType where Id = :app.RecordTypeId];
        if(rt.DeveloperName == 'MRIS_Reinstatement_Application')
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public static String FindSubscriptionId(MRIS_Application__c app)
    {
        if(app.Existing_Subscriber_ID__c == null || app.Existing_Subscriber_ID__c == '') return null;
        List<Subscriptions__c> sub = [select Id, Name from Subscriptions__c where Name = :app.Existing_Subscriber_ID__c];
        if(sub.size() != 1) return null;
        return sub.get(0).Id;
    }
    
    static testMethod void MRISApplicationCaseTest()
    {
        test.startTest();
        //Create an Account to Assign to the MRIS Application
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
           cau.addAddrs();    
           Account a = new Account();
           a.name = 'ADA1234';
           a.type = 'Residential';
           a.Account_Name__c = 'Test Account';
           a.City__c = 'Herndon';
           a.Zip__c = '20171';
           a.QAS_Mailing_County__c = 'Fairfax';
           a.County__c = 'Fairfax';
           a.Street_Type__c = '';
           a.Billing_Street_Type__c = 'BLFS';
           a.QAS_Mailing_Street_Type__c ='test';
           insert a;
        //Create an MRIS Application record
        MRIS_Application__c app = new MRIS_Application__c();
        app.Company_Code__c = a.Id;
        insert(app);
        MRISApplicationCase.Create(app);
        test.stopTest();
    }
}