﻿if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(qtools_documentReady);

function prodx_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        qtools_documentReady();
    }
}

$(document).ready(function ()
{
    qtools_documentReady();
});

function qtools_documentReady()
{
    var toolId = $('#quiktools').attr('toolid');
    if (toolId != null && toolId.length > 0)
    {
        var tool = $("#quiktools a.quiktool[id='" + toolId + "']");
        if (tool.length > 0)
            qtools_setTool(tool, false);
    }
    //else
    //    $('#btn_quiktool div').text('QuikTools');

    $('#quiktools a.quiktool').click(function (event)
    {
        if ($(this).hasClass('inactive'))
        {
            event.preventDefault();
            event.stopPropagation();
            return;
        }

        global_closeDropMenus();

        if (!$(this).hasClass('never-active'))
            qtools_setTool($(this), true);
    });
}

function qtools_setTool(trigger, persist)
{
    if (persist)
        qtools_persistTool(trigger);

    var button = $('#btn_quiktool');

    var id = button.attr('id');
    var cls = 'text';
    var src = $('#btn_quiktool img').attr('src');
    var text = trigger.attr("ToolName");
    var newElem = $("<a id='" + id + "'><div><img align=texttop src='" + src + "' />" + text + "</div></a>");

    // copy attributes from selected tool to the main button
    $($(trigger)[0].attributes).each(function ()
    {
        var name = this.name.toLowerCase();
        // this "specified" check was added ONLY because IE7 has a zillion worthless attributes that need to be ignored
        var specified = this.specified === undefined ? true : this.specified;
        if (specified)
        {
            switch (name)
            {
                case 'id':
                    // ignore
                    break;
                case 'class':
                    cls += ' ' + this.value;
                    break;
                default:
                    newElem.attr(this.name, this.value);
            }
        }
    });

    newElem.attr('class', cls);
    newElem.insertAfter(button);
    button.remove();

}

function qtools_persistTool(trigger)
{
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/SessionUtilityMethods.aspx/PersistQuikTool';

    var data = "toolId='" + trigger.attr('id') + "'&toolName='" + trigger.attr('ToolName') + "'";
    if ($('#global_instanceCache').val().length > 0)
        data += '&' + $('#global_instanceCache').val();

    $.ajax({
        type: 'GET',
        url: url,
        data: data,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json'
    });

}
