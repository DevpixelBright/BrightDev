({
    init : function(component, event, helper) {
        /*var today = $A.localizationService.formatDate(new Date(), "MM/dd/yyyy");
        component.set('v.today', today);
        var timezone = $A.get("$Locale.timezone");
        console.log('Time Zone Preference in Salesforce ORG :'+timezone);
        var mydate = new Date().toLocaleString("en-US", {timeZone: timezone});
        console.log('mydate----'+mydate);
        component.set('v.today', mydate.split(",")[0]);*/
        console.log('initform----');
        var action = component.get("c.getCaseCreatedDate");
        action.setParams({
            caseId : component.get("v.caseId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('states'+state);
            if(state === "SUCCESS") {
                var createdDate = response.getReturnValue();
                component.set('v.today', createdDate);
            }
        });
        $A.enqueueAction(action); 
    },
    
    handleClick : function(component, event, helper) {
        var subdivRbuildName;
        if(component.get("v.subDivisionOrBuilding") == "Subdivision"){
            subdivRbuildName = component.get("v.caseDescJson.Subdivisionname");
        }else{
            subdivRbuildName = component.get("v.caseDescJson.BuildingName");
        }
        window.open("/customers/apex/SubdivisionBuildingFormPDF?subDivRbuild="+component.get("v.subDivisionOrBuilding")+"&name="+subdivRbuildName+"&caseId="+component.get("v.caseId"), '_blank');
    }
})