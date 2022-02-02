({
    doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("id");
        console.log('--subId--'+subId);
        component.set("v.subscriptionId", subId);
        
        helper.fineData(component);
        var columns = [
            {
                type: 'text',
                fieldName: 'name',
                label: 'Office Id',
            },
            {
                type: 'text',
                fieldName: 'Account_Name__c',
                label: 'Account Name',
            },
            {
                type: 'text',
                fieldName: 'Street_Name__c',
                label: 'Street Name',
            },
            {
                type: 'text',
                fieldName: 'Street_Type__c',
                label: 'Street Type',
            },
            {
                type: 'text',
                fieldName: 'City__c',
                label: 'City',
            },
            {
                type: 'text',
                fieldName: 'State__c',
                label: 'State',
            }
            ,
            {
                type: 'text',
                fieldName: 'Zip__c',
                label: 'Zip',
            }
            
        ];
        component.set('v.gridColumns', columns);
        helper.handleChildrecord(component, event);
        helper.getBrandPicklistValues(component, event);
        helper.getHoldingCompanyValues(component,event);
        
    },
    handleBrandOnChange :function(component, event, helper){
        if(component.get("v.enableButton")==false)
        {
            component.set("v.enableButton",true);
        }
        var selectedBrandValue=component.get("v.account.Brand__c");
        component.set("v.hasBrandValue",false);
        component.set("v.hasCompanyValue",true);
        var fieldMap = [];
        if(selectedBrandValue=="")
        {
            component.find("companyPicklist").set("v.value","");
        }
        
        if(selectedBrandValue!="")
        {
            var depValues=component.get("v.dependentpicklist");
            Object.keys(depValues).forEach((key) => {
                if(depValues[key].key==selectedBrandValue){
                console.log(depValues[key].value); // 'Bob', 47
                var values = depValues[key].value;
                    for(var val in values.sort()){
                    fieldMap.push({key: values[val], value: values[val]}); 
                    }
    			}
			});
		}

        component.set("v.hasCompanyValue",true); 
        component.set("v.comapnyFieldMap", fieldMap.sort());
        
        console.log('tttddddd',component.get('v.comapnyFieldMap'));
        // helper.handleDependentList(component,event,selectedBrandValue);
        
        },
    handleCompanyOnChange:function(component, event, helper){
        component.set("v.enableButton",true); 
        var selectedCompanyValue = component.find("companyPicklist").get("v.value");
        if(selectedCompanyValue!=""){
            component.set("v.enableButton",false); 
        }
    },
        handleAccountSave:function(component, event, helper){
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            var selectedBrandValue=component.get("v.account.Brand__c");
            var selectedCompanyValue=component.get("v.account.HoldingCompany__c");
            helper.handleUpdateAccount(component, event,userId,selectedBrandValue,selectedCompanyValue);
            component.set("v.enableButton",true);
            component.set("v.hasCompanyValue",false);
            component.set("v.hasBrandValue",true);
            
        },
            closeModel : function(component, event, helper) {
                $A.util.addClass( component.find( 'toastModel' ), 'slds-hide' );
                component.set("v.messageType", "");
                component.set("v.messageType", "");
            }
})