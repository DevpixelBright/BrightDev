trigger QASErrorReporting on QAS_NA__QAS_CA_Account__c (after update) {

//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

for (Integer currentRecord = 0; currentRecord < trigger.new.size(); ++currentRecord) {
QAS_NA__QAS_CA_Account__c newRecord = trigger.new[currentRecord];
QAS_NA__QAS_CA_Account__c oldRecord = trigger.old[currentRecord];
if((newRecord.QAS_NA__LastErrorMessage__c != null || oldRecord.QAS_NA__LastErrorMessage__c != null)
&& newRecord.QAS_NA__LastErrorMessage__c != oldRecord.QAS_NA__LastErrorMessage__c) {
String[] ccAddresses = new String[1];
ccAddresses[0] = 'salesforcemonitor@qas.com';
String[] toAddresses = new String[1];
toAddresses[0] = 'kalyan.chintala@mris.net';
String subject = 'Error occurred in the QAS validation software';
String message = 'Hello,\nYour QAS for Salesforce.com integration is experiencing an error. Please contact Experian QAS support with questions at http://support.qas.com/contact.htm.\n\nScript-thrown exception: ' + newRecord.QAS_NA__LastErrorMessage__c;
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(toAddresses);
mail.setCcAddresses(ccAddresses);
mail.setSubject(subject);
mail.setUseSignature(false);
mail.setHtmlBody(message);
// Send the email
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}

}