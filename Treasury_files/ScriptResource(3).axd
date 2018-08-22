var globalMobileProperties = null;
var globalLoaded = false;

if (Sys.WebForms != null)
{
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(global_EndRequestHandler);
    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(global_PageLoadedHandler);
}

function global_EndRequestHandler(sender, args) 
{
    var error = args.get_error();
    if (error == undefined)
    {
        global_documentReady();
    }
    else 
    {
        args.set_errorHandled(true);
        var msg = error.message.replace("Sys.WebForms.PageRequestManagerServerErrorException: ", "");
        var isQSServerError = msg.indexOf("QS-ERROR") >= 0;
        if (isQSServerError)
        {
            error.message = null; // for some reason we need to do this or the error gets thrown again by the PageRequestManager
            msg = msg.replace("QS-ERROR", "");
            alert(msg);
        }
        // else
            // our server-side async error handler was never called so we are going to ignore the error...doing this because
            // we were getting some mysterious client error on Timer tick postbacks when Laptop sleeps
    }
}

function global_PageLoadedHandler(sender, args)
{
    global_pageLoaded();
}


$(document).ready(function () 
{
    global_documentReady();
});


function global_loadLast()
{
    if (!globalLoaded)
    {
        window.setTimeout(global_loadLast, 100);
    }
    else
    {
        // do this after everything is loaded so that css/jquery/image loading is done affecting the column widths
        global_initFrozenColumns();
    }
}

function global_pageLoaded()
{
    global_loadLast();
}

function global_documentReady()
{


    global_initMobile();

    global_setTimeZone();

    global_initAccess();

    global_initDynamicLists();

    global_setTitle();

    // look for the class that indicates prevention of default submit behavior
    var once = false;
    $("form").unbind("keypress");
    $(".no-default-submit").each(function ()
    {
        if (!once)
        {
            $("form").bind("keypress", function (e)
            {
                if (e.keyCode == 13 && e.target.tagName.toUpperCase() != 'TEXTAREA')
                    return false;
            });
            once = true;
        }
    });

    global_initEffects();

    global_initAutoColor();

    global_initActionMenu();

    global_enableCancel();

    $('.auto-check-on').click(function (event) {
        $('.auto-check input[type="checkbox"]').prop('checked', true);
        event.preventDefault();
    });

    $('.auto-check-off').click(function (event) {
        $('.auto-check input[type="checkbox"]').prop('checked', false);
        event.preventDefault();
    });

    $('.g-grp-check-on').click(function (event) {

        var gid = $(this).attr('gid');
        $("span[gid='" + gid + "'] > input[type=checkbox]").prop('checked', true);
        event.preventDefault();
    });

    $('.g-grp-check-off').click(function (event) {

        var gid = $(this).attr('gid');
        $("span[gid='" + gid + "'] > input[type=checkbox]").not("[disabled]").prop('checked', false);
        event.preventDefault();
    });




    $(".auto-tab").tabs();
    
    $("div.qs-tabs").addClass("ui-tabs ui-widget");
    $("div.qs-tabs > ul").addClass("ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all");
    $("div.qs-tabs > li").addClass("ui-state-default");

    $("div.qs-vtabs").removeClass("ui-widget-content").addClass("ui-tabs ui-widget ui-tabs-vertical ui-helper-clearfix");
    $("div.qs-vtabs > ul").addClass("ui-vtabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all");
    $("div.qs-vtabs > ul > li").removeClass("ui-corner-top").addClass("ui-corner-left ui-state-default vtab");
    $("div.qs-vtabs div.qs-vtab-panel").removeClass("ui-corner-bottom").addClass("ui-corner-right");


    // vertically center any divs that need it
    //$('div.center-me-v').each(function ()
    //{
    //    debugger;
    //    var parentHeight = $(this).parent().height();
    //    var myHeight = $(this).height();
    //    if (myHeight < parentHeight) {
    //        $(this).css('marginTop', ((parentHeight - myHeight) / 2) + 'px');
    //    }
    //});

    // horizontally center any divs that need it, NOTE: there is a style associated with this class in default.less
    $('div.center-me-h').each(function ()
    {
        var myW = $(this).width();
        $(this).css('display', 'block');
        $(this).css('width', myW + 'px');
    });

    //$(document).unbind('click');
    $(document).click(function (event)
    {
        // if we clicked in a qs-input-popup, do not close stuff
        if ($(event.target).data('preventClose') != '1')
            global_closeDropMenus();
    });


    $('div.qs-input-popup').unbind('click');
    $('div.qs-input-popup').bind('click', function (event)
    {
        $(event.target).data('preventClose', '1');
    });

    global_setDivScroll();

    // turn on main div...for mobile, this is turned off to avoid flicker while jquery processes css
    if ($('#global_attributes').attr('isMobile') == '1' && globalMobileProperties.HasClientProperties)
        document.body.style.display = '';

    // we do this last...otherwise in mobile mode the view picker control gets messed up
    $("div.qs-vtabs a.qs-tabs-trigger div.trigger-text").each(function ()
    {
        var width = $(this).closest('a.qs-tabs-trigger').width();
        $(this).width(width - 21);
    });

    globalLoaded = true;

}

