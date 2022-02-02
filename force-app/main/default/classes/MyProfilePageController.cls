/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {

    private User user;
    private boolean isEdit = false;
    
    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        
    }
    
    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    
    
    public void save() {
       
    }
    
    public PageReference changePassword() {
        return null;
    }
    
    public void cancel() {
       
    }
    
  

    @isTest
    static void testSave() {         
       
            MyProfilePageController controller = new MyProfilePageController();
            controller.cancel();
            controller.changePassword();
            controller.edit();
            controller.getUser();
            controller.save();
            controller.getIsEdit();
    }

}