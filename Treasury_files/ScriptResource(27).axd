﻿Type.registerNamespace('QuikStrike.WebControls');

QuikStrike.WebControls.DetailPopup = function (element) 
{
    QuikStrike.WebControls.DetailPopup.initializeBase(this, [element]);

    this.detailPopupClientId = null;
}

QuikStrike.WebControls.DetailPopup.prototype =
{
    get_DetailPopupClientId: function ()
    {
        return this.detailPopupClientId;
    },

    set_DetailPopupClientId: function (value)
    {
        if (this.detailPopupClientId != value)
        {
            this.detailPopupClientId = value;
            this.raisePropertyChanged('DetailPopupClientId');
        }
    },

    initialize: function ()
    {
        QuikStrike.WebControls.DetailPopup.callBaseMethod(this, 'initialize');

        detailpopup_documentReady($('#' + this.get_DetailPopupClientId()));
    }

//    dispose: function () {

//        if (Sys.WebForms.PageRequestManager.getInstance().get_isInAsyncPostBack()) {
//            alert('destroying');
//            var control = $('#' + this.get_DetailPopupClientId());
//            control.dialog('destroy').remove();

//            var triggerSelector = detailpopup_TriggerSelector(control);
//            $(triggerSelector).unbind();

//            control = null;
//        }

//        QuikStrike.WebControls.DetailPopup.callBaseMethod(this, 'dispose');

//    }
}


QuikStrike.WebControls.DetailPopup.registerClass('QuikStrike.WebControls.DetailPopup', Sys.UI.Control);

function detailpopup_documentReady(detailPopupControl)
{
    var dialog = detailPopupControl.dialog({
        autoOpen: false,
        width: parseInt(detailPopupControl.attr('popupWidth')),
        height: parseInt(detailPopupControl.attr('popupHeight')),
        resizable: detailPopupControl.attr('popupResizable') == "1" ? true : false,
        open: function () { }

    });

    dialog.parent().appendTo($('#upMain'));

    var triggerSelector = detailpopup_TriggerSelector(detailPopupControl);

    // set the id of the popup control on the trigger for later retrieval
    $(triggerSelector).attr('detailPopupId', detailPopupControl.attr('id'));

    var gadgetMode = detailPopupControl.attr('gadgetMode');

    if (gadgetMode == "1") {
        $(document).off('click', triggerSelector);
        $(document).on('click', triggerSelector, function (event)
        {
            detailpopup_executePopup($(this), $('#' + $(this).attr('detailPopupId')), event);
        })
    }
    else
    {
        $(triggerSelector).click(function (event)
        {
            detailpopup_executePopup($(this), $('#' + $(this).attr('detailPopupId')), event);
        })
    }

}

function detailpopup_executePopup(triggerControl, detailPopupControl, event)
{
    var detailPopupContent = $('#' + detailPopupControl.attr('id') + '-content');

    var isOpen = detailPopupControl.dialog('isOpen');
    var alwaysReposition = (detailPopupControl.attr('alwaysReposition') == undefined || detailPopupControl.attr('alwaysReposition') != "1" ? false : true);

    detailPopupContent.html('Loading...');
    detailPopupControl.dialog('open');
    detailPopupControl.parent().appendTo($('#upMain'));

    detailPopupControl.dialog('option', 'title', detailpopup_getTitle(detailPopupControl, triggerControl));

    if (!isOpen || alwaysReposition)
        detailpopup_setPosition(detailPopupControl, triggerControl);

    var path = $('#global_applicationPath').val();
    var url = window.location.protocol + '//' + window.location.host + path + detailPopupControl.attr('contentPageUrl') + '?noerr=' + detailpopup_getContentUrlAttributes(detailPopupControl, triggerControl);

    if ($('#global_instanceCache').val().length > 0)
        url += '&' + $('#global_instanceCache').val();

    var contentPageDivSourceId = detailPopupControl.attr('contentPageDivSourceId');
    if (contentPageDivSourceId != null && contentPageDivSourceId.length > 0)
        url += ' #' + contentPageDivSourceId;

    detailPopupContent.load(url, function (response, status, xhr)
    {
        if (status == 'error')
        {
            detailPopupContent.html('An error occurred while loading the page: ' + xhr.status + ' ' + xhr.statusText);
        }
        else
        {
            var onLoadScript = detailPopupControl.attr('onLoadScript');
            if (onLoadScript != null && onLoadScript.length > 0)
                eval(onLoadScript);

            // to fix wierd ie bug where div doesn't update until mouse is moved
            window.focus();

            detailPopupControl.dialog('moveToTop');
        }
    });

    event.preventDefault();
}

function detailpopup_getTitle(detailPopupControl, triggerControl)
{
    var popupTitle = detailPopupControl.attr('popupTitle');
    var popupTitleFormatAttributes = detailPopupControl.attr('popupTitleFormatAttributes');

    if (popupTitle == null || popupTitle.length == 0)
        return '';

    if (popupTitleFormatAttributes != null && popupTitleFormatAttributes.length > 0)
    {
        var attrs = popupTitleFormatAttributes.split(',');
        var statement = 'String.format(\'' + popupTitle + '\'';
        for (var i = 0; i < attrs.length; i++)
            statement += ', \'' + triggerControl.attr(attrs[i]).toString().replace('\'', '') + '\'';
        statement += ');';

        return eval(statement);
    }

    return popupTitle;

}

function detailpopup_setPosition(detailPopupControl, triggerControl)
{
    var popupPosition = detailPopupControl.attr('popupPosition');
    var position = [];
    position.my = "center";
    position.at = "center"
    position.of = window;

    if (popupPosition == 'TriggerRight')
    {
        position.my = "left top";
        position.at = "right bottom"
        position.of = triggerControl;
    }
    else if (popupPosition == 'TriggerLeft')
    {
        position.my = "right top";
        position.at = "left bottom"
        position.of = triggerControl;
    }

    detailPopupControl.dialog('option', 'position', position);

}

function detailpopup_getContentUrlAttributes(detailPopupControl, triggerControl)
{
    var contentAttributes = detailPopupControl.attr('contentAttributes');

    if (contentAttributes == null || contentAttributes.length == 0)
        return '';

    var attrs = contentAttributes.split(',');
    var attrString = '';
    for (var i = 0; i < attrs.length; i++)
        if (triggerControl.attr(attrs[i]) != undefined)
            attrString += '&' + attrs[i] + '=' + triggerControl.attr(attrs[i]).toString();

    return attrString;

}

function detailpopup_TriggerSelector(detailPopupControl)
{
    var triggerClass = detailPopupControl.attr('triggerClass');
    var triggerContainerId = detailPopupControl.attr('triggerContainerId');

    var selector = '';

    if (triggerContainerId != null && triggerContainerId.length > 0)
        selector = "#" + triggerContainerId;
    selector += " ." + triggerClass;

    return selector;
}
