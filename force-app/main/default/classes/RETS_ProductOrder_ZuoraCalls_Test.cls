/**
 
 */
@isTest(seeAllData = true)
global class RETS_ProductOrder_ZuoraCalls_Test {
     static testMethod void prodOrdForSubcontractor() {
     	
     	SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
     	TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA1', 'RETS', null, 'Subcontractor', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
         
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TST2', objRetsAcc.Id, objSubProd.Id, objSub.Id, null, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
     }
    
    static testMethod void prodOrdForSubcontractorWithRatePlan() {
     	
     	SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
     	TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA1', 'RETS', null, 'Subcontractor', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
         
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductRatePlanId__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TST2', objRetsAcc.Id, objSubProd.Id, objSub.Id, null, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
     }
    static testMethod void prodOrdForSubcontractorWithVendorRatePlan() {
     	
     	SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
     	TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA1', 'RETS', null, 'Subcontractor', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
         
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', RETS_Rate_Plan__c.getInstance('Subcontractor').Zuora_ProductRatePlanId__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TST2', objRetsAcc.Id, objSubProd.Id, objSub.Id, null, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
     }

    
    static testMethod void prodOrdForEnterprise() {
     	
     	SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        SMS_ZuoraMockCall.isSuccess = true;
        
     	TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA1', 'RETS', null, 'Enterprise', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TST2', objRetsAcc.Id, objSubProd.Id, objSub.Id, null, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
     }
    
    static testMethod void prodOrdForBrokerageEnterprise() {
     	
     	SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
     	TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA1', 'RETS', null, 'Enterprise', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Account objBrokerageAcc = TestData_UtilCls.createAccount('TSTB1', 'Residential', 'Broker Office', 'Subcontractor', null);
        objBrokerageAcc.status__c = 'Active';
        update objBrokerageAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TST2', objRetsAcc.Id, objSubProd.Id, null, objBrokerageAcc.Id, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
     }
    static testMethod void prodOrdForBrokerageEnterpriseWithRatePlan() {
     	
     	SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
     	TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA1', 'RETS', null, 'Enterprise', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Account objBrokerageAcc = TestData_UtilCls.createAccount('TSTB1', 'Residential', 'Broker Office', 'Subcontractor', null);
        objBrokerageAcc.status__c = 'Active';
        update objBrokerageAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', RETS_Rate_Plan__c.getInstance('BrokerageOffice').Zuora_ProductRatePlanId__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TST2', objRetsAcc.Id, objSubProd.Id, null, objBrokerageAcc.Id, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
     }
    static testMethod void prodOrdForBrokerageEnterpriseWithVendorRatePlan() {
     	
     	SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
     	TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA1', 'RETS', null, 'Enterprise', null ); //'Residential','XYZ123',
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        Account objBrokerageAcc = TestData_UtilCls.createAccount('TSTB1', 'Residential', 'Broker Office', 'Subcontractor', null);
        objBrokerageAcc.status__c = 'Active';
        update objBrokerageAcc;
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', RETS_Rate_Plan__c.getInstance('Enterprise').Zuora_ProductRatePlanId__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        RETS_Sub_Products__c objSubProd = TestData_UtilCls.createSubProd(objRetsAcc.Id, null);
        RETS_Product_Order__c objProdOrd = TestData_UtilCls.createRetsProdOrd('TST2', objRetsAcc.Id, objSubProd.Id, null, objBrokerageAcc.Id, 'In Progress', false);
        objProdOrd.status__c = 'Active';
        update objProdOrd;
     }
}