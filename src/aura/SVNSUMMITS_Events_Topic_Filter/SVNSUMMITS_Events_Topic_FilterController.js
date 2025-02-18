// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    //Initialization Method
    doInit : function(component, event, helper) {
        helper.getTopics(component);
    },
    // Setting the topic values
    setTopic : function(component, event, helper) {
        var appEvent = $A.get("e.c:SVNSUMMITS_Events_Topic_Filter_Event");
        if(component.find("filterByTopic").get("v.value") === '' || component.find("filterByTopic").get("v.value") === 'All') {
            var cmpTarget = component.find('clearButton');
            $A.util.removeClass(cmpTarget, 'toggleClass1');
            $A.util.addClass(cmpTarget, 'toggleClass');
            appEvent.setParams({
                "filterByTopic" : null
            });
        }else{
            appEvent.setParams({
                "filterByTopic" : component.find("filterByTopic").get("v.value"),
            });
        }
        appEvent.fire();
    },

    //clearing topics
    clearTopic : function(component, event, helper) {
        var appEvent = $A.get("e.c:SVNSUMMITS_Events_Topic_Filter_Event");
        appEvent.setParams({
            "filterByTopic" : null
        });
        appEvent.fire();

        $(".topic").each(function(){
            $(this).find('a').remove();
        });

        component.find('filterByTopic').set('v.value', '');
        helper.getTopics(component);
        var cmpTarget = component.find('clearButton');
        $A.util.removeClass(cmpTarget, 'toggleClass1');
        $A.util.addClass(cmpTarget, 'toggleClass');
    },

    //Method to Select Topics
    selectTopic : function(component, event, helper) {
        var cmpTarget = component.find('clearButton');
        $A.util.removeClass(cmpTarget, 'toggleClass');
        $A.util.addClass(cmpTarget, 'toggleClass1');
    }
})