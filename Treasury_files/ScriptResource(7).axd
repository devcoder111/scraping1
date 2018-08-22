﻿if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(iframeP_EndRequestHandler);

function iframeP_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        iframeP_Init();
    }
}

$(document).ready(function ()
{
    iframeP_Init();
});

function iframeP_Init()
{
    var popup = $('#globalContextPopup');

    $(document).off('click', 'a[PopupMenuName], input[PopupMenuName], td[PopupMenuName]');
    $(document).on('click', 'a[PopupMenuName], input[PopupMenuName], td[PopupMenuName]', function (event)
    {
        iframeP_openPopup(popup, $(this), false);
        event.preventDefault();
        event.stopPropagation();
    });

    $(document).off('click', 'a[ControlPath], input[ControlPath], td[ControlPath], area[ControlPath]');
    $(document).on('click', 'a[ControlPath], input[ControlPath], td[ControlPath], area[ControlPath]', function (event)
    {
        iframeP_openPopup(popup, $(this), true);
        event.preventDefault();
        event.stopPropagation();
    });

    $('#globalContextPopup a.popup-close').unbind('click');
    $('#globalContextPopup a.popup-close').click(function (event)
    {
        iframeP_closePopup(popup);
        event.preventDefault();
        event.stopPropagation();
    });

    var iframe = popup.find('iframe')
    $('#globalContextPopup').resize(function (event)
    {
        iframe.outerHeight(popup.height() - popup.find('div.popup-title').outerHeight());
        iframe.outerWidth(popup.width());
        //var pos = [popup.outerWidth() - 16, -12];
        //popup.find('a.popup-close').css({ left: pos[0], top: pos[1] });
    });


    $('#globalContextPopup div.popup-title').hover(
        function () { $(this).css('cursor', 'move'); },
        function () { $(this).css('cursor', ''); });

    $('#globalContextPopup').draggable({
        cursor: 'move',
        scroll: false,
        handle: 'div.popup-title',
        revert: function (event, ui)
        {
            var dragHandle = $('#globalContextPopup div.popup-title');
            var rect = dragHandle[0].getBoundingClientRect();
            return !(
                rect.top + dragHandle.height() - 5 >= 0 &&
                rect.left + dragHandle.width() - 20 >= 0 &&
                rect.bottom - dragHandle.height() + 5 <= $(window).height() &&
                rect.right - dragHandle.width() + 20 <= $(window).width()
            );
        },
        start: function (event, ui)
        {
            iframeP_disableEvents();
        },
        stop: function (event, ui) {
            iframeP_enableEvents();
        }
    });

    $('#globalContextPopup').resizable({
        handles: 'all',
        start: function (event, ui) {
            iframeP_disableEvents();
        },
        stop: function (event, ui) {
            iframeP_enableEvents();
        }
    });

}


function iframeP_openPopup(popup, trigger, simple)
{
    var iframe = popup.find('iframe');
    var group = trigger.attr('Group') == null ? (simple ? trigger.attr('ControlPath') : trigger.attr('PopupMenuName')) : trigger.attr('Group');
    var isInit = popup.attr('Group') != null && popup.attr('Group') == group;

    if ($('#global_viewAttributes').length > 0)
    {
        var autoRefreshTimer = $find($('#global_viewAttributes').attr('tmrRefreshId'));
        if (autoRefreshTimer != null && autoRefreshTimer.get_enabled())
            autoRefreshTimer._stopTimer();
    }

    if (!isInit)
    {
        if (trigger.attr('PopupWidth') != undefined)
            popup.width(parseInt(trigger.attr('PopupWidth')));
        else
            popup.width(900);
        if (trigger.attr('PopupHeight') != undefined)
            popup.height(parseInt(trigger.attr('PopupHeight')));
        else
            popup.height(570);
    }

    var src;
    if (simple)
        src = iframeP_ControlPath(trigger)
    else
        src = iframeP_ContextPath(trigger);

    // create overlay
    //var overlay = $('<div class="overlay" />');
    //overlay.appendTo(document.body);

    popup.show();

    var prevScroll = null;
    if (popup.attr('PrevScroll') != null)
        prevScroll = parseInt(popup.attr('PrevScroll'));

    // reposition if we have not yet been initialized OR if the scroll position of the window has changed
    if (!isInit || (prevScroll != null && prevScroll != $(window).scrollTop()))
    {
        // center
        var popupPos = [($(window).width() - popup.outerWidth()) / 2, ($(window).height() - popup.outerHeight()) / 2];
        var top = Math.max(popupPos[1], 5);
        if (trigger.attr('Top') != undefined)
            top = parseInt(trigger.attr('Top'));
        popup.css({ left: Math.max(popupPos[0], 5), top: top + $(window).scrollTop() });
        popup.attr('PrevScroll', $(window).scrollTop());
    }

    var divTitle = popup.find('div.popup-title');

    iframeP_InitTitle(trigger, divTitle);

    // adjust iframe height and width
    iframe.outerHeight(popup.height() - divTitle.outerHeight());
    iframe.outerWidth(popup.width());
    iframe.attr('src', src);

    // position close/drag
    //var pos = [popup.outerWidth() - 16, -12];
    //popup.find('a.popup-close').css({ left: pos[0], top: pos[1] });

    popup.attr('Group', group);

}

