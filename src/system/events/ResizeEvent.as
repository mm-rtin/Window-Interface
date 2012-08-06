/*
     File:	ResizeEvent.as
 Revision:	0.0.1
  Purpose:	Custom Event for handling events for Window Resizing
  Authors:	
  Created:	July 13, 2008
   Edited:	
    Notes:	
Functions:

*/

package system.events {
	
	import flash.events.*;
	import flash.display.DisplayObject;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class ResizeEvent
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class ResizeEvent extends Event {
		
		// ResizeEvent type constants
		public static const WINDOW_RESIZED:String = "windowResized";
		
		// ResizeEvent parameters
		public var windowWidth:int;					// new width of window
		public var windowHeight:int;				// new height of window
		public var referenceObject:DisplayObject;	// used to determine similarity between dispatcher and listener
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		ResizeEvent constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function ResizeEvent(type:String,
									bubbles:Boolean = false,
									cancelable:Boolean = false,
									windowWidth:int = 0,
									windowHeight:int = 0,
									referenceObject:DisplayObject = null) {
			
			super(type, bubbles, cancelable);	// pass Event parameters to superclass
			this.windowWidth = windowWidth;					
			this.windowHeight = windowHeight;
			this.referenceObject = referenceObject;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		clone: custom events must override clone
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function clone():Event {
			return new ResizeEvent(type, bubbles, cancelable, windowWidth, windowHeight, referenceObject);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		toString: custom events must override toString
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function toString():String {
			return formatToString("ResizeEvent", "type", "bubbles", "cancelable", "eventPhase", "windowWidth", "windowHeight", "referenceObject");
		}
		
	}
}