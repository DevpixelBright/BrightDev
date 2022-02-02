public class Training_AllCoursesController {
    public String coursesjson {set; get;}
    public Boolean isAuthenticatedUser {get; set;}
    Training_BaseController baseController;
    
    public Training_AllCoursesController() {
        
        baseController = new Training_BaseController();
        isAuthenticatedUser = baseController.isAuthenticatedUser;
        
        List<BT_Course__c> courseList = new list<BT_Course__c>();
        
        for(BT_Course__c course : [SELECT Id, AppropriateFor__c, AvailableDeliveryMethods__c, Description__c, Image__c,
                                      Duration__c, IsActive__c, Title__c,
                                      (SELECT Id FROM Classes__r WHERE isActive__c = true AND StartTime__c  >= Today)
                                      FROM   BT_Course__c
                                      WHERE  IsActive__c = true
                                      Order by Title__c
                                  ])
        {
            if(course.Classes__r != null && !course.Classes__r.isEmpty()){
                courseList.add(course);
            }
        }
        
        coursesjson = JSON.serialize(courseList);
        coursesjson = Training_BaseController.handleSpecialCharaters(coursesjson);
        system.debug('---coursesjson--->'+coursesjson);
        courseList.clear();
    }
}