function global_initMobile()
{
    if (mobile_isInitialLoad(false))
        return;

    var mobileClass = $('#global_attributes').attr('mobileClass');
    $(".do-mobile").addClass(mobileClass);

    var isMobile = $('#global_attributes').attr('isMobile') == '1';
    if (isMobile)
    {
        if (globalMobileProperties.DeviceType != DeviceTypeCode_Unknown)
        {
            $(window).bind('orientationchange', function (event)
            {
                if (globalMobileProperties.MobileSize != mobile_getMobileSize())
                {
                    document.body.style.display='none';
                    mobile_setMobileProperties(false);
                    return;
                }
            });
        }
        else
        {
            // orientation change
            $(window).bind('resize.mobile', function (event)
            {
                if (globalMobileProperties.MobileSize != mobile_getMobileSize())
                {
                    document.body.style.display='none';
                    mobile_setMobileProperties(false);
                    return;
                }
            });
        }
    }

}

function global_initFrozenColumns()
{
    $("table.mobile-scroll").each(function ()
    {
        global_freezeScrollSetup($(this))
    });

}

function global_setDivScroll()
{
    $('div.scroll-position').each(function ()
    {
        var hidden = $(this).find('input[type="hidden"].scroll-value');
        if (hidden.length > 0 && hidden.val().length > 0)
        {
            // use saved scroll position if available
            $(this).scrollTop(hidden.val());
        }
        else
        {
            // otherwise, center the selected item in the div
            var selected = $(this).find('.selected');
            if (selected.length > 0)
                $(this).scrollTop((selected.first().offset().top - $(this).offset().top)
                    - $(this).height() / 2 + selected.first().height() / 2);
        }
    });

    $('div.scroll-position .set-scroll').click(function (event)
    {
        // save scroll position when item is clicked
        var divScroll = $(this).closest('div.scroll-position');
        var hidden = divScroll.find('input[type="hidden"].scroll-value');
        if (hidden.length > 0)
            hidden.val(divScroll.scrollTop());
    });
}

function global_closeDropMenus(currentItem)
{
    //Set all popup state hidden field values to 'closed'
    $('a[PopupClientId], input[PopupClientId]').children('input[type="hidden"]').val("closed");

    if (currentItem === undefined)
        $('div.qs-popup,div.qs-input-popup,div.qs-confirm').hide();
    else
        $('div.qs-popup,div.qs-input-popup,div.qs-confirm').not(currentItem).hide();

    $('ul.nav a.popup-open').removeClass('popup-open');

    $("div.enable-cancel").each(function ()
    {
        global_resetCancelInputs($(this));
    });

    // inform the product selector that it may have been closed
    if (typeof prodx_close === 'function')
        prodx_close();
}

function global_setTimeZone()
{
    var indicator = $('#global_settimezone_indicator');
    if (indicator != undefined && indicator.val() != undefined && indicator.val() != '1')
        return;

    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/SessionUtilityMethods.aspx/SetTimeZoneOffset';

    $.ajax({
        type: 'GET',
        url: url,
        data: "timeZoneOffset='" + -(new Date().getTimezoneOffset()).toString() + "'",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
        },
        error: function (result)
        {
        }

    });

}


function global_initAccess()
{
    $('a.deny-standard-access,input.deny-standard-access').click(function (event)
    {
        global_closeDropMenus();
        $('#access-denied-msg').slideDown();
        event.preventDefault();
        event.stopImmediatePropagation();
    });

    $('#access-denied-msg a').click(function (event)
    {
        $('#access-denied-msg').slideUp();
        event.preventDefault();
    });
}

