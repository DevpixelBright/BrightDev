({
	init : function(cmp, event, helper) {
        if(cmp.get("v.recordData") && cmp.get("v.fieldName") && cmp.get("v.recordData")[cmp.get("v.fieldName")]){
            cmp.set("v.dataDisplay", cmp.get("v.recordData")[cmp.get("v.fieldName")]);
        }
        if(cmp.get("v.dataType") == "clickable" && cmp.get("v.hrefLink") && cmp.get("v.recordData.Id")){
            cmp.set("v.hrefLinkClickable", cmp.get("v.hrefLink").replace("{recordId}", cmp.get("v.recordData.Id")));
        }
	}
})