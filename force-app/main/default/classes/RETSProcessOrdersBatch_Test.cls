@isTest(seeAllData = true)
public class RETSProcessOrdersBatch_Test {
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
        objProdOrd.Start_Date__c = system.today();
        objProdOrd.ZuoraVendorProductIntegrationStatus__c = 'true';
        update objProdOrd;
       
       String query = 'SELECT Id, Name, Agent__c, Agent__r.Name, Status__c, ImportSourceID__c, ZuoraVendorProductIntegrationStatus__c,Start_Date__c FROM   RETS_Product_Order__c  WHERE  id = \''+objProdOrd.id+'\'';
       String zProductRatePlanId_rm = '2c92c0f860584120016068982f177965';
       String zProductRatePlanChargeId_rm = '2c92c0f8605841200160689959cb7a48';
       String zProductRatePlanId_add = '2c92c0f861789eda0161b1d63a2c1fe8';
       String zProductRatePlanChargeId_add = '2c92c0f96178a7ae0161b6d7d7044027';
       String effectiveDate = objProdOrd.Start_Date__c.format('yyyy-MM-dd\'T\'00:00:00');
       String batch = 'Batch47';
       RETSProcessOrdersBatch retsbatch = new RETSProcessOrdersBatch(query,zProductRatePlanId_rm,zProductRatePlanChargeId_rm,zProductRatePlanId_add,zProductRatePlanChargeId_add,effectiveDate,batch);
       Database.executeBatch(retsbatch,1);
     }
}