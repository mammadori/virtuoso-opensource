/*
 *  
 *  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
 *  project.
 *  
 *  Copyright (C) 1998-2006 OpenLink Software
 *  
 *  This project is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation; only version 2 of the License, dated June 1991.
 *  
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 *  
 *  
*/
// ---------------------------------------------------------------------------
function myPost(frm_name, fld_name, fld_value)
{
  createHidden(frm_name, fld_name, fld_value);
  document.forms[frm_name].submit();
}

// ---------------------------------------------------------------------------
function toolbarPost(fld_value)
{
  document.F1.toolbar_hidden.value = fld_value;
  doPost ('F1', 'toolbar');
}

// ---------------------------------------------------------------------------
//
function submitEnter(myForm, myButton, e) {
  var keycode;
  if (window.event)
    keycode = window.event.keyCode;
  else
    if (e)
      keycode = e.which;
    else
      return true;
  if (keycode == 13) {
    if (myButton != '') {
      doPost (myForm, myButton);
      return false;
    } else
      document.forms[myForm].submit();
  }
  return true;
}

// ---------------------------------------------------------------------------
//
function selectAllCheckboxes (form, btn)
{
  for (var i = 0; i < form.elements.length; i = i + 1) {
    var contr = form.elements[i];
    if (contr != null && contr.type == "checkbox") {
      contr.focus();
      if (btn.value == 'Select All')
        contr.checked = true;
      else
        contr.checked = false;
    }
  }
  if (btn.value == 'Select All')
    btn.value = 'Unselect All';
  else
    btn.value = 'Select All';
  btn.focus();
}

// ---------------------------------------------------------------------------
//
function countSelected (form, txt)
{
  var count = 1;

  if ((form != null) && (txt != null)) {
    count = 0;
    for (var i = 0; i < form.elements.length; i++) {
      var obj = form.elements[i];
      if ((obj != null) && (obj.type == "checkbox") && (obj.name.indexOf (txt) != -1) && obj.checked)
        count++;
    }
  }
  return count;
}

// ---------------------------------------------------------------------------
//
function getSelected (form, txt)
{
  if ((form != null) && (txt != null)) {
    for (var i = 0; i < form.elements.length; i++) {
      var obj = form.elements[i];
      if ((obj != null) && (obj.type == "checkbox") && (obj.name.indexOf (txt) != -1) && obj.checked)
        return (obj.name).substr(txt.length);
    }
  }
  return '';
}

