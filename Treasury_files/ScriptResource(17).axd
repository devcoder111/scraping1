
if (window.Sys !== undefined && Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(qswc_datepicker_EndRequestHandler);

function qswc_datepicker_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        qswc_datepickder_Init();
    }
}

$(document).ready(function ()
{
    qswc_datepickder_Init();
});

function qswc_datepickder_Init() {

    $('input:image.datepicker-clear-trigger').click(function (event)
    {
        $('#' + $(this).attr('target')).val('');
        event.preventDefault();
    });

}

function qswc_datepickder_dateChanged(dateTextClientId)
{
    var ctrlDate = $('#' + dateTextClientId);
    var selectedDate = new Date(Date.parseLocale(ctrlDate.val()));
    var minDate = new Date(Date.parseLocale(ctrlDate.attr('mindate')));

    if (selectedDate < minDate)
        ctrlDate.val(ctrlDate.attr('mindate'));
}
