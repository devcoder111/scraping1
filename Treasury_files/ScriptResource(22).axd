﻿var ctxhelp_arrowSize = 8;
var ctxhelp_padding = 5;
var ctxhelp_tipRadius = 11;
var ctxhelp_tipOffset = 2;

if (window.Sys !== undefined && Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(scm_EndRequestHandler);

function scm_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        ctxhelp_Init();
    }
}

$(document).ready(function ()
{
    ctxhelp_Init();
});

function ctxhelp_Init()
{
    var trigger = $('a.tips-trigger');

    trigger.unbind('click');
    trigger.click(function (event)
    {
        var isOn = $(this).attr('ison');

        if (isOn == null || isOn == '0')
            ctxhelp_PositionTips(trigger);
        else
            ctxhelp_hideTips(trigger, true);

        event.preventDefault();
        event.stopPropagation();
    });

    $(window).unbind('resize.helptips');
    $(window).bind('resize.helptips', function (event)
    {
        if (trigger.length > 0 && trigger.attr('ison') == '1')
            ctxhelp_PositionTips(trigger);
    });

    ctxhelp_hideTips(trigger, false);

}

function ctxhelp_hideTips(trigger, useEffect)
{
    trigger.attr('ison', '0');
    trigger.attr('title', 'Turn On Help Tips');
    trigger.removeClass('on');

    $('div.tips-bubble').each(function ()
    {
        $(this).parent().appendTo($('#upMain'));

        var bubble = $(this);
        var arrow = bubble.prev('div.tips-arrow');
        var idImg = arrow.prev('img.tips-id');
        var idNum = idImg.prev('div.tips-num');

        if (useEffect)
        {
            bubble.fadeOut(800);
            arrow.fadeOut(800);
            idImg.fadeOut(800);
            idNum.fadeOut(800);
        }
        else
        {
            bubble.hide();
            arrow.hide();
            idImg.hide();
            idNum.hide();
        }
    });
}

