public class ComplianceCaseDetailExtension {

    private Shadow_Case__c shdw;

    public ComplianceCaseDetailExtension(ApexPages.StandardController controller) {
        Shadow_Case__c s = (Shadow_Case__c)controller.getRecord();
        shdw = [select id, Related_Case__c, Related_Case__r.Description from Shadow_Case__c where Id = :s.Id limit 1];
    }

    public String CaseDescription {
        get {
            if(shdw == null) return '';
            return shdw.Related_Case__r.Description;
        }
    }
}