function global_setTitle()
{
    //debugger;
    var prefix = $('#global_title').attr('prefix');
    if (prefix != undefined && prefix.length > 0)
        prefix += ' - ';
    else
        prefix = '';

    var title = 'QuikStrike';
    if ($('#page_title').val() == undefined)
    {
        if (prefix.length > 0 && document.title.startsWith(prefix))
        // prefix has already been added to title
            return;
        else
        {
            if ($('#global_title').val() == undefined || $('#global_title').val().length == 0)
                title = document.title;
            else
                title = $('#global_title').val();
        }
    }
    else if ($('#page_title').val().length > 0)
        title = $('#page_title').val();


    document.title = prefix + title;
}


function global_initEffects() 
{
    $('input.ui-button, a.ui-button').hover(
	    function () {
	        $(this).addClass("ui-state-hover");
	    },
	    function () {
	        $(this).removeClass("ui-state-hover");
	    }
     );


    $('img.auto-hover-img, a.auto-hover-img, input[type="image"].auto-hover-img').hover(
	    function () {
	        $(this).addClass("auto-hover-effect-img");
	    },
	    function () {
	        $(this).removeClass("auto-hover-effect-img");
	    }
    );
}

function global_initAutoColor() {

    $('select.auto-color').each(function ()
    {
        $(this).bind('change', function ()
        {
            global_autoSetSelectColor($(this));
        });

        global_autoSetSelectColor($(this));

    });
}

function global_autoSetSelectColor(elem)
{
    /* PREFERED APPROACH - firefox doesn't like this, works fine in all versions of ie and chrome
    var color = elem.children('option:selected').css('backgroundColor');
    elem.css('backgroundColor', color);
    */

    var newColor = elem.children('option:selected').attr('class');

    if (elem.attr('exp-color') != undefined)
        elem.removeClass(elem.attr('exp-color'));
    
    elem.addClass(newColor);
    elem.attr('exp-color', newColor);

}

function global_initDynamicLists()
{
    $('ul.dyn-list').each(function() {
        $(this).children('li:not(.hide)').first().addClass('first');
        $(this).children('li:not(.hide)').last().addClass('last');
    });
}

function PopUpHrefWithSizeNoSizeOrScroll(sWindowName, pAnkr, iHeight, iWidth) {
    var win = window.open(pAnkr.href, sWindowName, "resizable=no,toolbar=no,scrollbars=no,top=0,left=0,width=" + iWidth + ",height=" + iHeight);
    win.focus();
    return false;
}

function CheckForNumber(pTB) {
    var bRet = false;
    bRet = ("-.0123456789".indexOf(String.fromCharCode(event.keyCode)) > -1);
    return (bRet);
}

function PopUp(sWindowName, sURL) {
    var win = window.open(sURL, sWindowName, "resizable=yes,toolbar=no,scrollbars=yes,top=0,left=0,width=1024,height=768");
    win.focus();
    return false;
}

//function global_openHelp(helpUrl)
//{
//    var windowOpen = false;

//    // NOTE: the desired behavior is to have help open in the same window all the time...and to force focus on that window
//    // however, broswers behave quite differently and also have quite a bit of dependence on security settings, so this stuff only "kinda" works
//    // basically, it doesn't work for shit in IE and the kludges below make it work OK for firefox...chrome is good, doesn't need any of this
//    if (globalHelpWindow != null && $.browser.mozilla)
//    {
//        windowOpen = true;
//        globalHelpWindow.close();
//    }

//    globalHelpWindow = window.open(helpUrl, 'HelpWindow');
//    if (globalHelpWindow != null)
//    {
//        if (!windowOpen && $.browser.mozilla)
//        {
//            globalHelpWindow.close();
//            globalHelpWindow = window.open(helpUrl, 'HelpWindow');
//        }
//        globalHelpWindow.focus();
//    }
//    return false;
//}

function global_initActionMenu() {
    $('ul.menu-action li.parent a.btn').click(function () {
        var isOpen = false;

        //if child menu is visible, hide it, if not, show it
        var e = $(this).parent().find('ul');

        if (e.length > 0) {
            if (e.is(':visible')) {
                isOpen = true;
            }
        }

        //hide all open menus
        $('ul.menu-action li.parent ul:visible').hide();
        $('ul.menu-action li.parent').removeClass('active');

        if (isOpen) {
            e.hide();
        }
        else {
            e.show();
            e.parents('li.parent').addClass('active');
            
            $(e).click(function () {
                e.hide();
            });
        }

        return false;
    });

    $(document).click(function (e) {
        var t = $(e.target);

        //hide all visible menus on a click outside of the menu
        if (t.parents('ul.menu-action').length == 0) {
            $('ul.menu-action li.parent ul').hide();
        }
    });
}

