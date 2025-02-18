// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    // initialize the date section
    doInit: function(component, event, helper) {
        //component.set("v.isRender", true);
        helper.calenderScroll(component);
    },

    //Dates Values Section
    setDates : function(component, event, helper) {
        var appEvent = $A.get("e.c:SVNSUMMITS_Events_Date_Filter_Event");

        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1;
        var yyyy = today.getFullYear();

        if (dd < 10) {
            dd='0'+dd;
        }

        if (mm < 10) {
            mm='0'+mm;
        }
        today = new Date(yyyy+'-'+mm+'-'+dd);

        var frmDtStr;

        appEvent.setParams({
	        "fromDate" : component.get('v.fromDt'),
	        "toDate"   : component.get('v.toDt')

        });
        appEvent.fire();

        return;

        if (component.find("frmdate").get("v.value") !== null && component.find("frmdate").get("v.value") !== '') {
            if (moment(component.find("frmdate").get("v.value")).isValid()) {
                if (component.find("frmdate").get("v.value").length > 0){
                    var dtString = component.find("frmdate").get("v.value").split('-');
                    if (dtString[1] < 10) {
                        dtString[1]='0'+dtString[1];
                    }

                    if (dtString[2] < 10) {
                        dtString[2]='0'+dtString[2];
                    }
                    frmDtStr = new Date(dtString[0]+'-'+dtString[1]+'-'+dtString[2]);
                }
            } else {
                component.set("v.strError",'Invalid Date');
            }
        }

        var toDtStr;
        if(component.find("todate").get("v.value") !== null  && component.find("todate").get("v.value") !== '') {
            if(moment(component.find("todate").get("v.value")).isValid()) {
                if(component.find("todate").get("v.value").length >0){
                    var dtString1 = component.find("todate").get("v.value").split('-');
                    if(dtString1[1] < 10) {
                        dtString1[1] = '0'+dtString1[1];
                    }

                    if(dtString1[2] < 10) {
                        dtString1[2] = '0'+dtString1[2];
                    }
                    toDtStr = new Date(dtString1[0]+'-'+dtString1[1]+'-'+dtString1[2]);
                }
            } else {
                component.set("v.strError",'Invalid Date');
            }
        }

//        if (frmDtStr > today ) {
//            component.set("v.strError",'From Date Can not be greater than today.');
//        } else
        if (toDtStr < frmDtStr) {
            component.set("v.strError",'To Date Can not be less than From Date.');
        } else if (component.find("frmdate").get("v.value") !== null &&
                   component.find("frmdate").get("v.value") !== ''&&
                component.find("todate").get("v.value") !== null &&
                component.find("todate").get("v.value") !== '') {
            helper.debug(component, component.find("frmdate").get("v.value"));
            helper.debug(component, component.find("todate").get("v.value"));
            component.set("v.strError",null);
            appEvent.setParams({
                "fromDate" : component.find("frmdate").get("v.value"),
                "toDate" : component.find("todate").get("v.value"),
            });
            appEvent.fire();
        } else if (component.find("frmdate").get("v.value") !== null &&
        component.find("frmdate").get("v.value") !== '') {
            if(moment(component.find("frmdate").get("v.value")).isValid()) {
                component.set("v.strError",null);
                appEvent.setParams({
                    "fromDate" : component.find("frmdate").get("v.value"),
                });
                appEvent.fire();
            } else if(component.find("todate").get("v.value") !== null && component.find("todate").get("v.value") !== '') {
                if(moment(component.find("todate").get("v.value")).isValid()){
                    component.set("v.strError",null);
                    appEvent.setParams({
                        "toDate" : component.find("todate").get("v.value"),
                    });
                    appEvent.fire();
                }
            }
        }
    },

    // Method to clear dates
    clearDates : function(component, event, helper) {
        var appEvent = $A.get("e.c:SVNSUMMITS_Events_Date_Filter_Event");
        appEvent.setParams({
            "fromDate" : null,
            "toDate" : null,
        });
        appEvent.fire();
        component.find("frmdate").set("v.value",'');
        component.find("todate").set("v.value",'');
        var cmpTarget = component.find('clearButton');
        $A.util.removeClass(cmpTarget, 'toggleClass1');
        $A.util.addClass(cmpTarget, 'toggleClass');
    },

    //Method called id date changes
    dateChange: function(component, event, helper) {
        var cmpTarget = component.find('clearButton');
        $A.util.removeClass(cmpTarget, 'toggleClass');
        $A.util.addClass(cmpTarget, 'toggleClass1');
    }
})