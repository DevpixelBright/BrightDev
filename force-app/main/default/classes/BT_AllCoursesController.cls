public class BT_AllCoursesController {
    
    public String coursesjson {set; get;}
    public String subscriptionId {set; get;}
    public Boolean isAuthenticatedUser {get; set;}
    BT_BaseController baseController;
    
    public BT_AllCoursesController() {
        
        baseController = new BT_BaseController();
        isAuthenticatedUser = baseController.isAuthenticatedUser;
               
        List<BT_Course__c> courses = [SELECT Id, AppropriateFor__c, AvailableDeliveryMethods__c, Description__c, Image__c,
                                             Duration__c, IsActive__c, Title__c 
                                      FROM   BT_Course__c
                                      WHERE  IsActive__c = true
                                     ];
        
        coursesjson = JSON.serialize(courses);
    }

}