// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    //Initialize the calendar method
    doInit : function(cmp, event, helper) {        
        helper.initializeCalendar(cmp);
    },
    
    // Filter for calendar topics view
    calendarViewOfTopicFilter : function(cmp,event,helper){
        helper.CalendarViewTopicFilter(cmp,event);
    },
    
    //Sort by methods for Calendar view
    sortBy : function(component, event, helper){
        var sortBy = event.getParam("sortBy");
        component.set("v.sortBy", sortBy);
        helper.initializeCalendar(component);
    }
})