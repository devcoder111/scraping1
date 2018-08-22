﻿if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(popupNav_EndRequestHandler);

function popupNav_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        popupNav_documentReady();
    }
}

$(document).ready(function ()
{
    popupNav_documentReady();
});

function popupNav_documentReady()
{
    $('a[PopupClientId], input[PopupClientId]').unbind('click');
    $('a[PopupClientId], input[PopupClientId]').click(function (event)
    {
        var popupId = $(this).attr('PopupClientId');
        //debugger;
        //alert(popupId);
        var popup = $('#' + popupId);

        // if i am open, close me and all other menus
        if (popup.is(':visible'))
        {
            if (popup.attr('Animate') == 'SlideRight')
                popup.hide("slide", { direction: "right" });
            else
                popup.hide();
            global_closeDropMenus(popup);
            //global_resetCancelInputs($('#' + popupId));
            event.preventDefault();
            event.stopPropagation();
            return;
        }

        global_closeDropMenus();

        $(this).addClass('popup-open');

        // move the popup so that it is not part of the normal page flow
        var appendTo = popup.attr('AppendTo');
        if (appendTo == undefined)
            appendTo = 'upMain';
        if (popup.parent().attr('id') != appendTo)
            popup.appendTo($('#' + appendTo));

        popupNav_openPopup(popup, $(this));

        //Set the value of the popup state hidden field to 'open'
        $(this).children('input[type="hidden"]').val("open");

        event.preventDefault();
        event.stopPropagation();

    });

    $('a[PopupClientId].hoverable, input[PopupClientId].hoverable').unbind('hover');
    $('a[PopupClientId].hoverable, input[PopupClientId].hoverable').hover(function (event)
    {
        var trigger = $(this);
        var popupId = trigger.attr('PopupClientId');
        var popup = $('#' + popupId);

        popupNav_doHover(trigger, popup);

        var popupId = trigger.attr('PopupClientId');
        var popup = $('#' + popupId);

        // so that the popup stays open when the mouse moves from the trigger to the popup div...
        popup.unbind('hover');
        popup.hover(function (event)
        {
            popupNav_doHover(trigger, popup);
        },
        function (event)
        {
            global_closeDropMenus();
        });

    },
    function (event)
    {
        global_closeDropMenus();
    });

    $('div[showme].qs-confirm').each(function ()
    {
        var pos = [($(window).width() - $(this).outerWidth()) / 2, ($(window).height() - $(this).outerHeight()) / 2 + $(window).scrollTop()];

        $(this).css({ left: pos[0], top: pos[1] });
        $(this).show();
    });

    //Trigger click event on any popup triggers that have a state of 'open' so that they are open after postback
    $('a[PopupClientId]>input[type="hidden"]').each(function (index, element) {

        if ($(this).val() == "open")
            $(this).parent().trigger("click");
    });

    //When anchors or inputs with a class popup-close-trigger are clicked, set all popup state hidden fields to 'closed'
    $('a.popup-close-trigger, input.popup-close-trigger').unbind('click');
    $('a.popup-close-trigger, input.popup-close-trigger').click(function (event) {
        $('a[PopupClientId], input[PopupClientId]').children('input[type="hidden"]').val("closed");
    });

}

