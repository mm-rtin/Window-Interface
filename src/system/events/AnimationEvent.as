/*
     File:	AnimationEvent.as
 Revision:	0.0.1
  Purpose:	Custom Event for handling events for Animate class
  Authors:	
  Created:	July 15, 2008
   Edited:	
    Notes:	
Functions:

*/

package system.events {
	
	import flash.events.*;
	import flash.display.DisplayObject;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class AnimationEvent
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class AnimationEvent extends Event {
		
		// AnimationEvent type constants
		public static const ANIMATION_UPDATE:String = "animationUpdate";
		
		// AnimationEvent parameters
		public var a:Number;						// new a
		public var b:Number;						// new b
		public var animationTarget:DisplayObject;	// animationTarget of animation
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		AnimationEvent constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function AnimationEvent(type:String,
										bubbles:Boolean = false,
										cancelable:Boolean = false,
										a:Number = 0,
										b:Number = 0,
										animationTarget:DisplayObject = null) {
			
			super(type, bubbles, cancelable);	// pass Event parameters to superclass
			this.a = a;					
			this.b = b;
			this.animationTarget = animationTarget;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		clone: custom events must override clone
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function clone():Event {
			return new AnimationEvent(type, bubbles, cancelable, a, b, animationTarget);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		toString: custom events must override toString
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function toString():String {
			return formatToString("AnimationEvent", "type", "bubbles", "cancelable", "eventPhase", "a", "b", "animationTarget");
		}
		
	}
}