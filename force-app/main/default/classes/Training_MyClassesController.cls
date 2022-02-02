public class Training_MyClassesController{  
    public String msg { get; set; }
    
    public String classDetailsWrapJson {get; set;}
    Integer eighteenMonths = 540;
    Integer threeWeeks = 21;
    
    public String subscriptionId {set; get;}
    public Boolean isAuthenticatedUser {get; set;}
    
    Training_BaseController baseController;    
    List<MyClassDetail> myClassDetails;
    
    public Training_MyClassesController(){
        
        isAuthenticatedUser = false;
        baseController = new Training_BaseController();
        isAuthenticatedUser = baseController.isAuthenticatedUser; 
        subscriptionId = baseController.subscriptionId;
        
        myClassDetails = new List<MyClassDetail>();
        
        ClassMainMethod('Attended');
        ClassMainMethod('Registered');
        ClassMainMethod('Canceled');
        
        classDetailsWrapJson = JSON.serialize(myClassDetails);
        classDetailsWrapJson = Training_BaseController.handleSpecialCharaters(classDetailsWrapJson);
        
        system.debug('---classDetails--'+ myClassDetails );
    }
    
    Public void ClassMainMethod(String registrationStatus){
        try{
            
            String subId = Apexpages.currentpage().getParameters().get('subId');  
            String registrationQuery ='SELECT Subscription__c, Schedule__c FROM BT_Registration__c WHERE Subscription__r.Name = \'' + subscriptionId + '\'  And Status__c LIKE \'%' + registrationStatus + '%\'';
            Boolean isUpcoming = false;
            Boolean isCancelled = false;
            Boolean isCompleted = false;
            
            if(registrationStatus == 'Attended' )   {
                system.debug('RegStatus Attended' + registrationStatus);
                registrationQuery += 'And StartTime__c <= Today';
                isCompleted = true;
            }   
            else if(registrationStatus == 'Registered' ){
                 system.debug('RegStatus Registered' + registrationStatus);
                registrationQuery += 'And StartTime__c >= Today';  
                isUpcoming = true;
            }
            else if(registrationStatus == 'Canceled'){
                isCancelled = true;
            }
              system.debug('---registrationQuery--'+ registrationQuery );
            List<BT_Registration__c> registrations = Database.query(registrationQuery);
            system.debug('---registrationQuery--'+ registrationQuery );
            system.debug('---registrations--'+ registrations ); 
            
            List<String> classIds = new List<String>();           
            
            if(!registrations.isEmpty()){
                for(BT_Registration__c registration : registrations ){                            
                    classIds.add(registration.Schedule__c);        
                }
                
                for(BT_Class__c btCls :  [SELECT Id, Name, Capacity__c, Course__c, DeliveryMethod__c, Duration__c, SeatsRemaining__c, 
                                          StartTime__c, Title__c, IsRegistrationRequired__c, IsActive__c, RegistrationDeadline__c, 
                                          AdditionalDescription__c, PostDeliveryRecording__c, 
                                          Venue__c, Venue__r.Name, Venue__r.Street_Number__c, Venue__r.Street_Type__c, Venue__r.Street__c, Venue__r.City__c, 
                                          Venue__r.State__c, Venue__r.Country__c, Venue__r.Venue_Site__c, Venue__r.ZipCode__c, Venue__r.Zip_4__c 
                                          FROM   BT_Class__c WHERE Id IN :classIds
                                          ORDER BY StartTime__c ASC
                                         ]){
                                             
                                             Training_BaseController.ClassDetail classDetail = new Training_BaseController.ClassDetail(btcls, registrationStatus);
                                             MyClassDetail detail = new MyClassDetail();
                                             detail.classDetail = classDetail;
                                             detail.isUpcoming = isUpcoming;
                                             detail.isCancelled = isCancelled;
                                             detail.isCompleted = isCompleted;
                                             myClassDetails.add(detail);
                                         }
            }           
        }
        
        catch(Exception e) {
            msg = '****Exception ' + e.getMessage() + e.getStackTraceString();
            system.debug('---error msg--'+msg );
        }
    } 
    
    class MyClassDetail{
        Training_BaseController.ClassDetail classDetail;
        Boolean isUpcoming;
        Boolean isCancelled;
        Boolean isCompleted;
    }
    
}