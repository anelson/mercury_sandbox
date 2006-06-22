/*
Nasty hack which extends the Scriptaculous autocomplete controls to work with
my abominable kbdhandler
*/

/**
 * Feeds a key press event to the autocompleter.  Useful when listening
 * for 'keypress' events on the target element will be unhelpful
 */
Autocompleter.Base.prototype.feedKeyPress = function(keyCode) {
	var evt = new Object();
	evt.keyCode = keyCode;

	this.onKeyPress(evt);
}

Ajax.Autocompleter.prototype.feedKeyPress = Autocompleter.Base.prototype.feedKeyPress;
Autocompleter.Local.prototype.feedKeyPress = Autocompleter.Base.prototype.feedKeyPress;


