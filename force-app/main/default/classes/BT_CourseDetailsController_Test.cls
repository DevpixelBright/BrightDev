@isTest
public class BT_CourseDetailsController_Test {
    
    @isTest
    static void courseDetailConstructor() {
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
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       
       BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       BT_Registration__c reg1 = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg1;
       reg.Status__c = 'Canceled';
       update reg; 
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         //PageReference pg = new PageReference('/learnbrightmls/s/coursedetail?courseId='+course.Id);
         //Test.setCurrentPage(pg);
         ApexPages.currentPage().getHeaders().put('referer', '/learnbrightmls/s/coursedetail?courseId='+course.Id);
         BT_CourseDetailsController cd = new BT_CourseDetailsController();
         cd.registerClass();
         cd.cancelClass();  
       } 
    }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}