public class Communities_MyAccount_Controller{
    
    public String subscriptionId { get; set; }    
    public Subscriptions__c subscription { get; set; }
    public Boolean isEdit { get; set; }
    public String displayName { get; set; }
    public Boolean isTrendSubscriber { get; set; } 
    
    public String QASTypedownSessionToken {get; private set;}
    //public String newValue {set; get;}
    public String newLoginName { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String middleName { get; set; }
    public String caseNumber { get; set; }
    public String subName { get; set; }
    public String loginErrorMessage { get; set; }
    public Boolean isLoginNameAvailable { get; set; }  
    public Boolean ifCaseExists {get; set;}
    public list<Case> lCase {get;set;}
    
    public  Communities_MyAccount_Controller() {
        
        QAS_NA__QAS_CA_Account__c [] accountSObject = [SELECT QAS_NA__ValidationSessionToken__c FROM QAS_NA__QAS_CA_Account__c];        
        if(accountSObject != null && accountSObject.size() > 0)        
            QASTypedownSessionToken = accountSObject[0].QAS_NA__ValidationSessionToken__c;                
        subscriptionId = System.currentPageReference().getParameters().get('id');      
        system.debug('********************* subscriptionid**************'+subscriptionId);
        if(String.isBlank(subscriptionId))
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Subscription id is null'));
        
        else
        subscriptionDetails();
        ifCaseExists = false;
        isEdit = false;
        isTrendSubscriber = false;
        loginErrorMessage = ''; 
        isLoginNameAvailable = false;
    }
    
    public void subscriptionDetails() {
        subscription = new Subscriptions__c();
        subscription = [
            SELECT  
                Name,
                id,
                Primary_Phone__c,
                Pager__c,
                Fax__c,
                Voicemail__c,
                VM_Ext__c,
                Mobile_Phone__c,
                Home_Fax__c,
                Agent_Office_Phone__c,
                Website__c,
                Public_Email__c,
                Private_Email__c,
                Alternate_Private_Email__c,
                NRDS_ID__c,
                Primary__c,
                Service_Jurisdiction__c,
                TREND_Login_Name__c,
                Home_phone__c,
                BRIGHT_LoginName__c,
                JobTitle__c,
                
                Contact__c,
                Contact__r.Salutation,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Title,
                Contact__r.Middle_Name__c,
                Contact__r.Suffix__c,
                Contact__r.Nickname__c,
                Contact__r.PreferredName__c,
                Contact__r.PreferredFirstName__c,
                Contact__r.PreferredLastName__c,
                Contact__r.Website__c,
                
                QAS_Validation_Status__c,
                QAS_Validation_Timestamp__c,
                QAS_Mailing_Record_Type__c,
                
                Street_Type__c,
                Street_Direction__c,
                Unit_Type__c,
                County__c,
                QAS_Mailing_Country__c,
                QAS_Billing_Country__c,
                QAS_Billing_Record_Type__c,
                Billing_County__c,
                Billing_Street_Direction__c,
                Billing_Street_Type__c,
                Billing_Unit_Type__c,
                
                Street_Number__c,
                Street_Number_Suffix__c, 
                Street_Name__c, 
                QAS_Mailing_Street_Type__c,
                QAS_Mailing_Street_Direction__c,
                QAS_Mailing_Unit_Type__c,
                Unit__c,
                City__c,
                State__c,
                Zip__c,
                Zip_4__c,
                Country__c,
                QAS_Mailing_POBox__c,
                Addl_Display_Name__c,
                QAS_Mailing_County__c,
                
                Billing_Street_Number__c,
                Billing_Street_Suffix__c, 
                Billing_Street_Name__c, 
                QAS_Billing_Street_Type__c,
                QAS_Billing_Street_Direction__c,
                QAS_Billing_Unit_Type__c,
                Billing_Unit_Number__c,
                Billing_City__c,
                Billing_State__c,
                Billing_Zip__c,
                Billing_Zip_4__c,
                Billing_Country__c,
                Billing_Box__c,
                Billing_Addl_Display_Name__c,
                QAS_Billing_County__c
            FROM    Subscriptions__c 
            WHERE   Name = :subscriptionId
        ];
        
        if(subscription.Service_Jurisdiction__c != null && subscription.Service_Jurisdiction__c == 'TREND' && subscription.TREND_Login_Name__c != null) {
            displayName = 'TREND: ' + subscription.TREND_Login_Name__c + ' - ' + subscription.Name;
            isTrendSubscriber = true;
            newLoginName = subscription.TREND_Login_Name__c;
            system.debug('n1 name-->'+newLoginName);
        }
       else if(subscription.Service_Jurisdiction__c != null && subscription.Service_Jurisdiction__c == 'BRIGHT' && subscription.BRIGHT_LoginName__c != null) {
            displayName = 'BRIGHT: ' + subscription.BRIGHT_LoginName__c + ' - ' + subscription.Name;
            isTrendSubscriber = true;
            newLoginName = subscription.BRIGHT_LoginName__c;
           system.debug('n login name-->'+newLoginName);
        }
        else
            displayName = subscription.Name;   
        system.debug('d name-->'+displayName);
    }
    
    public void fetchCases() {
        List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Processing'];
        User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        List<Case>lCase = new List<Case>();
        lCase = [SELECT Id,CaseNumber, First_Name__c, Last_Name__c,Subscription_ID__c, Middle_Name__c, ContactId, OwnerId, Status
                 FROM   Case 
                 WHERE (Status != 'Approved' 
                 AND Status != 'Denied') 
                 AND Subject = 'Request Name Update' 
                 AND ContactId =: u.ContactId 
                 AND OwnerId=:queueIds[0].Id
                ];
        system.debug('*****CASESSSSSSSS******'+lCase);

        if(lCase.size()>0){
            caseNumber = lCase[0].CaseNumber;
            firstName = lCase[0].First_Name__c;
            lastName = lCase[0].Last_Name__c;
            middleName = lCase[0].Middle_Name__c;
			ifCaseExists = true;
        }
    }
    
    public void reset() {
        subscriptionDetails();
        //isEdit = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The Page has been Reset'));
    }    
    
    public void cancel(){
        subscriptionDetails();
        isEdit = false;
        /*PageReference subscriptionPage = ApexPages.currentPage();
        subscriptionPage.getParameters().put('id', subscriptionId);
        return subscriptionPage;*/
    }
    
    public void edit(){
        isEdit = true;
    }        
    
    public void validateLoginName() {
        
        //newLoginName; // = ApexPages.currentPage().getParameters().get('newLoginName');
        isLoginNameAvailable = false;
        try{           
            if(String.isBlank(newLoginName))
                throw new CustomException('Please enter Login Name');
                
            LoginName.isAvailable(subscription.Id, newLoginName);
            isLoginNameAvailable = true; 
            loginErrorMessage = 'Available';
                      
        }
        catch(Exception e){
            isLoginNameAvailable = false; 
            loginErrorMessage = e.getMessage();
        }
        system.debug('---isLoginNameAvailable-->'+isLoginNameAvailable);
    }
    
    public PageReference save() {
       
        system.debug('-- newLoginName--'+ newLoginName+'---isLoginNameAvailable--->'+isLoginNameAvailable);
        Boolean error = false;
        String commonError = 'The required field is missing:  ';
        
        if(subscription.QAS_Mailing_County__c == 'DISTRICT OF COLUMBIA')
            subscription.County__c = 'WASHINGTON';        
        else        
            subscription.County__c = subscription.QAS_Mailing_County__c;
        
        if (null != subscription.Addl_Display_Name__c) 
            subscription.QAS_Mailing_Record_Type__c = 'P';        
        
        //Street Direction Update
        
        if(subscription.QAS_Mailing_Street_Direction__c == NULL)
        {
            subscription.Street_Direction__c = '';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'N')
        {
            subscription.Street_Direction__c = 'N, NORTH';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'E')
        {
            subscription.Street_Direction__c = 'E, EAST';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'S')
        {
            subscription.Street_Direction__c = 'S, SOUTH';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'W')
        {
            subscription.Street_Direction__c = 'W, WEST';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'NE')
        {
            subscription.Street_Direction__c = 'NE, NORTHEAST';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'SE')
        {
            subscription.Street_Direction__c = 'SE, SOUTHEAST';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'NW')
        {
            subscription.Street_Direction__c = 'NW, NORTHWEST';
        }
        if(subscription.QAS_Mailing_Street_Direction__c == 'SW')
        {
            subscription.Street_Direction__c = 'SW, SOUTHWEST';
        }
        
        //Street Type Update
        if(subscription.QAS_Mailing_Street_Type__c == 'BLFS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }      
        if(subscription.QAS_Mailing_Street_Type__c == 'BRKS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BGS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CTRS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CIRS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CLF') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CMNS')                                                   
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CVS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'DRS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'EXTS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }                                
        if(subscription.QAS_Mailing_Street_Type__c == 'FLT') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }    
        if(subscription.QAS_Mailing_Street_Type__c == 'FRDS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRGS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GDN')                                                   
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GLNS') 
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GRNS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GRVS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'HBRS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'JCTS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LGTS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LF')                                                   
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MNRS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MTWY')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'OPAS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PARK')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PKWY')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PNE')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PTS')                                                   
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PRTS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RAMP')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RPD')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RDGS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RDS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RUE')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SKWY')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SPUR')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SQS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRWY')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRAK')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRFY')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'UPAS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'UNS')                                                   
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VLYS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VLGS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WALK')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WAYS')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WL')
        {
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == NULL)
        {
            subscription.Street_Type__c = '';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ST')
        {
            subscription.Street_Type__c = 'STREET, ST';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ALY')
        {
            subscription.Street_Type__c = 'ALLEY, ALY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ANX')
        {
            subscription.Street_Type__c = 'ANNEX, ANX';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ARC')
        {
            subscription.Street_Type__c = 'ARCADE, ARC';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'AVE')
        {
            subscription.Street_Type__c = 'AVENUE, AVE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BYU')
        {
            subscription.Street_Type__c = 'BAYOU, BYU';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BCH ')
        {
            subscription.Street_Type__c = 'BEACH, BCH';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BLF ')
        {
            subscription.Street_Type__c = 'BLUFF, BLF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BTM')
        {
            subscription.Street_Type__c = 'BOTTOM, BTM';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BLVD')
        {
            subscription.Street_Type__c = 'BOULEVARD, BLVD';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BR')
        {
            subscription.Street_Type__c = 'BRANCH, BR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BRG')
        {
            subscription.Street_Type__c = 'BRIDGE, BRG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BRK')
        {
            subscription.Street_Type__c = 'BROOK, BRK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BG')
        {
            subscription.Street_Type__c = 'BURG, BG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BYP')
        {
            subscription.Street_Type__c = 'BYPASS, BYP';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CP')
        {
            subscription.Street_Type__c = 'CAMP, CP';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CYN')
        {
            subscription.Street_Type__c = 'CANYON, CYN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CPE')
        {
            subscription.Street_Type__c = 'CAPE, CPE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CSWY')
        {
            subscription.Street_Type__c = 'CAUSEWAY, CSWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CTR')
        {
            subscription.Street_Type__c = 'CENTER, CTR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CIR')
        {
            subscription.Street_Type__c = 'CIRCLE, CIR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CLFS')
        {
            subscription.Street_Type__c = 'CLIFFS, CLFS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CLB')
        {
            subscription.Street_Type__c = 'CLUB, CLB';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CMN')
        {
            subscription.Street_Type__c = 'COMMON, COM';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'COR')
        {
            subscription.Street_Type__c = 'CORNER, COR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CORS')
        {
            subscription.Street_Type__c = 'CORNERS, CORS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CRSE')
        {
            subscription.Street_Type__c = 'COURSE, CRSE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CT')
        {
            subscription.Street_Type__c = 'COURT, CT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CTS')
        {
            subscription.Street_Type__c = 'COURTS, CTS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CV')
        {
            subscription.Street_Type__c = 'COVE, CV';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CRK')
        {
            subscription.Street_Type__c = 'CREEK, CRK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CRES')
        {
            subscription.Street_Type__c = 'CRESCENT, CRES';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'XING')
        {
            subscription.Street_Type__c = 'CROSSING, XING';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'XRD')
        {
            subscription.Street_Type__c = 'CROSSROAD, XRD';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'XRDS')
        {
            subscription.Street_Type__c = 'CROSSROADS, XRDS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CURV')
        {
            subscription.Street_Type__c = 'CURVE, CURV';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'DL')
        {
            subscription.Street_Type__c = 'DALE, DL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'DM')
        {
            subscription.Street_Type__c = 'DAM, DM';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'DV')
        {
            subscription.Street_Type__c = 'DIVIDE, DV';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'DR')
        {
            subscription.Street_Type__c = 'DRIVE, DR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'EST')
        {
            subscription.Street_Type__c = 'ESTATE, EST';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ESTS')
        {
            subscription.Street_Type__c = 'ESTATES, ESTS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'EXPY')
        {
            subscription.Street_Type__c = 'EXPRESSWAY, EXPY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'EXT')
        {
            subscription.Street_Type__c = 'EXTENSION, EXT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FALL')
        {
            subscription.Street_Type__c = 'FALL, FL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FLS')
        {
            subscription.Street_Type__c = 'FALLS, FLS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRY')
        {
            subscription.Street_Type__c = 'FERRY, FRY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FLD')
        {
            subscription.Street_Type__c = 'FIELD, FLD';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FLDS')
        {
            subscription.Street_Type__c = 'FIELDS, FLDS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FLTS')
        {
            subscription.Street_Type__c = 'FLATS, FLT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRD')
        {
            subscription.Street_Type__c = 'FORD, FRD';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRST')
        {
            subscription.Street_Type__c = 'FOREST, FRST';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRG')
        {
            subscription.Street_Type__c = 'FORGE, FRG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRK')
        {
            subscription.Street_Type__c = 'FORK, FRK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRKS')
        {
            subscription.Street_Type__c = 'FORKS, FRKS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FT')
        {
            subscription.Street_Type__c = 'FORT, FT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FWY')
        {
            subscription.Street_Type__c = 'FREEWAY, FWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GDNS')
        {
            subscription.Street_Type__c = 'GARDENS, GDNS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GTWY')
        {
            subscription.Street_Type__c = 'GATEWAY, GTWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GLN')
        {
            subscription.Street_Type__c = 'GLEN, GLN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GRN')
        {
            subscription.Street_Type__c = 'GREEN, GRN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GRV')
        {
            subscription.Street_Type__c = 'GROVE, GRV';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'HBR')
        {
            subscription.Street_Type__c = 'HARBOR, HBR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'HVN')
        {
            subscription.Street_Type__c = 'HAVEN, HVN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'HTS')
        {
            subscription.Street_Type__c = 'HEIGHTS, HTS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'HWY')
        {
            subscription.Street_Type__c = 'HIGHWAY, HWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'HOLW')
        {
            subscription.Street_Type__c = 'HOLLOW, HOLW';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'INLT')
        {
            subscription.Street_Type__c = 'INLET, INLT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'IS')
        {
            subscription.Street_Type__c = 'ISLAND, ISL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ISS')
        {
            subscription.Street_Type__c = 'ISLANDS, ISS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ISLE')
        {
            subscription.Street_Type__c = 'ISLE, ISLE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'JCT')
        {
            subscription.Street_Type__c = 'JUNCTION, JCT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'KY')
        {
            subscription.Street_Type__c = 'KEY, KY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'KYS')
        {
            subscription.Street_Type__c = 'KEYS, KYS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'KNL')
        {
            subscription.Street_Type__c = 'KNOLL, KNL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'KNLS')
        {
            subscription.Street_Type__c = 'KNOLLS, KNLS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LK')
        {
            subscription.Street_Type__c = 'LAKE, LK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LKS')
        {
            subscription.Street_Type__c = 'LAKES, LKS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LAND')
        {
            subscription.Street_Type__c = 'LAND, LAND';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LNDG')
        {
            subscription.Street_Type__c = 'LANDING, LNDG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LN')
        {
            subscription.Street_Type__c = 'LANE, LN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LGT')
        {
            subscription.Street_Type__c = 'LIGHT, LGT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LCK')
        {
            subscription.Street_Type__c = 'LOCK, LCK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LCKS')
        {
            subscription.Street_Type__c = 'LOCKS, LCKS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LDG')
        {
            subscription.Street_Type__c = 'LODGE, LDG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LOOP')
        {
            subscription.Street_Type__c = 'LOOP, LOOP';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MALL')
        {
            subscription.Street_Type__c = 'MALL, MALL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MNR')
        {
            subscription.Street_Type__c = 'MANOR, MNR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MDW')
        {
            subscription.Street_Type__c = 'MEADOW, MDW';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MDWS')
        {
            subscription.Street_Type__c = 'MEADOWS, MDWS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MEWS')
        {
            subscription.Street_Type__c = 'MEWS, MEWS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ML')
        {
            subscription.Street_Type__c = 'MILL, ML';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MLS')
        {
            subscription.Street_Type__c = 'MILLS, MLS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MSN')
        {
            subscription.Street_Type__c = 'MISSION, MSN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MT')
        {
            subscription.Street_Type__c = 'MOUNT, MT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MTN')
        {
            subscription.Street_Type__c = 'MOUNTAIN, MTN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MTNS')
        {
            subscription.Street_Type__c = 'MOUNTAINS, MTNS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'NCK')
        {
            subscription.Street_Type__c = 'NECK, NCK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ORCH')
        {
            subscription.Street_Type__c = 'ORCHARD, ORCHT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'OVAL')
        {
            subscription.Street_Type__c = 'OVAL, OVAL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PARK')
        {
            subscription.Street_Type__c = 'PARK, PARK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PKWY')
        {
            subscription.Street_Type__c = 'PARKWAY, PKWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PASS')
        {
            subscription.Street_Type__c = 'PASS, PASS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PSGE')
        {
            subscription.Street_Type__c = 'PASSAGE, PSGE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PATH')
        {
            subscription.Street_Type__c = 'PATH, PATH';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PIKE')
        {
            subscription.Street_Type__c = 'PIKE, PIKE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PNES')
        {
            subscription.Street_Type__c = 'PINES, PNES';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PL')
        {
            subscription.Street_Type__c = 'PLACE, PL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PLN')
        {
            subscription.Street_Type__c = 'PLAIN, PLN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PLNS')
        {
            subscription.Street_Type__c = 'PLAINS, PLNS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PLZ')
        {
            subscription.Street_Type__c = 'PLAZA, PLZ';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PT')
        {
            subscription.Street_Type__c = 'POINT, PT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PRT')
        {
            subscription.Street_Type__c = 'PORT, PRT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PR')
        {
            subscription.Street_Type__c = 'PRAIRIE, PR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RADL')
        {
            subscription.Street_Type__c = 'RADIAL, RADL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RNCH')
        {
            subscription.Street_Type__c = 'RANCH, RNCH';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RPDS')
        {
            subscription.Street_Type__c = 'RAPIDS, RPDS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RST')
        {
            subscription.Street_Type__c = 'REST, RST';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RDG')
        {
            subscription.Street_Type__c = 'RIDGE, RDG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RIV')
        {
            subscription.Street_Type__c = 'RIVER, RIV';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RD')
        {
            subscription.Street_Type__c = 'ROAD, RD';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RTE')
        {
            subscription.Street_Type__c = 'ROUTE, RTE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'ROW')
        {
            subscription.Street_Type__c = 'ROW, ROW';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RUN')
        {
            subscription.Street_Type__c = 'RUN, RUN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SHL')
        {
            subscription.Street_Type__c = 'SHOAL, SHL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SHLS')
        {
            subscription.Street_Type__c = 'SHOALS, SHLS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SHR')
        {
            subscription.Street_Type__c = 'SHORE, SHR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SPG')
        {
            subscription.Street_Type__c = 'SPRING, SPG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SPGS')
        {
            subscription.Street_Type__c = 'SPRINGS, SPGS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SPUR')
        {
            subscription.Street_Type__c = 'SPUR, SPUR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SQ')
        {
            subscription.Street_Type__c = 'SQUARE, SQ';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'STA')
        {
            subscription.Street_Type__c = 'STATION, STA';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'STRA')
        {
            subscription.Street_Type__c = 'STRAVENUE, STV';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'STRM')
        {
            subscription.Street_Type__c = 'STREAM, STRM';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'STS')
        {
            subscription.Street_Type__c = 'STREETS, STS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SMT')
        {
            subscription.Street_Type__c = 'SUMMIT, SMT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TER')
        {
            subscription.Street_Type__c = 'TERRACE, TER';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRCE')
        {
            subscription.Street_Type__c = 'TRACE, TRCE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRL')
        {
            subscription.Street_Type__c = 'TRAIL, TRL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRLR')
        {
            subscription.Street_Type__c = 'TRAILER, TRLR';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TUNL')
        {
            subscription.Street_Type__c = 'TUNNEL, TUNL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TPKE')
        {
            subscription.Street_Type__c = 'TURNPIKE, TPKE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'UN')
        {
            subscription.Street_Type__c = 'UNION, UN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VLY')
        {
            subscription.Street_Type__c = 'VALLEY, VLY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VIA')
        {
            subscription.Street_Type__c = 'VIADUCT, VIA';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VW')
        {
            subscription.Street_Type__c = 'VIEWS, VWS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VLG')
        {
            subscription.Street_Type__c = 'VILLAGE, VLG';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VL')
        {
            subscription.Street_Type__c = 'VILLE, VL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VIS')
        {
            subscription.Street_Type__c = 'VISTA, VIS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WALK')
        {
            subscription.Street_Type__c = 'WALK, WALK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WALL')
        {
            subscription.Street_Type__c = 'WALL, WL';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WAY')
        {
            subscription.Street_Type__c = 'WAY, WAY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WLS')
        {
            subscription.Street_Type__c = 'WELLS, WLS';
        }  
        if(subscription.QAS_Mailing_Street_Type__c == 'BLFS')
        {
            subscription.Street_Type__c = 'BLUFFS, BLFS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BRKS')
        {
            subscription.Street_Type__c = 'BROOKS, BRKS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'BGS')
        {
            subscription.Street_Type__c = 'BURGS, BGS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CTRS')
        {
            subscription.Street_Type__c = 'CENTERS, CTRS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CIRS')
        {
            subscription.Street_Type__c = 'CIRCLES, CIRS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CLF')
        {
            subscription.Street_Type__c = 'CLIFF, CLF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CMNS')
        {
            subscription.Street_Type__c = 'COMMONS, CMNS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'CVS')
        {
            subscription.Street_Type__c = 'COVES, CVS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'DRS')
        {
            subscription.Street_Type__c = 'DRIVES, DRS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'EXTS')
        {
            subscription.Street_Type__c = 'EXTENSIONS, EXTS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FLT')
        {
            subscription.Street_Type__c = 'FLAT, FLT';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRDS')
        {
            subscription.Street_Type__c = 'FORDS, FRDS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'FRGS')
        {
            subscription.Street_Type__c = 'FORGES, FRGS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GDN')
        {
            subscription.Street_Type__c = 'GARDEN, GDN';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GLNS')
        {
            subscription.Street_Type__c = 'GLENS, GLNS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GRNS')
        {
            subscription.Street_Type__c = 'GREENS, GRNS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'GRVS')
        {
            subscription.Street_Type__c = 'GROVES, GRVS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'HBRS')
        {
            subscription.Street_Type__c = 'HARBORS, HBRS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'JCTS')
        {
            subscription.Street_Type__c = 'JUNCTIONS, JCTS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LGTS')
        {
            subscription.Street_Type__c = 'LIGHTS, LGTS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'LF')
        {
            subscription.Street_Type__c = 'LOAF, LF';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MNRS')
        {
            subscription.Street_Type__c = 'MANORS, MNRS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'MTWY')
        {
            subscription.Street_Type__c = 'MOTORWAY, MTWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'OPAS')
        {
            subscription.Street_Type__c = 'OVERPASS, OPAS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PNE')
        {
            subscription.Street_Type__c = 'PINE, PNE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PTS')
        {
            subscription.Street_Type__c = 'POINTS, PTS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'PRTS')
        {
            subscription.Street_Type__c = 'PORTS, PRTS ';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RAMP')
        {
            subscription.Street_Type__c = 'RAMP, RAMP';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RPD')
        {
            subscription.Street_Type__c = 'RAPID, RPD';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RDGS')
        {
            subscription.Street_Type__c = 'RIDGES, RDGS ';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RDS')
        {
            subscription.Street_Type__c = 'ROADS, RDS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'RUE')
        {
            subscription.Street_Type__c = 'RUE, RUE';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SKWY')
        {
            subscription.Street_Type__c = 'SKYWAY, SKWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'SQS')
        {
            subscription.Street_Type__c = 'SQUARES, SQS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRWY')
        {
            subscription.Street_Type__c = 'THROUGHWAY, TRWY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRAK')
        {
            subscription.Street_Type__c = 'TRACK, TRAK';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'TRFY')
        {
            subscription.Street_Type__c = 'TRAFFICWAY, TRFY';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'UPAS')
        {
            subscription.Street_Type__c = 'UNDERPASS, UPAS ';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'UNS')
        {
            subscription.Street_Type__c = 'UNIONS, UNS ';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VLYS')
        {
            subscription.Street_Type__c = 'VALLEYS, VLYS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'VLGS')
        {
            subscription.Street_Type__c = 'VILLAGES, VLGS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WAYS')
        {
            subscription.Street_Type__c = 'WAYS, WAYS';
        }
        if(subscription.QAS_Mailing_Street_Type__c == 'WL')
        {
            subscription.Street_Type__c = 'WELL, WL';
        }
        
        //Unit Type Update
        if(subscription.QAS_Mailing_Unit_Type__c == NULL)
        {
            subscription.Unit_Type__c = '';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'APT')
        {
            subscription.Unit_Type__c = 'APT, APARTMENT';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'BSMT')
        {
            subscription.Unit_Type__c = 'BSMT, BASEMENT';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'BLDG')
        {
            subscription.Unit_Type__c = 'BLDG, BUILDING';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'DEPT')
        {
            subscription.Unit_Type__c = 'DEPT, DEPARTMENT';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'FL')
        {
            subscription.Unit_Type__c = 'FL, FLOOR';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'FRNT')
        {
            subscription.Unit_Type__c = 'FRNT, FRONT';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'HNGR')
        {
            subscription.Unit_Type__c = 'HNGR, HANGAR';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'KEY')
        {
            subscription.Unit_Type__c = 'KEY, KEY';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'LBBY')
        {
            subscription.Unit_Type__c = 'LBBY, LOBBY';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'LOT')
        {
            subscription.Unit_Type__c = 'LOT, LOT';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'LOWR')
        {
            subscription.Unit_Type__c = 'LOWR, LOWER';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'OFC')
        {
            subscription.Unit_Type__c = 'OFC, OFFICE';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'PH')
        {
            subscription.Unit_Type__c = 'PH, PENTHOUSE';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'PIER')
        {
            subscription.Unit_Type__c = 'PIER, PIER';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'REAR')
        {
            subscription.Unit_Type__c = 'REAR, REAR';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'RM')
        {
            subscription.Unit_Type__c = 'RM, ROOM';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'SIDE')
        {
            subscription.Unit_Type__c = 'SIDE, SIDE';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'SLIP')
        {
            subscription.Unit_Type__c = 'SLIP, SLIP';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'SPC')
        {
            subscription.Unit_Type__c = 'SPC, SPACE';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'STOP')
        {
            subscription.Unit_Type__c = 'STOP, STOP';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'STE')
        {
            subscription.Unit_Type__c = 'STE, SUITE';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'TRLR')
        {
            subscription.Unit_Type__c = 'TRLR, TRAILER';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'UNIT')
        {
            subscription.Unit_Type__c = 'UNIT, UNIT';
        }
        if(subscription.QAS_Mailing_Unit_Type__c == 'UPPR')
        {
            subscription.Unit_Type__c = 'UPPR, UPPER';
        }        
        
        String zip4s = subscription.Zip_4__c + '';
        
        if(zip4s.length() != 0 && zip4s.length() != 4) 
        {
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Zip-4 must have 0 or 4 digits'));
        }        
        
        String apS = subscription.Agent_Office_Phone__c + '';
        String faxS = subscription.Fax__c + '';
        String homefaxS = subscription.Home_Fax__c + '';
        String mobileS = subscription.Mobile_Phone__c + '';
        String primPhoneS = subscription.Primary_Phone__c + '';
        String voicemailS = subscription.Voicemail__c + '';
        String pagerS = subscription.Pager__c + '';
        
        if (subscription.name == null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Subscription name'));
        } 
        
        if(subscription.Public_Email__c == null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Public Email'));
        }
        if(subscription.Primary_Phone__c == null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Primary Phone'));
        }
        if(subscription.Mobile_Phone__c == null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Mobile Phone'));
        }
        if(subscription.Zip__c == null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Zip'));
        }
        if(subscription.City__c == null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'City'));
        }
        if(subscription.State__c == null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'State'));
        }
        if(subscription.QAS_Mailing_County__c== null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Mailing County'));                    
        }       
        
        if(subscription.Private_Email__c== null){
            error=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Private Email'));          
        }
        
        if(!error) {
            error = false;
            try {
                if(subscription.Service_Jurisdiction__c == 'TREND' || subscription.Service_Jurisdiction__c == 'BRIGHT') {                   
                    
                    if(subscription.Service_Jurisdiction__c == 'TREND' && newLoginName != Subscription.TREND_Login_Name__c){ 
                        validateLoginName(); 
                        if(isLoginNameAvailable)  
                            Subscription.TREND_Login_Name__c = newLoginName;
                        else{
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, loginErrorMessage));
                            return null;    
                        }
                    }
                    else if (subscription.Service_Jurisdiction__c == 'BRIGHT' && newLoginName != Subscription.BRIGHT_LoginName__c){
                        validateLoginName();
                        if(isLoginNameAvailable)
                            Subscription.BRIGHT_LoginName__c = newLoginName;
                        else{
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, loginErrorMessage));
                            return null;    
                        }                            
                    }
                                          
                    
                    if(subscription.QAS_Billing_Street_Direction__c == NULL)
                    {
                        subscription.Billing_Street_Direction__c = '';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c== 'N')
                    {
                        subscription.Billing_Street_Direction__c = 'N, NORTH';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c == 'E')
                    {
                        subscription.Billing_Street_Direction__c = 'E, EAST';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c== 'S')
                    {
                        subscription.Billing_Street_Direction__c = 'S, SOUTH';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c== 'W')
                    {
                        subscription.Billing_Street_Direction__c = 'W, WEST';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c == 'NE')
                    {
                        subscription.Billing_Street_Direction__c = 'NE, NORTHEAST';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c == 'SE')
                    {
                        subscription.Billing_Street_Direction__c = 'SE, SOUTHEAST';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c == 'NW')
                    {
                        subscription.Billing_Street_Direction__c = 'NW, NORTHWEST';
                    }
                    if(subscription.QAS_Billing_Street_Direction__c == 'SW')
                    {
                        subscription.Billing_Street_Direction__c = 'SW, SOUTHWEST';
                    }
                    
                    //Billing Street Type Update
                    
                    if(subscription.QAS_Billing_Street_Type__c == 'BLFS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }      
                    if(subscription.QAS_Billing_Street_Type__c == 'BRKS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BGS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CTRS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CIRS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CLF') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CMNS')                                                   
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CVS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'DRS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'EXTS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }                                
                    if(subscription.QAS_Billing_Street_Type__c == 'FLT') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }    
                    if(subscription.QAS_Billing_Street_Type__c == 'FRDS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRGS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GDN')                                                   
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GLNS') 
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GRNS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GRVS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'HBRS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'JCTS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LGTS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LF')                                                   
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MNRS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MTWY')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'OPAS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PARK')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PKWY')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PNE')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PTS')                                                   
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PRTS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RAMP')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RPD')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RDGS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RDS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RUE')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SKWY')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SPUR')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SQS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRWY')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRAK')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRFY')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'UPAS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'UNS')                                                   
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VLYS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VLGS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WALK')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WAYS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WL')
                    {
                        subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == NULL)
                    {
                        subscription.Billing_Street_Type__c = '';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ST')
                    {
                        subscription.Billing_Street_Type__c = 'STREET, ST';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ALY')
                    {
                        subscription.Billing_Street_Type__c = 'ALLEY, ALY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ANX')
                    {
                        subscription.Billing_Street_Type__c = 'ANNEX, ANX';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ARC')
                    {
                        subscription.Billing_Street_Type__c = 'ARCADE, ARC';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'AVE')
                    {
                        subscription.Billing_Street_Type__c = 'AVENUE, AVE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BYU')
                    {
                        subscription.Billing_Street_Type__c = 'BAYOU, BYU';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BCH ')
                    {
                        subscription.Billing_Street_Type__c = 'BEACH, BCH';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BLF ')
                    {
                        subscription.Billing_Street_Type__c = 'BLUFF, BLF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BTM')
                    {
                        subscription.Billing_Street_Type__c = 'BOTTOM, BTM';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BLVD')
                    {
                        subscription.Billing_Street_Type__c = 'BOULEVARD, BLVD';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BR')
                    {
                        subscription.Billing_Street_Type__c = 'BRANCH, BR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BRG')
                    {
                        subscription.Billing_Street_Type__c = 'BRIDGE, BRG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BRK')
                    {
                        subscription.Billing_Street_Type__c = 'BROOK, BRK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BG')
                    {
                        subscription.Billing_Street_Type__c = 'BURG, BG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BYP')
                    {
                        subscription.Billing_Street_Type__c = 'BYPASS, BYP';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CP')
                    {
                        subscription.Billing_Street_Type__c = 'CAMP, CP';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CYN')
                    {
                        subscription.Billing_Street_Type__c = 'CANYON, CYN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CPE')
                    {
                        subscription.Billing_Street_Type__c = 'CAPE, CPE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CSWY')
                    {
                        subscription.Billing_Street_Type__c = 'CAUSEWAY, CSWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CTR')
                    {
                        subscription.Billing_Street_Type__c = 'CENTER, CTR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CIR')
                    {
                        subscription.Billing_Street_Type__c = 'CIRCLE, CIR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CLFS')
                    {
                        subscription.Billing_Street_Type__c = 'CLIFFS, CLFS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CLB')
                    {
                        subscription.Billing_Street_Type__c = 'CLUB, CLB';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CMN')
                    {
                        subscription.Billing_Street_Type__c = 'COMMON, COM';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'COR')
                    {
                        subscription.Billing_Street_Type__c = 'CORNER, COR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CORS')
                    {
                        subscription.Billing_Street_Type__c = 'CORNERS, CORS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CRSE')
                    {
                        subscription.Billing_Street_Type__c = 'COURSE, CRSE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CT')
                    {
                        subscription.Billing_Street_Type__c = 'COURT, CT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CTS')
                    {
                        subscription.Billing_Street_Type__c = 'COURTS, CTS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CV')
                    {
                        subscription.Billing_Street_Type__c = 'COVE, CV';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CRK')
                    {
                        subscription.Billing_Street_Type__c = 'CREEK, CRK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CRES')
                    {
                        subscription.Billing_Street_Type__c = 'CRESCENT, CRES';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'XING')
                    {
                        subscription.Billing_Street_Type__c = 'CROSSING, XING';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'XRD')
                    {
                        subscription.Billing_Street_Type__c = 'CROSSROAD, XRD';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'XRDS')
                    {
                        subscription.Billing_Street_Type__c = 'CROSSROADS, XRDS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CURV')
                    {
                        subscription.Billing_Street_Type__c = 'CURVE, CURV';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'DL')
                    {
                        subscription.Billing_Street_Type__c = 'DALE, DL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'DM')
                    {
                        subscription.Billing_Street_Type__c = 'DAM, DM';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'DV')
                    {
                        subscription.Billing_Street_Type__c = 'DIVIDE, DV';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'DR')
                    {
                        subscription.Billing_Street_Type__c = 'DRIVE, DR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'EST')
                    {
                        subscription.Billing_Street_Type__c = 'ESTATE, EST';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ESTS')
                    {
                        subscription.Billing_Street_Type__c = 'ESTATES, ESTS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'EXPY')
                    {
                        subscription.Billing_Street_Type__c = 'EXPRESSWAY, EXPY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'EXT')
                    {
                        subscription.Billing_Street_Type__c = 'EXTENSION, EXT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FALL')
                    {
                        subscription.Billing_Street_Type__c = 'FALL, FL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FLS')
                    {
                        subscription.Billing_Street_Type__c = 'FALLS, FLS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRY')
                    {
                        subscription.Billing_Street_Type__c = 'FERRY, FRY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FLD')
                    {
                        subscription.Billing_Street_Type__c = 'FIELD, FLD';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FLDS')
                    {
                        subscription.Billing_Street_Type__c = 'FIELDS, FLDS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FLTS')
                    {
                        subscription.Billing_Street_Type__c = 'FLATS, FLT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRD')
                    {
                        subscription.Billing_Street_Type__c = 'FORD, FRD';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRST')
                    {
                        subscription.Billing_Street_Type__c = 'FOREST, FRST';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRG')
                    {
                        subscription.Billing_Street_Type__c = 'FORGE, FRG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRK')
                    {
                        subscription.Billing_Street_Type__c = 'FORK, FRK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRKS')
                    {
                        subscription.Billing_Street_Type__c = 'FORKS, FRKS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FT')
                    {
                        subscription.Billing_Street_Type__c = 'FORT, FT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FWY')
                    {
                        subscription.Billing_Street_Type__c = 'FREEWAY, FWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GDNS')
                    {
                        subscription.Billing_Street_Type__c = 'GARDENS, GDNS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GTWY')
                    {
                        subscription.Billing_Street_Type__c = 'GATEWAY, GTWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GLN')
                    {
                        subscription.Billing_Street_Type__c = 'GLEN, GLN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GRN')
                    {
                        subscription.Billing_Street_Type__c = 'GREEN, GRN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GRV')
                    {
                        subscription.Billing_Street_Type__c = 'GROVE, GRV';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'HBR')
                    {
                        subscription.Billing_Street_Type__c = 'HARBOR, HBR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'HVN')
                    {
                        subscription.Billing_Street_Type__c = 'HAVEN, HVN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'HTS')
                    {
                        subscription.Billing_Street_Type__c = 'HEIGHTS, HTS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'HWY')
                    {
                        subscription.Billing_Street_Type__c = 'HIGHWAY, HWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'HOLW')
                    {
                        subscription.Billing_Street_Type__c = 'HOLLOW, HOLW';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'INLT')
                    {
                        subscription.Billing_Street_Type__c = 'INLET, INLT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'IS')
                    {
                        subscription.Billing_Street_Type__c = 'ISLAND, ISL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ISS')
                    {
                        subscription.Billing_Street_Type__c = 'ISLANDS, ISS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ISLE')
                    {
                        subscription.Billing_Street_Type__c = 'ISLE, ISLE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'JCT')
                    {
                        subscription.Billing_Street_Type__c = 'JUNCTION, JCT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'KY')
                    {
                        subscription.Billing_Street_Type__c = 'KEY, KY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'KYS')
                    {
                        subscription.Billing_Street_Type__c = 'KEYS, KYS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'KNL')
                    {
                        subscription.Billing_Street_Type__c = 'KNOLL, KNL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'KNLS')
                    {
                        subscription.Billing_Street_Type__c = 'KNOLLS, KNLS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LK')
                    {
                        subscription.Billing_Street_Type__c = 'LAKE, LK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LKS')
                    {
                        subscription.Billing_Street_Type__c = 'LAKES, LKS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LAND')
                    {
                        subscription.Billing_Street_Type__c = 'LAND, LAND';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LNDG')
                    {
                        subscription.Billing_Street_Type__c = 'LANDING, LNDG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LN')
                    {
                        subscription.Billing_Street_Type__c = 'LANE, LN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LGT')
                    {
                        subscription.Billing_Street_Type__c = 'LIGHT, LGT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LCK')
                    {
                        subscription.Billing_Street_Type__c = 'LOCK, LCK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LCKS')
                    {
                        subscription.Billing_Street_Type__c = 'LOCKS, LCKS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LDG')
                    {
                        subscription.Billing_Street_Type__c = 'LODGE, LDG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LOOP')
                    {
                        subscription.Billing_Street_Type__c = 'LOOP, LOOP';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MALL')
                    {
                        subscription.Billing_Street_Type__c = 'MALL, MALL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MNR')
                    {
                        subscription.Billing_Street_Type__c = 'MANOR, MNR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MDW')
                    {
                        subscription.Billing_Street_Type__c = 'MEADOW, MDW';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MDWS')
                    {
                        subscription.Billing_Street_Type__c = 'MEADOWS, MDWS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MEWS')
                    {
                        subscription.Billing_Street_Type__c = 'MEWS, MEWS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ML')
                    {
                        subscription.Billing_Street_Type__c = 'MILL, ML';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MLS')
                    {
                        subscription.Billing_Street_Type__c = 'MILLS, MLS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MSN')
                    {
                        subscription.Billing_Street_Type__c = 'MISSION, MSN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MT')
                    {
                        subscription.Billing_Street_Type__c = 'MOUNT, MT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MTN')
                    {
                        subscription.Billing_Street_Type__c = 'MOUNTAIN, MTN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MTNS')
                    {
                        subscription.Billing_Street_Type__c = 'MOUNTAINS, MTNS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'NCK')
                    {
                        subscription.Billing_Street_Type__c = 'NECK, NCK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ORCH')
                    {
                        subscription.Billing_Street_Type__c = 'ORCHARD, ORCHT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'OVAL')
                    {
                        subscription.Billing_Street_Type__c = 'OVAL, OVAL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PARK')
                    {
                        subscription.Billing_Street_Type__c = 'PARK, PARK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PKWY')
                    {
                        subscription.Billing_Street_Type__c = 'PARKWAY, PKWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PASS')
                    {
                        subscription.Billing_Street_Type__c = 'PASS, PASS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PSGE')
                    {
                        subscription.Billing_Street_Type__c = 'PASSAGE, PSGE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PATH')
                    {
                        subscription.Billing_Street_Type__c = 'PATH, PATH';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PIKE')
                    {
                        subscription.Billing_Street_Type__c = 'PIKE, PIKE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PNES')
                    {
                        subscription.Billing_Street_Type__c = 'PINES, PNES';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PL')
                    {
                        subscription.Billing_Street_Type__c = 'PLACE, PL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PLN')
                    {
                        subscription.Billing_Street_Type__c = 'PLAIN, PLN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PLNS')
                    {
                        subscription.Billing_Street_Type__c = 'PLAINS, PLNS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PLZ')
                    {
                        subscription.Billing_Street_Type__c = 'PLAZA, PLZ';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PT')
                    {
                        subscription.Billing_Street_Type__c = 'POINT, PT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PRT')
                    {
                        subscription.Billing_Street_Type__c = 'PORT, PRT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PR')
                    {
                        subscription.Billing_Street_Type__c = 'PRAIRIE, PR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RADL')
                    {
                        subscription.Billing_Street_Type__c = 'RADIAL, RADL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RNCH')
                    {
                        subscription.Billing_Street_Type__c = 'RANCH, RNCH';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RPDS')
                    {
                        subscription.Billing_Street_Type__c = 'RAPIDS, RPDS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RST')
                    {
                        subscription.Billing_Street_Type__c = 'REST, RST';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RDG')
                    {
                        subscription.Billing_Street_Type__c = 'RIDGE, RDG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RIV')
                    {
                        subscription.Billing_Street_Type__c = 'RIVER, RIV';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RD')
                    {
                        subscription.Billing_Street_Type__c = 'ROAD, RD';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RTE')
                    {
                        subscription.Billing_Street_Type__c = 'ROUTE, RTE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'ROW')
                    {
                        subscription.Billing_Street_Type__c = 'ROW, ROW';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RUN')
                    {
                        subscription.Billing_Street_Type__c = 'RUN, RUN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SHL')
                    {
                        subscription.Billing_Street_Type__c = 'SHOAL, SHL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SHLS')
                    {
                        subscription.Billing_Street_Type__c = 'SHOALS, SHLS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SHR')
                    {
                        subscription.Billing_Street_Type__c = 'SHORE, SHR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SPG')
                    {
                        subscription.Billing_Street_Type__c = 'SPRING, SPG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SPGS')
                    {
                        subscription.Billing_Street_Type__c = 'SPRINGS, SPGS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SPUR')
                    {
                        subscription.Billing_Street_Type__c = 'SPUR, SPUR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SQ')
                    {
                        subscription.Billing_Street_Type__c = 'SQUARE, SQ';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'STA')
                    {
                        subscription.Billing_Street_Type__c = 'STATION, STA';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'STRA')
                    {
                        subscription.Billing_Street_Type__c = 'STRAVENUE, STV';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'STRM')
                    {
                        subscription.Billing_Street_Type__c = 'STREAM, STRM';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'STS')
                    {
                        subscription.Billing_Street_Type__c = 'STREETS, STS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SMT')
                    {
                        subscription.Billing_Street_Type__c = 'SUMMIT, SMT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TER')
                    {
                        subscription.Billing_Street_Type__c = 'TERRACE, TER';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRCE')
                    {
                        subscription.Billing_Street_Type__c = 'TRACE, TRCE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRL')
                    {
                        subscription.Billing_Street_Type__c = 'TRAIL, TRL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRLR')
                    {
                        subscription.Billing_Street_Type__c = 'TRAILER, TRLR';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TUNL')
                    {
                        subscription.Billing_Street_Type__c = 'TUNNEL, TUNL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TPKE')
                    {
                        subscription.Billing_Street_Type__c = 'TURNPIKE, TPKE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'UN')
                    {
                        subscription.Billing_Street_Type__c = 'UNION, UN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VLY')
                    {
                        subscription.Billing_Street_Type__c = 'VALLEY, VLY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VIA')
                    {
                        subscription.Billing_Street_Type__c = 'VIADUCT, VIA';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VW')
                    {
                        subscription.Billing_Street_Type__c = 'VIEWS, VWS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VLG')
                    {
                        subscription.Billing_Street_Type__c = 'VILLAGE, VLG';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VL')
                    {
                        subscription.Billing_Street_Type__c = 'VILLE, VL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VIS')
                    {
                        subscription.Billing_Street_Type__c = 'VISTA, VIS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WALK')
                    {
                        subscription.Billing_Street_Type__c = 'WALK, WALK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WALL')
                    {
                        subscription.Billing_Street_Type__c = 'WALL, WL';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WAY')
                    {
                        subscription.Billing_Street_Type__c = 'WAY, WAY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WLS')
                    {
                        subscription.Billing_Street_Type__c = 'WELLS, WLS';
                    }  
                    if(subscription.QAS_Billing_Street_Type__c == 'BLFS')
                    {
                        subscription.Billing_Street_Type__c = 'BLUFFS, BLFS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BRKS')
                    {
                        subscription.Billing_Street_Type__c = 'BROOKS, BRKS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'BGS')
                    {
                        subscription.Billing_Street_Type__c = 'BURGS, BGS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CTRS')
                    {
                        subscription.Billing_Street_Type__c = 'CENTERS, CTRS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CIRS')
                    {
                        subscription.Billing_Street_Type__c = 'CIRCLES, CIRS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CLF')
                    {
                        subscription.Billing_Street_Type__c = 'CLIFF, CLF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CMNS')
                    {
                        subscription.Billing_Street_Type__c = 'COMMONS, CMNS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'CVS')
                    {
                        subscription.Billing_Street_Type__c = 'COVES, CVS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'DRS')
                    {
                        subscription.Billing_Street_Type__c = 'DRIVES, DRS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'EXTS')
                    {
                        subscription.Billing_Street_Type__c = 'EXTENSIONS, EXTS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FLT')
                    {
                        subscription.Billing_Street_Type__c = 'FLAT, FLT';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRDS')
                    {
                        subscription.Billing_Street_Type__c = 'FORDS, FRDS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'FRGS')
                    {
                        subscription.Billing_Street_Type__c = 'FORGES, FRGS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GDN')
                    {
                        subscription.Billing_Street_Type__c = 'GARDEN, GDN';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GLNS')
                    {
                        subscription.Billing_Street_Type__c = 'GLENS, GLNS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GRNS')
                    {
                        subscription.Billing_Street_Type__c = 'GREENS, GRNS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'GRVS')
                    {
                        subscription.Billing_Street_Type__c = 'GROVES, GRVS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'HBRS')
                    {
                        subscription.Billing_Street_Type__c = 'HARBORS, HBRS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'JCTS')
                    {
                        subscription.Billing_Street_Type__c = 'JUNCTIONS, JCTS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LGTS')
                    {
                        subscription.Billing_Street_Type__c = 'LIGHTS, LGTS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'LF')
                    {
                        subscription.Billing_Street_Type__c = 'LOAF, LF';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MNRS')
                    {
                        subscription.Billing_Street_Type__c = 'MANORS, MNRS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'MTWY')
                    {
                        subscription.Billing_Street_Type__c = 'MOTORWAY, MTWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'OPAS')
                    {
                        subscription.Billing_Street_Type__c = 'OVERPASS, OPAS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PNE')
                    {
                        subscription.Billing_Street_Type__c = 'PINE, PNE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PTS')
                    {
                        subscription.Billing_Street_Type__c = 'POINTS, PTS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'PRTS')
                    {
                        subscription.Billing_Street_Type__c = 'PORTS, PRTS ';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RAMP')
                    {
                        subscription.Billing_Street_Type__c = 'RAMP, RAMP';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RPD')
                    {
                        subscription.Billing_Street_Type__c = 'RAPID, RPD';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RDGS')
                    {
                        subscription.Billing_Street_Type__c = 'RIDGES, RDGS ';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RDS')
                    {
                        subscription.Billing_Street_Type__c = 'ROADS, RDS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'RUE')
                    {
                        subscription.Billing_Street_Type__c = 'RUE, RUE';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SKWY')
                    {
                        subscription.Billing_Street_Type__c = 'SKYWAY, SKWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'SQS')
                    {
                        subscription.Billing_Street_Type__c = 'SQUARES, SQS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRWY')
                    {
                        subscription.Billing_Street_Type__c = 'THROUGHWAY, TRWY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRAK')
                    {
                        subscription.Billing_Street_Type__c = 'TRACK, TRAK';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'TRFY')
                    {
                        subscription.Billing_Street_Type__c = 'TRAFFICWAY, TRFY';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'UPAS')
                    {
                        subscription.Billing_Street_Type__c = 'UNDERPASS, UPAS ';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'UNS')
                    {
                        subscription.Billing_Street_Type__c = 'UNIONS, UNS ';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VLYS')
                    {
                        subscription.Billing_Street_Type__c = 'VALLEYS, VLYS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'VLGS')
                    {
                        subscription.Billing_Street_Type__c = 'VILLAGES, VLGS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WAYS')
                    {
                        subscription.Billing_Street_Type__c = 'WAYS, WAYS';
                    }
                    if(subscription.QAS_Billing_Street_Type__c == 'WL')
                    {
                        subscription.Billing_Street_Type__c = 'WELL, WL';
                    }
                    
                    //Billing Unit Type Update
                    if(subscription.QAS_Billing_Unit_Type__c == NULL)
                    {
                        subscription.Billing_Unit_Type__c = '';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'APT')
                    {
                        subscription.Billing_Unit_Type__c = 'APT, APARTMENT';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'BSMT')
                    {
                        subscription.Billing_Unit_Type__c = 'BSMT, BASEMENT';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'BLDG')
                    {
                        subscription.Billing_Unit_Type__c = 'BLDG, BUILDING';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'DEPT')
                    {
                        subscription.Billing_Unit_Type__c = 'DEPT, DEPARTMENT';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'FL')
                    {
                        subscription.Billing_Unit_Type__c = 'FL, FLOOR';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'FRNT')
                    {
                        subscription.Billing_Unit_Type__c = 'FRNT, FRONT';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'HNGR')
                    {
                        subscription.Billing_Unit_Type__c = 'HNGR, HANGAR';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'KEY')
                    {
                        subscription.Billing_Unit_Type__c = 'KEY, KEY';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'LBBY')
                    {
                        subscription.Billing_Unit_Type__c = 'LBBY, LOBBY';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'LOT')
                    {
                        subscription.Billing_Unit_Type__c = 'LOT, LOT';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'LOWR')
                    {
                        subscription.Billing_Unit_Type__c = 'LOWR, LOWER';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'OFC')
                    {
                        subscription.Billing_Unit_Type__c = 'OFC, OFFICE';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'PH')
                    {
                        subscription.Billing_Unit_Type__c = 'PH, PENTHOUSE';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'PIER')
                    {
                        subscription.Billing_Unit_Type__c = 'PIER, PIER';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'REAR')
                    {
                        subscription.Billing_Unit_Type__c = 'REAR, REAR';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'RM')
                    {
                        subscription.Billing_Unit_Type__c = 'RM, ROOM';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'SIDE')
                    {
                        subscription.Billing_Unit_Type__c = 'SIDE, SIDE';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'SLIP')
                    {
                        subscription.Billing_Unit_Type__c = 'SLIP, SLIP';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'SPC')
                    {
                        subscription.Billing_Unit_Type__c = 'SPC, SPACE';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'STOP')
                    {
                        subscription.Billing_Unit_Type__c = 'STOP, STOP';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'STE')
                    {
                        subscription.Billing_Unit_Type__c = 'STE, SUITE';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'TRLR')
                    {
                        subscription.Billing_Unit_Type__c = 'TRLR, TRAILER';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'UNIT')
                    {
                        subscription.Billing_Unit_Type__c = 'UNIT, UNIT';
                    }
                    if(subscription.QAS_Billing_Unit_Type__c == 'UPPR')
                    {
                        subscription.Billing_Unit_Type__c = 'UPPR, UPPER';
                    }
                    
                    if(String.isBlank(Subscription.Contact__r.FirstName)) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The required field is missing: First Name'));
                        return null;
                    }
                    
                    if(String.isBlank(Subscription.Contact__r.LastName)) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The required field is missing: Last Name'));
                        return null;
                    } 
                    
                    if(subscription.QAS_Billing_County__c == 'DISTRICT OF COLUMBIA')
                        subscription.Billing_County__c = 'WASHINGTON';        
                    else        
                        subscription.Billing_County__c = subscription.QAS_Billing_County__c;
                    
                    if (null != subscription.Billing_Addl_Display_Name__c)
                        subscription.QAS_Billing_Record_Type__c = 'P';
                    
                    String billing_zip4s = subscription.Billing_Zip_4__c + '';
                    
                    if(billing_zip4s.length() != 0 && billing_zip4s.length() != 4) 
                    {
                        error=true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Home Zip-4 must have 0 or 4 digits'));
                    }  
                    
                    if(subscription.Service_Jurisdiction__c != 'BRIGHT' && subscription.Billing_Zip__c == null){
                        error=true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Home Zip'));
                    }
                    if(subscription.Service_Jurisdiction__c != 'BRIGHT' && subscription.Billing_City__c == null){
                        error=true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Home City'));
                    }
                    if(subscription.Service_Jurisdiction__c != 'BRIGHT' && subscription.Billing_State__c == null){
                        error=true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Home State'));
                    }
                    if(subscription.Service_Jurisdiction__c != 'BRIGHT' && subscription.QAS_Billing_County__c == null){
                        error=true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Home County'));                    
                    }
                    
                    
                    Contact c = new Contact();
                    c.Id = subscription.Contact__c;
                    c.FirstName = Subscription.Contact__r.FirstName;
                    c.LastName = Subscription.Contact__r.LastName;
                    c.Middle_Name__c = Subscription.Contact__r.Middle_Name__c;
                    c.Title = subscription.Contact__r.Title;
                    c.Suffix__c = subscription.Contact__r.Suffix__c;
                    c.Nickname__c = subscription.Contact__r.Nickname__c;
                    c.Website__c = subscription.Contact__r.Website__c;
                    if(subscription.Service_Jurisdiction__c == 'BRIGHT') {
                       c.PreferredName__c = subscription.Contact__r.PreferredName__c;
                       c.PreferredFirstName__c = subscription.Contact__r.PreferredFirstName__c;
                       c.PreferredLastName__c = subscription.Contact__r.PreferredLastName__c;                                              
                    }
                    update c;
                }
                if(!error){
                    //setting SSV validation to verified to avoid verifying address in salesforce again
                    subscription.AddressValidationStatus__c = 'Verified';
                    update subscription ;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your account is successfully updated'));
                    isEdit = false;
                }
            }
            catch (DmlException ex){
                String messak = ex.getMessage();
                messak = messak.substring(messak.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+34,messak.length()-3);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,messak)); 
                isEdit = true;
            }
            catch (Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Operation failed due to some Internal Error ')); 
                System.debug('ex........'+ex);
                isEdit = true;
            }
        }
        else
            isEdit = true;
        
        return null;
    }
    
    
    
    //Method to query 
    public void brokerSubmittedForms() {
        User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        List <Case> lCase = new list <Case>();
         lCase = [SELECT Id, First_Name__c, Last_Name__c, Middle_Name__c, CreatedDate
                     FROM 	Case
                     WHERE 	CreatedById = :u.ContactId];        
    }
    
     //Method to save Case data
    @RemoteAction
    public static String saveCaseDataForm(String firstName, String lastName, String middleName) {
        system.debug('****firstName'+firstName);
        List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Processing'];
        User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        
        Case oCase = new Case();
        oCase.ContactId = u.ContactId;
        oCase.OwnerId = queueIds[0].Id;
        oCase.Status = 'New';
        oCase.Subject = 'Request Name Update';
        oCase.Type = 'Request Name Update';
        oCase.First_Name__c = firstName;
      	oCase.Last_Name__c = lastName;
        oCase.Middle_Name__c = middleName;
        if(middleName != ''){
        oCase.Description = 'Request Name Update - ' +firstName + ' ' + middleName + ' ' + lastName;
        }else{
        		oCase.Description = 'Request Name Update - ' + firstName + ' ' +lastName;
        }
        
        List<Subscriptions__c>lSubs = new List<Subscriptions__c>();
        lSubs = [SELECT Id, Name, Contact__c, Primary__c, Status__c  
                 FROM Subscriptions__c 
                 WHERE Contact__c =:u.ContactId 
                 AND Status__c = 'Active'
                ];
        if(lSubs[0].Primary__c = true){
            oCase.Subscription_ID__c = lSubs[0].Id;
        }else{
            oCase.Subscription_ID__c = lSubs[0].Id;
        }

        insert oCase;
        return oCase.Id;
    } 
    
    //Method to save file parts
    @RemoteAction
    public static String attachFile(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue) {
        system.debug('***base64BlobValue'+base64BlobValue);
        if(attachmentId == '' || attachmentId == null) {
            Attachment att = new Attachment(
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            system.debug(att.Body);
            att.ParentId = parentId;
            insert att;
            return att.Id;
        }
        else {
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]) {
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }                     
    }
    
    public class CustomException extends Exception{}
}