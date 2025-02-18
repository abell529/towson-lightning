/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 5/2/18.
 */
({

    doCallout: function (component, method, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            // Set action and param
            var action = component.get(method);
            if (params != null) {
                action.setParams(params);
            }
            // Callback
            action.setCallback(component, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    var errors = response.getError();
                    reject(errors);
                }
            });
            $A.enqueueAction(action);
        }));
    },

    showToast: function (type, message) {
        // types: error, warning, success, info
        var toastEvent = $A.get('e.force:showToast');
        if (toastEvent) {
            toastEvent.fire({
                type: type,
                message: message
            });
        }
    }
})