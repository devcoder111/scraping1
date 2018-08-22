﻿if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(prodx_EndRequestHandler);

function prodx_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        prodx_documentReady();
    }
}

$(document).ready(function ()
{
    prodx_documentReady();
});

function prodx_documentReady()
{
    $('div.product-selector').attr('changed', '0');

    $('div.product-selector div.groups a').click(function (event)
    {
        $(this).closest('div.product-selector').attr('changed', '1');
        prodx_ChangeGroup($(this), false);
        event.preventDefault();
        event.stopPropagation();
    });

    $(document).off('click', 'div.product-selector div.families a');
    $(document).on('click', 'div.product-selector div.families a', function (event)
    {
        $(this).closest('div.product-selector').attr('changed', '1');
        prodx_ChangeFamily($(this), false);
        event.preventDefault();
        event.stopPropagation();
    });

    $('div.product-selector select.groups').change(function (event)
    {
        $(this).closest('div.product-selector').attr('changed', '1');
        prodx_ChangeGroup($(this), true);
        event.preventDefault();
        event.stopPropagation();
    });

    $(document).off('change', 'div.product-selector select.families');
    $(document).on('change', 'div.product-selector select.families', function (event)
    {
        $(this).closest('div.product-selector').attr('changed', '1');
        prodx_ChangeFamily($(this), true);
        event.preventDefault();
        event.stopPropagation();
    });

    $(document).off('click', 'div.product-selector[isfamilymode="True"] a[FamilyId]');
    $(document).on('click', 'div.product-selector[isfamilymode="True"] a[FamilyId]', function (event)
    {
        var familyId = $(this).attr('familyid');

        // fire postback
        __doPostBack($(this).closest('div.product-selector').attr('ParentId'), 'FamilyChange_' + familyId);
        event.preventDefault();
        event.stopPropagation();
    });

    $(document).off('click', 'div.product-selector[isnavmode="False"] a[ProductId]');
    $(document).on('click', 'div.product-selector[isnavmode="False"] a[ProductId]', function (event)
    {
        var familyId = $(this).attr('familyid');
        var productId = $(this).attr('productid');

        // fire postback
        __doPostBack($(this).closest('div.product-selector').attr('ParentId'), 'ProductChange_' + familyId + '|' + productId);
        event.preventDefault();
        event.stopPropagation();
    });

}

function prodx_close()
{
    $('div.product-selector[changed="1"]').each(function ()
    {
        $(this).attr('changed', '0');
        prodx_Reset($(this));
    });
}

function prodx_Reset(container)
{
    var groupId = container.attr('groupid');
    var familyId = container.attr('familyid');

    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/ProductSelectorMethods.aspx/ChangeGroupFamily';

    var data = "groupId=" + groupId + "&familyid=" + familyId + '&navigationMode=' + (container.attr('isnavmode').toLowerCase() == 'true') + '&partyId=' + container.attr('partyid');
    if ($('#global_instanceCache').val().length > 0)
        data += '&' + $('#global_instanceCache').val();

    $.ajax({
        type: 'GET',
        url: url,
        data: data,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            prodx_UpdateLists(container, groupId, result.d, true);

            if (container.attr('ismobile').toLowerCase() == 'true')
            {
                container.find('select.groups').val(groupId);
            }
            else
            {
                var groups = container.find('div.groups a');
                groups.removeClass('selected');
                container.find("div.groups a[groupid='" + groupId + "']").addClass('selected');
            }
        }

    });

}

function prodx_ChangeGroup(trigger, isMobile)
{
    var container = trigger.closest('div.product-selector');
    var groupId = -1;
    if (!isMobile)
    {
        groupId = trigger.attr('groupid');

        // change selection in advance to help with responsiveness
        var groups = container.find('div.groups a');
        groups.removeClass('selected');
        trigger.addClass('selected');
    }
    else
    {
        groupId = container.find('select.groups').val();
    }

    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/ProductSelectorMethods.aspx/ChangeGroup';

    var data = "groupId=" + groupId + '&navigationMode=' + (container.attr('isnavmode').toLowerCase() == 'true') + '&partyId=' + container.attr('partyid');
    if ($('#global_instanceCache').val().length > 0)
        data += '&' + $('#global_instanceCache').val();

    $.ajax({
        type: 'GET',
        url: url,
        data: data,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            prodx_UpdateLists(container, groupId, result.d, false);
        }

    });

}


