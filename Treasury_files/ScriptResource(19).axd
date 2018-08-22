﻿
if (window.Sys !== undefined && Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(qswc_spinTextBox_EndRequestHandler);

function qswc_spinTextBox_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        qswc_spinTextBox_InitSpinner();
    }
}

$(document).ready(function ()
{
    qswc_spinTextBox_InitSpinner();
});

function qswc_spinTextBox_InitSpinner()
{
    $('img.qswc_spinTextBox_up').click(function ()
    {
        qswc_spinTextBox_up($(this).attr('target'), $(this).attr('postbackref'));
    });

    $('img.qswc_spinTextBox_down').click(function ()
    {
        qswc_spinTextBox_down($(this).attr('target'), $(this).attr('postbackref'));
    });

}

function qswc_OnSpinnerTextBoxChange(ctrlId)
{
    var ctrl = $('#' + ctrlId);
    var spinnerInfoObject = qswc_getSpinTextBoxInfoObject(ctrl.attr('id'));
    var newValue = qswc_spinTextBox_ConvertFromBase(Number.parseLocale(ctrl.val()), spinnerInfoObject.Base, spinnerInfoObject.Scale)
    $('#' + spinnerInfoObject.RawValueClientId).val(newValue);
}

function qswc_spinTextBox_up(ctrlId, postbackRef)
{
    var ctrl = $('#' + ctrlId);
    var spinnerInfoObject = qswc_getSpinTextBoxInfoObject(ctrl.attr('id'));
    var number = Number.parseLocale(ctrl.val());
    var rawCtrl = $('#' + spinnerInfoObject.RawValueClientId);
    var rawNumber = 0;
    if (rawCtrl.val() != undefined)
        rawNumber = parseFloat(rawCtrl.val());
    if (number != 'NaN')
    {
        qswc_spinTextBox_GetPrev(ctrl, spinnerInfoObject, number, rawCtrl, rawNumber);

        if (postbackRef.length > 0)
            qswc_spinTextBox_doPostback(postbackRef, 500);
    }

}

function qswc_spinTextBox_down(ctrlId, postbackRef)
{
    var ctrl = $('#' + ctrlId);
    var spinnerInfoObject = qswc_getSpinTextBoxInfoObject(ctrl.attr('id'));

    var number = Number.parseLocale(ctrl.val());
    var rawCtrl = $('#' + spinnerInfoObject.RawValueClientId);
    var rawNumber = 0;
    if (rawCtrl.val() != undefined)
        rawNumber = parseFloat(rawCtrl.val());

    if (number != 'NaN')
    {
        qswc_spinTextBox_GetNext(ctrl, spinnerInfoObject, number, rawCtrl, rawNumber);

        if (postbackRef.length > 0)
            qswc_spinTextBox_doPostback(postbackRef, 500);
    }
}

function qswc_spinTextBox_doPostback(postbackRef, delay) {

    if ($('#global_attributes').attr('qswc_spinTextBox') != undefined) {
        window.clearTimeout($('#global_attributes').attr('qswc_spinTextBox'));
        //alert('timer cleared');
    }

    var timer = window.setTimeout(postbackRef, delay);

    $('#global_attributes').attr('qswc_spinTextBox', timer);

}



function qswc_getSpinTextBoxInfoObject(ctrlId)
{
    var jsonString = $('#' + ctrlId + '_hdn').val();
    return $.parseJSON(jsonString);
}

function qswc_spinTextBox_GetPrev(textCtrl, spinnerInfoObject, currentNumber, rawCtrl, rawNumber)
{
    switch (spinnerInfoObject.SpinnerType)
    {
        case 'List':
            var iCnt = 0;
            while (iCnt < spinnerInfoObject.Values.length)
            {
                if (Number.parseLocale(spinnerInfoObject.Values[iCnt]) >= currentNumber)
                {
                    if (iCnt > 0)
                        textCtrl.val(spinnerInfoObject.Values[iCnt - 1]);
                    return;
                }
                iCnt++;
            }
            textCtrl.val(spinnerInfoObject.Values[iCnt - 1]);
            break;
        case 'Simple':
            if (spinnerInfoObject.Increment == 1 && (currentNumber == 0 || currentNumber - 1 == 0))
                textCtrl.toggleClass('highlight');

            textCtrl.val((currentNumber - spinnerInfoObject.Increment).toFixed(spinnerInfoObject.NumberOfDecimals));
            break;
        case 'Tick':
            var tmp = Sys.CultureInfo.CurrentCulture.numberFormat['NumberGroupSeparator'];
            try
            {
                Sys.CultureInfo.CurrentCulture.numberFormat['NumberGroupSeparator'] = '';
                var newValue = Math.max(spinnerInfoObject.Min, rawNumber - spinnerInfoObject.Step);
                var formatString = 'N' + spinnerInfoObject.NumberOfDecimals;
                textCtrl.val(qswc_spinTextBox_Convert(newValue, spinnerInfoObject.Base, spinnerInfoObject.Scale).localeFormat(formatString));
                rawCtrl.val(newValue);
            }
            finally
            {
                Sys.CultureInfo.CurrentCulture.numberFormat['NumberGroupSeparator'] = tmp;
            }
            break;
    }
}

function qswc_spinTextBox_GetNext(textCtrl, spinnerInfoObject, currentNumber, rawCtrl, rawNumber)
{
    
    switch (spinnerInfoObject.SpinnerType)
    {
        case 'List':
            var iCnt = spinnerInfoObject.Values.length - 1;
            while (iCnt >= 0)
            {
                if (Number.parseLocale(spinnerInfoObject.Values[iCnt]) <= currentNumber)
                {
                    if (iCnt < spinnerInfoObject.Values.length - 1)
                        textCtrl.val(spinnerInfoObject.Values[iCnt + 1]);
                    return;
                }
                iCnt--;
            }
            textCtrl.val(spinnerInfoObject.Values[0]);
            break;
        case 'Simple':
            if (spinnerInfoObject.Increment == 1 && (currentNumber == 0 || currentNumber + 1 == 0))
                textCtrl.toggleClass('highlight');

            textCtrl.val((currentNumber + spinnerInfoObject.Increment).toFixed(spinnerInfoObject.NumberOfDecimals));
            break;
        case 'Tick':
            var tmp = Sys.CultureInfo.CurrentCulture.numberFormat['NumberGroupSeparator'];
            try
            {
                Sys.CultureInfo.CurrentCulture.numberFormat['NumberGroupSeparator'] = '';
                var newValue = rawNumber + spinnerInfoObject.Step
                var formatString = 'N' + spinnerInfoObject.NumberOfDecimals;
                textCtrl.val(qswc_spinTextBox_Convert(newValue, spinnerInfoObject.Base, spinnerInfoObject.Scale).localeFormat(formatString));
                rawCtrl.val(newValue);
            }
            finally
            {
                Sys.CultureInfo.CurrentCulture.numberFormat['NumberGroupSeparator'] = tmp;
            }
            break;
    }
}

//Converts from decimal to formatted
function qswc_spinTextBox_Convert(value, base, scale)
{

    if (base == 100)
        return scale * value;

    var fractionalPart = value - Math.floor(value);
    var num = base * fractionalPart;

    return scale * (Math.floor(value) + num / 100);
}

//Converts from formatted to decimal
function qswc_spinTextBox_ConvertFromBase(value, base, scale)
{

    var scaled = value / scale;

    if (base == 100)
        return scaled;

    var fractionalPart = scaled - Math.floor(scaled);
    return Math.floor(scaled) + Math.round(100 * fractionalPart) / base;
}

