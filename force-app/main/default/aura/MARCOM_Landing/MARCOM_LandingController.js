({
    doInit : function(component, event, helper) {
        helper.getEmailTemplates(component, event, helper);
        helper.getConfig(component, event, helper);
    },
    
    lastPage : function(component, event, helper){
        var pagination = component.get('v.pagination');
        component.set('v.currentPage',pagination);
        //helper.getEmailTemplates(component, event, helper);
        helper.pageTemplates(component);
    },
    
    firstPage : function(component, event, helper){
        component.set('v.currentPage', 1);
        //helper.getEmailTemplates(component, event, helper);
        helper.pageTemplates(component);
    },
    
    getPage : function(component, event, helper){
        var ctarget = event.currentTarget; 
        var offset = ctarget.dataset.offset;
        component.set('v.currentPage', parseInt(offset));
        //helper.getEmailTemplates(component, event, helper);
        helper.pageTemplates(component);
    },
    
    onConfigChange : function(component, event, helper){
        component.set('v.currentPage', 1);
        helper.getEmailTemplates(component, event, helper);
    },
    
    openPopup : function(component, event, helper){
        var ctarget = event.currentTarget; 
        var templateId = ctarget.dataset.templateid;
        var modalBody;
        $A.createComponent("c:MARCOM_Popup", {emailTemplateId: templateId},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       body: modalBody,
                                       showCloseButton: false
                                   })
                               }
                           });
    },
    
    sortField : function(component, event, helper){
        var columnName = event.currentTarget.getAttribute('data-columnName');
        var sortColumn = component.get('v.sortColumn');
        if(sortColumn == columnName){
            component.set('v.descending', !component.get('v.descending'));
        }else{
            component.set('v.sortColumn', columnName);
            component.set('v.descending', false);
        }
        helper.getEmailTemplates(component, event, helper);
    },
    
    sortByColumn : function(component, event, helper){
        component.set('v.currentPage', 1);
        helper.sortByColumn(component, event);
    },
    
    navigateToTemplate : function(component, event, helper){
        var templateId = event.currentTarget.getAttribute('data-template-id');
        //alert(templateId);
        var navEvt = $A.get("e.force:navigateToSObject");
        if(navEvt){
            navEvt.setParams({
                "recordId": templateId
            });
            navEvt.fire();
        }
    },
    
    printSelectedEmail : function(component, event, helper){
        var redirectParam = '';
        var emails = component.find('selectedEmail');
        if(emails && emails != null && emails.length > 0){
            for(var selectedEmail of emails){
                if(selectedEmail.get('v.checked') == true){
                    redirectParam += (((redirectParam != '')?',':'') + selectedEmail.get('v.value'));
                }
            }
        }
        
        if(redirectParam != ''){
            window.open("/apex/PrintEmailTemplate?id="+redirectParam, '_blank');
        }else{
            component.find('notifLib').showToast({
                "variant" : "error",
                "title": "Error",
                "message": "Please select the email template(s) you want to print."
            });
        }
        
    },
    
    selectAll : function(component, event, helper){
        var allValue = component.find('selectAllCheckbox').get('v.checked')
        var emails = component.find('selectedEmail');
        if(emails && emails.length > 0){
            for(var selectedEmail of emails){
                selectedEmail.set('v.checked', allValue);
            }
        }
    }
})