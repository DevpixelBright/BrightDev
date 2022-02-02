@isTest
private class Communities_RETS_Product_Controller_Test {

    static testMethod void myUnitTest() {
        
        TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TESTA1', 'RETS', null, 'Subcontractor', null );
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TEST1', objRetsAcc.Id, objSubProd.Id, objSub.Id, null, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
        
        
        PageReference myVfPage = Page.Communities_RETS_Product_VF;
		Test.setCurrentPage(myVfPage);
		// Put Id into the current page Parameters
		ApexPages.currentPage().getParameters().put('id',objSub.Name);
		
        Communities_RETS_Product_Controller objRetsProdCon = new Communities_RETS_Product_Controller();
    }
}