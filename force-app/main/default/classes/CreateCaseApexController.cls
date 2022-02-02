public class CreateCaseApexController {
    
    public static Case c { get; set; }
    
    @AuraEnabled
    public static String createRecord (Case inputCase){        
        String result = 'Initial Before Insert';
        try{
            System.debug('***inputCase: '+ inputCase);            
            if(inputCase != null){
                insert inputCase;
            } 
            result = inputCase.Id;           
        } 
        catch (Exception ex){
            result = ex.getMessage() + ex.getStackTraceString();
        } 
        
        return result;       
    }   
    @AuraEnabled
    public static Case initiliseCase(){
        Case inputCase = new Case();
        User cureCustomer = [SELECT Id,Name, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Account_Name__c
                        FROM   User 
                             //WHERE Id = '005J0000006LxYC'];
                        WHERE  Id = :UserInfo.getUserId()]; 
        inputCase.Origin = 'CURE Community';
        inputCase.ContactId = cureCustomer.ContactId;
        inputCase.AccountId = cureCustomer.Contact.AccountId;
        inputCase.CURE_Group__c = cureCustomer.Contact.Account.Account_Name__c;
        //inputCase.RecordTypeId = '012J00000000vaK';
        c = inputCase;
        return inputCase;
    }
    @AuraEnabled
    public static List<String> getRequestType(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Request_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    @AuraEnabled
    public static List<String> getCURECustomer(){
        List<String> options = new List<String>();
        if(c.CURE_Group__c == 'CARETS') 
            options = new List<String> {'Multiple', 'CLAW', 'COOP', 'CRISNET', 'ITECH', 'PALM', 'VCRDS'};
        else if(c.CURE_Group__c == 'WIREX') 
            options = new List<String> {'Multiple', 'MET', 'RANW', 'SCW', 'CWBR', 'DCBR', 'MET', 'MCBR', 'NWW', 'SAAR', 'WWRA'};
        else if(c.CURE_Group__c == 'GLR') 
            options = new List<String> {'Multiple', 'MISPE', 'RCO', 'AAABOR', 'DRAR', 'FAAR', 'HCBR', 'JAAR', 'LCAR', 'MCAR', 'SAOR', 'SBR'};
        else if(c.CURE_Group__c == 'TREND') 
            options = new List<String> {'TREND'};
        else {
            Schema.DescribeFieldResult fieldResult = Case.CURE_Customer__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry f: ple) {
                options.add(f.getLabel());
            }        
        }                         
        return options;
    }
    
    @AuraEnabled
    public static List<String> getCategory(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Category_Resource__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    @AuraEnabled
    public static List<String> getComponent(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Component_Function__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List<String> getEnvironment(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Environment__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    @AuraEnabled
    public static List<String> getReload(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Reload_Data_Refresh__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List<String> getImpact(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Impact_VIP__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    @AuraEnabled
    public static List<String> getUrgency(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Urgency_Critical_Business_Time__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = parentId;

        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
        
        return a.Id;
    }
    
    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update a;
    }
   
}