@isTest
private class RETS_ProductOrder_Test {

    static testMethod void prodOrdForAgent() {
    	
        TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TESTA1', 'RETS', null, 'Subcontractor', null ); //'Residential','XYZ123',
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
    }
    
    static testMethod void prodOrdForBrokerage() {
        
        try{
        TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TESTA1', 'RETS', null, 'Subcontractor', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Account objBrokerageAcc = TestData_UtilCls.createAccount('TESTA2', 'Residential', 'Broker Office', 'Subcontractor', null);
        objBrokerageAcc.status__c = 'Active';
        update objBrokerageAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TEST1', objRetsAcc.Id, objSubProd.Id, null, objBrokerageAcc.id, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
        
        delete objProdOrd;
        //RETS_Product_Order__c objProdOrd2 = TestData_UtilCls.createRetsProdOrd('TEST3', objRetsAcc.Id, objSubProd.Id, null, objBrokerageAcc.id, 'Active', false);
        //RETS_Product_Order__c objProdOrd3 = TestData_UtilCls.createRetsProdOrd('TEST4', objRetsAcc.Id, objSubProd.Id, null, objBrokerageAcc.id, 'Active', true);
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
        }
    }
    
    static testMethod void prodOrdForAgentWithEclusions() {
        try{
        TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TESTA1', 'RETS', null, 'Subcontractor', 'Brokerage' ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Account objBrokerageAcc = TestData_UtilCls.createAccount('TESTA2', 'Residential', 'Broker Office', 'Subcontractor', null);
        objBrokerageAcc.status__c = 'Active';
        update objBrokerageAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        Test.startTest();
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, 'Brokerage');
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TEST1', objRetsAcc.Id, objSubProd.Id, objSub.Id, null, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
        
        objProdOrd.status__c = 'InActive';
        update objProdOrd;
        Test.stopTest();
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
        }
    }
}