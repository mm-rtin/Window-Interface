/*
     File:	GlobalEventDispatcher.as
  Purpose:	
   Author:	
  Created:	July 13, 2008
   Edited:
    Notes:	
    
*/

package system.events {
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 * class GlobalEventDispatcher
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class GlobalEventDispatcher {
	
		// objects
		private static var dispatcher:EventDispatcher;
 
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * addEventListener
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
      		if (dispatcher == null) dispatcher = new EventDispatcher();
	    	dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
      	}
 
 		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * dispatchEvent
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function dispatchEvent(event:Event):void {
			if (dispatcher == null) return;
			dispatcher.dispatchEvent(event);
		}
 
  		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * removeEventListener
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
  			if (dispatcher == null) return;
  			dispatcher.removeEventListener(type, listener, useCapture);
      	}
	}
}