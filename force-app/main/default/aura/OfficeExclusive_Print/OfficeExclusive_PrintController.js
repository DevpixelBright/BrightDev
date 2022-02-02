({
    
    printPage : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction").fire();
        var id=component.get("v.recordId");
        window.open("/apex/Communities_OfficeExclusivesPDF?id="+id,'_blank');
        
    }	
})