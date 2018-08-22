﻿if (window.Sys !== undefined && Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(popupTip_EndRequestHandler);

function popupTip_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        popupTip_Init();
    }
}

$(document).ready(function ()
{
    popupTip_Init();
});

function popupTip_Init()
{

    $('a.popuptip-trigger').click(function (event)
    {
        var popup = $('#popupTip_Container');
        var popupContent = $('#popupTip_Content');
        var trigger = $(this);

        var path = $('#global_applicationPath').val();
        var url = window.location.protocol + '//' + window.location.host + path + trigger.attr('contentPageUrl');

        popupContent.load(url, function (response, status, xhr)
        {
            if (status == 'error')
            {
                popupContent.html('An error occurred while loading content: ' + xhr.status + ' ' + xhr.statusText);
            }
            else
            {
                // to fix wierd ie bug where div doesn't update until mouse is moved
                window.focus();

                // center
                var pos = [($(window).width() - popup.outerWidth()) / 2, ($(window).height() - popup.outerHeight()) / 2 + $(window).scrollTop()];
                popup.css({ left: pos[0], top: pos[1] });

                popup.show("scale", {}, 750);

            }
        });

        event.preventDefault();

    });

    $('#popupTip_Close').click(function (event)
    {
        global_closeDropMenus();
        event.preventDefault();
    });

}




