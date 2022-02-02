@isTest
public class BT_MaterialController_Test {
	
    @isTest
    static void authenticatedUserseatsRemaining() {
        generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', 28601, null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub; 
       BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
        System.runAs(u) {
           BT_MaterialController mc = new BT_MaterialController();
           mc.selectedAppropriate = '';
           mc.selectedDeliveryMethod = '';
           mc.selectedFullClassFilter = ''; 
           mc.getDeliveryMethods();
           mc.getAppropriateFor();
           mc.getIncludeFullClasses();
        } 
    } 
    
    @isTest
    static void authenticatedUserseatsNotRemaining() {
        generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', 28601, null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub; 
       List<BT_Registration__c> registrations = new List<BT_Registration__c>();
       for(Integer i = 0; i < 20; i++) {
       	   BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
           registrations.add(reg);
        }
       insert registrations;
       
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
        System.runAs(u) {
           BT_MaterialController mc = new BT_MaterialController();
           mc.selectedAppropriate = '';
           mc.selectedDeliveryMethod = '';
           mc.selectedFullClassFilter = ''; 
           mc.getDeliveryMethods();
           mc.getAppropriateFor();
           mc.getIncludeFullClasses();
        } 
    }
    
    @isTest
    static void unauthenticatedUser() {
        generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', 28601, null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub; 
       List<BT_Registration__c> registrations = new List<BT_Registration__c>();
       for(Integer i = 0; i < 20; i++) {
       	   BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
           registrations.add(reg);
        }
       insert registrations;
       
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
        System.runAs(new user(Id = UserInfo.getUserId())) {
           BT_MaterialController mc = new BT_MaterialController();
           mc.selectedAppropriate = '';
           mc.selectedDeliveryMethod = '';
           mc.selectedFullClassFilter = ''; 
           mc.getDeliveryMethods();
           mc.getAppropriateFor();
           mc.getIncludeFullClasses();
        } 
    }
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}