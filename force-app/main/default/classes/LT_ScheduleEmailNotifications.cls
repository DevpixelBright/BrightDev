public class LT_ScheduleEmailNotifications implements Schedulable {
   
    public void execute(SchedulableContext sc) {
        LT_EmailNotifications emailnotifications = new LT_EmailNotifications();
        emailnotifications.sendApprovedEmails();
        emailnotifications.sendExpiredEmails();
        emailnotifications.sendRejectedEmails();
        emailnotifications.sendReminderEmails();
        emailnotifications.sendSubmissionEmails();
        emailnotifications.sendSubmissionEmailsforDestinationofc();
    }
}