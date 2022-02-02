({
	handleClick : function(component, event, helper) {
        debugger;
        var subId=component.get("v.recordId");
            helper.handleDownloadPDF(component, event, helper, subId);
	}

})