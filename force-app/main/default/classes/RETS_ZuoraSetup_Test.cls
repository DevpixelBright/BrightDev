@isTest(seeAllData = true)
private class RETS_ZuoraSetup_Test {

    static testMethod void testForRets() {
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA12345', 'RETS', null, 'Subcontractor', null ); //'Residential','XYZ123',
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        
        //SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
    }
    static testMethod void testForRetsWithZuoraAcc() {
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA12345', 'RETS', null, 'Subcontractor', null ); //'Residential','XYZ123',
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', RETS_Rate_Plan__c.getInstance('Subcontractor').Zuora_ProductRatePlanId__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
    }
    
    static testMethod void testForBrokerOff() {
        try{
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        
        
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA12345', 'Residential', 'Broker Office', 'Subcontractor', null ); //'Residential','XYZ123',
        /*
        Account objParent = TestData_UtilCls.createAccount('TSPAR1', 'Corporate', null, 'Subcontractor', null);
        objParent.status__c = 'Active';
        update objParent; 
        */
        
        Contact objCon = TestData_UtilCls.createContact(objRetsAcc.Id);
        
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objRetsAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        Relationship__c objRel = TestData_UtilCls.createRetsRelationship(objRetsAcc.Id, objCon.Id, objSub.Id, 'Broker Of Record');
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        
        //objRetsAcc.ParentId = objParent.Id;
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
        }
    }
    
    static testMethod void testForBrokerOffWithZuoraAcc() {
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        Account objRetsAcc = TestData_UtilCls.createAccount('TSTA12345', 'Residential', 'Broker Office', 'Subcontractor', null ); //'Residential','XYZ123',
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objRetsAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', RETS_Rate_Plan__c.getInstance('BrokerageOffice').Zuora_ProductRatePlanId__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        
        objRetsAcc.status__c = 'Active';
        update objRetsAcc;
    }
}