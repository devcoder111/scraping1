﻿function useractivityctrl_init()
{
    $('#event-activity-list a').click(function (event)
    {
        var eventId = $(this).attr('eventlogid');

        // toggle +/- image
        $('#event-activity-list a[eventlogid="' + eventId + '"]').toggleClass('hide');

        // toggle details
        $('#event-details-' + eventId).toggleClass('hide');

        event.preventDefault();
    });

    $('#event-activity-expand-all').click(function (event)
    {
        // show the "-" image
        $('#event-activity-list a.plus').addClass('hide');
        $('#event-activity-list a.minus').removeClass('hide');

        // show the details
        $('#event-activity-list .event-activity-details').removeClass('hide');

        event.preventDefault();
    });

    $('#event-activity-collapse-all').click(function (event)
    {
        // show the "+" image
        $('#event-activity-list a.minus').addClass('hide');
        $('#event-activity-list a.plus').removeClass('hide');

        // hide the details
        $('#event-activity-list .event-activity-details').addClass('hide');

        event.preventDefault();
    });

}