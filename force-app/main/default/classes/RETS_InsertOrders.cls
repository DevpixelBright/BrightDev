public class  RETS_InsertOrders{
    public static  void createAccountproductorders() {
          Account objAcc = new Account();
           objAcc.name = 'ADA1231';
           objAcc.type = 'RETS';
           objAcc.Company_Type__c = 'Subcontractor';
           objAcc.Account_Name__c = 'Main Account';
           objAcc.City__c = 'Herndon';
           objAcc.Zip__c = '20171';
           objAcc.QAS_Mailing_County__c = 'Fairfax';
           objAcc.County__c = 'Fairfax';
           objAcc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
           objAcc.RETS_Billing_Type__c = 'Subcontractor';
           objAcc.status__c = 'In Progress';
    
           insert objAcc;
        objAcc.status__c = 'Active';
            update objAcc;

      
    
   LIST<RETS_Product_Order__c> Prodord = new LIST<RETS_Product_Order__c>();
   
   for(integer i=1; i<=10; i++){
       RETS_Product_Order__c objPrdOrd = new RETS_Product_Order__c();
      objPrdOrd.Vendor_Order_ID__c = 'Test name'+i;
      objPrdOrd.Vendor_Product__c = objAcc.Id;
       if(i < 4){
           objPrdOrd.Agent__c = 'a06J000000KRnuT';}
      else
          objPrdOrd.Brokerage__c = '001J000001zWbow';
      objPrdOrd.status__c = 'In Progress';
      Prodord.add(objPrdOrd);
    }
   insert Prodord;
    }      
}