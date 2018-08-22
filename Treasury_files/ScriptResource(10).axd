﻿if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(pfio_EndRequestHandler);

function pfio_EndRequestHandler(sender, args) {
    if (args.get_error() == undefined) {
        pfio_documentReady();
    }
}

$(document).ready(function () {
    pfio_documentReady();
});


function pfio_documentReady()
{

    var dialog = $('#pfio-summary-dialog').dialog({
        autoOpen: false,
        hide: 'blind',
        width: 740,
        height : 500
    });

    dialog.parent().appendTo($('#upMain'));

    $('#pfio-product-summaries a.pfio-summary-trigger').click(function (event)
    {
        pfio_openSummary(this, $(this).attr('eid'));
        event.preventDefault();
    });

}

function pfio_openSummary(triggerCtrl, expirationId)
{
    $('#pfio-dialog-content').html('Loading...');
    $('#pfio-summary-dialog').dialog('open');
    $('#pfio-summary-dialog').parent().appendTo($('#upMain'));

    $('#pfio-summary-dialog').dialog('option', 'title', $(triggerCtrl).attr('portname') + ' - ' + $(triggerCtrl).attr('prod'));
        
    //Load the dialog with the contents from the AJAX call
    var path = $('#global_applicationPath').val();

    var url = window.location.protocol + '//' + window.location.host + path + '/User/Portfolio/PortfolioExpirationDetail.aspx?noerr=&pid=' + $(triggerCtrl).attr('pid');
    if (expirationId != null)
        url += '&eid=' + expirationId;

    if ($('#global_instanceCache').val().length > 0)
        url += '&' + $('#global_instanceCache').val();

    url += ' #pfio-detail';

    $('#pfio-dialog-content').load(url, function (response, status, xhr)
    {
        if (status == 'error')
        {
            $('#pfio-dialog-content').html('An error occurred while loading the portfolio expiration detail: ' + xhr.status + ' ' + xhr.statusText);
        }
        else
        {
            // to fix wierd ie bug where div doesn't update until mouse is moved
            window.focus();

        }
    });

    

}
