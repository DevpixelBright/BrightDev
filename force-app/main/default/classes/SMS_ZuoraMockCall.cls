public class SMS_ZuoraMockCall {
    
    public static String zObjectName;
    public static List<String> zConditions; 
    public static List<String> zFields;
    public static Boolean isSuccess = true;
    /*
    public static Map<String, Map<String, Zuora.zSchema.zFieldDescription>> allZFeildDescription {
        get {
            if (allZFeildDescription == null) {
                allZFeildDescription =  Zuora.zSchema.getAllzFieldDescription();
            }
            return allZFeildDescription;
        }
        private set;
    }
    */
    public static void parseZQuery(String zQuery) {
        Integer startIndex = zQuery.indexOf('FROM');
        Integer endIndex = zQuery.indexOf('WHERE');
        if (endIndex > 0) {    
            zObjectName = zQuery.substring(startIndex + 5, endIndex - 1);
            //system.debug('*** zObjectName : ' + zObjectName); 
            
            startIndex = zQuery.indexOf('WHERE');
            endIndex = zQuery.length();
            
            String conditions = zQuery.substring(startIndex + 6, endIndex);
            //system.debug('*** conditions : ' + conditions);
            
            if (conditions.indexOf('OR') > 0) 
                zConditions = conditions.split('OR');  
            else if (conditions.indexOf('AND') > 0) 
                zConditions = conditions.split('AND');
            else
                zConditions = new List<String>{conditions };                
             
            // System.Debug('*** zConditions : '+zConditions );
             
        }
        else {
            List<String> parts = zQuery.split(' FROM ');
            if (parts.Size() == 2)
                zObjectName = parts[1];
                
            zConditions = new List<String>();
        }
        
        startIndex = zQuery.indexOf('SELECT');
        endIndex = zQuery.indexOf('FROM');
         
        //List<String> fields = new List<String>();
        zFields = zQuery.substring(startIndex + 7, endIndex - 1).split(',');
        
        //System.Debug('*** zFields :'+zFields );        
    }   
   
    public static List<Zuora.zObject> getZObjects(String zQuery) {
        List<Zuora.zObject> zObjects = new List<Zuora.zObject>();
        
        parseZQuery(zQuery);
        zObjects = SMS_ZuoraMockDataGenerator.generateTestData(zObjectName, zFields, zConditions); 
        
        return zObjects;
    }
    
    public static List<Zuora.zApi.SaveResult> getZSaveResult(List<Zuora.zObject> zobjects){
        List<Zuora.zApi.SaveResult> zSaveResults = new List<Zuora.zApi.SaveResult>();
        
        Zuora.zApi.SaveResult zSaveResult = new Zuora.zApi.SaveResult();
        
        if(isSuccess){
            zSaveResult.success = true;
            zSaveResult.errors = null;  
            zSaveResult.Id = 'asklfjaslkjfkalsf';         
        }
        else{
            zSaveResult.Success = false; 
            
            List<Zuora.zObject> errors = new List<Zuora.zObject>();
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Code', '1000');
            error.setValue('Field', '');
            error.setValue('Message', 'Process ZResult test call');
            errors.add(error);            
            
            zSaveResult.errors = errors; 
        } 
              
        zSaveResults.add(zSaveResult);
            
        return zSaveResults;
    }
    
    public static List<Zuora.zApi.SubscribeResult> getZSubscribeResult(List<Zuora.zApi.SubscribeRequest> requests) {
        List<Zuora.zApi.SubscribeResult> zSubscribeResults = new List<Zuora.zApi.SubscribeResult>();
        Zuora.zApi.SubscribeResult zSubscribeResult = new Zuora.zApi.SubscribeResult();
       
        if(isSuccess){
        
            Zuora.zObject Invoice = new Zuora.zObject('Invoice');
            
            Zuora.zObject InvoiceItem = new Zuora.zObject('InvoiceItem');
            InvoiceItem.setValue('InvoiceId', 'sdfgfdsgdf');
            
            List<Zuora.zObject> items = new List<Zuora.zObject>();
            items.add(InvoiceItem);
            
            Zuora.zObject InvoiceData = new Zuora.zObject('InvoiceData');
            InvoiceData.setValue('Invoice', Invoice);
            InvoiceData.setValue('InvoiceItem', items);
            
            List<Zuora.zObject> InvoiceDatas = new List<Zuora.zObject>();
            InvoiceDatas.add(InvoiceData);
            
            zSubscribeResult.AccountId = '45345wWseferr34sfdf';
            zSubscribeResult.success = true;
            zSubscribeResult.errors = null; 
            zSubscribeResult.InvoiceDatas = InvoiceDatas;
        }
        else{
            zSubscribeResult.Success = false; 
            
            List<Zuora.zObject> errors = new List<Zuora.zObject>();
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Code', '1000');
            error.setValue('Field', '');
            error.setValue('Message', 'Process ZResult test call');
            errors.add(error);            
            
            zSubscribeResult.errors = errors; 
        } 
        
        zSubscribeResults.add(zSubscribeResult);
        return zSubscribeResults;
    }  

    public static Zuora.zApi.AmendResult getZAmendResult(List<Zuora.zApi.AmendRequest> requests) {
        Zuora.zApi.AmendResult zAmendResult = new Zuora.zApi.AmendResult(); 
        if(isSuccess) {
            zAmendResult.Success = true; 
            zAmendResult.errors = null;
        }
        else{
            zAmendResult.Success = false; 
            
            List<Zuora.zObject> errors = new List<Zuora.zObject>();
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Code', '1000');
            error.setValue('Field', '');
            error.setValue('Message', 'Process ZResult test call');
            errors.add(error);            
            
            zAmendResult.errors = errors;        
        }  
        return zAmendResult;
    }  

    public static List<Zuora.zApi.DeleteResult> getZDeleteResults(String zType, List<String> ids) {
        List<Zuora.zApi.DeleteResult> zDeleteResults = new List<Zuora.zApi.DeleteResult>(); 
        
        Zuora.zApi.DeleteResult zDeleteResult = new Zuora.zApi.DeleteResult();
        if(isSuccess){
            zDeleteResult.success = true;
            zDeleteResult.errors = null;           
        }
        else{
            zDeleteResult.Success = false; 
            
            List<Zuora.zObject> errors = new List<Zuora.zObject>();
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Code', '1000');
            error.setValue('Field', '');
            error.setValue('Message', 'Process ZResult test call');
            errors.add(error);            
            
            zDeleteResult.errors = errors; 
        } 
                
        zDeleteResults.add(zDeleteResult);               
        return zDeleteResults;
    }  
      
}