public class Communities_OE_Subscription_Print {
public string subId {get; set;}
    public List<OfficeExclusiveSubscription.officeExclusiveWrapper> officeExclusives{get; set;}
        public Communities_OE_Subscription_Print()
        {
            subId = ApexPages.currentPage().getParameters().get('id');
            officeExclusives = new List<OfficeExclusiveSubscription.officeExclusiveWrapper>();
            officeExclusives = OfficeExclusiveSubscription.getDataMethod(subId);
        }
}