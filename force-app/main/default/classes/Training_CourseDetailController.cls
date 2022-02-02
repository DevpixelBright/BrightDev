public class Training_CourseDetailController {
    public BT_Course__c course {set; get;}
    public String courseClassesjson {set; get;}
    public string subscriptionId {get; set;}
    Training_BaseController baseController;
    public boolean isAuthenticatedUser {get; set;}
    public string courseId;
    public string courseRecordJson {get; set;}
    public Training_CourseDetailController () {

        
        string parentURl = ApexPages.currentPage().getHeaders().get('Referer');
        system.debug('---parentUrl--'+parentUrl+'---'+parentUrl.split('courseId='));
        parentUrl = parentUrl.split('courseId=').size() > 0 ? parentUrl.split('courseId=')[1] : null;
        system.debug('---parentUrl--'+parentUrl);
        
        courseId = parentUrl;
        
        baseController = new Training_BaseController();        
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
        courseRecordJson = Training_BaseController.handleSpecialCharaters(courseRecordJson);
        
        Map<Id, BT_Class__c> classIdDetails = new Map<Id, BT_Class__c>(
                                                  [SELECT Id, Name, Capacity__c, Course__c, DeliveryMethod__c, HasNoShowFee__c, ExternalRegistationSite__c, Duration__c, SeatsRemaining__c, PostDeliveryRecording__c, 
                                                          StartTime__c, Title__c, IsRegistrationRequired__c, IsActive__c, RegistrationDeadline__c, AdditionalDescription__c, 
                                                          Venue__c, Venue__r.Name, Venue__r.Street_Number__c, Venue__r.Street_Type__c, Venue__r.Street__c, 
                                                          Venue__r.City__c, Venue__r.State__c, Venue__r.Country__c, Venue__r.Venue_Site__c, Venue__r.ZipCode__c, Venue__r.Zip_4__c
                                                   FROM   BT_Class__c WHERE Course__c = :courseId
                                                   AND    isActive__c = true 
                                                   AND    StartTime__c  >= Today
                                                   ORDER BY StartTime__c ASC
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
        
        List<Training_BaseController.ClassDetail> classDetails = new List<Training_BaseController.ClassDetail>();
        
        system.debug('---classRegistrations---'+classRegistrations);
        for(BT_Class__c btCls : classIdDetails.values()){
            String registrationStatus = null;
            if(classRegistrations.containskey(btCls.Id))
                registrationStatus = classRegistrations.get(btCls.Id);
            
            system.debug('---registrationStatus--->'+registrationStatus+'---'+btCls.Id);
            Training_BaseController.ClassDetail classDetail = new Training_BaseController.ClassDetail(btcls, registrationStatus);
            
            if(btcls.Venue__r.name != null)
                classDetail.venueAddress = btcls.Venue__r.name+', ';
            if(btcls.Venue__r.Street__c != null)
                classDetail.venueAddress += btcls.Venue__r.Street__c+', ';
            if(btcls.Venue__r.City__c != null)
                classDetail.venueAddress += btcls.Venue__r.City__c+', ';
            if(btcls.Venue__r.State__c != null)
                classDetail.venueAddress += btcls.Venue__r.State__c;
            
            classDetail.venueAddress = classDetail.venueAddress.endsWith(', ') ? classDetail.venueAddress.removeEnd(', ') : classDetail.venueAddress;
            classDetails.add(classDetail);
        }
        system.debug('---classDetails-->'+classDetails);
        courseClassesjson = JSON.serialize(classDetails);
        courseClassesjson = Training_BaseController.handleSpecialCharaters(courseClassesjson);
        system.debug('---courseClassesjson--->'+courseClassesjson);
    }
    
    public void registerClass(){
        String classId = ApexPages.currentPage().getParameters().get('classId');
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