function prodx_ChangeFamily(trigger, isMobile)
{
    var groupId = -1;
    var familyId = -1;
    var container = trigger.closest('div.product-selector');

    if (!isMobile)
    {
        familyId = trigger.attr('familyid');
        groupId = trigger.attr('groupid');

        // change selection in advance to help with responsiveness
        container.find('div.families div.items a').removeClass('selected');
        trigger.addClass('selected');
    }
    else
    {
        familyId = container.find('select.families').val();
        groupId = container.find('select.groups').val();
    }

    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/ProductSelectorMethods.aspx/ChangeFamily';

    var data = "groupId=" + groupId + "&familyid=" + familyId + '&navigationMode=' + (container.attr('isnavmode').toLowerCase() == 'true') + '&partyId=' + container.attr('partyid');
    if ($('#global_instanceCache').val().length > 0)
        data += '&' + $('#global_instanceCache').val();

    $.ajax({
        type: 'GET',
        url: url,
        data: data,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            prodx_UpdateLists(container, groupId, result.d, false);
        }

    });

}

function prodx_UpdateLists(container, groupId, data, closing)
{
    var currentFamilyId = container.attr('familyid');
    var familyMode = container.attr('isfamilymode').toLowerCase() == 'true';

    if (data.Families != null)
    {
        if (container.attr('ismobile').toLowerCase() == 'true')
        {
            var familiesDDL = container.find('select.families');
            familiesDDL.empty();

            for (var i = 0; i < data.Families.length; i++)
            {
                var attrs = "";
                if (data.Families[i].Id == data.SelectedFamilyId)
                    attrs += " selected='selected'";

                familiesDDL.append($("<option value='" + data.Families[i].Id + "'" + attrs + "></option>").html(data.Families[i].Name));
            }
        }
        else
        {
            var familiesDiv = container.find('div.families div.items');
            familiesDiv.empty();

            for (var i = 0; i < data.Families.length; i++)
            {
                var attrs = " groupId=" + groupId + " familyId=" + data.Families[i].Id;
                var classes = familyMode ? "family-mode" : "";
                if (familyMode)
                {
                    if (data.Families[i].Id == currentFamilyId)
                        classes += " selected";
                }
                else
                {
                    if (data.Families[i].Id == data.SelectedFamilyId)
                        classes += " selected";
                }

                familiesDiv.append($("<a href='#'" + attrs + " class='" + classes + "'></a>").html(data.Families[i].Name));
            }
        }
    }

    var productsDiv = container.find('div.products div.items');
    productsDiv.empty();

    var currentProductId = container.attr('productid');
    var viewPage = container.attr('viewpage');
    var baseUrl = container.attr('BaseUrl');

    for (var i = 0; i < data.Products.length; i++)
    {
        var url = '#';
        var eventAttrs = '';
        if (container.attr('isnavmode').toLowerCase() == 'true')
        {
            url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val();
            if (baseUrl == null || baseUrl.length == 0)
                url += '/User/' + viewPage
            else
                url += baseUrl;
            url += '?pid=' + data.Products[i].Id + '&pf=' + data.SelectedFamilyId;
            url += productsDiv.attr('ExtraParms');
        }
        else
        {
            eventAttrs = " ProductId='" + data.Products[i].Id + "' FamilyId='" + data.SelectedFamilyId + "'";
        }

        var attrs = " title='" + data.Products[i].Description + "'";
        if (data.Products[i].Id == currentProductId && data.SelectedFamilyId == currentFamilyId)
            attrs += " class='selected'";
        attrs += eventAttrs;

        productsDiv.append($("<a href='" + url + "'" + attrs + "></a>").html(data.Products[i].Name));
    }

    // re-adjust height to compensate for longer lists
    container.parent().removeAttr('setheight');
    if (!closing)
        popupNav_setHeight(container.parent());
}