// ---------------------------------------------------------------------------
//
function anySelected (form, txt, selectionMsq, mode)
{
  if ((form != null) && (txt != null)) {
    for (var i = 0; i < form.elements.length; i++) {
      var obj = form.elements[i];
      if ((obj != null) && (obj.type == "checkbox") && (obj.name.indexOf (txt) != -1) && obj.checked)
        return true;
    }
    if (selectionMsq != null) {
      if ((mode != null) && (mode == 'confirm'))
        return confirm(selectionMsq);
      alert(selectionMsq);
    }
    return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
//
function singleSelected (form, txt, zeroMsq, moreMsg, mode)
{
  var count = countSelected(form, txt);
  if (count == 0) {
    if (zeroMsq != null)
      alert(zeroMsq);
    return false;
  }
  if (count > 1) {
    if (moreMsg != null)
      alert(moreMsg);
    return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
//
function getFileName(obj)
{
  var S = obj.value;
  var N;
  if (S.lastIndexOf('\\') > 0)
    N = S.lastIndexOf('\\') + 1;
  else
    N = S.lastIndexOf('/') + 1;
  S = S.substr(N, S.length);
  if (S.indexOf('?') > 0) {
    N = S.indexOf('?');
    S = S.substr(0, N);
  }
  if (S.indexOf('#') > 0) {
    N = S.indexOf('#');
    S = S.substr(0, N);
  }
  document.F1.dav_name.value = S;
}

// ---------------------------------------------------------------------------
//
function chkbx(bx1, bx2)
{
  if (bx1.checked == true && bx2.checked == true)
    bx2.checked = false;
}

// ---------------------------------------------------------------------------
//
function updateLabel(value)
{
  hideLabel(4, 9);
  if (value == 'oMail')
    showLabel(4, 4);
  if (value == 'PropFilter')
    showLabel(5, 5);
  if (value == 'ResFilter')
    showLabel(7, 9);
  if (value == 'CatFilter')
    showLabel(7, 9);
}

// ---------------------------------------------------------------------------
//
function showLabel(from, to)
{
  for (var i = from; i <= to; i++) {
    var div = document.getElementById('tabLabel_'+i);
    if (div != null) {
      div.style.visibility = 'visible';
      div.style.display = 'inline';
    }
  }
}

// ---------------------------------------------------------------------------
//
function hideLabel(from, to)
{
  for (var i = from; i <= to; i++) {
    var div = document.getElementById('tabLabel_'+i);
    if (div != null) {
      div.style.visibility = 'hidden';
      div.style.display = 'none';
    }
  }
}

// ---------------------------------------------------------------------------
//
function showTab(tab, tabs)
{
  for (var i = 1; i <= tabs; i++) {
    var div = document.getElementById(i);
    if (div != null) {
      var divTab = document.getElementById('tab_'+i);
      if (i == tab) {
        var divNo = document.getElementById('tabNo');
        divNo.value = tab;
        div.style.visibility = 'visible';
        div.style.display = 'block';
        if (divTab != null) {
          divTab.className = "tab activeTab";
          divTab.blur();
        };
      } else {
        div.style.visibility = 'hidden';
        div.style.display = 'none';
        if (divTab != null)
          divTab.className = "tab";
      }
    }
  }
}

// ---------------------------------------------------------------------------
//
function initTab(tabs, defaultNo)
{
  var divNo = document.getElementById('tabNo');
  var tab = defaultNo;
  if (divNo != null) {
    var divTab = document.getElementById('tab_'+divNo.value);
    if (divTab != null)
      tab = divNo.value;
  }
  showTab(tab, tabs);
}

// ---------------------------------------------------------------------------
//
function uncheck(checkBox)
{
  document.F1.elements[checkBox].checked = false;
}

// ---------------------------------------------------------------------------
//
function initDisabled()
{
	var box = document.F1.elements;
	for (var i=0; i<box.length; i++)
		if (box[i].disabled)
      if (document.F1.elements['formRight'])
        if (document.F1.elements['formRight'].value == '1')
          box[i].disabled = false;
}

// ---------------------------------------------------------------------------
//
function initEnabled()
{
	var box = document.F1.elements;
	for (var i=0; i<box.length; i++)
    box[i].disabled = false;
}

// ---------------------------------------------------------------------------
//
function deleteConfirm()
{
  return confirm('Are you sure you want to delete the chosen record?');
}

// ---------------------------------------------------------------------------
//
function deprecateConfirm()
{
  return confirm('Are you sure you want to deprecate the chosen record?');
}

// ---------------------------------------------------------------------------
function confirmAction(confirmMsq, form, txt, selectionMsq) {
  if (anySelected (form, txt, selectionMsq))
    return confirm(confirmMsq);
  return false;
}

// ---------------------------------------------------------------------------
//
function windowShow(sPage, width, height)
{
  if (width == null)
    width = 500;
  if (height == null)
    height = 420;
  sPage = sPage + '&sid=' + document.forms[0].elements['sid'].value + '&realm=' + document.forms[0].elements['realm'].value;
  win = window.open(sPage, null, "width="+width+",height="+height+",top=100,left=100,status=yes,toolbar=no,menubar=no,scrollbars=yes,resizable=yes");
  win.window.focus();
}

// ---------------------------------------------------------------------------
//
function renameShow(myForm, myPrefix, myPage, width, height)
{
  var myFile = getSelected(myForm, myPrefix);
  if (myFile != '') {
    if (height == null)
      height = 250;
    myPage = myPage + '&file=' + escape(myFile);
    windowShow(myPage, width, height);
  }
}

// ---------------------------------------------------------------------------
function trim(sString, ch)
{
  if (ch == null)
    ch = ' ';
  while (sString.substring(0,1) == ch)
    sString = sString.substring(1, sString.length);

  while (sString.substring(sString.length-1, sString.length) == ch)
    sString = sString.substring(0,sString.length-1);

  return sString;
}

// ---------------------------------------------------------------------------
//
function coloriseTable(id)
{
  if (document.getElementsByTagName) {
    var table = document.getElementById(id);
    if (table != null) {
      var rows = table.getElementsByTagName("tr");
      for (i = 0; i < rows.length; i++) {
        if (rows[i].className != "nocolor") {
          rows[i].className = "td_row" + (i % 2);
        }
      }
    }
  }
}

// ---------------------------------------------------------------------------
//
function rowSelect(obj)
{
  var submitMode = false;
  if (window.document.F1.elements['src'])
    if (window.document.F1.elements['src'].value.indexOf('s') != -1)
      submitMode = true;
  if (submitMode)
    if (window.opener.document.F1)
      if (window.opener.document.F1.elements['submitting'])
        return false;
  var closeMode = true;
  if (window.document.F1.elements['dst'])
    if (window.document.F1.elements['dst'].value.indexOf('c') == -1)
      closeMode = false;
  var singleMode = true;
  if (window.document.F1.elements['dst'])
    if (window.document.F1.elements['dst'].value.indexOf('s') == -1)
      singleMode = false;

  var s2 = (obj.name).replace('b1', 's2');
  var s1 = (obj.name).replace('b1', 's1');

  var myRe = /^(\w+):(\w+);(.*)?/;
  var params = window.document.forms['F1'].elements['params'].value;
  var myArray;
  while(true) {
    myArray = myRe.exec(params);
    if (myArray == undefined)
      break;
    if (myArray.length > 2)
      if (window.opener.document.F1)
        if (window.opener.document.F1.elements[myArray[1]]) {
          if (myArray[2] == 's1')
            if (window.opener.document.F1.elements[myArray[1]])
              rowSelectValue(window.opener.document.F1.elements[myArray[1]], window.document.F1.elements[s1], singleMode, submitMode);
          if (myArray[2] == 's2')
            if (window.opener.document.F1.elements[myArray[1]])
              rowSelectValue(window.opener.document.F1.elements[myArray[1]], window.document.F1.elements[s2], singleMode, submitMode);
        }
    if (myArray.length < 4)
      break;
    params = '' + myArray[3];
  }
  if (submitMode) {
    window.opener.createHidden('F1', 'submitting', 'yes');
    window.opener.document.F1.submit();
  }
  if (closeMode)
    window.close();
}

// ---------------------------------------------------------------------------
//
function rowSelectValue(dstField, srcField, singleMode, submitMode)
{
  if (singleMode) {
    dstField.value = trim(srcField.value, ',');
  } else {
    if (dstField.value == '') {
      dstField.value = srcField.value;
    } else {
      srcField.value = trim(srcField.value , ',');
      var aSrc = srcField.value.split(',');

      dstField.value = dstField.value + ',';
      for (var i = 0; i < aSrc.length; i = i + 1) {
        if (aSrc[i] != '')
          if (dstField.value.indexOf(aSrc[i]+',') == -1)
            dstField.value = dstField.value + trim(aSrc[i], ',') + ',';
      }
    }
    dstField.value = trim(dstField.value, ',');
  }
}

// ---------------------------------------------------------------------------
//
function updateChecked(form, objName)
{
  for (var i = 0; i < form.elements.length; i = i + 1) {
    var obj = form.elements[i];
    if (obj != null && obj.type == "checkbox" && obj.name == objName) {
      if (obj.checked) {
        if (form.s1.value.indexOf(obj.value+',') == -1)
          form.s1.value = form.s1.value + obj.value+',';
      } else {
        form.s1.value = (form.s1.value).replace(obj.value+',', '');
      }
    }
  }
}

// ---------------------------------------------------------------------------
//
function addChecked (form, txt, selectionMsq)
{
  if (!anySelected (form, txt, selectionMsq, 'confirm'))
    return;

  var submitMode = false;
  if (window.document.F1.elements['src'])
    if (window.document.F1.elements['src'].value.indexOf('s') != -1)
      submitMode = true;
  if (submitMode)
    if (window.opener.document.F1)
      if (window.opener.document.F1.elements['submitting'])
        return false;
  var singleMode = true;
  if (window.document.F1.elements['dst'])
    if (window.document.F1.elements['dst'].value.indexOf('s') == -1)
      singleMode = false;

  var s1 = 's1';
  var s2 = 's2';

  var myRe = /^(\w+):(\w+);(.*)?/;
  var params = window.document.forms['F1'].elements['params'].value;
  var myArray;
  while(true) {
    myArray = myRe.exec(params);
    if (myArray == undefined)
      break;
    if (myArray.length > 2)
      if (window.opener.document.F1)
        if (window.opener.document.F1.elements[myArray[1]]) {
          if (myArray[2] == 's1')
            if (window.opener.document.F1.elements[myArray[1]])
              rowSelectValue(window.opener.document.F1.elements[myArray[1]], window.document.F1.elements[s1], singleMode, submitMode);
          if (myArray[2] == 's2')
            if (window.opener.document.F1.elements[myArray[1]])
              rowSelectValue(window.opener.document.F1.elements[myArray[1]], window.document.F1.elements[s2], singleMode, submitMode);
        }
    if (myArray.length < 4)
      break;
    params = '' + myArray[3];
  }
  if (submitMode)
    window.opener.document.F1.submit();
  window.close();
}

// ---------------------------------------------------------------------------
//
function createHidden(frm_name, fld_name, fld_value)
{
  var hidden;

  if (document.forms[frm_name]) {
    hidden = document.forms[frm_name].elements[fld_name];
    if (hidden == null) {
      hidden = document.createElement("input");
      hidden.setAttribute("type", "hidden");
      hidden.setAttribute("name", fld_name);
      hidden.setAttribute("id", fld_name);
      document.forms[frm_name].appendChild(hidden);
    }
    hidden.value = fld_value;
  }
}