function ctxhelp_PositionTips(trigger)
{
    trigger.attr('ison', '1');
    trigger.attr('title', 'Turn Off Help Tips');
    trigger.addClass('on');

    $('div.tips-bubble').each(function ()
    {
        var bubble = $(this);
        var target = $('#' + bubble.attr('tipTarget'));
        var arrow = bubble.prev('div.tips-arrow');
        var idImg = arrow.prev('img.tips-id');
        var idNum = idImg.prev('div.tips-num');

        var bubbleWidth = parseInt(bubble.attr('width'));
        if (bubbleWidth > 0)
            bubble.width(bubbleWidth);

        var targetOffset = target.offset();
        targetOffset.left += parseInt($(this).attr('xoffset'));
        targetOffset.top += parseInt($(this).attr('yoffset'));

        var bubblePos;
        switch(bubble.attr('position').toLowerCase())
        {
            case "center":
                bubblePos = ctxhelp_Center(bubble, target, targetOffset, arrow);
                break;
            case "topcenter":
                bubblePos = ctxhelp_TopCenter(bubble, target, targetOffset, arrow);
                break;
            case "rightcenter":
                bubblePos = ctxhelp_RightCenter(bubble, target, targetOffset, arrow);
                break;
            case "leftcenter":
                bubblePos = ctxhelp_LeftCenter(bubble, target, targetOffset, arrow);
                break;
            default:
                bubblePos = ctxhelp_BottomCenter(bubble, target, targetOffset, arrow);
                break;
        }

        if (!bubblePos.bubbleVisible || !target.is(':visible'))
        {
            arrow.hide();
            bubble.hide();
            idImg.hide();
            idNum.hide();
            return;
        }

        // IE sucks, but IE7 really sucks!!!
        //if ($.browser.msie && parseInt($.browser.version, 10) === 7)
        //    bubblePos.hideArrow = true;

        arrow.css({ left: bubblePos.arrowLeft, top: bubblePos.arrowTop });
        bubble.css({ left: bubblePos.bubbleLeft, top: bubblePos.bubbleTop });
        idImg.css({ left: bubblePos.idLeft, top: bubblePos.idTop });

        // ** turn stuff on

        if (!bubblePos.hideArrow)
            arrow.fadeIn(1500);

        // position the number
        var tipId = $(this).attr('tipId');
        if (tipId != null && tipId.length > 0)
        {
            idNum.text($(this).attr('tipId'));
            var imgOffset = idImg.offset();
            idNum.css({ left: bubblePos.idLeft + ctxhelp_tipRadius - (idNum.outerWidth() / 2), top: bubblePos.idTop + ctxhelp_tipRadius - (idNum.outerHeight() / 2) });
            idImg.fadeIn(1500);
            idNum.fadeIn();
        }

        bubble.fadeIn(1500);

    });

    function ctxhelp_Center(bubble, target, targetOffset, arrow)
    {
        var bubblePos = new Object();
        bubblePos.bubbleVisible = true;
        bubblePos.hideArrow = true;

        // ** center **

        // position the bubble
        var targetXCenter = targetOffset.left + (target.outerWidth() / 2);
        var targetYCenter = targetOffset.top + (target.outerHeight() / 2);
        bubblePos.bubbleLeft = targetXCenter - (bubble.outerWidth() / 2);
        bubblePos.bubbleTop = targetYCenter - (bubble.outerHeight() / 2);

        // position the id img
        bubblePos.idLeft = targetXCenter - ctxhelp_tipRadius;
        bubblePos.idTop = bubblePos.bubbleTop - (ctxhelp_tipRadius * 2) - ctxhelp_tipOffset;


        return bubblePos;
    }

    function ctxhelp_BottomCenter(bubble, target, targetOffset, arrow)
    {
        var bubblePos = new Object();
        bubblePos.bubbleVisible = true;

        // ** bottom center **
        arrow.addClass('up');

        // position the bubble
        var targetCenter = targetOffset.left + (target.outerWidth() / 2);
        bubblePos.bubbleLeft = targetCenter - (bubble.outerWidth() / 2);
        bubblePos.bubbleTop = targetOffset.top + target.outerHeight() + ctxhelp_arrowSize;

        // position the arrow
        bubblePos.arrowLeft = targetCenter - ctxhelp_arrowSize;
        bubblePos.arrowTop = targetOffset.top + target.outerHeight();

        // position the id img
        bubblePos.idLeft = targetCenter - ctxhelp_tipRadius;
        bubblePos.idTop = bubblePos.arrowTop - (ctxhelp_tipRadius * 2) - ctxhelp_tipOffset;

        ctxhelp_AdjustH(bubble, target, targetOffset, arrow, bubblePos);

        return bubblePos;
    }

    function ctxhelp_TopCenter(bubble, target, targetOffset, arrow)
    {
        var bubblePos = new Object();
        bubblePos.bubbleVisible = true;

        // ** bottom center **
        arrow.addClass('down');

        // position the bubble
        var targetCenter = targetOffset.left + (target.outerWidth() / 2);
        bubblePos.bubbleLeft = targetCenter - (bubble.outerWidth() / 2);
        bubblePos.bubbleTop = targetOffset.top - bubble.outerHeight() - ctxhelp_arrowSize;

        // position the arrow
        bubblePos.arrowLeft = targetCenter - ctxhelp_arrowSize;
        bubblePos.arrowTop = targetOffset.top - ctxhelp_arrowSize;

        // position the id img
        bubblePos.idLeft = targetCenter - ctxhelp_tipRadius;
        bubblePos.idTop = targetOffset.top + ctxhelp_tipOffset;

        ctxhelp_AdjustH(bubble, target, targetOffset, arrow, bubblePos);

        return bubblePos;

    }

    function ctxhelp_RightCenter(bubble, target, targetOffset, arrow)
    {
        var bubblePos = new Object();
        bubblePos.bubbleVisible = true;

        // ** bottom center **
        arrow.addClass('right');

        // position the bubble
        var targetCenter = targetOffset.top + (target.outerHeight() / 2);
        bubblePos.bubbleTop = targetCenter - (bubble.outerHeight() / 2);
        bubblePos.bubbleLeft = targetOffset.left + target.outerWidth() + ctxhelp_arrowSize;

        // position the arrow
        bubblePos.arrowTop = targetCenter - ctxhelp_arrowSize;
        bubblePos.arrowLeft = targetOffset.left + target.outerWidth();

        // position the id img
        bubblePos.idTop = targetCenter - ctxhelp_tipRadius;
        bubblePos.idLeft = bubblePos.arrowLeft - (ctxhelp_tipRadius * 2) - ctxhelp_tipOffset;

        return bubblePos;

    }

    function ctxhelp_LeftCenter(bubble, target, targetOffset, arrow)
    {
        var bubblePos = new Object();
        bubblePos.bubbleVisible = true;

        // ** bottom center **
        arrow.addClass('left');

        // position the bubble
        var targetCenter = targetOffset.top + (target.outerHeight() / 2);
        bubblePos.bubbleTop = targetCenter - (bubble.outerHeight() / 2);
        bubblePos.bubbleLeft = targetOffset.left - bubble.outerWidth() - ctxhelp_arrowSize;

        // position the arrow
        bubblePos.arrowTop = targetCenter - ctxhelp_arrowSize;
        bubblePos.arrowLeft = targetOffset.left - ctxhelp_arrowSize;

        // position the id img
        bubblePos.idTop = targetCenter - ctxhelp_tipRadius;
        bubblePos.idLeft = targetOffset.left + ctxhelp_tipOffset;

        return bubblePos;

    }

    function ctxhelp_AdjustH(bubble, target, targetOffset, arrow, bubblePos)
    {
        windowWidth = $(window).width() + $(window).scrollLeft() - ctxhelp_padding;

        // left side of window
        if (bubblePos.bubbleLeft < ctxhelp_padding)
            bubblePos.bubbleLeft = ctxhelp_padding;

        // right side of window
        if (bubblePos.bubbleLeft + bubble.outerWidth() > windowWidth)
        {
            var adjustedLeft = windowWidth - bubble.outerWidth();
            var furthestLeft = bubblePos.arrowLeft + (ctxhelp_arrowSize * 2) + 4 /*random amt*/ - bubble.outerWidth();
            bubblePos.bubbleLeft = Math.max(adjustedLeft, furthestLeft);
        }
    }

}
