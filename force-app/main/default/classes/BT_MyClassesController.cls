public class BT_MyClassesController{
    public String msg { get; set; }
   
    public String classDetailsWrapJson {get; set;}
    Integer eighteenMonths = 540;
    Integer threeWeeks = 21;
    
    public String subscriptionId {set; get;}
    public Boolean isAuthenticatedUser {get; set;}
    
    BT_BaseController baseController;    
    List<MyClassDetail> myClassDetails;
    
    public BT_MyClassesController(){
        
        isAuthenticatedUser = false;
        baseController = new BT_BaseController();
        isAuthenticatedUser = baseController.isAuthenticatedUser; 
        subscriptionId = baseController.subscriptionId;
        
        myClassDetails = new List<MyClassDetail>();
        
        ClassMainMethod('Attended');
        ClassMainMethod('Registered');
        ClassMainMethod('Canceled');
        
        classDetailsWrapJson = JSON.serialize(myClassDetails);
        
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
                registrationQuery += ' And CreatedDate = LAST_N_DAYS:' + eighteenMonths;
                isCompleted = true;
            }   
            else if(registrationStatus == 'Registered' ){
                registrationQuery += ' And StartTime__c = NEXT_N_DAYS:' + threeWeeks;
                isUpcoming = true;
            }
            else if(registrationStatus == 'Canceled'){
                registrationQuery += ' And CreatedDate = LAST_N_DAYS:' + eighteenMonths;
                isCancelled = true;
            }
            
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
                                                  AdditionalDescription__c, Venue__r.Name, Venue__r.State__c, Venue__r.City__c, Venue__r.Street__c, PostDeliveryRecording__c  
                                           FROM   BT_Class__c WHERE Id IN :classIds
                                           ]){
                                           
                    BT_BaseController.ClassDetail classDetail = new BT_BaseController.ClassDetail(btcls, registrationStatus);
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
        BT_BaseController.ClassDetail classDetail;
        Boolean isUpcoming;
        Boolean isCancelled;
        Boolean isCompleted;
    }
    
}