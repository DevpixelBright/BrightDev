({
	doInit: function(component, event, helper) {
        var d = new Date();
        var n = d.getFullYear();
        //var n = d.getDay();
        //var n = d.getDate();
        component.set("v.currentYear", n);
    },
})