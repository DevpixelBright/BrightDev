@istest(seealldata = true)
private class SMS_CreditBalance_Controller_Test{

    private static testMethod void doTestOne() {
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Balance', '23');
        preDefinedValues.put('CreditBalance', '20');
        preDefinedValues.put('TotalInvoiceBalance', '20');
        //SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;       
    
        SMS_CreditBalance_Controller obj = new SMS_CreditBalance_Controller();
        obj.zAccountsSelected = '123sdfdfsd4543, wfewrew234324';
        obj.applyCreditBalance();
    }

}