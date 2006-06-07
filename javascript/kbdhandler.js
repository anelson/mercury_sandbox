var KeyboardHandler = Class.create();
KeyboardHandler.DEBUG = false;

KeyboardHandler.KEY_BACKSPACE        = 8;
KeyboardHandler.KEY_TAB              = 9;
KeyboardHandler.KEY_ENTER            = 13;
KeyboardHandler.KEY_SHIFT            = 16;
KeyboardHandler.KEY_CTRL             = 17;
KeyboardHandler.KEY_ALT              = 18;
KeyboardHandler.KEY_PAUSE_BREAK      = 19;
KeyboardHandler.KEY_CAPS_LOCK        = 20;
KeyboardHandler.KEY_ESCAPE           = 27;
KeyboardHandler.KEY_PAGE_UP          = 33;
KeyboardHandler.KEY_PAGE_DOWN        = 34;
KeyboardHandler.KEY_END              = 35;
KeyboardHandler.KEY_HOME             = 36;
KeyboardHandler.KEY_LEFT_ARROW       = 37;
KeyboardHandler.KEY_UP_ARROW         = 38;
KeyboardHandler.KEY_RIGHT_ARROW      = 39;
KeyboardHandler.KEY_DOWN_ARROW       = 40;
KeyboardHandler.KEY_INSERT           = 45;
KeyboardHandler.KEY_DELETE           = 46;
KeyboardHandler.KEY_LEFT_WINDOW_KEY  = 91;
KeyboardHandler.KEY_RIGHT_WINDOW_KEY = 92;
KeyboardHandler.KEY_SELECT_KEY       = 93;
KeyboardHandler.KEY_F1              = 112;
KeyboardHandler.KEY_F2              = 113;
KeyboardHandler.KEY_F3              = 114;
KeyboardHandler.KEY_F4              = 115;
KeyboardHandler.KEY_F5              = 116;
KeyboardHandler.KEY_F6              = 117;
KeyboardHandler.KEY_F7              = 118;
KeyboardHandler.KEY_F8              = 119;
KeyboardHandler.KEY_F9              = 120;
KeyboardHandler.KEY_F10             = 121;
KeyboardHandler.KEY_F11             = 122;
KeyboardHandler.KEY_F12             = 123;
KeyboardHandler.KEY_NUM_LOCK         = 144;
KeyboardHandler.KEY_SCROLL_LOCK      = 145;

KeyboardHandler.CONTROL_KEYS = [
	KeyboardHandler.KEY_BACKSPACE,
	KeyboardHandler.KEY_TAB,
	KeyboardHandler.KEY_ENTER,
	KeyboardHandler.KEY_SHIFT,
	KeyboardHandler.KEY_CTRL,
	KeyboardHandler.KEY_ALT,
	KeyboardHandler.KEY_PAUSE_BREAK,
	KeyboardHandler.KEY_CAPS_LOCK,
	KeyboardHandler.KEY_ESCAPE,
	KeyboardHandler.KEY_PAGE_UP,
	KeyboardHandler.KEY_PAGE_DOWN,
	KeyboardHandler.KEY_END,
	KeyboardHandler.KEY_HOME,
	KeyboardHandler.KEY_LEFT_ARROW,
	KeyboardHandler.KEY_UP_ARROW,
	KeyboardHandler.KEY_RIGHT_ARROW,
	KeyboardHandler.KEY_DOWN_ARROW,
	KeyboardHandler.KEY_INSERT,
	KeyboardHandler.KEY_DELETE,
	KeyboardHandler.KEY_LEFT_WINDOW_KEY,
	KeyboardHandler.KEY_RIGHT_WINDOW_KEY,
	KeyboardHandler.KEY_SELECT_KEY,
	KeyboardHandler.KEY_F1,
	KeyboardHandler.KEY_F2,
	KeyboardHandler.KEY_F3,
	KeyboardHandler.KEY_F4,
	KeyboardHandler.KEY_F5,
	KeyboardHandler.KEY_F6,
	KeyboardHandler.KEY_F7,
	KeyboardHandler.KEY_F8,
	KeyboardHandler.KEY_F9,
	KeyboardHandler.KEY_F10,
	KeyboardHandler.KEY_F11,
	KeyboardHandler.KEY_F12,
	KeyboardHandler.KEY_NUM_LOCK,
	KeyboardHandler.KEY_SCROLL_LOCK
	];

