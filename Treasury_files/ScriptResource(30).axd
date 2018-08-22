﻿Type.registerNamespace('QuikStrike.Public.Web.UserControls.Messages');

QuikStrike.Public.Web.UserControls.Messages.Alerts = function (element)
{
    QuikStrike.Public.Web.UserControls.Messages.Alerts.initializeBase(this, [element]);

    this.dialogClientId = '';
    this.showAlerts = false;
    this.noteIds = null;
    this.ajaxLoadMethod = '';
    this.partyId = -1;
    this.dialogTitle = 'System Alerts';
    this.refreshInterval = 300000; // milliseconds

}

QuikStrike.Public.Web.UserControls.Messages.Alerts.prototype =
{

    get_DialogClientId: function ()
    {
        return this.dialogClientId;
    },

    set_DialogClientId: function (value)
    {
        if (this.dialogClientId != value)
        {
            this.dialogClientId = value;
            this.raisePropertyChanged('DialogClientId');
        }
    },

    get_ShowAlerts: function ()
    {
        return this.showAlerts;
    },

    set_ShowAlerts: function (value)
    {
        if (this.showAlerts != value)
        {
            this.showAlerts = value;
            this.raisePropertyChanged('ShowAlerts');
        }
    },

    get_NoteIds: function ()
    {
        return this.noteIds;
    },

    set_NoteIds: function (value)
    {
        if (this.noteIds != value)
        {
            this.noteIds = value;
            this.raisePropertyChanged('NoteIds');
        }
    },

    get_AjaxLoadMethod: function ()
    {
        return this.ajaxLoadMethod;
    },

    set_AjaxLoadMethod: function (value)
    {
        if (this.ajaxLoadMethod != value)
        {
            this.ajaxLoadMethod = value;
            this.raisePropertyChanged('AjaxLoadMethod');
        }
    },

    get_DialogTitle: function ()
    {
        return this.dialogTitle;
    },

    set_DialogTitle: function (value)
    {
        if (this.dialogTitle != value)
        {
            this.dialogTitle = value;
            this.raisePropertyChanged('DialogTitle');
        }
    },

    get_PartyId: function ()
    {
        return this.partyId;
    },

    set_PartyId: function (value)
    {
        if (this.partyId != value)
        {
            this.partyId = value;
            this.raisePropertyChanged('PartyId');
        }
    },

    get_RefreshInterval: function ()
    {
        return this.refreshInterval;
    },

    set_RefreshInterval: function (value)
    {
        if (this.refreshInterval != value)
        {
            this.refreshInterval = value;
            this.raisePropertyChanged('RefreshInterval');
        }
    },

    initialize: function ()
    {
        QuikStrike.Public.Web.UserControls.Messages.Alerts.callBaseMethod(this, 'initialize');

        var noteIndex = 0
        var noteIds = this.noteIds;
        var dialogSelector = '#' + this.get_DialogClientId();
        var ajaxMethod = this.get_AjaxLoadMethod();
        var partyId = this.get_PartyId();
        var refreshInterval = this.get_RefreshInterval();
        var uniquieId = this.get_DialogClientId();

        $(dialogSelector + ' a.alert-dialog-prev').click(function (event)
        {
            noteIndex--;
            alert_Load(dialogSelector, noteIds[noteIndex]);
            alert_UpdateUI(dialogSelector, noteIndex, noteIds);
        });

        $(dialogSelector + ' a.alert-dialog-next').click(function (event)
        {
            noteIndex++;
            alert_Load(dialogSelector, noteIds[noteIndex]);
            alert_UpdateUI(dialogSelector, noteIndex, noteIds);
        });

        // init dialog
        var dialog = $(dialogSelector).dialog({
            autoOpen: this.get_ShowAlerts(),
            width: 600,
            minHeight: 300,
            title: this.get_DialogTitle(),
            modal: true,
            resizable: true
        });

        dialog.parent().appendTo($('#upMain'));

        // setup ajax
        if (ajaxMethod.length > 0)
        {
            var loadMethod = function ()
            {
                var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/NoteMethods.aspx/' + ajaxMethod;

                $.ajax({
                    type: "Get",
                    url: url,
                    data: "partyId='" + partyId + "'",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    cache: false,
                    success: function (result)
                    {
                        if (result != null && result.d.length > 0 && !$(dialogSelector).dialog('isOpen'))
                        {
                            noteIndex = 0
                            noteIds = result.d;

                            $(dialogSelector).dialog('open');
                            $(dialogSelector).parent().appendTo($('#upMain'));

                            alert_UpdateUI(dialogSelector, noteIndex, noteIds);
                            alert_Load(dialogSelector, noteIds[noteIndex]);

                        }
                    },
                    error: function (result) { /* do nothing */ }
                });

                alert_initDynamicLoad(loadMethod, refreshInterval, uniquieId);
            }

            alert_initDynamicLoad(loadMethod, refreshInterval, uniquieId);

        }

        if (!this.get_ShowAlerts())
            return;

        alert_UpdateUI(dialogSelector, noteIndex, noteIds);
        alert_Load(dialogSelector, noteIds[noteIndex]);

    }
}

QuikStrike.Public.Web.UserControls.Messages.Alerts.registerClass('QuikStrike.Public.Web.UserControls.Messages.Alerts', Sys.UI.Control);

function alert_initDynamicLoad(loadMethod, refreshInterval, uniquieId)
{
    if ($('#global_attributes').attr(uniquieId) != undefined)
        window.clearTimeout($('#global_attributes').attr(uniquieId));
    $('#global_attributes').attr(uniquieId, window.setTimeout(loadMethod, refreshInterval /* in milliseconds */));
}

function alert_Load(topSelector, noteId)
{
    var contentDiv = $(topSelector + ' div.alert-content');

    var path = $('#global_applicationPath').val();
    var url = window.location.protocol + '//' + window.location.host + path + '/User/Message/Alert.aspx?noerr=&nid=' + noteId;

    if ($('#global_instanceCache').val().length > 0)
        url += '&' + $('#global_instanceCache').val();

    url += ' #alert-dialog-content';

    contentDiv.load(url, function (response, status, xhr)
    {
        if (status == 'error')
        {
            contentDiv.html('An error occurred while loading the message: ' + xhr.status + ' ' + xhr.statusText);
        }
        else
        {
            // to fix wierd ie bug where div doesn't update until mouse is moved
            window.focus();
        }
    });

}


function alert_UpdateUI(topSelector, noteIndex, noteIds)
{
    if (noteIndex > 0)
        $(topSelector + ' a.alert-dialog-prev').removeClass('hide');
    else
        $(topSelector + ' a.alert-dialog-prev').addClass('hide');

    if (noteIndex + 1 < noteIds.length)
        $(topSelector + ' a.alert-dialog-next').removeClass('hide');
    else
        $(topSelector + ' a.alert-dialog-next').addClass('hide');
}


