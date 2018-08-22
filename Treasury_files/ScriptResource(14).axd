﻿if (window.Sys !== undefined && Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(scm_EndRequestHandler);

function scm_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        qmenu_Init();
    }
}

$(document).ready(function ()
{
    qmenu_Init();
});

function qmenu_Init()
{

    $('a.quikmenu-trigger').click(function (event)
    {
        var isActive = $(this).attr('IsActive').toLowerCase() == 'true';
        if (isActive)
            qmenu_RemoveFromMenu($(this).attr('ViewId'), $(this).attr('ViewName'));
        else
            qmenu_AddToMenu($(this).attr('ViewId'), $(this).attr('ViewName'));
        event.preventDefault();
    });

    $('#spanQuikMenuRemove').click(function (event)
    {
        var li = $(this).closest('li')
        $('#divQuikMenuControls img').removeClass("auto-hover-effect-img");
        qmenu_RemoveFromMenu(li.attr('vid'));
        event.preventDefault();
    });

    $(document).off('mouseenter', '#pnlQuikMenuPopup a.quikmenu-item');
    $(document).on('mouseenter', '#pnlQuikMenuPopup a.quikmenu-item', function (event)
    {
        qmenu_hoverItemIn($(event.target));
    });

    $(document).off('mouseleave', '#pnlQuikMenuPopup a.quikmenu-item');
    $(document).on('mouseleave', '#pnlQuikMenuPopup a.quikmenu-item', function (event)
    {
        qmenu_hoverItemOut();
    });

}

function qmenu_AddToMenu(viewId, viewName)
{
    var parms = { 'name': viewName, 'viewId': viewId };
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/QuikMenuMethods.aspx/Add';

    $.ajax({
        type: 'POST',
        url: url,
        data: JSON.stringify(parms),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            var trigger = $("a.quikmenu-trigger[ViewId='" + viewId + "']");
            var img = trigger.children('img');
            img.attr('src', img.attr('src').replace('lightning-off-16', 'lightning-on-16'));
            img.attr('title', "Remove '" + viewName + "' from my QuikMenu");
            trigger.attr('IsActive', 'True');

            // add to DOM
            var container = $('#pnlQuikMenuPopup');
            var ul = container.find('div.group ul.nav');
            ul.append($("<li vid=" + viewId + "><a class='quikmenu-item' href=javascript:__doPostBack('" + container.attr('UniqueId') + "','" + viewId + "')>" + viewName + "</a></li>"));

            qmenu_updateEmpty();
        },
        error: qmenu_ajaxFailed
    });

}

function qmenu_RemoveFromMenu(viewId, viewName)
{
    var parms = { 'viewId': viewId };
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/QuikMenuMethods.aspx/Remove';

    $.ajax({
        type: 'POST',
        url: url,
        data: JSON.stringify(parms),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            var trigger = $("a.quikmenu-trigger[ViewId='" + viewId + "']");
            if (trigger.length > 0)
            {
                var img = trigger.children('img');
                img.attr('src', img.attr('src').replace('lightning-on-16', 'lightning-off-16'));
                img.attr('title', "Add '" + viewName + "' from my QuikMenu");
                trigger.attr('IsActive', 'False');
            }

            // remove from DOM
            $('#divQuikMenuControls').hide();
            $('#pnlQuikMenuPopup').append($('#divQuikMenuControls'));
            $("#pnlQuikMenuPopup div.group ul.nav li[vid='" + viewId + "']").remove();

            qmenu_updateEmpty();
        },
        error: qmenu_ajaxFailed
    });
}

function qmenu_hoverItemIn(trigger)
{
   
    var triggerOffset = trigger.offset();
    var controls = $('#divQuikMenuControls');
    trigger.append(controls);
    controls.show();
    var pos = [triggerOffset.left + trigger.outerWidth() - controls.outerWidth() - 5, triggerOffset.top + (trigger.outerHeight() - controls.outerHeight()) / 2];
    controls.css({ left: pos[0], top: pos[1] });
}

function qmenu_hoverItemOut()
{
    $('#divQuikMenuControls').hide();
}

function qmenu_updateEmpty()
{
    if ($("#pnlQuikMenuPopup div.group ul.nav li").length == 0)
        $("#pnlQuikMenuPopup div.empty").show();
    else
        $("#pnlQuikMenuPopup div.empty").hide();
}

function qmenu_ajaxFailed(result)
{

    var errorMessage = 'The following error occured while trying to update your QuikMenu:\n';
    errorMessage += $.parseJSON(result.responseText).Message;
    alert(errorMessage);
}
