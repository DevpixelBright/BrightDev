@istest(seealldata = true)
public class SMS_LockBoxDeposits_Controller_Test {
    
    private static testMethod void doTestOne() {
        
        SMS_LockBoxDeposits_Controller obj = new SMS_LockBoxDeposits_Controller();
        obj.newPaymentsListStr = '[{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"3053347","selected":false,"recordId":"a1PK0000001hF3AMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"0544","amount":"1000"},{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"9999999","selected":false,"recordId":"a1PK0000001hF3BMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"072517","amount":"1000"}]';
        obj.fileRecords();
        obj.validate();

    } 
    
    private static testMethod void doTestTwo() {
        try {
            SMS_LockBoxDeposits_Controller obj = new SMS_LockBoxDeposits_Controller();       
            obj.paymentsListStr = '[{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"3053347","selected":false,"recordId":"a1PK0000001hF3AMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"0544","amount":"1000"},{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"9999999","selected":false,"recordId":"a1PK0000001hF3BMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"072517","amount":"1000"}]';
            obj.createPayments();
            obj.savePayments();
            obj.deletePayments();
        }
        catch(Exception e) {
        
        }
    } 
    
    private static testMethod void doTestThree() {
        
        SMS_VLockBoxDeposits_Controller obj = new SMS_VLockBoxDeposits_Controller();
        obj.newPaymentsListStr = '[{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"3053347","selected":false,"recordId":"a1PK0000001hF3AMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"0544","amount":"1000"},{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"9999999","selected":false,"recordId":"a1PK0000001hF3BMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"072517","amount":"1000"}]';
        obj.fileRecords();
        obj.validate();

    } 
    
    private static testMethod void doTestFour() {
        try {
            SMS_VLockBoxDeposits_Controller obj = new SMS_VLockBoxDeposits_Controller();       
            obj.paymentsListStr = '[{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"3053347","selected":false,"recordId":"a1PK0000001hF3AMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"0544","amount":"1000"},{"zuoraAcctName":null,"zuoraAcctId":"2c92c0f94ddbecdb014ddd4293592f2a","valid":false,"subscriptionId":"9999999","selected":false,"recordId":"a1PK0000001hF3BMAU","processed":false,"paymentMethod":null,"fileName":"LOCKBOX DEPOSIT 05-26-15.txt","createdDate":"2015-06-22","checkNumber":"072517","amount":"1000"}]';
            obj.createPayments();
            obj.savePayments();
            obj.deletePayments();
        }
        catch(Exception e) {
        
        }
    }                

}