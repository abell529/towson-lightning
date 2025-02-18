/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/14/17.
 */
({
	// Constants
	custom : {
		BUTTON_SUCCESS  : 'success',
		BUTTON_INVERSE  : 'inverse',
		BUTTON_BRAND    : 'brand',
		BUTTON_DELAY    : 5000
	},

	action : {
		ADD     : 'add',
		UPDATE  : 'update',
		DELETE  : 'delete',
		CLEAR   : 'clear',
		SUCCESS : 'success'
	},

	filter: {
		FAMILY : 'family'
	},

	doCallout: function (component, method, params, hideToast, toastTitle, cache) {
		var self = this;

        console.log(params);
		return new Promise(function (resolve, reject) {
			var action = component.get(method);
			console.log(action);

			if (params) {
				action.setParams(params);
			}

			// Enable the local cache
			if (cache) {
				action.setStorable();
			}

			console.log(params);
			action.setCallback(component, function (response) {
				var state = response.getState();

				if (component.isValid() && state === "SUCCESS") {
					resolve(response.getReturnValue());
				} else {
					var errors = response.getError();

					if (errors && errors[0] && errors[0].message && !hideToast) {
						self.showMessage("error", toastTitle || 'Callback failed', errors[0].message);
					} else if (!hideToast) {
						self.showMessage("error", 'Callback failed', "Unknown Error");
					}

					reject(errors);
				}
			});

			$A.enqueueAction(action);
		});
	},


    gotoUrl: function (component, url) {
		$A.get("e.force:navigateToURL")
			.setParams({
				'url'       : url,
				'isredirect': true
			}).fire();
	},

	gotoRecord: function (component, recordId) {
		$A.get("e.force:navigateToSObject")
			.setParams({
				"recordId"    : recordId,
				"slideDevName": "related"
			}).fire();
	},

	showMessage: function (level, title, message) {
		console.log("Message (" + level + "): " + message);

		$A.get("e.force:showToast")
			.setParams({
				"title"  : title,
				"message": message,
				"type"   : level
			}).fire();
	},

    /*
    Get a URL paramter by name, Locker Service safe!
    helper.getUrlParameter('YOURPARAMETER')
    Courtesy of https://developer.salesforce.com/forums?id=906F0000000g1blIAA
 */
    getUrlParameter: function getUrlParameter(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }

        return null;
    }

})
