public without sharing class Portal_Controller extends Bootstrap_Controller
{
    public String Target { get; private set; }
    
    private Map<String, String> Keys = new Map<String, String>{
        'listingprotect' => 'LISTING_PROTECT',
        'myaccount' => 'MY_ACCOUNT'
    };
          
    public Portal_Controller() {
        super();
        
        Target = ApexPages.currentPage().getParameters().get('target').toLowerCase();
        Target = String.format('MRIS_{0}_', new String[]{Keys.get(Target)});
    }
}