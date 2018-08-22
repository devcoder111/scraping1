
if (Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(qs_EndRequestHandler);

function qs_EndRequestHandler(sender, args)
{
    var error = args.get_error();
    if (error == undefined)
    {
        // do this after the display is turned back on and all jquery has processed so that column widths are set correctly
        twitcard_init();
    }
}

$(document).ready(function ()
{
    twitcard_init();
});

function twitcard_init(event, ui)
{

    $('a.card-tweeter').click(function (event)
    {
        var image = $(this).children('img');
        var mode = $(this).attr('cardmode');

        var container = null;
        if ($(this).attr('containerid').length > 0)
            container = $('#' + $(this).attr('containerid'));
        if (mode == '0' && (container == null || container.length == 0))
        {
            alert('No Tweet content available');
            event.preventDefault();
            event.stopPropagation();
            return;
        }

        var title = $(this).attr('cardtitle');
        if (title.length == 0)
        {
            if ($('#twittercard-title').length > 0)
                title = $('#twittercard-title').val();
        }

        twitcard_createCard(container, image, mode, title, $(this).attr('carddesc'), $(this).attr('via'));

        event.preventDefault();
    });

}

function twitcard_createCard(container, image, mode, title, description, via)
{
    var method = mode == '0' ? 'CreateChartCard' : 'CreateViewCard';
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/TwitterMethods.aspx/' + method;

    var data = '';
    if (mode == '0')
    {
        var chart = container.find('img.chart');
        if (chart.length == 0)
        {
            alert('No Tweet content available');
            return;
        }
        data = 'imageSrc=' + "'" + encodeURIComponent(chart.attr('src')) + "'&";
    }
    data += 'title=' + "'" + encodeURIComponent(title.replace(/'/g, "\\'")) + "'";
    data += '&description=' + "'" + encodeURIComponent(description.replace(/'/g, "\\'")) + "'";
    if ($('#global_instanceCache').val().length > 0)
        data += '&' + $('#global_instanceCache').val();

    var src = image.attr('src');
    image.attr('src', '../images/icons/throbber.gif');

    $.ajax({
        type: 'GET',
        url: url,
        data: data,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            image.attr('src', src);
            twitcard_openCard(result.d, title, via);
        },
        error: function (result)
        {
            image.attr('src', src);
            var errorMessage = 'The following error occured while trying to tweet:\n';
            errorMessage += $.parseJSON(result.responseText).Message;
            alert(errorMessage);
        }
    });

}

function twitcard_openCard(cardResponse, text, via)
{

    if (!cardResponse.IsSuccess)
    {
        alert('Unable to generate twitter image.  If this problem persists please contact support.');
        return;
    }

    var url = 'https://twitter.com/intent/tweet?url=' + encodeURIComponent(cardResponse.CardUrl);
    url += '&text=' + encodeURIComponent(text);
    //url += '&text=' + encodeURIComponent(text + ' @QuikStrike1');
    url += '&hashtags=QuikTweets';
    url += '&via=QuikStrike1';
    if (via.length > 0)
        url += ' ' + via;

    var screenLeft = 0;
    var screenTop = 0;
    if (typeof window.screenLeft !== 'undefined')
    {
        screenLeft = window.screenLeft;
        screenTop = window.screenTop;
    }
    else if (typeof window.screenX !== 'undefined')
    {
        screenLeft = window.screenX;
        screenTop = window.screenY;
    }

    var width = 540;
    var height = 280;
    var left = screenLeft + ($(window).width() - width) / 2;
    var top = screenTop + ($(window).height() - height) / 2;

    var win = window.open(url, '', 'resizable=yes,toolbar=no,menubar=no,scrollbars=yes,width=' + width + ',height=' + 280 + ',top=' + top + ',left=' + left);
}
