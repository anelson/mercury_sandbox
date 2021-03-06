/*

Simple helper class that allows an application to strictly control focus within a page
*/
var FocusController = Class.create();

FocusController = {
	focusElement : null,
	
	initialize: function() {
	},

	/**
	 * sets and locks focus to a new element.  users and other scripts will be
	 * prevented from changing focus.  If another element was previously focused,
	 * unlocks that element's focus first. 
	 */
	setFocus : function(newFocusElement) {
		 if (this.focusElement != null) {
			 this.unlockFocus();
		 }
		 
		this.focusElement = $(newFocusElement);

		//focus this element
		this.refocusElement();

		//IE won't focus an element if the document isn't done loading; 
		//just in case the document isn't loaded yet, add a handler
		Event.observe(document.body, 'load', this.focusOnLoad.bind(this));

		//Capture loss of focus.  Sadly, focus and blur don't bubble in IE6, so
		//this is somewhat harder
		Event.observe(this.focusElement, 'blur', this.onLosingFocus.bind(this));
	},

	/**
	 * Unlocks focus and changes the focus to the body element 
	 */
	clearFocus : function() {
		 this.unlockFocus();
		 document.body.focus();
	},

	/**
	 * Unlocks the focus, so the user or other script can change the focus from the
	 * focusElement.  Doesn't actually change focus
	 */
	unlockFocus : function() {
		//Stop listening for focus loss
		Event.stopObserving(this.focusElement,
							'blur',
							this.onLosingFocus.bind(this));

		this.focusElement = null;
	},

	focusOnLoad : function(e) {
		 _refocusElement();
		 Event.stopObserving(document.body, 
							 'load',
							 this.focusOnLoad.bind(this));
	},

	onLosingFocus : function(e) {
		 //In IE, stopping the 'blur' event like this will prevent 'click'
		 // events from firing then clicking on other elements, including buttons.
		 // This makes for a pretty unresponsive UI, and isn't effective on its own
		 // anyway
		 //Event.stop(e);
		 
		 this.refocusElement();
		 return false;
	},

	refocusElement : function() {
		 //As soon as the current event finishes processing, set the focus
		 //back to focusElement
		 setTimeout(this._refocusElement.bind(this),1);
	},

	_refocusElement : function() {
		this.focusElement.focus();
	}
}

