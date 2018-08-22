﻿
if (window.Sys !== undefined && Sys.WebForms != null) {
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(qswc_spin_BeginRequestHandler);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(qswc_spin_EndRequestHandler);
}

function qswc_spin_BeginRequestHandler(sender, args) {
    $('img.qswc_spin_up').unbind();
    $('img.qswc_spin_down').unbind();
    $('img.qswc_spin_up + select').unbind();
}

function qswc_spin_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        qswc_spin_InitSpinner();
    }
}

$(document).ready(function ()
{
    qswc_spin_InitSpinner();
});

// may be called externally to disable 
function qswc_spin_disable(target, disable)
{
    if (disable)
    {
        target.attr('disabled', 'disabled');
        target.prev().attr('disabled', 'disabled');
        target.next().attr('disabled', 'disabled');
    }
    else
    {
        target.removeAttr('disabled');
        target.prev().removeAttr('disabled');
        target.next().removeAttr('disabled');
    }
}

function qswc_spin_InitSpinner()
{
    $('img.qswc_spin_up').click(function () {
        qswc_spin_up($(this).attr('target'), $(this).attr('postbackref'));
    });

    $('img.qswc_spin_down').click(function ()
    {
        qswc_spin_down($(this).attr('target'), $(this).attr('postbackref'));
    });

    // handle left right keys
    $('img.qswc_spin_up + select').keydown(function (event)
    {
        if (event.which == 39 /*right*/)
        {
            var img = $(this).next();
            qswc_spin_down(img.attr('target'), img.attr('postbackref'));
            event.preventDefault();
        }
        else if (event.which == 37 /*left*/)
        {
            var img = $(this).next();
            qswc_spin_up(img.attr('target'), img.attr('postbackref'));
            event.preventDefault();
        }
    });

}

function qswc_spin_up(ctrlId, postbackRef)
{
    var prev = $('#' + ctrlId + ' option:selected').prev();
    if (prev.val() != undefined)
    {
        $('#' + ctrlId).val(prev.val());
        $('#' + ctrlId).change();
        if (postbackRef.length > 0)
            window.setTimeout(postbackRef, 0);
    }
}

function qswc_spin_down(ctrlId, postbackRef)
{
    var next = $('#' + ctrlId + ' option:selected').next();
    if (next.val() != undefined)
    {
        $('#' + ctrlId).val(next.val());
        $('#' + ctrlId).change();
        if (postbackRef.length > 0)
            window.setTimeout(postbackRef, 0);
    }
}

