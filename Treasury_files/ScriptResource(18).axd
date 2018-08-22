﻿/* public helpers */
function qswc_dayspicker_setDays(clientId, days)
{
    var ctrl = $('#' + clientId);
    var ctrlDate = $('#' + ctrl.attr('dateClientId'));
    var ctrlDays = $('#' + ctrlDate.attr('daysClientId'));

    var anchorDate = new Date(ctrlDate.attr('anchorDate'));

    var targetDate = qswc_dayspicker_adddays(anchorDate, days);

    ctrlDate.attr('targetDate', targetDate.toString());
    ctrlDays.val(days);

    var calExtender = Sys.Application.findComponent(ctrlDate.attr('calClientId'));

    calExtender.set_selectedDate(gswc_dayspicker_truncateTime(anchorDate));

}

function qswc_dayspicker_getDays(clientId)
{
    var ctrl = $('#' + clientId);
    var ctrlDate = $('#' + ctrl.attr('dateClientId'));
    var ctrlDays = $('#' + ctrlDate.attr('daysClientId'));
    return ctrlDays.val();
}

/* private methods used by control itself */
function qswc_dayspicker_daysChanged(daysCtrlClientId, days, expirationDate)
{
    var ctrlDate = $('#' + daysCtrlClientId);
    var ctrlDays = $('#' + ctrlDate.attr('daysClientId'));

    var days = Number.parseLocale(ctrlDays.val());
    if (isNaN(days))
        days = 0.0;
    ctrlDays.val(days.localeFormat('N' + parseInt(ctrlDate.attr('decimalPlaces'))));

    var targetDate = new Date(ctrlDate.attr('targetDate'));

    var dtNewDate = qswc_dayspicker_adddays(targetDate, -days);
    dtNewDate = gswc_dayspicker_truncateTime(dtNewDate);

    var calExtender = Sys.Application.findComponent(ctrlDate.attr('calClientId'));

    calExtender.set_selectedDate(dtNewDate);
    //ctrlDate.val(sNewDate.format('d'));

}

function qswc_dayspicker_dateChanged(sender, args)
{
    var ctrlDate = $('#' + sender.get_element().id);
    var ctrlDays = $('#' + ctrlDate.attr('daysClientId'));

    var selectedDate = new Date(Date.parseLocale(ctrlDate.val()));
    var targetDate = new Date(ctrlDate.attr('targetDate'));

    selectedDate = gswc_dayspicker_syncTimes(targetDate, selectedDate);

    var dayDiff = qswc_dayspicker_daydiff(targetDate, selectedDate);
    //dayDiff = dayDiff.toFixed(parseInt(ctrlDate.attr('decimalPlaces')));
    dayDiff = dayDiff.localeFormat('N' + parseInt(ctrlDate.attr('decimalPlaces')));

    ctrlDays.val(dayDiff);

    var postbackref = ctrlDate.attr('postbackref');
    if (postbackref.length > 0)
        window.setTimeout(postbackref, 0);

}

function gswc_dayspicker_syncTimes(src, dest)
{
    var srcDate = new Date(src.getFullYear(), src.getMonth(), src.getDate(), 0, 0, 0, 0);
    var srcTime = src.getTime() - srcDate.getTime();
    var destDate = new Date(dest.getFullYear(), dest.getMonth(), dest.getDate(), 0, 0, 0, 0);
    return new Date(destDate.getTime() + srcTime);
}

function gswc_dayspicker_truncateTime(dateTime)
{
    return new Date(dateTime.getFullYear(), dateTime.getMonth(), dateTime.getDate(), 0, 0, 0, 0);
}

function qswc_dayspicker_daydiff(date1, date2)
{
    // The number of milliseconds in one day
    var oneDay = 1000 * 60 * 60 * 24;

    // Convert both dates to milliseconds
    var millisec1 = Date.UTC(date1.getFullYear(), date1.getMonth(), date1.getDate(), date1.getMinutes(), date1.getSeconds(), date1.getMilliseconds()); //date1.getTime();
    var millisec2 = Date.UTC(date2.getFullYear(), date2.getMonth(), date2.getDate(), date2.getMinutes(), date2.getSeconds(), date2.getMilliseconds()); //date2.getTime();

    // Calculate the difference in milliseconds
    var diff = millisec1 - millisec2;

    // Convert back to days and return
    //return Math.round(diff / oneDay);
    return diff / oneDay;
}

function qswc_dayspicker_adddays(date1, days)
{
    // The number of milliseconds in one day
    var oneDay = 1000 * 60 * 60 * 24;

    return new Date(date1.getTime() + (days * oneDay));
}

