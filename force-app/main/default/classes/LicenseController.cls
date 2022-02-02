public class LicenseController {
    public static void sendEmail(){
        EmailTemplate templateId = [Select id from EmailTemplate where name = 'Subscriber_License_Expiring_1_day'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-reply@brightmls.com'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setTemplateID(templateId.Id); 
        mail.setToAddresses(new List<String>{'pavan@devpixel.com'});
        //mail.setTargetObjectId(contactId);
        mail.setSaveAsActivity(false);
        allmsg.add(mail);
        Messaging.sendEmail(allmsg);
    }
}