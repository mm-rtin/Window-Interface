/*
     File:	WindowGroup.as
  Purpose:	
   Author:	
  Created:	June 26, 2008
   Edited:
    Notes:	Manages Window class
    
*/

package window {
	
	import data.ContentLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import system.Animate;
	import system.KeyInput;
	import system.Mouse;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 * class WindowGroup
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class WindowGroup {
	
		// properties
		private static var stageRef:Stage;			// reference to stage
		private static var focusWindow:Object;		// window which is currently focused
		private static var dragWindow:Object;		// window user is moving
		private static var resizeWindow:Object;		// window user is resizing
		private static var easeDragging:Boolean;	// true = apply easing to window drag
		private static var easeResizing:Boolean;	// true = apply easing to window resize
		
		// objects
		private static var windowObjects:Array;		// references to all window instances
		private static var groupBoundary:Rectangle;	// boundary area for all windows
		
		// sprites
		private static var groupContainer:Sprite;	// container for windows
		
		// constants
		private static const SNAP:Boolean = true;
		private static const SNAP_AREA:uint = 15;	// area size outside of window bounds to activate snapping
		private static const SNAP_LOCATION:uint = 5;	
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * initialize WindowGroup
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize(stageRef:Stage, boundary:Rectangle, easeDragging:Boolean = true, easeResizing:Boolean = true):Sprite {
			
			// init properties
			WindowGroup.stageRef = stageRef;
			WindowGroup.easeDragging = easeDragging;
			WindowGroup.easeResizing = easeResizing;
			WindowGroup.groupBoundary = boundary;
			
			// init objects
			dragWindow = new Object();
			resizeWindow = new Object();
			focusWindow = new Object();
			groupContainer = new Sprite();
			windowObjects = new Array();
			
			// create mouse events
			stageRef.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);		// mouse move event
			stageRef.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);		// mouse down event
			stageRef.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);			// mouse up event
			
			// create keyboard events
			stageRef.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);		// key down event
			
			return groupContainer;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * newWindow - creates new window with content. Maximize width/height or set manually
		 * @param content - displayOjbect content to load into window
		 * @param x - initial x position
		 * @param y - initial y position
		 * @param width - set manual widht of window
		 * @param height - set manual height of window
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function newWindow(content:DisplayObject, windowTitle:String, 
										 x:int, y:int, width:uint = 0, height:uint = 0, 
										 contentPadding:uint = 1, async:Boolean = false, useGroupBoundary:Boolean = true, 
										 windowBoundary:Rectangle = null):void {
			
			// maximize window to width/height of content
			if (width == 0 && height == 0) {
				width = content.width;
				height = content.height;
			}
			
			// select boundary
			var windowBoundary:Rectangle;
			if (useGroupBoundary) {
				windowBoundary = groupBoundary;
			}
			
			
			var windowClass:Window = new Window();
			var newWindow:Sprite = windowClass.createWindow(content, windowTitle, 
															x, y, width, height, contentPadding,
															true, windowBoundary, async);

			// save reference to windowObjects
			windowObjects.push(windowClass);
 
 			// add to groupContainer
			groupContainer.addChild(newWindow);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * setFocusWindow - change window focus
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function setFocusWindow(windowClass:Window):void {

			if (focusWindow.window == windowClass || !windowClass) return;
	
			// unfocus previous window
			if (focusWindow.window) {
				var unfocusWindow:Window = focusWindow.window as Window;
				unfocusWindow.changeFocus(false);
			}
			
			// save current focus to focusWindow object
			focusWindow.window = windowClass;
			focusWindow.last = windowClass;
			
			// remove windowContainer and add to top of display list			
			var windowContainer:Sprite = windowClass.getWindowContainer();
			groupContainer.removeChild(windowContainer);
			groupContainer.addChild(windowContainer);
			
			// focus window
			windowClass.changeFocus(true);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * setNextFocus - change window focus to next window in order of creation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function setNextFocus(direction:int = 1):void {
			
			// get currently focused window
			var current:Window = focusWindow.window;
			if (current) {
				// find index of focused window and focus next/previous window in array or first/last				
				var focusNumber:uint;
				for (var key:String in windowObjects) {
					if (windowObjects[key] == current) {
						if (direction == -1) {
							focusNumber = (uint(key) + -1 < 0) ? windowObjects.length - 1 : uint(key) + -1;
						} else {
							focusNumber = (uint(key) + 1 >= windowObjects.length) ? 0 : uint(key) + 1;
						}
						break;							
					}
				}
				setFocusWindow(windowObjects[focusNumber]);
			
			// if last window exists, focus it
			} else if (focusWindow.last) {
				setFocusWindow(focusWindow.last);
			
			// focus first window in windowObjects
			} else {
				setFocusWindow(windowObjects[0]);
			}
		}
				
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * setDragWindow - set reference of window object to dragWindow property
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function setDragWindow(windowClass:Window, clickX:int = 0, clickY:int = 0):void {
			
			// set dragWindow properties
			dragWindow.window = windowClass;
			dragWindow.windowContainer = windowClass.getWindowContainer();
			dragWindow.clickX = clickX;
			dragWindow.clickY = clickY;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * setResizeWindow - set reference of window object to dragWindow property
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function setResizeWindow(window:Window, resizeType:String, clickX:int = 0, clickY:int = 0):void {
			
			// set resizeWindow properties
			resizeWindow.window = window;
			resizeWindow.type = resizeType;
			resizeWindow.clickX = clickX;
			resizeWindow.clickY = clickY;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * removeWindow - remove window reference from windowObjects
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function removeWindow(window:Window):void {
			
			// interate through windowObjects and delete window reference from windowObjects array
			for (var key:String in windowObjects) {
				if (windowObjects[key] == window) {
					
					// remove from windowObjects
					windowObjects.splice(key, 1);
					
					// delete saved focusWindow references
					focusWindow.window = null;
					focusWindow.last = null;
				}
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseMoveHandler - handles MOUSE_MOVE for stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function mouseMoveHandler(event:MouseEvent):void {
			
			var windowClass:Window;
			
			/* drag window
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			if (dragWindow.window) {
				windowClass = dragWindow.window as Window;
				
				// create adjusted move point
				var movePoint:Point = new Point(event.stageX - dragWindow.clickX,
												event.stageY - dragWindow.clickY);

				// check if snapping on
				if (SNAP) {
					// check snapping and return updated x,y
					movePoint = checkSnapping(windowClass, movePoint.x, movePoint.y);
				}
				
				// move window to snapPoint
				windowClass.moveWindow(movePoint.x, movePoint.y, easeDragging)
			}
			
			/* resize window
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			if (resizeWindow.window) {
				windowClass = resizeWindow.window as Window;
				
				var newWidth:uint = event.stageX - windowClass.baseRect.x - resizeWindow.clickX;
				var newHeight:uint = event.stageY - windowClass.baseRect.y - windowClass.titleBarHeight - resizeWindow.clickY;
				
				
				// select resizing type
				switch(resizeWindow.type) {
					case "resizeRight":
						windowClass.resizeWindow(newWidth, windowClass.baseRect.height, easeResizing);
						break;
					case "resizeBottom":
						windowClass.resizeWindow(windowClass.baseRect.width, newHeight, easeResizing);
						break;
					case "resizeCorner":
						windowClass.resizeWindow(newWidth, newHeight, easeResizing);
						break;		
				}
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * checkSnapping
		 * @param windowClass - Window class reference
		 * @param x - proposed x position of window
		 * @param y - proposed y position of window
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function checkSnapping(windowClass:Window, x:int, y:int):Point {
			
			/* initliaze objects
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var snapPoint:Point = new Point(x, y);					// default snap point
			// window edge values
			var edge:int;											// size of window edge
			var edgeTotal:int;										// edgeSize * 2 for each plane
			// target bounds
			var targetBounds:Rectangle;								// bounding rectangle of target window
			var maxBounds:Rectangle;								// maximum snapping rectangle
			var minBounds:Rectangle;								// mininum snapping rectangle
			var snapBounds:Rectangle;								// bounding rectangle to snap to
			
			// windowBounds follows window strictly
			var windowBounds:Rectangle = windowClass.getWindowBounds();
			// mouseBounds 'drifts' away from window based on proposed x,y values
			var mouseBounds:Rectangle = new Rectangle(x - windowClass.edgeOffset, 
													  y - windowClass.edgeOffset, 
													  windowBounds.width, 
													  windowBounds.height);
			
			/* iterate through currently active windowObjects
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for (var key:String in windowObjects) {
				
				if (windowObjects[key] == windowClass) continue;		// skip if source is target

				edge = windowObjects[key].edgeOffset;
				edgeTotal = edge << 1;
				
				// set target bounding rectangles
				targetBounds = windowObjects[key].getWindowBounds();
					// maximum
					maxBounds = targetBounds.clone();
					maxBounds.inflate(SNAP_AREA + edge, SNAP_AREA + edge);
					// minimum
					minBounds = targetBounds.clone();
					minBounds.inflate(-SNAP_AREA, -SNAP_AREA);
					// snapping
					snapBounds = targetBounds.clone();
					snapBounds.inflate(SNAP_LOCATION + edge, SNAP_LOCATION + edge);
				
				// check if source window within snapping range
				if (windowBounds.intersects(maxBounds)) {
				
					/* opposite side
					~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
					// top
					if (mouseBounds.bottom > maxBounds.top && mouseBounds.bottom < minBounds.top) {
						snapPoint.y = snapBounds.top - windowBounds.height + edgeTotal;
					}
					// bottom
					if (mouseBounds.top < maxBounds.bottom && mouseBounds.top > minBounds.bottom) {
						snapPoint.y = snapBounds.bottom;
					}
					// left
					if (mouseBounds.right > maxBounds.left && mouseBounds.right < minBounds.left) {
						snapPoint.x = snapBounds.left - windowBounds.width + edgeTotal;
					}
					// right
					if (mouseBounds.left < maxBounds.right && mouseBounds.left > minBounds.right) {
						snapPoint.x = snapBounds.right;
					}
				
					/* same side
					~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
					// top
					if (mouseBounds.top > maxBounds.top && mouseBounds.top < minBounds.top) {
						snapPoint.y = targetBounds.top + edge;
					}
					// bottom
					if (mouseBounds.bottom < maxBounds.bottom && mouseBounds.bottom > minBounds.bottom) {
						snapPoint.y = targetBounds.bottom - windowBounds.height + edge;
					}
					// left
					if (mouseBounds.left > maxBounds.left && mouseBounds.left < minBounds.left) {
						snapPoint.x = targetBounds.left + edge;
					}
					// right
					if (mouseBounds.right < maxBounds.right && mouseBounds.right > minBounds.right) {
						snapPoint.x = targetBounds.right - windowBounds.width + edge;
					}
				}
			}
			
			return snapPoint;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseDownHandler - handles MOUSE_DOWN on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function mouseDownHandler(event:MouseEvent):void {
			
			if (event.target == stageRef) {
				// unfocus current window
				if (focusWindow.window) {
					var unfocusWindow:Window = focusWindow.window as Window;
					unfocusWindow.changeFocus(false);
					focusWindow.window = null;
				}
			}
			
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseUpHandler - handles MOUSE_UP on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function mouseUpHandler(event:MouseEvent):void {
			
			// default cursor on mouse up
			if (event.target.name != resizeWindow.type && resizeWindow.window) Mouse.defaultCursor();
			
			// stop all user interaction events on mouse up
			dragWindow.window = null;
			resizeWindow.window = null;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * keyDownHandler - handles KEY_DOWN on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function keyDownHandler(event:KeyboardEvent):void {
		
			// tab key			
			if (event.keyCode == Keyboard.TAB) {
				// Shift-Tab
				if (KeyInput.isDown(Keyboard.SHIFT)) {
					setNextFocus(-1);
				// Tab
				} else {
					setNextFocus(1);
				}
			}
		}
	}
}