/**
 * Functions used by the "related factors", "related strategies" and other forms in 
 * the Redmine Arch Decisions plugin.
 * NOTE: requires the shortcut.js script to be included in any page that uses these scripts
 * 
 * @author timothy.high@gmail.com
 */

/*
 * Functions for the New <Entity> forms
 */
function initializeForm(frm) {
	deactivateShortcuts(frm)
	cancelForm(frm);
}
function showForm(frm) {
    $("#"+frm + '_link').hide();
    $("#"+frm + '_form_row').show();
    var f = $('#'+frm)[0];
    for (i=0; i < f.elements.length; i++) {
	if (f.elements[i].type != 'hidden') {
	    f.elements[i].focus();
	    break;
	}
    }
    // TODO: get rid of this hack. Dunno why I can't call scrollTo outside this method.
    if (frm == "new_discussion") {
	//scrollTo($('#new_discussion_form_row'));
    }
    deactivateShortcuts();
}
function hideForm(frm) {
    $("#"+frm + '_form_row').hide();
    $("#"+frm + '_link').show();
    activateShortcuts();
}
function cancelForm(frm) {
	hideForm(frm);
	$('#'+frm)[0].reset();
}
function callOnSubmit(frm) {
	var code = $("#"+frm).attr('onsubmit');
	eval(code);
}
// Hotkey / Shortcut functions
function activateShortcuts() {
	// New Factor
	shortcut.add("f",function() {
		showForm('new_factor');
	});
	// Add Factor
	shortcut.add("a",function() {
		var elem = $('add_factor_link');
		elem.onclick.apply(elem);
		});
	// New Strategy
	shortcut.add("s",function() {
		showForm('new_strategy');
	});
	// Add Issue
	shortcut.add("i",function() {
		showForm('add_issue');
	});
	// New Discussion Comment
	shortcut.add("c",function() {
		showForm('new_discussion');
	});
}
function deactivateShortcuts() {
	shortcut.remove("f");
	shortcut.remove("a");
	shortcut.remove("s");
	shortcut.remove("i");
	shortcut.remove("c");
}

/*
 * Functions for Factor prioritization (drag and drop)
 */
function showDropTarget(target) {
    target.css("background-color", "#000000");
}
function showDropped(target) {
    target.css("background-color", "#FF0000");
}

function scrollTo(target) {
    $('html, body').animate({
	    scrollTop: target.offset().top
		}, 1000);
}