({
    init: function (component) {
        component.set('v.updatedCount', 12);
        component.set('v.selectedItem', 'reports_recent');
        component.set('v.currentContent', 'reports_recent');
    },

    handleSelect: function(component, event, helper) {
        var selected = event.getParam('name');

        if (selected === 'reports_updated') {
            component.set('v.updatedCount', 0);
        }

        component.set('v.currentContent', selected);

    }
});