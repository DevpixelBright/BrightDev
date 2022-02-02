@isTest(seeAllData = true)
private class govtagencytest {

    static testMethod void testForGovernmentAgency() {
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        Account objGAAcc = TestData_UtilCls.createAccount('TSTA12345', 'Government Agency', null, 'Subcontractor', null ); //'Residential','XYZ123',
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objGAAcc.Id);
        objGAAcc.Billing_Period__c = 'Quarterly';
        objGAAcc.status__c = 'Active';
        update objGAAcc;
        
        //SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
    }
    static testMethod void testForGAWithZuoraAcc() {
        try{
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        Account objGAAcc = TestData_UtilCls.createAccount('TSTA12345', 'Government Agency', null, 'Subcontractor', null ); //'Residential','XYZ123',
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objGAAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', Government_Agency_Rateplans__c.getInstance('Subcontractor').Zuora_Product_Rate_Plan_Id__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        objGAAcc.Billing_Period__c = 'Quarterly';
        objGAAcc.status__c = 'Active';
        
        update objGAAcc;
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
        }
    }
    
    static testMethod void testForBrokerOff() {
        try{
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        
        
        Account objGAAcc = TestData_UtilCls.createAccount('TSTA12345', 'Residential', 'Broker Office', 'Subcontractor', null ); //'Residential','XYZ123',
        Contact objCon = TestData_UtilCls.createContact(objGAAcc.Id);
        
        Subscriptions__c objSub = TestData_UtilCls.createSubscription(objGAAcc.Id, objCon.Id);
        objSub.status__c = 'Active';
        update objSub;
        
        Relationship__c objRel = TestData_UtilCls.createRetsRelationship(objGAAcc.Id, objCon.Id, objSub.Id, 'Broker Of Record');
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objGAAcc.Id);
        
        //objGAAcc.ParentId = objParent.Id;
        objGAAcc.status__c = 'Active';
        update objGAAcc;
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
        }
    }
    
    static testMethod void testForBrokerOffWithZuoraAcc() {
        Government_Agency_Rateplans__c gAgencyRtPlan = new Government_Agency_Rateplans__c();
        gAgencyRtPlan.Name = 'BrokerageOffice';
        gAgencyRtPlan.Zuora_Product_Id__c = '2cdft45236ehwrf3j2of';
        gAgencyRtPlan.Zuora_Product_Rate_Plan_Charge_Id__c = '2cdft45236ehwrui3j2m';
        gAgencyRtPlan.Zuora_Product_Rate_Plan_Id__c = '2cdft45236ehwrui3j67';
        insert gAgencyRtPlan;
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        TestData_UtilCls.generateCornerstone();             
        Account objGAAcc = TestData_UtilCls.createAccount('TSTA12345', 'Residential', 'Broker Office', 'Subcontractor', null ); //'Residential','XYZ123',
        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', objGAAcc.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('ProductRatePlanId', Government_Agency_Rateplans__c.getInstance('BrokerageOffice').Zuora_Product_Rate_Plan_Id__c);
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        
        objGAAcc.status__c = 'Active';
        update objGAAcc;
      
    }
}