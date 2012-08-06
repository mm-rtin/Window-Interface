/*
     File:	ScrollerEvent.as
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
	class ScrollerEvent
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class ScrollerEvent extends Event {
		
		// ScrollerEvent type constants
		public static const SCROLLER_VISIBLE:String = "scrollerVisible";
		
		// ScrollerEvent parameters
		public var verticalVisible:Boolean;			// visibility status of vertical scrollBar
		public var verticalArrowsVisible:Boolean;	// visibility status of vertical arrows
		public var horizontalVisible:Boolean;		// visibility status of horizontal scrollBar
		public var horizontalArrowsVisible:Boolean;	// visibility status of horizontal arrows
		public var reservedScrollerSize:uint;		// total size reserved for scroller area
		public var referenceObject:DisplayObject;	// used to determine similarity between dispatcher and listener
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		ScrollerEvent constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function ScrollerEvent(type:String,
									bubbles:Boolean = false,
									cancelable:Boolean = false,
									verticalVisible:Boolean = false,
									verticalArrowsVisible:Boolean = false,
									horizontalVisible:Boolean = false,
									horizontalArrowsVisible:Boolean = false,
									reservedScrollerSize:uint = 0,
									referenceObject:DisplayObject = null) {
			
			super(type, bubbles, cancelable);						// pass Event parameters to superclass
			
			this.verticalVisible = verticalVisible;			
			this.verticalArrowsVisible = verticalArrowsVisible;		
			this.horizontalVisible = horizontalVisible;
			this.horizontalArrowsVisible = horizontalArrowsVisible;
			this.reservedScrollerSize = reservedScrollerSize;
			this.referenceObject = referenceObject;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		clone: custom events must override clone
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function clone():Event {
			return new ScrollerEvent(type, bubbles, cancelable, verticalVisible, verticalArrowsVisible, horizontalVisible, horizontalArrowsVisible, reservedScrollerSize, referenceObject);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		toString: custom events must override toString
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function toString():String {
			return formatToString("ScrollerEvent", "type", "bubbles", "cancelable", "eventPhase", "verticalVisible", "verticalArrowsVisible", "horizontalVisible", "horizontalArrowsVisible", "reservedScrollerSize", "referenceObject");
		}
	}
}