({
	 fineData : function(component) {

        var action = component.get("c.getDetails");
        action.setParams({
            subId: component.get("v.subscriptionId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                component.set("v.account", response.getReturnValue());

		var action = component.get("c.findHierarchyData");
            action.setParams({
            recId: component.get("v.account").Id
        });
        
        //console.log(JSON.stringify(params));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Processed successfully at server');
                //callback.call(this,response.getReturnValue());
                var apexResponse  = response.getReturnValue();
                var expandedRows = [];
                var roles = {};
                    roles[undefined] = { Name: "Root", _children: [] };
                    apexResponse.forEach(function(v) {
                        expandedRows.push(v.Id);
                        roles[v.Id] = { 
                            name: v.Name ,
                            Account_Name__c: v.Account_Name__c,
                            Street_Name__c:v.Street_Name__c,
                            Street_Type__c:v.Street_Type__c,
                            City__c:v.City__c,
                            State__c:v.State__c,
                            Zip__c:v.Zip__c,
                            _children: [] };
                    });
                    apexResponse.forEach(function(v) {
                        roles[v.ParentId]._children.push(roles[v.Id]);   
                    });                
                    component.set("v.gridData", roles[undefined]._children);
                    console.log('*******treegrid data:',JSON.stringify(roles[undefined]._children));
                    component.set('v.gridExpandedRows', expandedRows);
                var tree = component.find('mytree');
        		tree.expandAll();
                }
                   
        
            else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
		$A.enqueueAction(action);
               
            }
           
        });
        $A.enqueueAction(action);   	
    },
    getBrandPicklistValues: function(component, event) {
        var action = component.get("c.getBrandFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.brandFieldMap", fieldMap);
                component.set("v.showModel",true);
            }
        });
        $A.enqueueAction(action);
    },
    getHoldingCompanyValues: function(component, event) {
        var action = component.get("c.getHoldingCompanyFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.dependentpicklist", fieldMap);
            }
            console.log('--->',component.get("v.dependentpicklist"));
        });
        $A.enqueueAction(action);
    },
    handleUpdateAccount : function(component, event,userId,selectedBrandValue,selectedCompanyValue) {
        console.log('*******userId:',userId);
        console.log('*******selectedBrandValue:',selectedBrandValue);
         var action = component.get("c.updateBrokerInformation");
        
        action.setParams({
            accountId: component.get("v.account.Id"),
            brandValue:selectedBrandValue,
            companyValue:selectedCompanyValue,
            userId:userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //var state="ERROR";
            if (state === "SUCCESS") {
                component.set("v.message","Success: Your information is now updated to include this Brand Affiliation.");
                component.set("v.showToast",true);
                /*var closeTime='5000';
                      setTimeout(function(){ 
                    $A.util.addClass( component.find( 'toastModel' ), 'slds-hide' ); 
                    component.set("v.message", "");
                    component.set("v.messageType", "");
                }, closeTime);*/
            }
            if (state === "ERROR") {
                component.set("v.message","Error: An error was encountered while submitting this update. Please refresh this page and try again.  If the issue persists, contact our Support Center at support@brightmls.com.");
                component.set("v.showToast",true);
                component.set("v.messageType", "error");
            }
        });
        $A.enqueueAction(action);
    },
      handleChildrecord: function(component, event) {
          var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getParentAccount");
           action.setParams({
            //userId:userId,
               subId: component.get("v.subscriptionId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result==true)
                {
                    component.set("v.isChilduser",true);
                }
            }
        });
        $A.enqueueAction(action);
    },
})