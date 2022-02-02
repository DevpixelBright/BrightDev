public without sharing class Communities_OfficeExclusives_Print 
{
    public string subId {get; set;}
    public List<OfficeExclusiveCertification.officeExclusiveWrapper> officeExclusives{get; set;}
        public Communities_OfficeExclusives_Print()
        {
            subId = ApexPages.currentPage().getParameters().get('id');
            officeExclusives = new List<OfficeExclusiveCertification.officeExclusiveWrapper>();
            officeExclusives = OfficeExclusiveCertification.getDataMethod(subId);
        }
}