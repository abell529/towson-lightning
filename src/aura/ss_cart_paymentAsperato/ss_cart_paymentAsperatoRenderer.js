/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/24/18.
 */
({
    afterRender: function (component, helper) {

        window.addEventListener('message',$A.getCallback(function (event) {
            helper.receiveMessage(component, event, helper);

        }));
    }
})