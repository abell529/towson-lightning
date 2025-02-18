/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/27/18.
 */
({
    afterRender: function (component, helper) {

        window.addEventListener('message',$A.getCallback(function (event) {
            if (event.origin == 'https://towson.tfaforms.net') {
                var payload = event.data.split(',');
                if (payload[0] == 'submitted') {
                    helper.submitted(component, event, helper);
                }
            }
        }));
    }
})