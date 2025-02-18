({
    // Determine if guest
    initUtilityNavigation: function(component, event, helper) {
        // Create the action
        var action = component.get("c.isGuestUser");

        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isGuest", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
            component.set("v.isInit", true);
        });

        // Send action off to be executed
        $A.enqueueAction(action);
    },
    handleMobileUtilNav: function(component, event, helper) {
        helper.toggleMobileNav(component);
    }
})