KeyboardHandler.CURSOR_MOVEMENT_KEYS = [
	KeyboardHandler.KEY_PAGE_UP,
	KeyboardHandler.KEY_PAGE_DOWN,
	KeyboardHandler.KEY_END,
	KeyboardHandler.KEY_HOME,
	KeyboardHandler.KEY_LEFT_ARROW,
	KeyboardHandler.KEY_UP_ARROW,
	KeyboardHandler.KEY_RIGHT_ARROW,
	KeyboardHandler.KEY_DOWN_ARROW
	];

KeyboardHandler.prototype = {	
	/**
	 * Creates a new instance of a keyboard handler for handling custom keyboard capture
	 * for a specific target element.
	 * 
	 * textChangeCallback is a function which takes:
	 * 	handler - The keyboard handler reporting the change
	 * 	oldText - The old text value
	 * 	newText - The new text value
	 * 
	 * controlKeyPressCallback is a function which takes:
	 * 	handler - The keyboard handler reporting the change
	 * 	shift - True if the shift key was down when the key was pressed
	 * 	control - True if control was down
	 * 	alt - True if alt was down
	 * 	meta - True if the platform-specific meta key was down
	 * 	charCode - The ASCII or Unicode code of the character that was pressed.
	 * 		On IE6 this will be the keycode of the key pressed on the keyboard, without
	 * 		regard to any alternative input language settings or the shift key.  On Gecko
	 * 		this will be the Unicode character of the key that was pressed, taking the preceeding
	 * 		into account.  The practical implication of this is that checking for letters like 'A'
	 * 		or whatever needs to be done in both cases.
	 */
	initialize: function(targetElement, textChangeCallback, controlKeyPressCallback) {
		this.targetElement = $(targetElement);
		this.textChangeCallback = textChangeCallback;
		this.controlKeyPressCallback = controlKeyPressCallback;
		this.controlKeyCallbackHash = {};

		//Create a dummy text box to capture the keyboard events
		var txtBoxId = '_text' + Math.ceil(Math.random() * 100000);
		var containerId = '_textcont' + Math.ceil(Math.random() * 100000);
		
		new Insertion.Bottom(this.targetElement,
						  '<div id="' + containerId + '"><input type="text" autocomplete="false" id="' + txtBoxId + '" size="1" value="" /></div>');

		this.dummyTextBox = $(txtBoxId);
		var containerDiv = $(containerId);

		if (!KeyboardHandler.DEBUG) {
			//Modify the DIV containing the text box to make it one practically invisible,
			// and obscure the text box inside it
			Element.setStyle(containerDiv,
							 {
								overflow: "hidden",//The text box lying outside the boundary of the div will not be visible
								width: "1px", //The div will be only one pixel square
								height: "1px", //so it will be nearly invisible
								position: "absolute",//The div's position is absolute, so it doesn't alter the position of surrounding elements
								margin: "10em" //The div's contents start 10em's in from the top left corner, so nothing in the div will be visible in the 1 pixel visible area
							 });

			//Modify the text box itself so its actual position is off the screen, so the blinking cursor
			//and the contents of the text box are never visible
			Element.setStyle(this.dummyTextBox,
							 { 
								position: "relative",//Position this text box relative to its placement in the DIV
								left: "-1000em", //1000 ems to the left...
								top: "-1000em" //..and 1000ems up, taking it well off the screen
							 });
		}

		//Add event handlers to track when the dummy text box gains and loses
		//focus.  This will determine whether the target element will receive keyboard
		//events through the keyboard handler, and thus it's 'focus'.  Add the 'kbd-focus'
		//class to the target element when it has focus, and remove it when it's lost
		Event.observe(this.dummyTextBox,
					  'focus',
					  this.onTextBoxFocus.bind(this));
		
		Event.observe(this.dummyTextBox,
					  'blur',
					  this.onTextBoxBlur.bind(this));

		//Catch key presses in the text box to detect control keys and to 
		//hint when text changes
		Event.observe(this.dummyTextBox,
					  'keypress',
					  this.onTextBoxKeyPress.bind(this));

		//Initialize the cached text box value
		this.lastTextBoxValue = "";

		this.installDefaultControlKeyHandlers();
	},

	/**
	 * Sets the focus to the target element so text events are captured and sent to it.
	 * Focus cannot be changed by the user; focus will reset if focus() is called on another
	 * KeyboardHandler or if unlockFocus() is called 
	 * 
	 * The 'kbd-focus' class will be added to the target element when it has keyboard
	 * focus, and removed when it loses it
	 */
	lockFocus : function() {
		 FocusController.setFocus(this.dummyTextBox);
	},

	unlockFocus : function() {
		FocusController.unlockFocus();
	},

	/**
	 * Returns the current text buffer
	 */
	getText : function() {
		 return this.lastTextBoxValue;
	},

	/**
	 * Replaces the current text buffer with an arbitrary string, invoking the
	 * textChange callback
	 */
	setText : function(newValue) {
		this.dummyTextBox.value = newValue;
	},

	/**
	 * Registers a callback in response to a specific control character/modifier combination.
	 * 
	 * The callback should take the same arguments as those passed to the general purpose
	 * control character callback passed to initialize, and all the same caveats apply.
	 */
	setControlKeyCallback : function(shift, ctrl, alt, meta, charCode, callback) {
		var hashKey = this.computeControlKeyHashKey(shift, ctrl, alt, meta, charCode);

		this.dump('Installing control key callback with key ' + hashKey + ': ' + callback);
		this.controlKeyCallbackHash[hashKey] = callback;
		if (!this.controlKeyCallbackHash[hashKey]) {
			this.dump('Didnt work');
		}
	},

	/**
	 * Unregisters a callback registered with registerControlKeyCallback
	 */
	clearControlKeyCallback : function(shift, ctrl, alt, meta, charCode) {
		var hashKey = this.computeControlKeyHashKey(shift, ctrl, alt, meta, charCode);

		this.dump('Clearing control key callback with key ' + hashKey);
		this.controlKeyCallbackHash[hashKey] = undefined;
	},

	onTextBoxFocus : function(e) {
		//The dummy text box has focus, so the target element will receive kbd events
		Element.addClassName(this.targetElement,
							 'kbd-focus');
	},

	onTextBoxBlur : function(e) {
		//The dummy text box lost focus, so the target element won't receive kbd events
		Element.removeClassName(this.targetElement,
								'kbd-focus');
	},

	onTextBoxKeyPress : function(e) {
		 this.dump('Text box key pressed: ' +
				   "Shift: " + e.shiftKey + ", " +
					"Control " + e.ctrlKey + ", " +
					"Alt: " + e.altKey + ", " +
					"Meta: " + e.metaKey + ", " +
					"keyCode: " + e.keyCode + ", " +
					"charCode: " + e.charCode);
		 //A key is pressed within the text box.  This fires every time a key goes
		 //down while the text box has focus, whether it's a printable character or a control
		 //key.  Note that Gecko and IE6 will both put control keys in e.keyCode, but IE6 
		 //will also put numbers/letters/punct/etc in keyCode, hence the need to check
		 //with isControlKey
		 var controlKey = e.altKey || e.ctrlKey || e.metaKey || this.isControlKey(e.keyCode);

		 this.dump('Last key press was ' + (controlKey ? '' : 'not') + ' a control key');
		 
		 //Gecko and IE 6 both report control keys in the keyCode attribute.  Gecko reports
		 //printable characters in the charCode attribute, while IE 6 stupidly reports the key code
		 //for printable characters in the keyCode attribute, and doesn't adjust for shift/capslock,
		 //alternative input language, etc.
		 //
		 //Long story short, control keys are reported in keyCode for both browsers, while Gecko takes the
		 // trouble to translate printable keys into Unicode and places them in charCode, while IE 6 takes
		 // the raw code from the keyboard and puts it in keyCode.  So, we'll use 'charCode' if it's there; 
		 // if not fall back to keyCode.
		 var keyCode = e.charCode ? e.charCode : e.keyCode;
		 
		 if (controlKey) {
			 var retval = this.processNonPrintableKeyPress(e.shiftKey,
												  e.ctrlKey,
												  e.altKey,
												  e.metaKey,
												  keyCode);

			 if (retval == false) {
				 this.dump('Canceling last key press');
				 Event.stop(e);
			 }
		 } 

		 if (!controlKey || this.isPossibleTextChangeKey(keyCode)) {
			 //Else, something printable or a control key that could change text (like backspace).  
			 //Check for text changes once this event finishes
			 this.dump('Last key press potentially a text modifier; queueing check for text change');
			 
			 setTimeout(this.onPossibleTextBoxChange.bind(this), 1);
			 return true;
		 }
	},

	onPossibleTextBoxChange : function() {
		//A key is pressed within the text box.  
		//After the event is processed, the text box value will be the character
		//entered, if any.  For control keys the text box value will be unchanged.
		//
		//Let this event process, then inspect the text box value
		 if (this.dummyTextBox.value != this.lastTextBoxValue) {
			 this.dump('Text box has changed from last recorded value');
			 
			 var retval = this.processTextChanged(this.lastTextBoxValue, this.dummyTextBox.value);
			 if (retval != false) {
				 this.dump('Keeping new value');
				 this.lastTextBoxValue = this.dummyTextBox.value;
			 } else {
				 this.dump('Rejecting new value');
				 this.dummyTextBox = this.lastTextBoxValue;
			 }
		 }
	},

	/**
	 * Installs default handlers for certain control keys, mostly to disable them
	 * for example, Control-V is disabled by default to avoid confusing matters with a paste 
	 * of text
	 */
	installDefaultControlKeyHandlers : function() {
		 var hellNo = function() {
			 return false;
		 }

		 var clearText = function(handler) {
			 handler.setText('');
		 }

		 //Control-x (lower case for Gecko; IE6 will report capital X)
		 this.setControlKeyCallback(false, //shift
							   true, //control
							   false, //alt
							   false, //meta
							   'x'.charCodeAt(0),
									hellNo);
		 this.setControlKeyCallback(false, //shift
							   true, //control
							   false, //alt
							   false, //meta
							   'X'.charCodeAt(0),
									hellNo);

		 //Ditto control-v
		 this.setControlKeyCallback(false, //shift
							   true, //control
							   false, //alt
							   false, //meta
							   'v'.charCodeAt(0),
									hellNo);
		 this.setControlKeyCallback(false, //shift
							   true, //control
							   false, //alt
							   false, //meta
							   'V'.charCodeAt(0),
									hellNo);

		 //Control-backspace should clear the entered text
		 this.setControlKeyCallback(false, //shift
							   true, //control
							   false, //alt
							   false, //meta
							   KeyboardHandler.KEY_BACKSPACE,
									clearText);
		 
	},

	/**
	 * Report the changed text to the text change callback
	 */
	processTextChanged : function(oldText, newText) {
		 var retval = true;
		 
        if (this.textChangeCallback) {
			retval = this.textChangeCallback(this, oldText, newText);
		}

		return retval;
	},

	/**
	 * Handles a press of a non-printable key.  Runs the key press through the associated
	 * key-specific callback, or the general-purpose control key callback if there is none.
	 */
	processNonPrintableKeyPress : function(shift, ctrl, alt, meta, charCode) {
		 //Control keys should *never* be passed through.  Different platforms/apps
		 //define different control keys for significant operations like save as, print, close, etc
		 //All of these will cause unanticipated behavior.
		 //
		 //That said, brave/stupid users of the code can return 'true' in their callbacks
		 //to allow control characters to proceed.  'false' is the default.
		var retval = false;

		//Check for a specific callback
		var key = this.computeControlKeyHashKey(shift, ctrl, alt, meta, charCode);
		this.dump('Checking for specific control key callback ' + key);
		if (this.controlKeyCallbackHash[key]) {
			this.dump('Calling specific control key callback');
			retval = this.controlKeyCallbackHash[key](this, shift, ctrl, alt, meta, charCode);
		} else if (this.controlKeyPressCallback) {
			this.dump('Calling general control key callback');
			retval = this.controlKeyPressCallback(this, shift, ctrl, alt, meta, charCode);
		}

		//If any cursor movement keys were pressed, suppress them no matter what the callback
		//says
		if (retval && this.isCursorMovementKey(charCode)) {
			retval = false;
		}

		return retval;
	},

	/**
	 * Determines if a given key code corresponds to a control key or 
	 * not
	 */
	isControlKey : function(charCode) {
		return KeyboardHandler.CONTROL_KEYS.indexOf(charCode) != -1; 
	},

	/**
	 * Determines if a given key code corresponds to a cursor movement key or 
	 * not
	 */
	isCursorMovementKey : function(charCode) {
		return KeyboardHandler.CURSOR_MOVEMENT_KEYS.indexOf(charCode) != -1; 
	},

	isPossibleTextChangeKey : function(charCode) {
		if (charCode == KeyboardHandler.KEY_BACKSPACE || 
			charCode == KeyboardHandler.KEY_DELETE) {
			return true;
		} else {
			return false;
		}
	},

	/**
	 * Builds a string encoding the variables that identify a specific control key
	 * for use in a hash table
	 */
	computeControlKeyHashKey : function(shift, ctrl, alt, meta, charCode) {
		 var key = '';

		 key += shift ? '+' : '-';
		 key += ctrl ? '+' : '-';
		 key += alt ? '+' : '-';
		 key += meta ? '+' : '-';
		 key += charCode;

		 return key;
	},

	dump : function(msg) {
		 if (KeyboardHandler.DEBUG) {
			 var dbg = $('debug');
			 if (dbg) {
				 new Insertion.Bottom(dbg, '<div>' + msg.escapeHTML() + '</div>');
			 }
		 }
	}
}

