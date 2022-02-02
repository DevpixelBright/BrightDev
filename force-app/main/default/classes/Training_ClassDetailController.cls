public class Training_ClassDetailController {

    public String state { get; set; }
    public String city { get; set; }
    public String street { get; set; }
 
    public boolean isAuthenticatedUser {set; get;}
    public string subscriptionId {get; set;}
    public String classId {set; get;}
    Training_BaseController basecontroller;
    public String classDetails { get; set; }
   
    
    public Training_ClassDetailController(){
        
        baseController = new Training_BaseController();        
        isAuthenticatedUser = baseController.isAuthenticatedUser;
        subscriptionId = basecontroller.subscriptionId;
        
        string parentURl = ApexPages.currentPage().getHeaders().get('Referer');
        parentUrl = parentUrl.split('classId=').size() > 0 ? parentUrl.split('classId=')[1] : null;
        system.debug('---parentUrl--'+parentUrl);
        classId = parentUrl;
        
        Map<Id, BT_Class__c> classIdDetails = new Map<Id, BT_Class__c>(
                                            [SELECT Id, Name, Capacity__c, Course__c, ExternalRegistationSite__c, HasNoShowFee__c , DeliveryMethod__c, Duration__c, SeatsRemaining__c, 
                                            PostDeliveryRecording__c, StartTime__c, Title__c, IsRegistrationRequired__c, IsActive__c, 
                                            RegistrationDeadline__c, AdditionalDescription__c, 
                                            Venue__c, Venue__r.Name, Venue__r.Street_Number__c, Venue__r.Street_Type__c, Venue__r.Street__c, 
                                            Venue__r.City__c, Venue__r.State__c, Venue__r.Country__c, Venue__r.Venue_Site__c, Venue__r.ZipCode__c, Venue__r.Zip_4__c,
                                            Instructor__r.Contact__r.Name 
                                            FROM   BT_Class__c WHERE Id = :classId

                                            ]);
        System.debug('==='+classIdDetails.size() + ' ====');
        Map<Id, String> classRegistrations = new Map<Id, String>();
        System.debug('isAuthenticatedUser ******** '+ baseController.isAuthenticatedUser);
        
        if(!classIdDetails.isEmpty()) {
            if(baseController.isAuthenticatedUser){
                system.debug('---subscriptionId-->'+subscriptionId);
                for(BT_Registration__c reg : [SELECT Schedule__c, Status__c, Subscription__r.Status__c FROM BT_Registration__c 
                                              WHERE  Schedule__c IN :classIdDetails.keyset()
                                              AND    Subscription__r.Name = :subscriptionId
                                              AND    Status__c IN ('Registered', 'Canceled', 'Attended')                                         
                                             ]) 
                 {
                     system.debug('---reg---'+reg);
                     classRegistrations.put(reg.Schedule__c, reg.Status__c);
                 }
            }        
            
            List<Training_BaseController.ClassDetail> classWrapper = new List<Training_BaseController.ClassDetail>();
            
            system.debug('---classRegistrations--- '+classRegistrations);
            for(BT_Class__c btCls : classIdDetails.values()){
                String registrationStatus = null;
                if(classRegistrations.containskey(btCls.Id) && !classRegistrations.IsEmpty() && btCls.IsActive__c )
                    registrationStatus = classRegistrations.get(btCls.Id);
                
                Training_BaseController.ClassDetail wrap = new Training_BaseController.ClassDetail(btcls, registrationStatus);
                classWrapper.add(wrap);
            }
            
            if(classWrapper.size() == 1) {
                classDetails = JSON.serialize(classWrapper[0]);
                classDetails = Training_BaseController.handleSpecialCharaters(classDetails);
                if(!string.isBlank(classDetails)){
                    street = classWrapper[0].btClass.Venue__r.Street__c;
                    city = classWrapper[0].btClass.Venue__r.City__c;
                    state = classWrapper[0].btClass.Venue__r.State__c;
                }
            }
            system.debug('JSON ----- '+ classDetails);
        }
        else
            classDetails = '';
    }
    
    public void registerClass(){
        string result = baseController.registerClass(classId);
        system.debug('--result-->'+result);
    }
    
    public void cancelClass(){
        string result = baseController.cancelClass(classId);
        system.debug('--result-->'+result);
    }   
    
}