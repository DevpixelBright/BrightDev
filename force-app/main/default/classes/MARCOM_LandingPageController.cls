public class MARCOM_LandingPageController {
    
    @AuraEnabled
    public static wrapper getTemplates(String status, String folder, String searchText, String createdDate, String lastModofiedDate, String category){
        system.debug(category);
        wrapper wrap = new wrapper();
        /*
        Integer offsetHelper = 0;
        if(offset != null){
            offsetHelper = offset * 10;
        }
        */
        String countQuery = 'SELECT count() FROM EmailTemplate ';
        
        String query = 'SELECT Id, Name, FolderName, IsActive, TemplateType, Description, CreatedDate, FolderId FROM EmailTemplate ';
		        
        Boolean hasWhere = false;
        if(String.isNotBlank(status)){
            String condQuery = 'WHERE isActive = '+((status == 'Active')?'true':'false');
            countQuery += condQuery;
            query += condQuery;
            hasWhere = true;
        }
        
        if(String.isNotBlank(folder)){
            String condQuery = ((hasWhere)?' AND ':'WHERE ') + 'folderId = \''+folder+'\'';
            countQuery += condQuery;
            query += condQuery;
            hasWhere = true;
        }else{
            Map<Id,Folder> mFolder = new Map<Id,Folder>([SELECT Id, Name FROM Folder WHERE Type = 'Email' ORDER BY Name]);
            mFolder.put(UserInfo.getOrganizationId(), null);
            String condQuery2 = (hasWhere)?' AND (':' WHERE (';
            Boolean isFirst = true;
            hasWhere = true;
            for(String k : mFolder.keyset()){
                condQuery2 += ((isFirst)?'':' OR') + ' folderid = \''+ k +'\'';
                isFirst = false;
            }
            condQuery2 += ')';
            countQuery += condQuery2;
            query += condQuery2;
        }
        
        if(String.isNotBlank(createdDate)){
            String condQuery = ((hasWhere)?' AND ':'WHERE ') + ' DAY_ONLY(CreatedDate) = '+ createdDate;
            countQuery += condQuery;
            query += condQuery;
            hasWhere = true;
        }
        
        if(String.isNotBlank(lastModofiedDate)){
            String condQuery = ((hasWhere)?' AND ':'WHERE ') + ' DAY_ONLY(LastModifiedDate) = '+ lastModofiedDate;
            countQuery += condQuery;
            query += condQuery;
            hasWhere = true;
        }
        
        if(String.isNotBlank(category)){
            String condQuery = ((hasWhere)?' AND ':'WHERE ') + ' Description LIKE \'{"Category":"'+ category + '"%\'';
            countQuery += condQuery;
            query += condQuery;
            hasWhere = true;
        }
        /*
        if(false & String.isNotBlank(searchText)){
            if(Label.MARCOM_SearchBody == 'true'){
                getSearchTextResult(query, searchText, wrap);
	            return wrap;    
            }else{
                String condQuery = ((hasWhere)?' AND ':'WHERE ') + '(Name LIKE \'%'+searchText+'%\')';
                countQuery += condQuery;
                query += condQuery;
            }
        }
        */
        
        /*
        if(String.isNotBlank(sortColumn)){
            query += ' ORDER BY ' + sortColumn + (order == true?' DESC':' ASC');
            query += ' NULLS LAST';
        }
        
        query += ' LIMIT 10';
        query += ' OFFSET '+offsetHelper;
        */
        system.debug('query---'+query);
        wrap.lTemplates = Database.query(query);
        Integer pages = Database.countQuery(countQuery);
        //wrap.pagination = pages/10 + (Math.mod(pages, 10) > 0?1:0);
        //wrap.pages = pagination(offset, wrap.pagination);
        return wrap;
    }
    
    @AuraEnabled
    public static ConfigWrapper getConfigurations(){
        Set<String> folderIds = new Set<String>();
        for(AggregateResult aggr : [SELECT count(id), FolderId FROM EmailTemplate group by folderId]){
            folderIds.add((String)aggr.get('FolderId'));
        }
        List<Folder> lFolder = [SELECT Id, Name FROM Folder WHERE Type = 'Email' ORDER BY Name];
        List<PicklistValues> optionlist = new List<PicklistValues>();
        for (Folder fldr : lFolder) {
            optionlist.add(new PicklistValues(fldr.Name, fldr.Id));
        }
        optionlist.add(new PicklistValues('Unfiled Public Classic Email Templates', UserInfo.getOrganizationId()));
        
        List<PicklistValues> categoryList = new List<PicklistValues>();
        Map<String, Email_Template_Category__c> mcs = Email_Template_Category__c.getAll();
        for (String name : mcs.keySet()) {
            categoryList.add(new PicklistValues(name, name));
        }
        
		return new ConfigWrapper(optionlist, categoryList);
    }
    
    @AuraEnabled
    public static EmailTemplate getEmailDetails(String EmailId){
        if(String.isBlank(EmailId)){
            throw new AuraHandledException('Something went wrong');
        }
        EmailTemplate eDetails = [SELECT Id, Name, Subject, HtmlValue, body, TemplateType, Markup FROM EmailTemplate WHERE Id =: EmailId];
        try{
        	if(eDetails.TemplateType == 'visualforce'){
                eDetails.Subject = eDetails.Markup.substringAfter('<messaging:emailTemplate subject="').substringBefore('"');
            }    
        }catch(Exception ex){}
        try{
        	if(eDetails.TemplateType == 'visualforce' && eDetails.HtmlValue == null){
                String body = eDetails.Markup.substringAfter('HtmlEmailBody');
                eDetails.HtmlValue = eDetails.Markup.substringBetween('<messaging:htmlEmailBody >','</messaging:htmlEmailBody>');
                if(eDetails.HtmlValue == null || eDetails.HtmlValue == ''){
                    eDetails.HtmlValue = eDetails.Markup.substringBetween('<messaging:HtmlEmailBody >','</messaging:HtmlEmailBody>');
                }
            }    
        }catch(Exception ex){}
        eDetails.Markup = null;
        //eDetails.HtmlValue = MARCOM_Util.processEmailBody(eDetails.HtmlValue);
        return eDetails;
    }
    @AuraEnabled
    public static List<MARCOM_Notes__c> getNotes(String EmailId){
        if(String.isBlank(EmailId)){
            throw new AuraHandledException('No Email id found.');
        }
        List<MARCOM_Notes__c> mNotes = [SELECT Id, Name, Email_Template_Name__c, Subject__c, Priority__c, Due_Date__c, CreatedDate, CreatedBy.Name, Request_Status__c  FROM MARCOM_Notes__c WHERE Email_Template_ID__c =: EmailId ORDER BY CreatedDate Desc];
        return mNotes;
    }
    
    @AuraEnabled
    public static List<PicklistValues> getPicklist(){
		List<PicklistValues> optionlist = new List<PicklistValues>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get('MARCOM_Notes__c').getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get('Priority__c').getDescribe().getPickListValues();       
             
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(new PicklistValues(pv.getLabel(), pv.getValue()));
        }
        
        return optionlist;
    }
    /*
    public static List<Integer> pagination(Integer offset, Integer maxPages){
        List<Integer> pages = new List<Integer>();
        Integer count = 1;
        if(offset > maxPages)
            offset = 0;
        
        if(maxPages > 5){
            if(offset > maxPages - 3){
                count = maxPages - 4;
            }else if(offset < 3){
                count = 1;
            }else{
                count = offset - 1;
            }
            for(Integer i = count; i < count + 5; i++){
                pages.add(i);
            }  
        }else{
            for(Integer i = 1; i <= maxPages; i++){
                pages.add(i);
            } 
        }
        return pages;
    }
    */
    /*
    public static void getSearchTextResult(String query, String searchText, Wrapper wrap){
        
        query = query.replace('SELECT', 'SELECT Subject, Body, HtmlValue,');
        system.debug('query---'+query);
        List<EmailTemplate> lTmplt = (List<EmailTemplate>)Database.query(query);
        List<EmailTemplate> filteredList = new List<EmailTemplate>();
        for(EmailTemplate et : lTmplt){
            Boolean addItem = false;
            if(et.Name != null && et.Name.containsIgnoreCase(searchText)){
                addItem = true;
            }else if(et.subject != null && et.subject.containsIgnoreCase(searchText)){
                addItem = true;
            }else if(et.body != null && et.body.containsIgnoreCase(searchText)){
                addItem = true;
            }else if(et.htmlvalue != null && et.htmlvalue.containsIgnoreCase(searchText)){
                addItem = true;
            }
            if(addItem){
                et.Body = null;
                et.HtmlValue = null;
                et.Subject = null;
                filteredList.add(et);
            }
        }
        wrap.lTemplates = filteredList;
        
        ///*
        if(filteredList.size() < 10){
        	wrap.lTemplates = filteredList;
            wrap.pagination = 0;
            wrap.pages = pagination(0, 1);    
        }else{
            if(offset == null){
                offset = 0;
            }
            wrap.lTemplates = new List<EmailTemplate>();
            for(Integer i = offset; i < offset+10 && i < filteredList.size(); i++){
            	wrap.lTemplates.add(filteredList[i]);
            }
            wrap.pagination = filteredList.size()/10;
            wrap.pages = pagination(offset/10, filteredList.size()/10);
        }
        // * /
    }
    */
    public class wrapper{
        @AuraEnabled public Integer pagination;
        @AuraEnabled public List<sObject> lTemplates;
        @AuraEnabled public List<Integer> pages;
        @AuraEnabled public Boolean isSysAdmin = false;
        public wrapper(){
            pagination = 0;
            lTemplates = new List<sObject>();
            pages = new List<Integer>();
            
            list<User> currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            isSysAdmin = currentUser[0].Profile.Name == 'System Administrator' ? true : false;
        }
    }
    
    public class PicklistValues{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistValues(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    public class ConfigWrapper{
        @AuraEnabled public List<PicklistValues> lFolder;
        @AuraEnabled public List<PicklistValues> lCategory;
        public ConfigWrapper(List<PicklistValues> lfolder, List<PicklistValues> lCategory){
            this.lfolder = lfolder;
            this.lCategory = lCategory;
        }
    }
    
    

}