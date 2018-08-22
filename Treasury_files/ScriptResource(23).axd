﻿var charttip_arrowSize = 8;

function charttip_Show(areaElem, event)
{
    area = $(areaElem);
    area.focus();

    var popup = $('#charttip_MainPopup');

    var template = $('#' + area.attr('templateId'));

    var html = charttip_getTipHtml(area, template);
    popup.html(html);

    charttip_showit(area, popup, event);

    try { event.stopPropagation(); } catch (e) { event.cancelBubble = true; }
}

function charttip_Hide()
{
    var popup = $('#charttip_MainPopup');
    popup.prev('div.tips-arrow').hide();
    popup.hide();
    try { event.stopPropagation(); } catch (e) { event.cancelBubble = true; }
}

function charttip_getTipHtml(area, template)
{
    var fields = area.attr('fields').split('~');

    var html = template.get(0).outerHTML;
    for (var i = 0; i < fields.length; i++)
    {
        var namevalue = fields[i].split('|')
        var name = '{' + namevalue[0] + '}';
        html = html.replace(new RegExp(name, 'g'), namevalue[1]);
    }

    var selected = area.attr('select');
    if (selected != null && selected.length > 0)
        html = html.replace(new RegExp(selected, 'g'), "selected");

    // remove 1st display:none and id from template html text
    html = html.replace(area.attr('templateId'), '');
    return html.replace(/display:\s*none/i, '');
}

function charttip_showit(area, popup, event)
{

    var areaOffset = new Object();
    var imgOffset = area.parent().prev('img').offset();
    var arrow = popup.prev('div.tips-arrow');
    var coords = area.attr('coords').split(',');
    switch (area.attr('shape').toUpperCase())
    {
        case 'RECT':
            areaOffset.left = imgOffset.left + parseInt(coords[0]);
            areaOffset.top = imgOffset.top + parseInt(coords[1]);
            areaOffset.width = parseInt(coords[2]) - parseInt(coords[0]);
            areaOffset.height = parseInt(coords[3]) - parseInt(coords[1]);
            break;
        case 'POLY':
            areaOffset.left = 10000;
            var right = 0;
            areaOffset.top = 10000;
            var bottom = 0;
            for (var i = 0; i < coords.length; i += 2)
            {
                areaOffset.left = Math.min(areaOffset.left, parseInt(coords[i]));
                right = Math.max(right, parseInt(coords[i]));
                areaOffset.top = Math.min(areaOffset.top, parseInt(coords[i + 1]));
                bottom = Math.max(bottom, parseInt(coords[i + 1]));
            }
            areaOffset.width = right - areaOffset.left;
            areaOffset.height = bottom - areaOffset.top;
            areaOffset.left = imgOffset.left + areaOffset.left;
            areaOffset.top = imgOffset.top + areaOffset.top;
            break;
        case 'CIRCLE':
            areaOffset.left = imgOffset.left + (parseInt(coords[0]) - parseInt(coords[2]));
            areaOffset.top = imgOffset.top + (parseInt(coords[1]) - parseInt(coords[2]));
            areaOffset.width = parseInt(coords[2]) * 2;
            areaOffset.height = parseInt(coords[2]) * 2;
            break;
        default:
            alert('unsupported area shape type: ' + area.attr('shape'));
            return;
    }

    var areaCenter = areaOffset.top + areaOffset.height / 2;
    var popupTop = areaCenter - (popup.outerHeight() / 2);

    // always position to right, unless it will be off the screen...then do left
    var popupPosition = null;
    var arrowPosition = null;
    if (areaOffset.left + areaOffset.width + popup.outerWidth() + charttip_arrowSize + 7 > $(window).width())
    {
        // off the screen, try left
        if (areaOffset.left - popup.outerWidth() - charttip_arrowSize - 7 < 0)
        {
            //off the screen left, go inside
            if (Math.abs(event.clientX - areaOffset.left) < Math.abs(event.clientX - areaOffset.left - areaOffset.width))
            {
                //Click was closer to the left edge - go inside left
                popupPosition = [areaOffset.left + charttip_arrowSize, popupTop];

                // position the arrow to left
                arrow.removeClass('left');
                arrow.addClass('right');
                arrowPosition = [popupPosition[0] - charttip_arrowSize, areaCenter - charttip_arrowSize];
            }
            else
            {
                //Click was closer to the right edge - go inside right
                popupPosition = [areaOffset.left + areaOffset.width - popup.outerWidth() - charttip_arrowSize, popupTop];

                // position the arrow to right
                arrow.removeClass('right');
                arrow.addClass('left');
                arrowPosition = [popupPosition[0] + popup.outerWidth(), areaCenter - charttip_arrowSize];
            }
        }
        else
        {
            //go left
            popupPosition = [areaOffset.left - popup.outerWidth() - charttip_arrowSize, popupTop];

            // position the arrow to right
            arrow.removeClass('right');
            arrow.addClass('left');
            arrowPosition = [popupPosition[0] + popup.outerWidth(), areaCenter - charttip_arrowSize];
        }
    }
    else
    {
        // default case...go right
        popupPosition = [areaOffset.left + areaOffset.width + charttip_arrowSize, popupTop];

        // position the arrow to left
        arrow.removeClass('left');
        arrow.addClass('right');
        arrowPosition = [popupPosition[0] - charttip_arrowSize, areaCenter - charttip_arrowSize];
    }

    popup.css({ left: popupPosition[0], top: popupPosition[1] });
    arrow.css({ left: arrowPosition[0], top: arrowPosition[1] });
    popup.show();

    // IE sucks, but IE7 really sucks!!!
    //if ($.browser.msie && parseInt($.browser.version, 10) === 7)
    //    return;

    arrow.show();
}

