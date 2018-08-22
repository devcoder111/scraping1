﻿Type.registerNamespace('QuikStrike.Public.Web.UserControls.Pdf');

QuikStrike.Public.Web.UserControls.Pdf.SavePdf = function (element)
{
    QuikStrike.Public.Web.UserControls.Pdf.SavePdf.initializeBase(this, [element]);

    this.triggerClientId = null;
    this.dialogAppendSelector = null;
    this.urlRoot = null;

}

QuikStrike.Public.Web.UserControls.Pdf.SavePdf.prototype =
{
    get_TriggerClientId: function ()
    {
        return this.triggerClientId;
    },

    set_TriggerClientId: function (value)
    {
        if (this.triggerClientId != value)
        {
            this.triggerClientId = value;
            this.raisePropertyChanged('TriggerClientId');
        }
    },

    get_DialogAppendSelector: function ()
    {
        return this.dialogAppendSelector;
    },

    set_DialogAppendSelector: function (value)
    {
        if (this.dialogAppendSelector != value)
        {
            this.dialogAppendSelector = value;
            this.raisePropertyChanged('DialogAppendSelector');
        }
    },

    get_UrlRoot: function ()
    {
        return this.urlRoot;
    },

    set_UrlRoot: function (value)
    {
        if (this.urlRoot != value)
        {
            this.urlRoot = value;
            this.raisePropertyChanged('UrlRoot');
        }
    },

    initialize: function ()
    {
        QuikStrike.Public.Web.UserControls.Pdf.SavePdf.callBaseMethod(this, 'initialize');

        var dialogAppendSelector = this.get_DialogAppendSelector();

        var dialog = $('#dialog-save-pdf').dialog({
            autoOpen: false,
            width: 400,
            title: 'Save PDF',
            resizable: false
        });
        dialog.parent().appendTo($(dialogAppendSelector));

        $(document).on('click', 'a.savepdf-trigger', function (event)
        {

            //var dialogWidth = $('#dialog-save-pdf').dialog('option', 'width');
            //$('#dialog-save-pdf').dialog('option', 'position', {
            //    my: "right top",
            //    at: "left bottom",
            //    of: $(this)
            //});

            // open dialog
            $('#dialog-save-pdf').dialog('open');
            $('#dialog-save-pdf').parent().appendTo($(dialogAppendSelector));

            event.preventDefault();
        });

        $('#dialog-save-pdf .cancel-trigger').click(function (event)
        {
            $('#dialog-save-pdf').dialog('close');
            event.preventDefault();
        });

        var baseUrl = this.get_UrlRoot();

        $('#dialog-save-pdf .save-trigger').click(function (event)
        {
            $('#dialog-save-pdf .pdfurl-section').hide('fast');

            var fileName = $('#dialog-save-pdf .pdffilename').val();
            if (fileName.length == 0)
            {
                event.preventDefault();
                return;
            }

            // remove extension because engine assumes it is not part of the Name
            var index = fileName.toLowerCase().indexOf(".pdf");
            if (index >= 0)
                fileName = fileName.substring(0, index);

            $('#hdnFileName').val(fileName);

            // show url
            $('#dialog-save-pdf .pdfurl').text(baseUrl + fileName + ".pdf");
            $('#dialog-save-pdf .pdfurl-section').show('slow');

        });

    }

}


QuikStrike.Public.Web.UserControls.Pdf.SavePdf.registerClass('QuikStrike.Public.Web.UserControls.Pdf.SavePdf', Sys.UI.Control);



