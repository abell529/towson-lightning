/**
 * Created by francoiskorb on 9/1/17.
 */
({

	getPicklists: function (component) {
		this.getEventPicklistValues(component, 'locationTypeAhead', 'Location_Name__c', 'v.locationValues', '');
	},

	setInvalidField : function (component, fieldId) {
		//var inputField = component.find(fieldAuraId);
		//inputField.set('v.validity', {valid:false, badInput :true});

		$A.util.addClass(component.find(fieldId), 'showInvalid');
	},

	clearInvalidField : function (component, fieldId) {
		//var inputField = component.find(fieldAuraId);
		//inputField.set('v.validity', {valid:true, badInput :false});
		$A.util.removeClass(component.find(fieldId), 'showInvalid');
	},

	getEventPicklistValues: function (component, fieldAuraId, fieldName, valueSet, searchString) {
		var action = component.get('c.getEventsPicklist');

		action.setParams({
			'fieldName'    : fieldName,
			'searchString' : searchString
		});

		action.setStorable();

		action.setCallback(this, function (actionResult) {
			if (actionResult.getState() === 'SUCCESS') {
				var values = actionResult.getReturnValue();

				if (searchString.length && !values.length) {
					console.log('Type ahead pickList empty for ' + fieldName);
					this.setInvalidField(component, fieldAuraId);
				}

				values.unshift(component.get('v.selectAll'));
				component.set(valueSet, values);
			}
		});

		$A.enqueueAction(action);

	},

	fireSearchEvent: function (component) {
		var selectAll      = component.get('v.selectAll');
		var locationEvent  = $A.get("e.c:SVNSUMMITS_Events_Location_Filter_Event");
		var locationString = '';

		if (component.get('v.locationFilter')) {
			var locationFilter = component.get('v.locationFilter');

			if (locationFilter.length && locationFilter !== selectAll) {
				locationString = locationFilter;
			}
		}

		locationEvent.setParams({
			'locationString' : locationString
		});

		locationEvent.fire();
	}

})