function popupNav_openPopup(popup, trigger)
{
    // custom event
    popup.trigger('popupBeforeShow', trigger);

    var anchor;
    if (popup.attr('PopupAnchor') != null)
        anchor = $('#' + popup.attr('PopupAnchor'));
    else
        anchor = trigger;

    var anchorOffset = anchor.offset();

    if (popup.attr('Animate') === undefined)
        popup.show();

    // set popup width to prevent wrapping, then position it
    popupNav_setWidth(popup);
    popupNav_setHeight(popup);

    var pos;
    var top;
    var offScreen;
    var cushion = 5;
    if (popup.attr('PopupOffset') == 'left')
    {
        // position left of anchor, making sure to stay within browser window
        offScreen = (popup.outerWidth() + cushion) - (anchorOffset.left + anchor.outerWidth());
        if (offScreen > 0)
            pos = [cushion, anchorOffset.top + anchor.outerHeight()];
        else
            pos = [anchorOffset.left + anchor.outerWidth() - popup.outerWidth(), anchorOffset.top + anchor.outerHeight()];
    }
    else if (popup.attr('PopupOffset') == 'farleftcenter')
    {
        // for now, assume it fits in window
        pos = [anchorOffset.left - popup.outerWidth(), anchorOffset.top - (popup.outerHeight() - anchor.outerHeight()) / 2];
    }
    else if (popup.attr('PopupOffset') == 'center')
    {
        pos = [Math.max(anchorOffset.left - ((popup.outerWidth() - anchor.outerWidth()) / 2), cushion), anchorOffset.top + anchor.outerHeight()];
    }
    else if (popup.attr('PopupOffset') == 'windowcenter')
    {
        pos = [($(window).width() - popup.outerWidth()) / 2, ($(window).height() - popup.outerHeight()) / 2 + $(window).scrollTop()];
    }
    else if (popup.attr('PopupOffset') == 'topright')
    {
        // position above and to the right of the anchor, making sure to stay within browser window
        offScreen = (anchorOffset.left + popup.outerWidth() + cushion) - $(window).width();
        if (offScreen > 0)
            pos = [anchorOffset.left - offScreen, anchorOffset.top - popup.outerHeight()];
        else
            pos = [anchorOffset.left, anchorOffset.top - popup.outerHeight()];
    }
    else
    {
        // position right of anchor, making sure to stay within browser window
        offScreenR = (anchorOffset.left + popup.outerWidth() + cushion) - $(window).width();
        if (offScreenR < 0)
            offScreenR = 0;
        offScreenB = (anchorOffset.top + anchor.outerHeight() + popup.outerHeight() + cushion) - $(window).height();
        if (offScreenB < 0)
            offScreenB = 0;
        pos = [anchorOffset.left - offScreenR, anchorOffset.top + anchor.outerHeight() - offScreenB];
    }

    popup.css({ left: pos[0], top: pos[1] });

    if (popup.attr('Animate') == 'SlideRight')
    {
        //var x = parent.document.getElementById('mainFrame');
        //x.scrolling = "no";
        popup.show("slide", { direction: "right" });
    }

    // custom event
    popup.trigger('popupAfterShow', trigger);

}

function popupNav_doHover(trigger, popup)
{
    global_closeDropMenus();

    trigger.addClass('popup-open');

    // move the popup so that it is not part of the normal page flow
    var appendTo = popup.attr('AppendTo');
    if (appendTo == undefined)
        appendTo = 'upMain';
    if (popup.parent().attr('id') != appendTo)
        popup.appendTo($('#' + appendTo));

    popupNav_openPopup(popup, trigger);
}

function popupNav_setWidth(popup)
{
    // only calc width once
    if (popup.attr('setwidth') != undefined)
        return;

    var totalWidth = 0;
    popup.find('div.group').each(function () {
        totalWidth += $(this).outerWidth(true);
    });

    popup.attr('setwidth', '');
    if (totalWidth > 0)
        popup.width(totalWidth);
}

function popupNav_setHeight(popup)
{
    // only calc height once
    if (popup.attr('setheight') != undefined)
        return;

    var keepGoing = true;
    var heightIndex = 0;
    while (keepGoing)
    {
        var group = popup.find('[HeightGroup=' + heightIndex + ']');
        if (group.length == 0)
            keepGoing = false;
        else
        {
            // clear height styles
            group.each(function ()
            {
                $(this).height('auto');
            });

            heightIndex++;
            var maxHeight = 0;

            // allow for a minimum height for each group
            var groupParent = group.first().closest('div[MinGroupHeight]');
            if (groupParent.length != 0)
                maxHeight = parseInt(groupParent.attr('MinGroupHeight'));

            // get max height for group
            group.each(function ()
            {
                if ($(this).height() > maxHeight)
                    maxHeight = $(this).height();
            });

            // set height for all elements in group
            group.each(function () {
                $(this).height(maxHeight);
            });
        }
    }

    popup.attr('setheight', '');
}