function iframeP_ContextPath(trigger)
{
    var menu = trigger.attr('PopupMenuName');
    var path = $('#global_applicationPath').val();

    var context = "Shared";
    if (trigger.attr('PopupContext') != undefined)
        context = trigger.attr('PopupContext');

    var url = window.location.protocol + '//' + window.location.host + path + '/ContextPopup/' + context + '/';

    var src = url + menu + '/?pid=' + trigger.attr('ProductId');

    var attrs = '';
    $($(trigger)[0].attributes).each(function ()
    {
        var name = this.name.toLowerCase();
        // this "specified" check was added ONLY because IE7 has a zillion worthless attributes that need to be ignored
        var specified = this.specified === undefined ? true : this.specified;
        if (specified)
        {
            switch (name)
            {
                case 'expirationid':
                    src += '&expirationid=' + this.value;
                    break;
                case 'expirationsymbol':
                    src += '&expirationsymbol=' + this.value;
                    break;
                case 'strikeid':
                    src += '&strikeid=' + this.value;
                    break;
                case 'strikeprice':
                    src += '&strikeprice=' + this.value;
                    break;
                case 'futuresymbol':
                    src += '&futureSymbol=' + this.value;
                    break;
                case 'tradedate':
                    src += '&tradedate=' + this.value;
                    break;
                case 'viewid':
                    if (this.value.length > 0)
                        src += '&viewid=' + this.value;
                    break;
                case 'shownav':
                    src += '&shownav=' + this.value;
                    break;
                case 'override':
                    src += '&override=' + this.value;
                    break;
                case 'persist':
                    src += '&persist=' + this.value;
                    break;
                case 'tabid':
                    src += '&tabid=' + this.value;
                    break;
                case 'title':
                case 'tooltip':
                case 'class':
                case 'id':
                case 'name':
                case 'style':
                case 'href':
                case 'caption':
                case 'productid':
                case 'popupmenuname':
                case 'popupcontext':
                case 'popupwidth':
                case 'popupheight':
                case 'group':
                    // ignore
                    break;
                default:
                    attrs += (attrs.length > 0 ? '|' : '') + this.name + '|' + this.value;
            }
        }
    });

    if (attrs.length > 0)
        src += '&attrs=' + encodeURIComponent(attrs);

    return src;
}

function iframeP_ControlPath(trigger)
{
    var path = $('#global_applicationPath').val();

    var protocol = window.location.protocol;
    if (trigger.attr('UseSSL') == "1")
        protocol = "https:";

    var src = protocol + '//' + window.location.host + path + '/User/ControlPopup.aspx?ControlPath=' + trigger.attr('ControlPath');

    $($(trigger)[0].attributes).each(function ()
    {
        var name = this.name.toLowerCase();
        // this "specified" check was added ONLY because IE7 has a zillion worthless attributes that need to be ignored
        var specified = this.specified === undefined ? true : this.specified;
        if (specified)
        {
            switch (name)
            {
                case 'title':
                case 'tooltip':
                case 'class':
                case 'id':
                case 'name':
                case 'style':
                case 'href':
                case 'popupwidth':
                case 'popupheight':
                case 'controlpath':
                case 'group':
                    // ignore
                    break;
                default:
                    src += '&' + this.name + '=' + this.value;
            }
        }
    });

    return src;
}

