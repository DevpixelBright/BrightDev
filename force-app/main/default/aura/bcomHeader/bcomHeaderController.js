({
	afterScriptsLoaded : function(cmp, event, helper) {
		alert("loaded script");
        $A.createComponent(
            "lightning:button",
            {
                "aura:id": "bcomHeader",
                "label": "Press Me",
                "onclick": cmp.getReference("c.handlePress")
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body.push(newButton);
                    cmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
	},

    handlePress : function(cmp) {
        // Find the button by the aura:id value
        console.log("button: " + cmp.find("findableAuraId"));
        console.log("button pressed");
    },

    doInit : function(cmp) {
        var currentUrl = new URL(window.location);
        var subscriptionId = currentUrl.searchParams.get("Id");
        console.log('--subId--'+subscriptionId);
        
        alert("on load");
        const link = document.createElement('link')
        link.href = 'https://menu.dev.brightmls.com/assets/menu/css/brightmlsmenu.min.css'
        //link.href = '{!$Label.BCOM_Header_CSS}'
        link.type = 'text/css'
        link.rel = 'stylesheet'                     
        const script = document.createElement('script')
        script.src = 'https://menu.dev.brightmls.com/assets/menu/js/brightmlsmenu.js'
        //script.src = '{!$Label.BCOM_Header_JS}'
        script.async = true
        script.onload = () => window.InitMenu(Number(subscriptionId), Number(subscriptionId), 'N', false, false);
        
        var body = cmp.get("v.body");
        body.push(script);
        body.push(link);
        cmp.set("v.body", body);
        document.getElementsByTagName('head')[0].appendChild(script)
        document.getElementsByTagName('head')[0].appendChild(link)
    }
})