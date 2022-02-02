public class Communities_OfficeExclusivePDF {
    public String officeExclusiveName { get; set; }
    public Office_Exclusive__c sOfficeExclusive {get;set;}
    
   public Communities_OfficeExclusivePDF(){
        try{
            officeExclusiveName = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(officeExclusiveName))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found' );
            sOfficeExclusive = [SELECT id,
                                Name,
                                List_Agent_ID__r.Name,
                                List_Agent_Name__c,
                                List_Agent_ID__r.Primary_Phone__c,
                                List_Office_ID__r.Name,
                                List_Office_Name__c,
                                Listing_Agreement_Date__c,
                                Listing_Expiration_Date__c,
                                List_Office_ID__r.Phone,
                                Seller_Landlord_Name_1__c,
                                Property_Address__c,
                                Seller_Landlord_Name_2__c,City__c,Unit_Type__c,
                                State__c,ZIP__c, New_Construction__c  from Office_Exclusive__c
                                where id =:officeExclusiveName LIMIT 1];        
            
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getStackTraceString()));
        }
    }
    public class CustomException extends Exception {}
}