function iframeP_disableEvents()
{
    if (/edge|trident|msie/.test(navigator.userAgent.toLowerCase()))
    {
        var ifr = $('iframe');
        var d = $('<div id="iframeP_fix" style="position:absolute;width:100%"></div>');
        $('#globalContextPopup div.content-container').append(d[0]);
        d.css({ top: ifr.position().top, left: 0 });
        d.height(ifr.height());
    }
    else
        $('iframe').css('pointer-events', 'none');
}

function iframeP_enableEvents()
{
    if (/edge|trident|msie/.test(navigator.userAgent.toLowerCase()))
        $('#iframeP_fix').remove();
    else
        $('iframe').css('pointer-events', 'auto');
}

function iframeP_RefreshTitle(popupProperties)
{
    var popup = $('#globalContextPopup');
    var divTitle = popup.find('div.popup-title');
    switch (popupProperties.TitleId)
    {
        case 'Expiration':
            iframeP_SetTitle(divTitle, 'Expiration', popupProperties.ExpirationId, null);
            break;
        case 'Product':
        case 'Future':
            iframeP_SetTitle(divTitle, popupProperties.TitleId, '', popupProperties.ProductId);
            break;
    }
}

function iframeP_InitTitle(trigger, divTitle)
{
    divText = divTitle.children().first();
    if (trigger.attr('caption') != null)
    {
        divText.text(trigger.attr('caption'));
        return;
    }

    var id = '';
    var popupName = trigger.attr('PopupMenuName');
    var productId = '';
    switch (popupName)
    {
        case 'Strike':
            id = trigger.attr('strikeid');
            break;
        case 'Expiration':
            id = trigger.attr('expirationId');
            break;
        case 'Future':
            id = trigger.attr('futureSymbol');
            productId = trigger.attr('productId');
            break;
        //case 'Product':
        //    productId = trigger.attr('productId');
        //    break;
        default:
            divText.text('');
            return;
    }

    iframeP_SetTitle(divTitle, popupName, id, productId);

}

function iframeP_SetTitle(divTitle, popupName, id, productId)
{
    divText = divTitle.children().first();

    var method = '';
    var data = '';
    switch (popupName)
    {
        case 'Strike':
            divText.text('Strike Detail');
            method = 'GetStrikeTitle';
            data = "strikeId='" + id + "'";
            break;
        case 'Expiration':
            divText.text('Expiration Detail');
            method = 'GetExpirationTitle';
            data = "expirationId='" + id + "'";
            break;
        case 'Future':
            divText.text('Future Detail');
            method = 'GetFutureTitle';
            data = "productId='" + productId + "'&futureSymbol='" + id + "'";
            break;
        case 'Product':
            divText.text('Product Detail');
            method = 'GetProductTitle';
            data = "productId='" + productId + "'";
            break;
        default:
            divText.text('');
            return;
    }

    divText.css('visibility', 'hidden');
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/PopupMethods.aspx/' + method;
    $.ajax({
        type: 'GET',
        url: url,
        data: data,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            divText.text(result.d);
            divText.css('visibility', 'visible');
        },
        error: function (result)
        {
            divText.css('visibility', 'visible');
        }
    });

}

function iframeP_closePopup(popup)
{
    popup.hide();
    var iframe = popup.find('iframe');
    iframe.attr('src', '');
    //$('div.overlay').remove();

    if ($('#global_viewAttributes').length > 0)
    {
        var autoRefreshTimer = $find($('#global_viewAttributes').attr('tmrRefreshId'));
        if (autoRefreshTimer != null && autoRefreshTimer.get_enabled())
            autoRefreshTimer._startTimer();
    }

    var postback = iframe.contents().find('#global_updatedAttributes').attr('postbackOnClose');
    if (postback != undefined)
        __doPostBack('');

    
}

