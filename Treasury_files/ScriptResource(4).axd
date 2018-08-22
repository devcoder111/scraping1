﻿if (Sys.WebForms != null)
{
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(qs_EndRequestHandler);
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(qs_BeginRequestHandler);
}

function qs_EndRequestHandler(sender, args) {
    var error = args.get_error();
    if (error == undefined) {

        qs_documentReady();
    }
}

function qs_BeginRequestHandler(sender, args)
{
    // moves the throbber over the refresh button while the update progress is active
    var refeshBtn = $('#refreshButton');
    if (refeshBtn.length)
    {
        throbbing = true;
        var pos = refeshBtn.offset();
        if (pos.left > 0)
        {
            // use visibility instead of hide() so flow does not affect other controls
            refeshBtn.css('visibility', 'hidden');
            $('#throbberImg').css({ left: pos.left, top: pos.top });
        }
    }
}


$(document).ready(function () {
    qs_documentReady();
});

function qs_documentReady() {

    qs_initItemWrapperFix();

    qs_initExpirationMatrixCrosshairs();

    qs_initLinks();

    qs_initSparklines();

}

function hideRail() {

    $('#doc3').removeClass('yui-t6');
    $('#rail').hide();
    $('#bd').removeClass('ui-resize');
}

function showRail() {
    $('#doc3').addClass('yui-t6');
    $('#rail').show();
    $('#bd').addClass('ui-resize');
}

function qs_initLinks() {
    //init external links
    $('a[rel="external"]').click(function () {
        $(this).attr({ 'target': '_blank' });
    });
}

function qs_initItemWrapperFix() {

    var totalWidth = 0;
    $('div.item-group div.item-wrapper').each(function (index) {
        $(this).width($(this).find('div.ui-widget-info').outerWidth());
        totalWidth += $(this).outerWidth() + 4;
    });

    $('div.item-group').width(totalWidth);

    //$('#tablethree').tableHover({ colClass: 'hover', cellClass: 'hovercell', clickClass: 'click' });


}

function qs_initExpirationMatrixCrosshairs() {

    $('table.crosshairs').tableHover({
        colClass: 'hover-test',
        cellClass: 'hover-test-cell',
        clickClass: 'hover-test-click'
    });
}

function qs_initSparklines() {
    $('.inlinesparkline').sparkline('html', { enableTagOptions: true });
}

