﻿var globalMobileProperties = null;

// keep these in sync with MobileSizeCode enum (enums.cs)
var MobileSizeCode_Unknown = 2;
var MobileSizeCode_Full = 4;
var MobileSizeCode_Medium = 8;
var MobileSizeCode_Small = 16;

// keep these in sync with DeviceType enum (enums.cs)
var DeviceTypeCode_Unknown = 0;
var DeviceTypeCode_Tablet = 1;
var DeviceTypeCode_Phone = 2;

function parseQueryString()
{
    var parsedParameters = {},
      uriParameters = location.search.substr(1).split('&');

    for (var i = 0; i < uriParameters.length; i++)
    {
        var parameter = uriParameters[i].split('=');
        parsedParameters[parameter[0].toLowerCase()] = decodeURIComponent(parameter[1]);
    }

    return parsedParameters;
}

function mobile_isInitialLoad(redirect)
{
    var isMobile = $('#global_attributes').attr('isMobile') == '1';
    if (isMobile)
    {
        var propertyStr = $('#global_mobile').val();
        globalMobileProperties = $.parseJSON(propertyStr);
        if (!globalMobileProperties.HasClientProperties || globalMobileProperties.MobileSize != mobile_getMobileSize())
        {
            mobile_setMobileProperties(redirect);
            return true;
        }
    }
    return false;
}

function mobile_setMobileProperties(redirect)
{
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/SessionUtilityMethods.aspx/SetMobileProperties';

    var mobileDTO = {};
    mobileDTO.MobileSize = mobile_getMobileSize();

    var parms = { 'mobileDTO': mobileDTO };

    $.ajax({
        type: 'POST',
        url: url,
        data: JSON.stringify(parms),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            if (redirect)
                mobile_redirect();
            else
                // postback
                $('#Form1').submit();
        },
        error: function (result)
        {
        }
    });

}

function mobile_getMobileSize()
{
    if (globalMobileProperties == null)
        return MobileSizeCode_Unknown;

    if (globalMobileProperties.DeviceType != DeviceTypeCode_Unknown)
    {
        if (window.orientation == 0 || window.orientation == 180)
            // portrait
            return globalMobileProperties.DeviceType == DeviceTypeCode_Tablet ? MobileSizeCode_Medium: MobileSizeCode_Small;
        else
            // landscape
            return globalMobileProperties.DeviceType == DeviceTypeCode_Tablet ? MobileSizeCode_Full: MobileSizeCode_Medium;
    }
    else
    {
        if ($(window).width() >= 960)
            return MobileSizeCode_Full;
        if ($(window).width() >= 600)
            return MobileSizeCode_Medium;
        return MobileSizeCode_Small;
    }
}

function mobile_redirect()
{

    var parms = parseQueryString();
    var regex = new RegExp('(User/QuikStrikeTools.aspx)', 'gi');
    var view = parms['tmpl'];
    if (view == undefined)
        view = 'QuikStrikeView';
    var url = window.location.href.replace(regex, 'User/' + view + '.aspx');
    window.location.replace(url);
}
