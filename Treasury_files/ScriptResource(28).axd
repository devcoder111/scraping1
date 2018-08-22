Type.registerNamespace('QuikStrike.Public.Web.UserControls.Common');

QuikStrike.Public.Web.UserControls.Common.ControlsTrigger = function (element) {
    QuikStrike.Public.Web.UserControls.Common.ControlsTrigger.initializeBase(this, [element]);

    this.clientId = null;
}

QuikStrike.Public.Web.UserControls.Common.ControlsTrigger.prototype =
{
    get_ClientId: function ()
    {
        return this.clientId;
    },

    set_ClientId: function (value)
    {
        if (this.clientId != value)
        {
            this.clientId = value;
            this.raisePropertyChanged('ClientId');
        }
    },

    initialize: function ()
    {
        QuikStrike.Public.Web.UserControls.Common.ControlsTrigger.callBaseMethod(this, 'initialize');
        //debugger;

        $('#' + this.get_ClientId()).click(function (event)
        {

            if ($('#' + $(this).attr('stateId')).val() == 'hide')
            {
                $('#' + $(this).attr('stateId')).val('show');
                $('#' + $(this).attr('targetId')).show();
            }
            else
            {
                $('#' + $(this).attr('stateId')).val('hide');
                $('#' + $(this).attr('targetId')).hide();
            }

            $(this).toggleClass('ui-icon-circle-triangle-s').toggleClass('ui-icon-circle-triangle-n');

            event.preventDefault();
        });
    }
}


QuikStrike.Public.Web.UserControls.Common.ControlsTrigger.registerClass('QuikStrike.Public.Web.UserControls.Common.ControlsTrigger', Sys.UI.Control);

