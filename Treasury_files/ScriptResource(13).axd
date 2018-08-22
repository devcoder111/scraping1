var scm_dragging = false;
var scm_activeTextElem = null;

if (window.Sys !== undefined && Sys.WebForms != null)
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(scm_EndRequestHandler);

function scm_EndRequestHandler(sender, args)
{
    if (args.get_error() == undefined)
    {
        scm_InitMenu();
        scm_InitAddNew();
    }
}

$(document).ready(function ()
{
    scm_InitMenu();
    scm_InitAddNew();
});

function scm_InitAddNew()
{

    $('#scm_AddNewShortcut').bind('popupBeforeShow', function ()
    {
        // init shortcut name text
        $('#scm_AddNewText').val($('#view_information').attr('menuName'));

        // load existing sections
        scm_LoadGroups();

        $('#scm_newGroupBlock').hide();
        $('#scm_NewGroupText').val('');
    });

    $('#scm_AddNewShortcut').bind('popupAfterShow', function ()
    {
        $('#scm_AddNewText').focus().select();
    });

    $('#scm_GroupDropDown').change(function ()
    {
        // init shortcut name text
        if ($(this).val() == "-1")
            $('#scm_newGroupBlock').show();
        else
            $('#scm_newGroupBlock').hide();

        $('#scm_GroupDropDownValue').val($(this).val());

    });

    $('#scm_NewShortcutSave').click(function (event)
    {
        if ($('#scm_AddNewText').val() == null || $('#scm_AddNewText').val().length == 0 || ($('#scm_GroupDropDown').val() == "-1" && ($('#scm_NewGroupText').val().length == 0 || $('#scm_GroupDropDown').val() == null)))
        {
            event.preventDefault();
            event.stopPropagation();
        }

    });

}

function scm_InitMenu()
{

    if (scm_HandleEmpty())
        return;

    dragging = false;

    $('#scm_edit_mode').click(function(event)
    {
        if ($(this).attr('mode') === 'edit')
            scm_EditModeOff($(this));
        else
            scm_EditModeOn($(this));

        event.preventDefault();
        event.stopPropagation();

    });

    $('#scm_delete_item').click(function (event)
    {
        scm_acceptText();

        var item = scm_GetItemPosition($(this));
        var removeElem = $(this).parents('div.scm-drop-item');
        $('#scm_itemcontrols').hide();
        $('#scm_ShortcutMenu').append($('#scm_itemcontrols,#scm_itemcontrols'));
        removeElem.remove();
        scm_refresh();
        scm_DeleteItem(item);
        scm_HandleEmpty();
        scm_UpdateStar();

        event.preventDefault();
        event.stopPropagation();
    });

    $('#scm_delete_group').click(function (event)
    {
        scm_acceptText();

        var group = scm_GetGroupPosition($(this));
        var removeElem = $(this).parents('div.scm-group');
        $('#scm_groupcontrols').hide();
        $('#scm_ShortcutMenu').append($('#scm_groupcontrols,#scm_itemcontrols'));
        removeElem.remove();
        scm_refresh();
        scm_DeleteGroup(group);
        scm_HandleEmpty();
        scm_UpdateStar();

        event.preventDefault();
        event.stopPropagation();
    });

    $('#scm_add_group').click(function (event)
    {
        scm_acceptText();

        var group = scm_GetGroupPosition($(this));
        scm_addGroup($(this).parents('div.scm-group'))
        scm_refresh();
        scm_AddGroup(group, 'New Section');

        event.preventDefault();
        event.stopPropagation();
    });

    $('#scm_ShortcutMenu').click(function (event)
    {
        scm_acceptText();
        event.stopPropagation();
    });

    $('#scm_textbox').click(function (event)
    {
        event.stopPropagation();
    });

    // NOTE: keypress with code 27 (escape) doesn't work in chrome
    $('#scm_textbox').keydown(function (event)
    {
        if (event.which == 13)
        {
            scm_acceptText();
            event.preventDefault();
            event.stopPropagation();
        }
        else if (event.which == 27)
        {
            scm_revertText();
            event.preventDefault();
            event.stopPropagation();
        }
    });

}

