public class BT_ClassHistory{
    public string msg { get; set; }
    public list<classesWrapper> finalWrapList;
    //public List<BT_Registration__c > lstRegistration{ get; set; }
    public string classDetailsWrapJson {get; set;}
    public Boolean isAuthenticatedUser {get; set;}
    Integer NoOfDays=210;
    Integer ClsStartTime=21 ;
    public string subscriptionId;
    
    public BT_ClassHistory(){
        
        BT_BaseController baseController = new BT_BaseController();
        subscriptionId = baseController.subscriptionId;
        isAuthenticatedUser = basecontroller.isAuthenticatedUser;
        
        finalWrapList = new list<classesWrapper>();        
        ClassMainMethod('Attended');
        ClassMainMethod('Registered');
        ClassMainMethod('Canceled');
        classDetailsWrapJson = JSON.serialize(finalWrapList);
        
        system.debug('---finalWrapList--'+finalWrapList );
    }
    
    Public void ClassMainMethod(string Status ){
        try{
            
           
            string Registration ='Select Subscription__c,Subscription__r.Name,Schedule__r.Id , Schedule__r.Title__c, Schedule__r.SeatsRemaining__c, Schedule__r.DeliveryMethod__c, Schedule__r.AdditionalDescription__c, Schedule__r.Venue__r.State__c, Schedule__r.Venue__r.City__c, Schedule__r.Venue__r.Street__c, Name, ClassName__c, ClassVenue__c, Duration__c, IsClassActive__c, InstructorName__c, StartTime__c,Status__c From BT_Registration__c Where Subscription__r.Name = \'' + subscriptionId + '\' And Status__c Like \'%' + Status + '%\'';
            
            If(Status == 'Attended' )   {
                Registration += ' And createdDate = LAST_N_DAYS:'+NoOfDays;
            }   
            Else If(Status == 'Registered' ){
                Registration += ' And StartTime__c = NEXT_N_DAYS:'+ClsStartTime;
            }
            Else If(Status == 'Canceled'){
                Registration += ' And createdDate = LAST_N_DAYS:'+NoOfDays;
            }
            
            List<BT_Registration__c> lstRegistration = Database.query(Registration);
            system.debug('---registration--'+ Registration );
            system.debug('---lstRegistration--'+ lstRegistration );
            
            
            if(!lstRegistration .isEmpty()){

                for(BT_Registration__c cl : lstRegistration ){
                    classesWrapper wrapobj = new classesWrapper();
                    wrapobj.classRec = cl;
                    if(cl.StartTime__c != null){
                        
                        string startDateTimeString = cl.StartTime__c.format('MM-dd-yyyy hh:mm a');
                        string endDateTimeString = cl.StartTime__c.addMinutes(integer.valueOf(cl.Duration__c)).format('MM-dd-yyyy hh:mm a');
                        wrapobj.classDate = startDateTimeString.split(' ')[0];
                        wrapobj.classStartTime = startDateTimeString.split(' ')[1]+' '+startDateTimeString.split(' ')[2];
                        wrapobj.classEndTime =  endDateTimeString.split(' ')[1]+' '+endDateTimeString.split(' ')[2];
                        
                    }
                    if(cl.Schedule__r.SeatsRemaining__c == 0)
                        wrapobj.isAvailable = false;
                    else
                        wrapobj.isAvailable = true;
                    
                    if(Status == 'Attended'){
                        wrapobj.upcoming = false;
                    }
                    else if(Status == 'Registered'){
                        wrapobj.upcoming = true;
                    }
                    else{
                        wrapobj.cancelled = true;
                    }          
                    finalWrapList.add(wrapobj);
                    system.debug('---wrapobj--'+wrapobj );
                }
            }
        }
         
        catch(Exception e) {
            msg = 'Exception ' + e.getMessage();
            system.debug('---error msg--'+msg );
         }
    }

        
    class classesWrapper{ 
        public BT_Registration__c classRec {get; set;}
        public string classDate {get; set;}
        public string classStartTime {get; set;}
        public string classEndTime {get; set;}
        public boolean isAvailable {get; set;}
        //public boolean isRegistered {get; set;}
        public boolean upcoming {get; set;}
        public boolean cancelled {get; set;}
    }
}