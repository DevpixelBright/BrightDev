({
	handleDownloadPDF: function (component, event, helper, subId) {
        debugger;
        var action = component.get('c.downloadWithPdf');
        action.setParams({
            'subId':subId

        });
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
             var blob = actionResult.getReturnValue();
            if (status === "SUCCESS") {
        		let downloadLink = document.createElement("a");
        		downloadLink.setAttribute("type", "hidden");
        		downloadLink.href = "data:text/html;base64,"+actionResult.getReturnValue();
                downloadLink.download = 'Good Standing Template.pdf';//'Statement-'+component.get('v.productName')+'-'+pciNumber.substr(-4)+'-'+statementDate.replace(/-/g, "")+'.pdf';//result.responseData.fileName;
        		document.body.appendChild(downloadLink);
        		downloadLink.click();
        		downloadLink.remove();
            } else if (status === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
            else {
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);
    },
    handleErrors: function (errors, addError) {
        // Configure error toast
        let toastParams = {
            mode: "sticky",
            title: "Erreur",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = addError + '' + errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
})