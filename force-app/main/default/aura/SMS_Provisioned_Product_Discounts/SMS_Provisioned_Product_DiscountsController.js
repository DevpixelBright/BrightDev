({
    
    doInit : function(component, event, helper) {
        var action = component.get("c.getProductRatePlans");
        var productId = component.get('v.productId');
        action.setParams({
            recordId : component.get('v.recordId'),
            provisionedStatus : component.get('v.SMSProvisionedProduct.Provisioned_Status__c'),
            productSubType : component.get('v.SMSProvisionedProduct.Product_Sub_Type__c')
        });
        
        action.setCallback(this, function(response) {
            try{
                var modalwindow = document.getElementsByClassName("slds-modal__content");
                modalwindow[0].classList.remove("slds-p-around--medium");
            }catch(ex){console.log(ex);}
            var state = response.getState();
            component.set('v.loading', false);
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set('v.options', response.getReturnValue());
            }else{
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action); 
        component.set('v.stylecss', '<style>.cuf-content{padding:0px !important;} .slds-modal__content{ padding:0 !important;height: auto !important; }</style>')
    },
    onSubmit :function(component, event, helper) {
        component.set('v.isDisabled', true);
        var action = component.get("c.applyDiscount");
        var selectedValue = component.get('v.selectedValue');
        selectedValue = selectedValue.split('-');
        action.setParams({
            zDiscountRateplanId : selectedValue[0],
            zDiscountRateplanChargeId : selectedValue[1],
            recordId : component.get('v.recordId')
        });
        
        action.setCallback(this, function(response) {
            component.set('v.isDisabled', true);
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(response.getReturnValue() === true){
                    component.find('notifLib').showToast({
                        "variant": "success",
                        "message": $A.get("$Label.c.Apply_Discounts_Success")
                    });
                }else{
                    component.find('notifLib').showToast({
                        "variant": "error",
                        "message": $A.get("$Label.c.Apply_Discounts_Error")
                    });
                }
                $A.get("e.force:closeQuickAction").fire();
            }else{
                console.log(response.getError());
                component.find('notifLib').showToast({
                    "variant": "error",
                    "message": "Something went wrong!"
                });
            }
        });
        $A.enqueueAction(action); 
    },
    
    handleCancel: function(){
        $A.get("e.force:closeQuickAction").fire();
    }
    
})