function scm_HandleEmpty()
{
    if ($('#scm_ShortcutMenu a.scm-trigger').length == 0)
    {
        if ($('#scm_edit_mode').attr('mode') === 'edit')
            scm_EditModeOff($('#scm_edit_mode'));
        $('#scm_emptynotice').show();
        $('#scm_edit_mode').hide();
        $('#scm_ShortcutMenu div.scm-group').hide();
        $('#scm_ShortcutMenu').unbind('click');
        return true;
    }

    return false;
}

function scm_UpdateStar()
{
    var currentShortcutId = $('#scm_AddNewShortcut').attr('CurrentShortcutId');
    if ($('#scm_ShortcutMenu a.scm-trigger[ShortcutId="' + currentShortcutId + '"]').length == 0)
    {
        var starImage = $('#scm_StarImage');
        starImage.attr('src', starImage.attr('src').replace('star.png', 'star-bw.png'));
        starImage.attr('title', 'Save the current view to your Shortcut Menu');
    }
}

function scm_EditModeOn(trigger)
{
    trigger.attr('mode', 'edit');
    trigger.addClass('on');
    trigger.attr('title', 'Click here to exit the Shortcut Menu manager');

    $('#scm_ShortcutMenu a.scm-trigger, #scm_ShortcutMenu div.scm-group-header').click(function (event)
    {
        scm_acceptText();
        scm_activateText($(this).parents('div.scm-drop-item,div.scm-drop-group'));
        event.preventDefault();
        event.stopPropagation();
    });

    $('#scm_ShortcutMenu a.scm-trigger,#scm_ShortcutMenu div.scm-group-header').addClass('edit-mode').removeClass('menu-mode');
    $('#scm_ShortcutMenu a.scm-trigger').hover(scm_hoverItemIn, scm_hoverItemOut);
    $('#scm_ShortcutMenu div.scm-group-header').hover(scm_hoverGroupIn, scm_hoverGroupOut);

    $('#scm_ShortcutMenu a.scm-trigger, #scm_ShortcutMenu div.scm-group-header').draggable({
        revert: 'invalid',
        revertDuration: 200,
        containment: '#scm_ShortcutMenu',
        start: function (event, ui)
        {
            scm_dragging = true;
            scm_acceptText();
            $('#scm_ShortcutMenu .scm-controls').hide();
            $('#scm_ShortcutMenu a.scm-trigger,#scm_ShortcutMenu div.scm-group-header').removeClass('edit-mode');
        },
        stop: function (event, ui)
        {
            scm_dragging = false;
            $('#scm_ShortcutMenu a.scm-trigger,#scm_ShortcutMenu div.scm-group-header').addClass('edit-mode');
        },
        cursor: 'move',
        helper: function (event)
        {
            return $('<span style="width:180px"/>').text( $(this).children('span.item-name').text());
        }
    });


    $('#scm_ShortcutMenu div.scm-drop-item, #scm_ShortcutMenu div.scm-drop-group').droppable({
        accept: '#scm_ShortcutMenu a.scm-trigger',
        hoverClass: 'item-drop-active',
        drop: scm_handleItemDrop
    });

    $('#scm_ShortcutMenu .scm-group').droppable({
        accept: '#scm_ShortcutMenu .scm-group-header',
        hoverClass: 'group-drop-active',
        drop: scm_handleGroupDrop
    });

    scm_refresh();

}

function scm_EditModeOff(trigger)
{
    scm_acceptText();

    $('#scm_ShortcutMenu a.scm-trigger, #scm_ShortcutMenu div.scm-group-header').draggable('destroy');
    $('#scm_ShortcutMenu a.scm-drop-item, #scm_ShortcutMenu div.scm-drop-group').droppable('destroy');
    $('#scm_ShortcutMenu .scm-group').droppable('destroy');

    trigger.attr('mode', '');
    trigger.removeClass('on');
    trigger.attr('title', 'Click here to manage your Shortcut Menu');

    $('#scm_ShortcutMenu a.scm-trigger,#scm_ShortcutMenu div.scm-group-header').addClass('menu-mode').removeClass('edit-mode');
    $('#scm_ShortcutMenu a.scm-trigger,#scm_ShortcutMenu div.scm-group-header').unbind('click mouseenter mouseleave');

    scm_refresh();

    $('#scm_editnotice').hide();

}

function scm_hoverItemIn()
{
    var trigger = $(this);

    trigger.css('cursor', 'move');

    if (scm_dragging)
        return;

    var triggerOffset = trigger.offset();
    var controls = $('#scm_itemcontrols');
    trigger.append(controls);
    controls.show();
    var pos = [triggerOffset.left + trigger.outerWidth() - controls.outerWidth() - 2, triggerOffset.top + (trigger.outerHeight() - controls.outerHeight()) / 2];
    controls.css({ left: pos[0], top: pos[1] });
}

