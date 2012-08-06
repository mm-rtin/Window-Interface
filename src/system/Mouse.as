/*
     File:	Mouse.as
  Purpose:	
   Author:	
  Created:	July 11, 2008
   Edited:
    Notes:	static class
    
*/

package system {
	
	import flash.display.Stage;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	// custom
	import graphics.Draw;
	import flash.display.Sprite;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 * class Mouse
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Mouse extends EventDispatcher {
	
		protected static var dispatcher:EventDispatcher;
		
		// private properties
		private static var stageRef:Stage;			// reference to stage
		
		// private objects
		private static var mouseContainer:Sprite;	// container for custom cursors
		private static var currentCursor:Sprite;	// current mouse cursor sprite
		
		// public objects
		public static var mousePoint:Point;			// mouse coordinates as point object
		public static var resizeHorizontalCursor:Bitmap;
		public static var resizeVericalCursor:Bitmap;
		public static var resizeCornerCursor:Bitmap;
		
		// public properties
		public static var mouseX:int;				// current mouse X position on stage
		public static var mouseY:int;				// current mouse Y position on stage
				
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * initialize Mouse
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize(stageRef:Stage):Sprite {
			
			// initialize properties
			Mouse.stageRef = stageRef;
			
			// sprites
			mouseContainer = new Sprite();
			mouseContainer.mouseEnabled = false;	// prevent custom cursor from intercepting mouse events
			
			currentCursor = new Sprite();
			currentCursor.mouseEnabled = false;
			
			// get resize cursors
			resizeHorizontalCursor = Draw.getBitmap("resizeHorizontal");
			resizeVericalCursor = Draw.getBitmap("resizeVertical");
			resizeCornerCursor = Draw.getBitmap("resizeCorner");
			
			// initialize Mouse components
			stageRef.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stageRef.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stageRef.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			
			// add to mouseContainer
			mouseContainer.addChild(currentCursor);
			
			return mouseContainer;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getMousePoint - return mouse coordinates as Point object
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function getMousePoint():Point {
			
			return new Point(mouseX, mouseY);
		}	
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * setCursor - hide default cursor and add new custom cursor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function setCursor(cursor:Bitmap):void {
			
			flash.ui.Mouse.hide();					// hide mouse
			try {
				currentCursor.removeChildAt(0);		// remove existing cursor
			} catch(error:Error) {}
			
			// init position
			currentCursor.x = stageRef.mouseX;
			currentCursor.y = stageRef.mouseY;
			
			cursor.x = -cursor.width >> 1;
			cursor.y = -cursor.height >> 1;
			
			currentCursor.addChild(cursor);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * defaultCursor - remove custom cursor and show default
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function defaultCursor():void {
			
			flash.ui.Mouse.show();					// show mouse
			try {
				currentCursor.removeChildAt(0);		// remove custom cursor
			} catch(error:Error) {}
			
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseMoveHandler
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function mouseMoveHandler(event:MouseEvent):void {
			
			// if custom cursor exists, follow mouse
			if (currentCursor.numChildren > 0) {
				currentCursor.x = event.stageX;
				currentCursor.y = event.stageY;
			}

			// set new mouseX, mouseY properties
			Mouse.mouseX = event.stageX;
			Mouse.mouseY = event.stageY;
			
			// remove custom cursor if none of the target names below match
			if (!event.buttonDown) {
				switch(event.target.name) {
					case "resizeRight":
						break;
					case "resizeBottom":
						break;
					case "resizeCorner":
						break;
					default:
						Mouse.defaultCursor();
						break;		
				}
			}	
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseDownHandler
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function mouseDownHandler(event:MouseEvent):void {
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseUpHandler
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function mouseUpHandler(event:MouseEvent):void {
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseLeaveHandler
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function mouseLeaveHandler(event:Event):void {
			defaultCursor();
		}
	}
}