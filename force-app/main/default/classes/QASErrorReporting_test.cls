@isTest
public with sharing class QASErrorReporting_test{
private static testmethod void TestAll() {
QAS_NA__QAS_CA_Account__c accountSObject = new QAS_NA__QAS_CA_Account__c( QAS_NA__LicenseKey__c='NO_SUCH_KEY'
, QAS_NA__IsNullOrEmptyValidCountry__c = true
, QAS_NA__ValidCountryValues__c = '\'US\',\'United States\', \'Canada\', \'CAN\''
, QAS_NA__TriggerRecordsLimit__c = 2
, QAS_NA__InteractiveIntervalFromLastUpdate__c = 1000
, QAS_NA__InteractiveInvokeIntervalFromLastUpdate__c = 200
, QAS_NA__NumberOfFailedAttempts__c = 0
, QAS_NA__LastFailedValidation__c = System.now()
, QAS_NA__ValidationTypes__c = 15
, QAS_NA__ValidationAttemptsPeriodInMinutes__c = 5);
insert accountSObject ;
accountSObject.QAS_NA__LastErrorMessage__c = 'Test error message';
update accountSObject;
}

}