function scm_hoverItemOut(event)
{
    var trigger = $(this);

    trigger.css('cursor', '');

    if (scm_dragging)
        return;

    $('#scm_ShortcutMenu .scm-controls').hide();
}

function scm_hoverGroupIn()
{
    var trigger = $(this);

    trigger.css('cursor', 'move');

    if (scm_dragging)
        return;

    var triggerOffset = trigger.offset();
    var controls = $('#scm_groupcontrols');
    trigger.append(controls);
    controls.show();
    var pos = [triggerOffset.left + trigger.outerWidth() - controls.outerWidth() - 2, triggerOffset.top + (trigger.outerHeight() - controls.outerHeight()) / 2];
    controls.css({ left: pos[0], top: pos[1] });
}

function scm_hoverGroupOut(event)
{
    var trigger = $(this);

    trigger.css('cursor', '');

    if (scm_dragging)
        return;

    $('#scm_ShortcutMenu .scm-controls').hide();

}

function scm_addGroup(addAfterElem)
{
    // NOTE: if any of this markup is changed, it may also have to be changed in ShortcutGroupList.ascx
    var newGroupHtml =
        '<div class="left scm-group ui-droppable" HeightGroup="0"> \
            <div class="scm-drop-group"> \
                <div id="scmGroupHeader" runat="server" class="scm-group-header"> \
                    <span class="item-name">New Section</span> \
                </div> \
            </div> \
            <div class="scm-item-container"> \
            </div> \
        </div>';

    // turn edit mode off and then back on to re-initialze the new section
    scm_EditModeOff($('#scm_edit_mode'));

    addAfterElem.after(newGroupHtml);

    scm_EditModeOn($('#scm_edit_mode'));

    scm_refresh();

    scm_activateText(addAfterElem.next().find('div.scm-drop-group'));

}

function scm_activateText(targetElem)
{
    scm_activeTextElem = targetElem;
    var textElem = targetElem.find('span.item-name');
    var targetOffset = targetElem.offset();
    var textbox = $('#scm_textbox');
    targetElem.append(textbox);

    // hide text and controls for active item
    targetElem.find('.edit-mode').css('visibility', 'hidden');

    textbox.show();
    textbox.val(textElem.text());
    textbox.width(targetElem.width() - 3);
    textbox.focus().select();
    textbox.css({ left: targetOffset.left, top: targetOffset.top - 3 });
}

function scm_acceptText()
{
    if (scm_activeTextElem == null)
        return;

    var textElem = scm_activeTextElem.find('span.item-name');
    var textbox = $('#scm_textbox');
    var name = textbox.val();

    // restore text and controls for active item
    scm_activeTextElem.find('.edit-mode').css('visibility', 'visible');

    textElem.text(name);
    textbox.hide();
    $('#scm_ShortcutMenu').append(textbox);

    scm_refresh();

    if (scm_activeTextElem.hasClass('scm-drop-item'))
        scm_RenameItem(scm_GetItemPosition(scm_activeTextElem.find('a.scm-trigger')), name);
    else
        scm_RenameGroup(scm_GetGroupPosition(scm_activeTextElem.find('div.scm-group-header')), name)

    scm_activeTextElem = null;

}

function scm_revertText()
{
    // restore text and controls for active item
    scm_activeTextElem.find('.edit-mode').css('visibility', 'visible');

    scm_activeTextElem = null;
    $('#scm_textbox').hide();

}

function scm_refresh()
{
    $('#scm_editnotice').hide();
    $('#scm_editnotice').width($('#scm_editnotice').parent().width()-6);
    $('#scm_editnotice').show();

    var popup = $('#scm_ShortcutMenu');
    popup.removeAttr('setheight');
    popupNav_setHeight(popup);
}

