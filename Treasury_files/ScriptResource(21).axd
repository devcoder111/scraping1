﻿
$(document).ready(function ()
{
    // if an initial time is provided, use it
    if ($('#global_utcTime').val() != undefined && $('#global_utcTime').val().length > 0)
    {
        clocks_SetTime(Date.parse($('#global_utcTime').val()));
        clocks_Init();
    }
    else
    {
        clocks_UpdateClocks();
    }

});

function clocks_Init()
{
    // set timer to update clocks
    window.setTimeout(clocks_UpdateClocks, 30000 /* in milliseconds */);
}

function clocks_SetClocks()
{
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/UtilityMethods.aspx/UtcTime';

    $.ajax({
        type: "GET",
        url: url,
        data: 'partyId="' + $('#global_utcTime').attr('partyid') + '"',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (result)
        {
            if (result != null)
                clocks_SetTime(Date.parse(result.d));
        },
        error: function (result) { clocks_SetTime(undefined); }
    });
}

function clocks_UpdateClocks()
{
    clocks_SetClocks();

    // set timer to update clocks
    window.setTimeout(clocks_UpdateClocks, 30000 /* in milliseconds */);
}

function clocks_SetTime(dUtcTime)
{

    $('.world-clock-tag').each(function ()
    {
        if (dUtcTime == undefined)
            $(this).html('NA');
        else
        {

            // adjust time for this clock's timezone
            var timeZoneOffset = parseInt($(this).attr('timezoneoffset'));
            var time = clocks_ConverTime(dUtcTime, timeZoneOffset)

            // set time
            $(this).html(clocks_FormatTime(time, $(this).attr('format')));

            // set tooltip
            var tooltipFormat = $(this).attr('ttformat');
            if (tooltipFormat.length > 0)
                $(this).attr('title', clocks_FormatTime(time, tooltipFormat));

            // is this timezone the local time zone
            if (new Date().getTimezoneOffset() == -timeZoneOffset)
                $(this).addClass('local');
        }
    });
}

function clocks_FormatTime(time, format)
{
    return time.localeFormat(format);
}

function clocks_ConverTime(dUtcTime, minuteOffset)
{
    var millisecondOffset = minuteOffset * 60000;
    var time = new Date();
    time.setTime(dUtcTime + millisecondOffset);
    return time;
}





