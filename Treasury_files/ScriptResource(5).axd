﻿
$(document).ready(function () {


    //New watch event from the ticker gadget
    $(document).on('click', '#ticker_list .gadget-command-add', function (event) {

        //Put the trigger id in a hidden field on the new watch dialog
        $('#newwatchdialog-triggerid').val($(this).attr('id'));

        //Put the tradestrategyid in a hidden field on the new watch dialog
        $('#newwatchdialog-strategyid').val($(this).attr('tradestrategyid'));

        //Initialize the name
        $('#newwatchdialog-name').val($(this).attr('watchname'));

        //Open the dialog
        $('#newwatchdialog').dialog('open');

        event.preventDefault();
    });

    //Delete watch event from the ticker gadget
    $(document).on('click', '#ticker_list .gadget-command-delete', function (event) {

        //Put the trigger id in a hidden field on the delete watch dialog
        $('#deletewatchdialog-triggerid').val($(this).attr('id'));

        //Put the tradestrategyid in a hidden field on the delete watch dialog
        $('#deletewatchdialog-strategyid').val($(this).attr('tradestrategyid'));

        //Open the dialog
        $('#deletewatchdialog').dialog('open');

        event.preventDefault();
    });

    //New watch event from a trade-strategy-list
    $(document).on('click', '#trade-strategy-list .gadget-command-add', function (event) {

        //Put the trigger id in a hidden field on the new watch dialog
        $('#newwatchdialog-triggerid').val($(this).attr('id'));

        //Put the tradestrategyid in a hidden field on the new watch dialog
        $('#newwatchdialog-strategyid').val($(this).attr('tradestrategyid'));

        //Initialize the name
        $('#newwatchdialog-name').val($(this).attr('watchname'));

        //Open the dialog
        $('#newwatchdialog').dialog('open');

        event.preventDefault();
    });

    //Delete watch event from a trade-strategy-list
    $(document).on('click', '#trade-strategy-list .gadget-command-delete', function (event) {

        //Put the trigger id in a hidden field on the delete watch dialog
        $('#deletewatchdialog-triggerid').val($(this).attr('id'));

        //Put the tradestrategyid in a hidden field on the delete watch dialog
        $('#deletewatchdialog-strategyid').val($(this).attr('tradestrategyid'));

        //Open the dialog
        $('#deletewatchdialog').dialog('open');

        event.preventDefault();
    });

    //Delete watch event from the watchlist gadget
    $(document).on('click', '#watch_list .gadget-command-delete', function (event) {

        //Put the trigger id in a hidden field on the delete watch dialog
        $('#deletewatchdialog-triggerid').val($(this).attr('id'));

        //Put the tradestrategyid in a hidden field on the delete watch dialog
        $('#deletewatchdialog-strategyid').val($(this).attr('tradestrategyid'));

        //Open the dialog
        $('#deletewatchdialog').dialog('open');

        event.preventDefault();
    });

    //Create the newwatch - error dialog
    $('#newwatchdialog-error').dialog({
        autoOpen: false,
        hide: 'blind',
        width: 350,
        height: 200,
        buttons: { Close: function () { $('#newwatchdialog-error').dialog('close'); } }
    });

    //Create the newwatchdialog
    var dialog = $('#newwatchdialog').dialog({
        autoOpen: false,
        hide: 'blind',
        width: 350,
        height: 175,
        buttons: {

            //Make the AJAX call to add the watch
            Ok: function (event) {

                $(event.target).attr('disabled', 'disabled');

                //Get the url for AJAX methods
                var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/GadgetMethods.aspx/AddWatch';

                $.ajax({
                    type: 'GET',
                    url: url,
                    data: 'tradeStrategyId=' + $('#newwatchdialog-strategyid').val() + '&name="' + $('#newwatchdialog-name').val() + '"',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function () {

                        //Process trade-strategy-list items that match the tradestrategyid
                        var tslselector = '#trade-strategy-list .gadget-command-add[tradestrategyid=' + $('#newwatchdialog-strategyid').val() + ']';
                        var results = $(tslselector);
                        results.toggleClass('ui-icon-circle-minus ui-icon-circle-plus');
                        results.attr('title', 'Delete this watch.');
                        results.toggleClass('gadget-command-add gadget-command-delete'); //Note: this has to go last since it changes the results

                        //Process ticker
                        var tickerselector = '#ticker_list .gadget-command-add[tradestrategyid=' + $('#newwatchdialog-strategyid').val() + ']';
                        var results = $(tickerselector);
                        results.toggleClass('ui-icon-circle-minus ui-icon-circle-plus');
                        results.attr('title', 'Delete the Watch on this Trade.');
                        results.toggleClass('gadget-command-add gadget-command-delete'); //Note: this has to go last since it changes the results

                        $('#newwatchdialog .success').show();

                        window.setTimeout(
                            function () {

                                $('#newwatchdialog .success').hide();
                                $('#newwatchdialog').dialog('close');
                            },
                            1500
                        );
                    },

                    error: function (result) {

                        $('#newwatchdialog').dialog('close');
                        $('#newwatchdialog-error .content').html(result.responseText);
                        $('#newwatchdialog-error').dialog('open');

                    }
                });


            },

            Cancel: function () {
                $('#newwatchdialog').dialog('close');
            }
        },
        close: function () {

            //Clear the triggerid and the tradestrategyid
            $('#newwatchdialog-name').val("");
            $('#newwatchdialog-triggerid').val("");
            $('#newwatchdialog-strategyid').val("")

        },
        open: function () {
            $('#newwatchdialog').nextAll('.ui-dialog-buttonpane').find('.ui-button').removeAttr("disabled");

        } //alert('opened'); }

    });


    //Create the deletewatch - error dialog
    $('#deletewatchdialog-error').dialog({
        autoOpen: false,
        hide: 'blind',
        width: 350,
        height: 200,
        buttons: { Close: function () { $('#deletewatchdialog-error').dialog('close'); } }
    });



    //Create the deletewatchdialog
    var dialog = $('#deletewatchdialog').dialog({
        autoOpen: false,
        hide: 'blind',
        width: 350,
        height: 150,
        buttons: {

            //Make the AJAX call to add the watch
            Ok: function () {

                //Get the url for AJAX methods
                var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/GadgetMethods.aspx/DeleteWatch';

                $.ajax({
                    type: 'GET',
                    url: url,
                    data: "tradeStrategyId='" + $('#deletewatchdialog-strategyid').val() + "'",
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function () {

                        //Process trade-strategy-list items that match the tradestrategyid
                        var tslselector = '#trade-strategy-list .gadget-command-delete[tradestrategyid=' + $('#deletewatchdialog-strategyid').val() + ']';
                        var results = $(tslselector);
                        results.toggleClass('ui-icon-circle-minus ui-icon-circle-plus');
                        results.attr('title', 'Add a watch to this item.');
                        results.attr('href', '#');
                        results.toggleClass('gadget-command-add gadget-command-delete'); //Note: this has to go last since it changes the results

                        //Process ticker items that match the tradestrategyid
                        var tslselector = '#ticker_list .gadget-command-delete[tradestrategyid=' + $('#deletewatchdialog-strategyid').val() + ']';
                        var results = $(tslselector);
                        results.toggleClass('ui-icon-circle-minus ui-icon-circle-plus');
                        results.attr('title', 'Add a Watch for this Trade.');
                        results.attr('href', '#');
                        results.toggleClass('gadget-command-add gadget-command-delete'); //Note: this has to go last since it changes the results


                        //Process watch-list items that match the tradestrategyid
                        var watchselector = '#watch_list .gadget-command-delete[tradestrategyid=' + $('#deletewatchdialog-strategyid').val() + ']';
                        $(watchselector).parent().parent().parent().toggleClass('hide');

                        $('#deletewatchdialog').dialog('close');
                        //$('#deletewatchdialog-success').dialog('open');

                    },

                    error: function (result) {

                        $('#deletewatchdialog').dialog('close');
                        $('#deletewatchdialog-error .content').html(result.responseText);
                        $('#deletewatchdialog-error').dialog('open');
                    }

                });
            },

            Cancel: function () {
                $('#deletewatchdialog').dialog('close');
            }
        },
        close: function () {

            //Clear the triggerid and the tradestrategyid
            $('#deletewatchdialog-triggerid').val("");
            $('#deletewatchdialog-strategyid').val("")

        },
        open: function () { } //alert('opened'); }

    });

});