function scm_handleItemDrop(event, ui)
{
    var from = scm_GetItemPosition(ui.draggable);
    var to = null;

    // if we are dropping it on another item, make sure it is not be dropped on itself
    if ($(event.target).hasClass('scm-drop-item') && ui.draggable.attr('id') != $(event.target).find('a.scm-trigger').attr('id'))
    {
        to = scm_GetItemPosition($(event.target).find('a.scm-trigger'))
        to.ItemIndex++;
        ui.draggable.parents('div.scm-drop-item').insertAfter(event.target);
    }
    else if ($(event.target).hasClass('scm-drop-group'))
    {
        to = scm_GetItemPosition($(event.target))
        to.ItemIndex = 0;
        ui.draggable.parents('div.scm-drop-item').prependTo($(event.target).siblings('.scm-item-container'));
    }

    scm_refresh();

    if (to != null)
        scm_MoveItem(from, to);
}   

function scm_handleGroupDrop(event, ui)
{
    var from = scm_GetGroupPosition(ui.draggable);
    var to = null;

    // making sure it is not be dropped on itself
    if (ui.draggable.attr('id') != $(event.target).find('div.scm-group-header').attr('id'))
    {
        to = scm_GetGroupPosition($(event.target).find('div.scm-group-header'));
        to++;
        ui.draggable.parents('div.scm-group').insertAfter(event.target);
    }

    scm_refresh();

    if (to != null)
        scm_MoveGroup(from, to);
}

function scm_GetItemPosition(item)
{

    var itemPos = {};
    itemPos.GroupIndex = item.parents('div.scm-group').index('div.scm-group');
    itemPos.ItemIndex = item.parents('div.scm-item-container').children('div.scm-drop-item').index(item.parents('div.scm-drop-item'));

    return itemPos;
}

function scm_GetGroupPosition(group)
{
    return group.parents('div.scm-group').index('div.scm-group');
}

function scm_AddGroups(groups)
{
    var groupDDL = $('#scm_GroupDropDown');

    groupDDL.empty();

    for (var i = 0; i < groups.length; i++)
    {
        groupDDL.append($('<option></option>').val(i).html(groups[i]));
    }
    groupDDL.append($('<option></option>').val(-1).html('-- Create a new menu section --'));

    $('#scm_GroupDropDownValue').val(groupDDL.val());

}


function scm_MoveItem(from, to)
{
    //alert('From: ' + from.GroupIndex + ', ' + from.ItemIndex + '    To: ' + to.GroupIndex + ', ' + to.ItemIndex);
    if (from.GroupIndex == to.GroupIndex && from.ItemIndex == to.ItemIndex)
        return;
    var parms = { 'source': from, 'dest': to };
    scm_PersistChange('MoveShortcut', parms);
}

function scm_DeleteItem(item)
{
    //alert(item.GroupIndex + ', ' + item.ItemIndex);
    var parms = { 'item': item };
    scm_PersistChange('DeleteShortcut', parms);
}

function scm_RenameItem(item, name)
{
    //alert(item.GroupIndex + ', ' + item.ItemIndex);
    var parms = { 'item': item, 'name': name };
    scm_PersistChange('RenameShortcut', parms);
}

function scm_MoveGroup(from, to)
{
    //alert('From: ' + from + '    To: ' + to);
    if (from == to)
        return;
    var parms = { 'sourceIndex': from, 'destIndex': to };
    scm_PersistChange('MoveGroup', parms);
}

function scm_DeleteGroup(group)
{
    //alert(group);
    var parms = { 'groupIndex': group };
    scm_PersistChange('DeleteGroup', parms);
}

function scm_AddGroup(addAfter, name)
{
    //alert(addAfter);
    var parms = { 'addAfterIndex': addAfter, 'name': name };
    scm_PersistChange('AddGroup', parms);
}

function scm_RenameGroup(group, name)
{
    //alert(group);
    var parms = { 'groupIndex': group, 'name': name };
    scm_PersistChange('RenameGroup', parms);
}


function scm_PersistChange(method, parms)
{
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/ShortcutMethods.aspx/' + method;

    $.ajax({
        type: 'POST',
        url: url,
        data: JSON.stringify(parms),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        error: scm_ajaxFailed
    });
}

function scm_LoadGroups()
{
    var url = window.location.protocol + '//' + window.location.host + $('#global_applicationPath').val() + '/AjaxPages/ShortcutMethods.aspx/GetGroups';

    $.ajax({
        type: 'GET',
        url: url,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (result)
        {
            scm_AddGroups(result.d);
        },
        error: scm_ajaxFailed
    });

}


function scm_ajaxFailed(result)
{

    var errorMessage = 'The following error occured while trying to save your changes:\n';
    errorMessage += $.parseJSON(result.responseText).Message;
    alert(errorMessage);
}

