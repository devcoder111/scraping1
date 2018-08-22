﻿if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(tsl_EndRequestHandler);

function tsl_EndRequestHandler(sender, args) {
    if (args.get_error() == undefined) {
        tsl_documentReady();
    }
}

$(document).ready(function () {
    tsl_documentReady();
});


function tsl_documentReady() {

   // alert('documentReady');

    var dialog = $('#tsl-dialog').dialog({
        autoOpen: false,
        hide: 'blind',
        width: 975,
        height: 675,
        open: function () { } //alert('opened'); }

    });

    dialog.parent().appendTo($('#upMain'));

    dialog = $('#tsl-filterdialog').dialog({
        autoOpen: false,
        hide: 'blind',
        width: 275,
        height: 300,
        open: function () { } //alert('opened'); }

    });

    dialog.parent().appendTo($('#upMain'));


    $('#trade-strategy-list .tsl-trigger').click(function (event) {

        //alert('click');
        $('#tsl-dialog-content').html('Loading...');
        $('#tsl-dialog').dialog('open');
        $('#tsl-dialog').parent().appendTo($('#upMain'));

        //Set the title of the dialog to the dialogtitle attribute of the trigger
        var title = $(this).attr('dialogtitle');
        $('#ui-dialog-title-tsl-dialog').html(title);

        //Load the dialog with the contents from the AJAX call
        var path = $('#global_applicationPath').val();

        var url = window.location.protocol + '//' + window.location.host + path + '/User/MiniStrategyDetail.aspx?noerr=&HideHeader=1&TradeStrategyId=' + $(this).attr('tradestrategyid');

        if ($('#global_instanceCache').val().length > 0)
            url += '&' + $('#global_instanceCache').val();

        url += ' #ts-detail';

        $('#tsl-dialog-content').load(url, function (response, status, xhr) {
            if (status == 'error') {
                $('#tsl-dialog-content').html('An error occurred while loading the details: ' + xhr.status + ' ' + xhr.statusText);
            }
            else {

                //Hook the chart list click events
                $('.chartTrigger').click(function (event) {

                    $('.chart').hide();
                    $('#' + $(this).attr('targetControl')).show();

                    event.preventDefault();
                });
            }
        });


        event.preventDefault();

    });

    $('#trade-strategy-list .tsl-filter-trigger').click(function (event) {

        //alert('click');

        /*
        var width = $('#tsl-filterdialog').dialog('option', 'width');
        var offset = $(this).offset();
        var coords = [offset.left - width, offset.top];
        if (coords[0] < 0)
            coords = [offset.left, offset.top];
        $('#tsl-filterdialog').dialog('option', 'position', coords);
        */
        $('#tsl-filterdialog').dialog('open');
        $('#tsl-filterdialog').parent().appendTo($('#upMain'));

        event.preventDefault();

    });

}