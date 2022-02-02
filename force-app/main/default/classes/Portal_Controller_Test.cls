@isTest
public class Portal_Controller_Test
{
    static testMethod void testDoTest() 
    {
         PageReference portalPage = Page.Portal;
         portalPage.getParameters().put('target', 'listingprotect');
         Test.setCurrentPage(portalPage);
         
         Portal_Controller portal = new Portal_Controller();       
    }
}