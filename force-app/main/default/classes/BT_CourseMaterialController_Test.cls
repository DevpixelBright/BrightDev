@isTest
public class BT_CourseMaterialController_Test {
	
    @isTest
    static void courseMaterialAuthenticatedUser() {
       generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;  
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
        
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         BT_CourseMaterialController cm = new BT_CourseMaterialController();  
       } 
    }
    
    @isTest
    static void courseMaterialUnAuthenticatedUser() {
       generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
         
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_CourseMaterialController cm = new BT_CourseMaterialController();
    }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}