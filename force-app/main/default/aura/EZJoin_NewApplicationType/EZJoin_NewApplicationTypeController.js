({
	appTypeClickEvtHandler : function(component, event, helper) {

        var ctarget = event.currentTarget; 
        var typeSelected = ctarget.dataset.value;

            switch(typeSelected) {
                case 'Agent':
                    window.location = '/eProcess/EZJoin_NewApplication?type=Agent';
                    break;
                case 'OS':
                    window.location = '/eProcess/EZJoin_NewApplication?type=OfficeSecretary';
                    break;
                case 'PA':
                    window.location = '/eProcess/EZJoin_NewApplication?type=PersonalAssistant';
                    break;
                case 'BR':
                    window.location = $A.get("$Label.c.EZJoin_Broker_Link");
                    break;
                case 'AB':
                    window.location = '/eProcess/EZJoin_NewApplication?type=AssociateBroker';
                    break;
                case 'Reinstate':
                    window.location = '/eProcess/EZJoin_Reactivate';
                    break;
                case 'ApplicationStatus':
                    window.location = '/eProcess/EZJoin_ApplicationStatus';
                    break;                 
            }
     	}
})