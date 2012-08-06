/*
     File:	KeyInput.as
  Purpose:	
   Author:	
  Created:	Aug 03, 2008
   Edited:
    Notes:	
    
*/

package system {
	
	import flash.display.Stage;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	
	// custom
	import system.events.GlobalEventDispatcher;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 * class KeyInput
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class KeyInput {
	
		// private properties
		private static var stageRef:Stage;			// reference to stage
		private static var keysDown:uint;			// number of keys currently pressed

		// objects
		private static var keyTimer:Timer;
		private static var downKeys:Dictionary;
		
		// constants
		private static const KEY_DELAY:uint = 50;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * initialize KeyInput
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize(stageRef:Stage):void {
			
			// initialize properties
			stageRef = stageRef;
			keysDown = 0;
			
			// initialize objects
			downKeys = new Dictionary();

			// create keyTimer
			keyTimer = new Timer(KEY_DELAY);
			keyTimer.addEventListener(TimerEvent.TIMER, keyPulseHandler);
			
			// add keyboard event listeners
			stageRef.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stageRef.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}	
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * isDown - returns true if keyCode is currently DOWN
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function isDown(keyCode:uint):Boolean {	
			return (downKeys[keyCode]) ? true : false;			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * keyDownHandler - handles KEY_DOWN on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function keyDownHandler(event:KeyboardEvent):void {

			// check if key does not exist in downKeys
			if (!downKeys[event.keyCode]) {

				downKeys[event.keyCode] = event;		// add event to downKeys
				GlobalEventDispatcher.dispatchEvent(event);		// dispatch KEY_DOWN event
				keyTimer.start();
				keysDown ++;
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * keyUpHandler - handles KEY_UP on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function keyUpHandler(event:KeyboardEvent):void {
			
			// dispatch initial KEY_UP event
			GlobalEventDispatcher.dispatchEvent(event);
			
			// remove from downKeys
			delete downKeys[event.keyCode]
			keysDown --;
			
			// if last key, stop keyTimer
			if (keysDown == 0) {
				keyTimer.stop();
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * keyPulseHandler - handles TIMER on keyTimer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function keyPulseHandler(event:TimerEvent):void {
			
			// iterate through all pressed keys and dispatch event
			for (var key:String in downKeys) {
				GlobalEventDispatcher.dispatchEvent(downKeys[key]);
			}
		}
	}
}