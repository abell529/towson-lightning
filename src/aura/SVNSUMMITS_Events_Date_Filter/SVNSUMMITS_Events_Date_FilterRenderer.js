// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	// Your renderer method overrides go here
 	rerender : function(component, helper)
    {
        var ren = this.superRerender();
        helper.calenderScroll(component);
        return ren;
	},
    
	render: function(component, helper) {
       //helper.changeValue(component);
       return this.superRender();
    },

})