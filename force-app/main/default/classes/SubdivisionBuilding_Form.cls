public without sharing class SubdivisionBuilding_Form {
    public string subDivisionOrBuildingName {get; set;}
    public string subDivisionOrBuilding {get; set;}
    public string subDivisionOrBuildingDate {get; set;}
    
    public SubdivisionBuilding_Form()
    {
        subDivisionOrBuildingName = Apexpages.currentPage().getParameters().get('name');
        subDivisionOrBuilding = Apexpages.currentPage().getParameters().get('subDivRbuild');
        string caseId = Apexpages.currentPage().getParameters().get('caseId');
        system.debug('caseId---'+caseId);
        if(!String.isEmpty(caseId)){
            list<Case> cases = [SELECT Id, CreatedDate FROM Case WHERE Id = :caseId];
            if(cases!= null && cases.size()>0){
                subDivisionOrBuildingDate = cases[0].CreatedDate.date().format();
            }
        }
        if(String.isEmpty(subDivisionOrBuildingDate)){
            subDivisionOrBuildingDate = system.today().format();
        }
    }
    @AuraEnabled
    public static SubDivisionFormWrapper initMethod(){
        // create a wrapper class object and set the wrapper class @AuraEnabled properties and return it to the lightning component.
        return new SubDivisionFormWrapper();    
    }
    
    @AuraEnabled
    public static List<Subdivision_Building_Form_States__c> getStateValues(){
        //List<Subdivision_Building_Form_States__c> stateList = Subdivision_Building_Form_States__c.getAll().Values();
        List<Subdivision_Building_Form_States__c> stateList = [SELECT Id, Name, State__c from Subdivision_Building_Form_States__c ORDER BY State__c ASC];
        return stateList;
    }
    
    @AuraEnabled
    public Static Subscriptions__c fetchSubscription(String subId) {
        //pg = new PageReference(url);
        //subscriptionId =  pg.getParameters().get('id');
        system.debug('subId---'+subId);
        List<Subscriptions__c> subs = [SELECT Id, Name,
                                       Related_Location_Broker_Office__c,
                                       Contact__c,Status__c,
                                       Service_Jurisdiction__c,
                                       Billing_Jurisdiction__c,
                                       Subscription_Type__c                                 
                                       FROM Subscriptions__c
                                       WHERE Name = :subId];
       
            return subs[0];
    }
    
    @AuraEnabled
    public static String saveSubdivisionBuildingForm(String subId, object caseDescJson, string subDivRbuilding, string subdivRbuildName){
        try{
            system.debug('subDivRbuilding--'+subDivRbuilding);
            List<Subscriptions__c> subs = new List<Subscriptions__c>{fetchSubscription(subId)};
                system.debug('subs'+subs);
            system.debug('caseDescJson----'+caseDescJson);
            List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'SC_Data_Corrections'];
            
            Case oCase = new Case();
            oCase.OwnerId = queueIds[0].Id;
            if(subDivRbuilding == 'SubDivision'){
                oCase.Subject = 'Subdivision Name Request';
            }else{
                oCase.Subject = 'Building Name Request';
            }
            oCase.Origin = 'Data Corrections';
            oCase.Status = 'Not Started';
            oCase.MLS__c = 'BRIGHT';
            oCase.AccountId = subs[0].Related_Location_Broker_Office__c;
            oCase.Subscription_ID__c = subs[0].Id;
            oCase.ContactId = subs[0].Contact__c;
            oCase.Description = caseDescJson!=null ?JSON.serialize(caseDescJson):'';
            
            Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Center Case').getRecordTypeId();
            oCase.recordTypeId = recordTypeId;
            insert oCase;
            
            
            String url = '/apex/SubdivisionBuildingFormPDF?subDivRbuild='+subDivRbuilding+'&name='+subdivRbuildName;
            PageReference pageRef = new PageReference(url);
            Blob ret ;
            if (!Test.isRunningTest()){
            ret = pageRef.getContentAsPDF();
            }
            else     
                ret = Blob.valueof('Some random String');
            
            String base64 = EncodingUtil.base64Encode(ret);
            String  respuesta='';
            ContentVersion v = new ContentVersion();
            v.versionData = EncodingUtil.base64Decode(base64);
            if(subdivRbuildName.length() < 20){
                v.title = subdivRbuildName +'.pdf';
                v.pathOnClient = subdivRbuildName +'.pdf';
            }else{
                v.title = subdivRbuildName.substring(0, 20) +'.pdf';
                v.pathOnClient = subdivRbuildName.substring(0, 20) +'.pdf';
            }
            
            insert v;
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:v.Id].ContentDocumentId;
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = oCase.Id;
            cDe.ShareType = 'I';
            cDe.Visibility = 'AllUsers';
            insert cDe; 
            ContentVersion cv = [select id from contentversion where contentdocumentid =:conDoc];
            respuesta =cv.id;
            
            return oCase.Id;
        }catch(Exception ex){
            system.Debug('***ex Error'+ex.getMessage());
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }
    
    
    @AuraEnabled
    public static String attachFile(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
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
    
    @AuraEnabled
    public static string getCaseCreatedDate(string caseId){
        DateTime caseCreatedDate = [SELECT CreatedDate FROM Case where Id =: caseId].CreatedDate;
        system.debug('****caseID'+caseCreatedDate);
        return caseCreatedDate.date().format();
    }
    
    
   /* public class wrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public wrapper(String label, String value){
            this.label = label;
            this.value = value;
            
        }
    }*/
    
    public class CustomException extends Exception {}
    
    
}