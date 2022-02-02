({
    onInit : function(component, event, helper) {
        var action = component.get("c.fetchContentDocumentData");
        //var recordId = component.get("v.recordId");
        //var id ='001J000002Dxk0fIAB'; //csv
        var id ='001J0000020MwmvIAC'; //MS - word
        action.setParams({
            "Id":id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==="SUCCESS"){
                //alert('Data ::'+response.getReturnValue());
                component.set("v.contentData",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);	
    }
})