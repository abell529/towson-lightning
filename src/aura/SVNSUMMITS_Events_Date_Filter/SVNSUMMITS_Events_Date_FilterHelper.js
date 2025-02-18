// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    // Method called to scroll the calendar scroll
    calenderScroll : function(component,event) {
        // vertical scroll position is the same as the number of pixels that are hidden from
        // view above the scrollable area. Setting the scrollTop positions the vertical scroll of
        // each matched element.
        //if(component.get("v.isRender")) {
        var scrollSize = 400;
        $('#stDate').click(function(e) {
            if($(window).scrollTop() > scrollSize)
            $(window).scrollTop(0);
        });
        $('#endDt').click(function(e){
            if($(window).scrollTop() > scrollSize) {
                $(window).scrollTop(0);
            }
        });
        //}
    },

    debug: function(component, msg, variable) {
        var debugMode = component.get("v.debugMode");
        if(debugMode){
            if(msg){
                console.log(msg);
            }
            if(variable){
                console.log(variable);
            }
        }
    }

})