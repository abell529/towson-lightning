/**
 * Created by francoiskorb on 9/1/17.
 */
({
	doInit: function (component, event, helper) {
		helper.getPicklists(component);
	},

	onLocationTypeAhead : function (component, event, helper) {
		var fieldId = event.getSource().getLocalId();

		helper.clearInvalidField(component, fieldId);

		var threshold    = component.get('v.searchThreshold');
		var searchString = component.get('v.' + fieldId);

		if (searchString.length === 0 || searchString.length >= threshold) {
			helper.getEventPicklistValues(
				component,
				fieldId,
				'Location_Name__c',
				'v.locationValues',
				searchString);
		}

	},

	onFilterEvents : function(component, event, helper) {
		helper.fireSearchEvent(component);
	}
})