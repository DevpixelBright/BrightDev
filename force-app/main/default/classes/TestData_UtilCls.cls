@isTest
public class TestData_UtilCls {
	
	public static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    public static Account createAccount(string AccountName, string Accounttype, string companyType, string billType, string billingExcls) {
        // insert Account
        Account objAcc = new Account();
        objAcc.name = AccountName; //'ADA1231';
        objAcc.type = Accounttype; //'RETS';
        objAcc.Company_Type__c = companyType;
        objAcc.Account_Name__c = 'Main Account';
        objAcc.City__c = 'Herndon';
        objAcc.Zip__c = '20171';
        objAcc.QAS_Mailing_County__c = 'Fairfax';
        objAcc.County__c = 'Fairfax';
        objAcc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        objAcc.RETS_Billing_Type__c = billType;
        objAcc.RETS_Billing_Exclusion__c = billingExcls;
        objAcc.status__c = 'In Progress';
        objAcc.RETS_BillingHasFullDiscount__c = true;
        insert objAcc;
        return objAcc;
    }
    public static RETS_Sub_Products__c createSubProd(string accountId, string billExcl){
    	RETS_Sub_Products__c objSubProd = new RETS_Sub_Products__c();
    	objSubProd.Name__c = 'Test subprod';
    	objSubProd.Vendor_Product__c = accountId;
    	objSubProd.RETS_Billing_Exclusion__c = billExcl; //'Brokerage';
    	insert objSubProd;
    	return objSubProd;
    }
    
    public static contact createContact(String accountId){
        contact objCon = new Contact();
        objCon.Email = 'email@something.com';
        objCon.FirstName = 'Test Class';
        objCon.LastName = 'Contact';
        objCon.Public_Email__c = 'email@something.com';
        objCon.AccountId = accountId; 
        objCon.Salutation = 'Mr.';
        objCon.City__c = 'Herndon';
        objCon.QAS_Mailing_County__c = 'Arlington';
        objCon.Zip__c = '20171';
        objCon.State__c = 'VA';
        insert objCon;
        return objCon;
    }
    
    public Static Subscriptions__c createSubscription(String accountId, String contactId){
        Subscriptions__c objSub = new Subscriptions__c();
        objSub.Name = '12345';
        objSub.Contact__c = contactId;
        objSub.Subscription_Type__c = 'Personal Assistant';
        objSub.Status__c = 'In Progress';
        objSub.City__c = 'Herndon';
        objSub.Zip__c = '20171';
        objSub.County__c = 'Fairfax';
        objSub.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        objSub.AgentKey__c = '123111';
        objSub.name = '123111';
        objSub.County__c = 'Fairfax';
        objSub.Related_Location_Broker_Office__c = accountId;
        objSub.Contact_Type__c = 'Agent';
        //objSub.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert objSub;
        return objSub; 
    }
    
    public static RETS_Product_Order__c createRetsProdOrd(string venName, string vendorId, string subProdId, string subscriptionId, string strBrokerageId, string status, boolean extBill){
    	RETS_Product_Order__c objPrdOrd = new RETS_Product_Order__c();
    	objPrdOrd.Vendor_Order_ID__c = venName;
    	objPrdOrd.Vendor_Product__c = vendorId;
    	objPrdOrd.RETS_Sub_Product__c = subProdId;
    	if(subscriptionId != null)
    		objPrdOrd.Agent__c = subscriptionId;
    	else if(strBrokerageId != null)
    		objPrdOrd.Brokerage__c = strBrokerageId;
    	objPrdOrd.Is_External_Billing__c = extBill;
    	objPrdOrd.status__c = status;
    	insert objPrdOrd;
    	return objPrdOrd;
    }
    
    public static Relationship__c createRetsRelationship(string accId, string conId, string subId, string relType){
    	Relationship__c objRel = new Relationship__c();
    	objRel.Relationship_Type__c = relType; //'Broker Of Record';
    	objRel.Subscription__c = subId;
    	objRel.Contact__c = conId;
    	objRel.Related_Account__c = accId;
    	objRel.Status__c = 'Active';
    	insert objRel;
    	return objRel;    	
    }
}