@isTest
public class Training_AllCoursesController_Test {
	@isTest
    static void courseMaterialAuthenticatedUser() {
       generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;  
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
        
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         Training_AllCoursesController cm = new Training_AllCoursesController();  
       } 
    }
    
    @isTest
    static void courseMaterialUnAuthenticatedUser() {
       generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
         
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       Training_AllCoursesController cm = new Training_AllCoursesController();
    }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}