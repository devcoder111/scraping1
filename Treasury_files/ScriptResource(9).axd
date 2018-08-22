﻿

if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(sendMail_EndRequestHandler);

function sendMail_EndRequestHandler(sender, args) {
    if (args.get_error() == undefined) {
        sendMail_documentReady();
    }
}

$(document).ready(function () {
    sendMail_documentReady();
});


function sendMail_documentReady() {

    var dialog = $('#users-dialog').dialog({
        autoOpen: false,
        hide: 'blind',
        classes: {"ui-dialog":"users-dialog"},
        open: function () { } //alert('opened'); }

    });

    dialog.parent().appendTo($('#upMain'));

    $('.user-dialog-trigger').click(function (event) {

        //Clear any previous selections
        $('#users-dialog select option:selected').each(function (index, element) {
            $(element).removeAttr('selected');
        })

        $('#users-dialog').dialog('open');

        event.preventDefault();
    });

    $('#user-dialog-ok-trigger').click(function (event) {

        var textbox = $('.user-dialog-target');

        $('#users-dialog select option:selected').each(function (index, element) {

            if (textbox.val() != '')
                textbox.val(textbox.val() + ',');

            textbox.val(textbox.val() + $(element).val());

        });

        $('#users-dialog').dialog('close');

        event.preventDefault();
    });

}