function global_enableCancel()
{
    // select any 'input' or 'select' element that has or is a child of, class .enable-cancel
    var cancelElements = $('input.enable-cancel, .enable-cancel input, select.enable-cancel, .enable-cancel select, textarea.enable-cancel, .enable-cancel textarea');

    // checkboxes and radio buttons
    cancelElements.filter('input:checkbox,input:radio').each(function ()
    {
        $(this).attr('cancelValue', $(this).is(':checked') ? '1' : '0');
    });

    // dropdownlists and textboxes
    cancelElements.filter('select, input:text, textarea').each(function ()
    {
        // because of a jQuery bug in find() and filter(), null attribute values are not returned (i.e. "cancelValue=''" is ok, but "cancelValue" is not)
        // ...so instead, we kludge it up (also see below)
        var val = $(this).val();
        $(this).attr('cancelValue', (val == null || val.length == 0) ? '_null_' : val);
    });

    // setup cancel trigger
    $(':submit[cancelTarget], a[cancelTarget]').each(function ()
    {
        $(this).click(function (event)
        {
            var targetId = $(this).attr('cancelTarget');
            global_resetCancelInputs($('#' + targetId));
            $('#' + targetId).hide();
            event.preventDefault();
        });
    });
}

function global_resetCancelInputs(cancelContainer)
{
    // reset checkboxes and radio buttons to initial values when canceling
    cancelContainer.find('input[type="checkbox"][cancelValue],input[type="radio"][cancelValue]').each(function ()
    {
        if ($(this).attr('cancelValue') == '1')
            $(this).prop('checked', true);
        else
            $(this).prop('checked', false);
    });


    // reset dropdownlists and textboxes
    cancelContainer.find('select[cancelValue],input[type="text"][cancelValue],textarea[cancelValue]').each(function ()
    {
        // because of a jQuery bug in find() and filter(), null attribute values are not returned (i.e. "cancelValue=''" is ok, but "cancelValue" is not)
        // so we flag null values - NOTE: a normal jQuery select works fine with null attribute value, i.e. $('input[type="text"][cancelValue])
        var val = $(this).attr('cancelValue');
        $(this).val(val == '_null_' ? '' : val);
    });
}

function global_freezeScrollSetup(table)
{
    var freezeCols = 1;
    if (table.attr('FrozenColumns') != null)
        freezeCols = parseInt(table.attr('FrozenColumns'));

    // two ways to specify where to freeze:
    // 1. set FrozenColumns attribute to the number of columns to be frozen...this doesn't always work if the first row with TDs has spanned columns
    // 2. set FrozenColumns to -1 and then add the "freeze-me" class to the last td in a row that should be frozen

    var freezeWidth;
    if (freezeCols == -1)
    {
        var tdFreezeMarker = table.find('td.freeze-me');
        freezeWidth = (tdFreezeMarker.position().left + tdFreezeMarker.outerWidth()) - table.position().left;
    }
    else
    {
        var tdFreezeMarker = table.find('td:nth-child(' + (freezeCols + 1) + ')');
        freezeWidth = tdFreezeMarker.position().left - table.position().left;
    }

    // before applying these classes, we need to lock the parent height
    table.parent().height(table.parent().height());

    table.wrap("<div class='freeze-scroll'/>");

    var copy = table.clone();
    copy.insertBefore(table);

    var borderClass = '';
    if (table.hasClass('hide-scroll-border'))
        borderClass = ' hide-scroll-border';

    table.wrap("<div class='pinned" + borderClass + "' />");
    copy.wrap("<div class='scrolling' />");

    // set the width of the pinned div to the width of the frozen columns
    table.parent().width(freezeWidth - 1);

    // reset pinned table width
    table.width(copy.outerWidth());

    // center the scrolling table if necessary
    var divFreezeScroll = table.parent().parent();
    if (table.hasClass('center-scroll') && table.outerWidth() < divFreezeScroll.width())
    {
        divFreezeScroll.width(table.outerWidth());
        divFreezeScroll.css('margin', 'auto');
    }

    // update sparklines if there are any
    var sparkSpans = copy.find('span.inlinesparkline');
    if (sparkSpans.length > 0)
    {
        sparkSpans.each(function ()
        {
            // remove the canvas
            $(this).empty();

            // append the sparkline data
            $(this).text($(this).attr('sparkData'));
        });
        qs_initSparklines();
    }

    // set initial scroll pos
    switch (table.attr('InitialScroll'))
    {
        case 'right':
            var div = copy.parent();
            div.scrollLeft(100000);
            break;
        default:
            break;
    }

}
