public class BT_CourseDetailsController {
    public BT_Course__c course {set; get;}
    public String courseClassesjson {set; get;}
    public string subscriptionId {get; set;}
    BT_BaseController baseController;
    public boolean isAuthenticatedUser {get; set;}
    public string courseId;
    public string courseRecordJson {get; set;}
    public BT_CourseDetailsController () {

        
        string parentURl = ApexPages.currentPage().getHeaders().get('Referer');
        system.debug('---parentUrl--'+parentUrl+'---'+parentUrl.split('courseId='));
        parentUrl = parentUrl.split('courseId=').size() > 0 ? parentUrl.split('courseId=')[1] : null;
        system.debug('---parentUrl--'+parentUrl);
        
        courseId = parentUrl;
        
        baseController = new BT_BaseController();        
        isAuthenticatedUser = baseController.isAuthenticatedUser;
        
        List<BT_Course__c> courses = [SELECT Id, AppropriateFor__c, AvailableDeliveryMethods__c, Description__c, Image__c,
                                             Duration__c, IsActive__c, Title__c
                                      FROM   BT_Course__c WHERE Id = :courseId
                                     ];
        if(courses.size() == 0)
            return;
        course = courses[0];
        system.debug('---course--->'+course);
        courseRecordJson = JSON.serialize(course); 
        
        Map<Id, BT_Class__c> classIdDetails = new Map<Id, BT_Class__c>(
                                                  [SELECT Id, Name, Capacity__c, Course__c, DeliveryMethod__c, Duration__c, SeatsRemaining__c, PostDeliveryRecording__c, 
                                                          StartTime__c, Title__c, IsRegistrationRequired__c, IsActive__c, RegistrationDeadline__c, 
                                                          AdditionalDescription__c, Venue__r.State__c, Venue__r.City__c, Venue__r.Street__c 
                                                   FROM   BT_Class__c WHERE Course__c = :courseId
                                                   AND    isActive__c = true
                                                  ]);
        
        Map<Id, String> classRegistrations = new Map<Id, String>();
       
        if(baseController.isAuthenticatedUser){
            for(BT_Registration__c reg : [SELECT Schedule__c, Status__c, Subscription__r.Status__c FROM BT_Registration__c 
                                          WHERE  Schedule__c IN :classIdDetails.keyset()
                                          AND    Subscription__r.Name = :baseController.subscriptionId
                                          AND    Status__c IN ('Registered', 'Canceled')                                         
                                         ]) {
                classRegistrations.put(reg.Schedule__c, reg.Status__c);
            }
        }        
        
        List<BT_BaseController.ClassDetail> classDetails = new List<BT_BaseController.ClassDetail>();
        
        system.debug('---classRegistrations---'+classRegistrations);
        for(BT_Class__c btCls : classIdDetails.values()){
            String registrationStatus = null;
            if(classRegistrations.containskey(btCls.Id))
                registrationStatus = classRegistrations.get(btCls.Id);
            
            system.debug('---registrationStatus--->'+registrationStatus+'---'+btCls.Id);
            BT_BaseController.ClassDetail classDetail = new BT_BaseController.ClassDetail(btcls, registrationStatus);
            classDetails.add(classDetail);
        }
        system.debug('---classDetails-->'+classDetails);
        courseClassesjson = JSON.serialize(classDetails);      
        
    }    
    
    public void registerClass(){
        String classId = ApexPages.currentPage().getParameters().get('classId');
        system.debug('-classId--'+classId);
        string result = baseController.registerClass(classId);
        system.debug('--result-->'+result);           
    }
    
    public void cancelClass(){
        
        String classId = ApexPages.currentPage().getParameters().get('classId');
        system.debug('-classId--'+classId+'---courseId--'+courseId);
        string result = baseController.cancelClass(classId);
        system.debug('--result-->'+result);
    }   
    
}