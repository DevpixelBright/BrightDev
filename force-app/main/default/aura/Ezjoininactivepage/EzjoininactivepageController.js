({
    
    doInit: function(component, event, helper) {
        helper.getSubscriptionValues(component);
        var d = new Date();
        var n = d.getFullYear();
        component.set("v.currentYear", n);
    },
    
    appTypeClickEvtHandler : function(component, event, helper) {
        console.log(component.get('v.pageReference'));
        var id = component.get("v.subscription");
        window.open("/customers/apex/Communities_SOA?id="+id.Name,'_blank');
    },
    appTypeClickEvtHandler1 : function(component, event, helper) {
        console.log(component.get('v.pageReference'));
        var id = component.get("v.subscription");
        window.open("/customers/apex/Communities_PayMyBalances?id="+id.Name,'_blank');
    },
    appTypeClickEvtHandler2 : function(component, event, helper) {
       helper.getActionValues(component);
    }
})