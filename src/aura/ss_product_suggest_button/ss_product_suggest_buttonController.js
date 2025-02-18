/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 11/2/17.
 */
({
	// NOTE
	// This code assumes we are on the Contact record and pulls the contact ID from the URL
	// This will fail if not called whilst on the contact page

	suggestToUser : function (component, event, helper) {
		var self = helper;

		var url       = window.location.href;
		var urlParts  = url.split("/");
		var urlLength = urlParts.length;
		var contactId = urlParts[urlLength-2];

		var dataRecord = component.find('contactDataRecord');
		component.set('v.contactId', contactId);

		component.set('v.buttonSuggest', component.get('v.buttonLabelSuggested'));
		component.set('v.buttonVariant', self.custom.BUTTON_INVERSE);

		window.setTimeout(function() {
			component.set('v.buttonSuggest', component.get('v.buttonLabelSuggest'));
			component.set('v.buttonVariant', self.custom.BUTTON_BRAND);
		}, self.custom.BUTTON_DELAY);

		dataRecord.reloadRecord();
	},

	handleUserLoaded : function (component, event, helper) {
		var eventParams = event.getParams();

		if (eventParams.changeType === 'LOADED') {
			var contact = component.get('v.targetContact');
			var message = component.get('v.toastMessage')
							.replace('{0}', contact.Name)
							.replace('{1}', component.get('v.productName'));

			helper.doCallout(component, 'c.sendSuggestedEmail',
				{
					'contactName'  : contact.Name,
					'contactEmail' : contact.Email,
					'productId'    : component.get('v.productId')
				}, false, 'Suggest Product')
				.then(function () {
					helper.showMessage('success', 'Suggestion', message);
				});
		}
		else if (eventParams.changeType === 'ERROR') {
			console.log('Error loading contact information for suggesting a product');
			helper.showMessage('error', 'Suggestion', 'Failed to load contact information');
		}
	}
})
