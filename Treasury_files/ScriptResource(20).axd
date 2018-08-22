﻿Type.registerNamespace('QuikStrike.WebControls');

QuikStrike.WebControls.Gadget = function (element) {
    QuikStrike.WebControls.Gadget.initializeBase(this, [element]);

    this.gadgetClientId = null;
}

QuikStrike.WebControls.Gadget.prototype =
{
    get_GadgetClientId: function ()
    {
        return this.gadgetClientId;
    },

    set_GadgetClientId: function (value)
    {
        if (this.gadgetClientId != value)
        {
            this.gadgetClientId = value;
            this.raisePropertyChanged('GadgetClientId');
        }
    },

    initialize: function ()
    {
        QuikStrike.WebControls.Gadget.callBaseMethod(this, 'initialize');

        //alert('gadget initialize');

        var gadgetId = this.get_GadgetClientId();
        var gadget = $('#' + gadgetId);

        //Set the initial gadget state

        var stateId = gadget.attr('stateId');
        var contentId = gadget.attr('contentId');
        var triggerId = gadget.attr('triggerId');
        var indicatorId = gadget.attr('indicatorId');
        var isDynamic = gadget.attr('loadDynamic') == 'true';
        var url = gadget.attr('url') + ' #' + gadget.attr('containerId');
        var interval = gadget.attr('interval');


        if ($('#' + stateId).val() == 'open') { $('#' + contentId).show(); }
        else { $('#' + contentId).hide(); }

        if ($('#' + stateId).val() == 'open' && isDynamic)
        {
            var callback = 'LoadGadget("' + contentId + '","' + stateId + '","' + gadgetId + '","' + url + '",' + interval + ')';

            if ($('#global_attributes').attr(gadgetId) != undefined)
                window.clearTimeout($('#global_attributes').attr(gadgetId));
            $('#global_attributes').attr(gadgetId, window.setTimeout(callback, interval));
        }

        var selector = '#' + triggerId + "," + '#' + indicatorId;
        $(selector).click(function (event)
        {

            //debugger;
            var gadgetId = $(this).attr('gadgetId');
            var gadget = $('#' + gadgetId);

            var stateId = gadget.attr('stateId');
            var state = $('#' + stateId);
            var contentId = gadget.attr('contentId');
            var content = $('#' + contentId);
            var header = $('#' + gadget.attr('headerId'));
            var indicator = $('#' + gadget.attr('indicatorId'));
            var key = gadget.attr('key');
            var isDynamic = gadget.attr('loadDynamic') == 'true';
            var url = gadget.attr('url') + ' #' + gadget.attr('containerId');
            var interval = gadget.attr('interval');

            content.toggle('blind');
            state.val() == 'open' ? state.val('closed') : state.val('open');

            $.ajaxSetup({ cache: false });

            $.ajax({
                type: 'GET',
                url: '../AjaxPages/GadgetMethods.aspx/SaveGadgetProfileState',
                data: 'key="' + key + '"&value="' + state.val() + '"',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function () { }, //alert('Gadget state saved'); },
                error: function () { alert('Error saving Gadget state: ' + result.responseText); }
            });

            header.toggleClass('ui-corner-all');
            header.toggleClass('ui-corner-top');
            indicator.toggleClass('ui-icon-triangle-1-n ui-icon-triangle-1-s');
            if (state.val() == 'open' && isDynamic)
            {
                var callback = 'LoadGadget("' + contentId + '","' + stateId + '","' + gadgetId + '","' + url + '",' + interval + ')';

                if ($('#global_attributes').attr(gadgetId) != undefined)
                    window.clearTimeout($('#global_attributes').attr(gadgetId));
                $('#global_attributes').attr(gadgetId, window.setTimeout(callback, interval));

            }

            event.preventDefault();
        });

    }
}


QuikStrike.WebControls.Gadget.registerClass('QuikStrike.WebControls.Gadget', Sys.UI.Control);


function LoadGadget(contentId, stateId, gadgetId, url, interval)
{

    $.ajaxSetup({ cache: false });
    $('#' + contentId).load(url);

    if ($('#' + stateId).val() == 'open')
    {
        var callback = 'LoadGadget("' + contentId + '","' + stateId + '","' + gadgetId + '","' + url + '",' + interval + ')';

        if ($('#global_attributes').attr(gadgetId) != undefined)
            window.clearTimeout($('#global_attributes').attr(gadgetId));
        $('#global_attributes').attr(gadgetId, window.setTimeout(callback, interval));
    }
}
