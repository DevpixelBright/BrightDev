public class ContentDocumentDataDisplay {
    @AuraEnabled
    public Static String fetchContentDocumentData(String Id) {
        system.debug('### Id::'+Id);
        // ka3J00000000e4WIAQ
        
        Knowledge__kav doc = [SELECT KB_Article_Content_RTF__c from Knowledge__kav where id='ka3J00000004gdsIAA'];
        ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:Id];
        system.debug('### ContentDocumentLink::'+cdl);
        List<ContentVersion> cv = [SELECT Id,Title,VersionData,Description FROM ContentVersion where ContentDocumentId=:cdl.ContentDocumentId AND IsLatest = true];
        system.debug('### ContentVersion::'+cv);
        
        HttpRequest tmp = new HttpRequest();
        tmp.setBodyAsBlob(cv[0].VersionData);
        String value = tmp.getBody();
        system.debug('### value'+value); 
                
        ContentDocument cd = [Select id,Title,FileType,CreatedBy.Name,ContentSize From contentDocument Where Id=:cdl.ContentDocumentId];
        system.debug('### ContentDocument::'+cd);
        
        return doc.KB_Article_Content_RTF__c;
    }
}