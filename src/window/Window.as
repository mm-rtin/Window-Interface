/*
     File:	window.as
  Purpose:	
   Author:	
  Created:	June 26, 2008
   Edited:	Aug 1, 2008
    Notes:	Internal class in the Window package
    
*/

package window {
	
	import data.ContentLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import graphics.*;
	
	import system.*;
	import system.events.*;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 * class Window
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	internal class Window {
	
		// classes
		private var scroller:Scroller;
		
		// window public properties
		public var windowWidth:uint;					// actual window graphics width
		public var windowHeight:uint;					// actual window graphics height
		public var titleBarHeight:uint;					// height of titleBar
		public var edgeOffset:int;						// total offset size of 1 side of a window edge
		public var shadowOffset:int;					// total space occupied by window drop shadow
		public var focus:Boolean;						// true = window is currently focused
		public var windowAnimations:Boolean;			// true = animate certain window functions
		
		// window objects
		public var baseRect:Rectangle;					// rectangle bounds for calculating window graphics	
		public var renderRect:Rectangle;				// actual rendered window bounds after drawing
		public var windowBoundary:Rectangle;			// boundary rectangle to constrain window within
		private var contentLoader:ContentLoader;
		
		// window private properties
		private var contentPadding:uint;				// amount to pad between window border and content
		private var windowTitleReservedWidth:int;		// total windowTitle footprint in titleBar
		private var verticalScrollReservedWidth:int;	// total width reserved by verticalScroller
		private var horizontalScrollReservedHeight:int;	// total height reserved by verticalScroller
		private var titleBarMouseClickPoint:Point;		// point object of coordinates mouse has been pressed on titleBar
		
		// containers
		private var windowContainer:Sprite;				// container for entire window
		private var windowGraphicsContainer:Sprite;		// holds graphic elements of window
		private var windowElementsContainer:Sprite;		// holds non-changing elements of window
		private var scrollerContainer:Sprite;			// holds scroller
		private var contentContainer:Sprite;			// holds content DisplayObject
		
		// window sprites
		private var windowBox:Sprite;					// main window area graphic		
		private var titleBar:Sprite;					// top titleBar - drag handle and holding window Buttons
		private var windowTitleText:TextField;			// window title text field
		
		private var windowButtons:Sprite;				// contains window function buttons
			private var closeIcon:Sprite;				// close icon (container)
			private var closeImageOver:Bitmap;			// close button (over)
			private var closeImageFocus:Bitmap;			// close button (focus)
			
			private var maximizeIcon:Sprite;			// maximize icon (container)
			private var maximizeImageOver:Bitmap;		// maximize button (over)
			
			private var minimizeIcon:Sprite;			// minimize icon (container)
			private var minimizeImageOver:Bitmap;		// minimize button (over)
		
		// resizeArea sprites
		private var resizeAreas:Sprite;					// holds all window resizing mouse handles
			private var rightHitArea:Sprite;			// right side of window (horizontal)
			private var bottomHitArea:Sprite;			// bottom side of window (vertical)
			private var cornerHitArea:Sprite;			// bottom-right corner (vertical & horizontal)
		
		// content reference
		private var content:DisplayObject;
		
		// contants
		private static const MAX_BITMAP_SIZE:uint = 2870;
		private static const WINDOW_BUTTONS_PAD:uint = 3;
		private static const ICON_PAD:uint = 2;		
		private static const HIT_SIZE_PAD:uint = 15;
		private static const EASE_DUR:uint = 10;
				
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * Window constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Window() {

		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * createWindow
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function createWindow(content:DisplayObject, windowTitle:String,
									 x:int, y:int, width:uint = 0, height:uint = 0, 
									 contentPadding:uint = 1, windowAnimations:Boolean = true,
									 windowBoundary:Rectangle = null, async = false):Sprite {
			
			/* init properties
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			this.content = content;
			this.contentPadding = contentPadding;
			this.windowAnimations = windowAnimations;
			this.titleBarHeight = Styles.TITLEBAR_HEIGHT - Styles.WINDOW_BORDER_SIZE;
			this.windowBoundary = windowBoundary;

			/* init objects
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			this.baseRect = new Rectangle(x, y, width, height);
			this.titleBarMouseClickPoint = new Point();
			
			// if asynchronous loading, cast content as ContentLoader and set completeFunction
			if (async) {
				contentLoader = content as ContentLoader;
				contentLoader.completeFunction = this.updateWindowSize;
			}
			
			/* init sprites
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			windowContainer = new Sprite();
			windowContainer.x = x;
			windowContainer.y = y;
			
			windowGraphicsContainer = new Sprite();
			windowElementsContainer = new Sprite();
			windowElementsContainer.mouseEnabled = false;
			
			contentContainer = new Sprite();
			contentContainer.cacheAsBitmap = true;
			
			/* draw window graphic elements
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			drawWindowGraphics(windowGraphicsContainer, baseRect.width, baseRect.height);

			/* draw interface elements
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// resizeAreas sprite - mouse hit area for resizing window
			resizeAreas = drawResizeHitZones(baseRect.width, baseRect.height + titleBarHeight, Styles.WINDOW_EDGE_SIZE);
			// window title text
			windowTitleText = Text.drawTextField(windowTitle, "global", "h1", false);
			windowTitleText.mouseEnabled = false;
			windowTitleText.x = 5;
			windowTitleText.y = int((titleBarHeight >> 1) - (windowTitleText.height >> 1)) - Styles.WINDOW_BORDER_SIZE;
			// create window buttons
			windowButtons = drawWindowButtons();
			// calculate windowTitle footprint
			windowTitleReservedWidth = windowTitleText.width + windowTitleText.x + windowButtons.width + (WINDOW_BUTTONS_PAD << 1);
			
			/* draw content
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			contentContainer.scrollRect = new Rectangle(0, 0, baseRect.width, baseRect.height);
			contentContainer.x = 0;
			contentContainer.y = titleBarHeight;
			// content padding
			content.x = contentPadding;
			content.y = contentPadding;
			
			/* draw scroller
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			scroller = new Scroller(content, contentContainer, baseRect.width, baseRect.height);
			scrollerContainer = scroller.getScrollerContainer();
			scrollerContainer.x = 0;
			scrollerContainer.y = titleBarHeight;
			
			// add scroller event
			GlobalEventDispatcher.addEventListener(ScrollerEvent.SCROLLER_VISIBLE, scrollerVisibilityChangeHandler);
			
			/* add to display list
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// window elements container
			windowElementsContainer.addChild(windowTitleText);		// child 0
			windowElementsContainer.addChild(windowButtons);		// child 1
			windowElementsContainer.addChild(scrollerContainer);	// child 2
			windowElementsContainer.addChild(resizeAreas);			// child 3
			// window container
			windowContainer.addChild(windowGraphicsContainer);		// graphics (child 0)
			windowContainer.addChild(contentContainer);				// content  (child 2)
			windowContainer.addChild(windowElementsContainer);		// elements (child 1)
			// content container
			contentContainer.addChild(content);
			
			// window mouse events
			windowContainer.addEventListener(MouseEvent.MOUSE_OVER, windowMouseOverHandler);
			windowContainer.addEventListener(MouseEvent.MOUSE_OUT, windowMouseOutHandler);
			windowContainer.addEventListener(MouseEvent.MOUSE_DOWN, windowMouseDownHandler);
			
			// window animation events
			windowContainer.addEventListener(AnimationEvent.ANIMATION_UPDATE, resizeAnimationUpdateHandler);
			
			return windowContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getWindowContainer - returns windowContainer sprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getWindowContainer():Sprite {
			return windowContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getWindowBounds - returns bounding rectangle for window graphics
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getWindowBounds():Rectangle {

			// to create accurate bounding rect, subtract edge space and ignore shadow for window size
			var bounds:Rectangle = new Rectangle(baseRect.x - edgeOffset, 
												 baseRect.y - edgeOffset, 
												 windowGraphicsContainer.width - shadowOffset, 
												 windowGraphicsContainer.height - shadowOffset);
			return bounds;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * moveWindow - move window by setting new x, y coordinates for windowContainer
		 * @param x - new x coordinate
		 * @param y - new y coordinate
		 * @param ease - true = ease move animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function moveWindow(x:int, y:int, ease:Boolean = false):void {
			
			// constrain window within boundary box
			var movePoint:Point = constrainToBoundary(x, y);
			
			// update x,y properties
			baseRect.x = movePoint.x;
			baseRect.y = movePoint.y;
			
			if (ease) {
				// animate window position - easing
				Animate.animatePosition(windowContainer, movePoint.x, movePoint.y, false, true, EASE_DUR, "easeOutExpo");
			} else {
				windowContainer.x = movePoint.x;
				windowContainer.y = movePoint.y;
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * maximizeWindow - maximize window to content width/height
		 * @param ease - true = animate maximize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function maximizeWindow(ease:Boolean = false):void {
			
			resizeWindow(getContentWidth(), getContentHeight(), ease);
		}	
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * minimizeWindow - minimize window to show titleBar only
		 * @param ease = animate minimize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function minimizeWindow(ease:Boolean = false):void {
			
			resizeWindow(baseRect.width, 0, ease);
		}	
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * closeWindow - hide window from view, closing animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function closeWindow():void {
			
			// remove window from window group
			WindowGroup.removeWindow(this);
			
			// window closing animation
			Animate.animateAlpha(scrollerContainer, 0, 10, "easeOut", 0);
			Animate.animateAlpha(contentContainer, 0, 10, "easeOut", 2);
			Animate.animateAlpha(windowButtons, 0, 10, "easeOut", 5);
			Animate.animateAlpha(windowContainer, 0, 15, "easeOut", 5, deleteWindow);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * deleteWindow - delete all window objects and remove event listeners
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function deleteWindow():void {
			
			// delete scroller
			scroller.deleteScroller();
			
			/* delete event listeners
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			GlobalEventDispatcher.removeEventListener(ScrollerEvent.SCROLLER_VISIBLE, scrollerVisibilityChangeHandler);
			
			windowContainer.removeEventListener(MouseEvent.MOUSE_OVER, windowMouseOverHandler);
			windowContainer.removeEventListener(MouseEvent.MOUSE_OUT, windowMouseOutHandler);
			windowContainer.removeEventListener(MouseEvent.MOUSE_DOWN, windowMouseDownHandler);
			windowContainer.removeEventListener(AnimationEvent.ANIMATION_UPDATE, resizeAnimationUpdateHandler);
			
			titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, titleBarMouseDownHandler);
			titleBar.removeEventListener(MouseEvent.DOUBLE_CLICK, titleBarMouseDoubleClickHandler);
			
			resizeAreas.removeEventListener(MouseEvent.MOUSE_OVER, resizeMouseOverHandler);
			resizeAreas.removeEventListener(MouseEvent.MOUSE_DOWN, resizeMouseDownHandler);
			resizeAreas.removeEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler);	
			
			closeIcon.removeEventListener(MouseEvent.MOUSE_OVER, closeButtonMouseOverHandler);
			closeIcon.removeEventListener(MouseEvent.MOUSE_OUT, closeButtonMouseOutHandler);
			closeIcon.removeEventListener(MouseEvent.CLICK, closeButtonMouseClickHandler);
			
			maximizeIcon.removeEventListener(MouseEvent.MOUSE_OVER, maximizeButtonMouseOverHandler);
			maximizeIcon.removeEventListener(MouseEvent.MOUSE_OUT, maximizeButtonMouseOutHandler);
			maximizeIcon.removeEventListener(MouseEvent.CLICK, maximizeButtonMouseClickHandler);
			
			minimizeIcon.removeEventListener(MouseEvent.MOUSE_OVER, minimizeButtonMouseOverHandler);
			minimizeIcon.removeEventListener(MouseEvent.MOUSE_OUT, minimizeButtonMouseOutHandler);
			minimizeIcon.removeEventListener(MouseEvent.CLICK, minimizeButtonMouseClickHandler);
			
			/* delete objects
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/		
			windowContainer = null;
			windowGraphicsContainer = null;
			windowElementsContainer = null;
			scrollerContainer = null;
			contentContainer = null;
			
			// window sprites
			windowBox = null;
			titleBar = null;
			windowTitleText = null;
			
			windowButtons = null;
			closeImageOver = null;
			closeImageFocus = null;
			maximizeImageOver = null;
			minimizeImageOver = null;
			
			// resizeArea sprites
			resizeAreas = null;					
			rightHitArea = null;
			bottomHitArea = null;
			cornerHitArea = null;
			
			// content reference
			content = null;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * changeFocus - remove focus from window
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function changeFocus(focus:Boolean):void {
			
			// update focus
			this.focus = focus;
			
			// update window graphics, close button
			if (focus) {
				drawWindowGraphics(windowGraphicsContainer, baseRect.width, baseRect.height, "focus");
				Animate.animateAlpha(closeImageFocus, 1);
			} else {
				drawWindowGraphics(windowGraphicsContainer, baseRect.width, baseRect.height, "out");
				Animate.animateAlpha(closeImageFocus, 0);
			}

			// add/remove focus from scroller	
			scroller.changeFocus(focus);	
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateWindowSize - update window size by calling resizeWindow with current parameters
		 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function updateWindowSize():void {
			resizeWindow(this.windowWidth, this.windowHeight, true);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * resizeWindow - resize window by redrawing bitmap elements to new size
		 * @param width - new width
		 * @param height - new height
		 * @param ease - true = animate resizing
		 * @note - ineficient to access Styles properties excessively
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function resizeWindow(width:int, height:int, ease:Boolean = false):void {
			
			// animate resize
			if (ease) {
				Animate.animateGeneric(windowContainer, baseRect.width, baseRect.height, width, height, false, EASE_DUR, "easeOutExpo");
				return;
			}
			
			// restrict window size
			width = restrictWidth(width, verticalScrollReservedWidth);
			height = restrictHeight(height, horizontalScrollReservedHeight);
			
			// constrain window within boundary box
			var sizePoint:Point = constrainToBoundary(width, height, true);
			
			// update baseRect.width, baseRect.height
			baseRect.width = sizePoint.x;
			baseRect.height = sizePoint.y;

			// dispatch ResizeEvent
			GlobalEventDispatcher.dispatchEvent(new ResizeEvent(ResizeEvent.WINDOW_RESIZED, false, false, baseRect.width, baseRect.height, content));
								
			/* redraw window graphics
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var windowStyle:String = (focus) ? "focus" : "out";
			drawWindowGraphics(windowGraphicsContainer, baseRect.width, baseRect.height, windowStyle);
			
			/* resize resizeAreas
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var resizeWidth:uint = baseRect.width;
			var resizeHeight:uint = baseRect.height + titleBarHeight;
			
 			rightHitArea.x = resizeWidth;
 			rightHitArea.height = resizeHeight;
 			
 			bottomHitArea.y = resizeHeight;
 			bottomHitArea.width = resizeWidth;
 			
 			cornerHitArea.x = resizeWidth;
 			cornerHitArea.y = resizeHeight;	
 			
 			/* position/resize interface elements
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// reposition windowButtons
			windowButtons.x = baseRect.width - windowButtons.width - WINDOW_BUTTONS_PAD;
			// resize content container scrollMask
			resizeScrollRect(baseRect.width - verticalScrollReservedWidth, baseRect.height - horizontalScrollReservedHeight);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * constrainToBoundary - constrain x,y values to within groupBoundary rectangle
		 * @param x - proposed x value
		 * @param y - proposed y value
		 * @param sizeMode - true = select boundry type based on resizing
		 * @param mouseMode - true = only restrict mouse point to boundry, allows window area to cross boundry
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function constrainToBoundary(x:int, y:int, sizeMode:Boolean = false, mouseMode:Boolean = true):Point {
			
			/* initliaze objects / properties
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var constrainPoint:Point = new Point(x, y);
			var edgeTotal:uint = edgeOffset << 1;
			var mousePoint:Point = Mouse.getMousePoint();
			
			var positionBoundary:Rectangle;
			var top:int;
			var bottom:int;
			var left:int;
			var right:int;
			
			// create windowBounds
			var windowBounds:Rectangle = getWindowBounds();

			if (sizeMode) {
				windowBounds = new Rectangle(windowBounds.x, windowBounds.y, x + edgeTotal, y + edgeTotal + titleBarHeight);
			} else {
				windowBounds = new Rectangle(x - edgeOffset, y - edgeOffset, windowBounds.width, windowBounds.height);
			}
			
			// select boundry mode (window area or mouse)
			if (mouseMode && !sizeMode) {
				positionBoundary = new Rectangle(mousePoint.x, mousePoint.y, 0, 0);
				top = -titleBarMouseClickPoint.y;
				left = -titleBarMouseClickPoint.x;
				bottom =  windowBoundary.bottom - titleBarMouseClickPoint.y;
				right =  windowBoundary.right - titleBarMouseClickPoint.x;
			} else {
				positionBoundary = windowBounds;
				top = windowBoundary.top + edgeOffset;
				left = windowBoundary.left + edgeOffset;
				
				if (sizeMode) {
					var heightAdjust:int = (windowBoundary.top - windowBounds.top > 0) ? windowBoundary.top - windowBounds.top : 0;
					var widthAdjust:int = (windowBoundary.left - windowBounds.left > 0) ? windowBoundary.left - windowBounds.left : 0;
					bottom = windowBoundary.intersection(windowBounds).height + heightAdjust - edgeTotal - titleBarHeight;
					right = windowBoundary.intersection(windowBounds).width + widthAdjust - edgeTotal;
				} else {
					bottom = windowBoundary.bottom - windowBounds.height + edgeOffset;
					right = windowBoundary.right - windowBounds.width + edgeOffset;
				}
			}
			
			/* constrain to windowBoundary
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// top
			if (positionBoundary.top < windowBoundary.top && !sizeMode) {
				constrainPoint.y = top;
			// bottom
			} else if (positionBoundary.bottom > windowBoundary.bottom) {
				constrainPoint.y = bottom;
			}
			
			// left
			if (positionBoundary.left < windowBoundary.left && !sizeMode) {
				constrainPoint.x = left;
			// right
			} else if (positionBoundary.right > windowBoundary.right) {
				constrainPoint.x = right;
			}
			
			return constrainPoint;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawWindowGraphics - returns windowContainer sprite
		 * @param target - container sprite to draw window graphics
		 * @param width - width of window area
		 * @param height - height of window area
		 * @param style - graphics style
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawWindowGraphics(target:Sprite, width:uint, height:uint, style:String = null):void {
			
			// select edge style
			var edgeColor:Number;
			switch (style) {
				case "over":
					edgeColor = Styles.WINDOW_EDGE_OVER; break;
				case "focus":
					edgeColor = Styles.WINDOW_EDGE_FOCUS; break;
				default:
					edgeColor = Styles.WINDOW_EDGE; break;
			}
			
			// remove existing window elements
			try {
				target.removeChild(windowBox);
				target.removeChild(titleBar);
			} catch (error:Error) {}

			/* resize window elements
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			titleBar = drawTitleBar(width, 
									Styles.TITLEBAR_HEIGHT, 
									Styles.TITLEBAR_BG, 
									Styles.TITLEBAR_BORDER, 
									Styles.TITLEBAR_GLOW1, 
									Styles.TITLEBAR_GLOW2,
									Styles.TITLEBAR_ALPHA,
									Styles.WINDOW_BORDER_SIZE);
				
			windowBox = drawWindow(width,
									height + titleBarHeight,
									Styles.WINDOW_BG, 
									Styles.WINDOW_BORDER,
									edgeColor,
									Styles.WINDOW_OUTLINE,
									Styles.WINDOW_SHADOW,
									Styles.WINDOW_SHADOW_ALPHA,
									Styles.WINDOW_GLOW1,
									Styles.WINDOW_GLOW2,
									Styles.WINDOW_BORDER_SIZE,
									Styles.WINDOW_EDGE_SIZE,
									Styles.WINDOW_OUTLINE_SIZE,
									Styles.WINDOW_SHADOW_SIZE,
									Styles.WINDOW_SHADOW_DISTANCE);
			
			// add new resized window elements
			target.addChild(windowBox);
			target.addChild(titleBar);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawWindow - draws window main area graphic
		 * @param width - width of window area
		 * @param height - height of window area
		 * @return window - bitmap sprite of window
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawWindow(width:uint, 
									height:uint,
									boxColor:Number,
									borderColor:Number,
									edgeColor:Number,
									outlineColor:Number,
									shadowColor:Number,
									shadowAlpha:Number,
									glowColor1:Number,
									glowColor2:Number,
									borderSize:uint,
									edgeSize:uint,
									outlineSize:uint,
									shadowSize:int,
									shadowDistance:uint):Sprite {
			
			// save public property edgeOffset 
			edgeOffset = borderSize + edgeSize + outlineSize;
			
			// due to negative nature of shadowSize, make sure total shadow is > 0
			if (shadowDistance + shadowSize > 0) {
				shadowOffset = shadowDistance + shadowSize;
			} else {
				shadowSize = 0;
				shadowDistance = 0;
				shadowOffset = 0;
			}
			
			var boxWidth:uint = width + (edgeOffset << 1);
			var boxHeight:uint = height + (edgeOffset << 1);
			
			var edgeWidth:uint = boxWidth - (outlineSize << 1);
			var edgeHeight:uint = boxHeight - (outlineSize << 1);
			
			var borderWidth:uint = edgeWidth - (edgeSize << 1);
			var borderHeight:uint = edgeHeight - (edgeSize << 1);
			
			var bodyWidth:uint = borderWidth - (borderSize << 1);
			var bodyHeight:uint = borderHeight - (borderSize << 1);
			
			// save window actual height/width
			windowWidth = boxWidth + shadowSize + shadowDistance;
			windowHeight = boxHeight + shadowSize + shadowDistance;

			var box:BitmapData = new BitmapData(windowWidth, windowHeight, true, 0x0);
			
			// shadow
			Draw.drawFilledRectangle(box, shadowDistance, shadowDistance, 
									 width + (edgeOffset << 1) + shadowSize, 
									 height + (edgeOffset << 1) + shadowSize, 
									 2, shadowColor, shadowAlpha);	
			// outline
			Draw.drawOutline(box, 0, 0, boxWidth, boxHeight, outlineSize, 2, outlineColor, .5);
			// edge
			Draw.drawOutline(box, outlineSize, outlineSize, 
							 edgeWidth, edgeHeight, edgeSize, 2, edgeColor, 1);
			// border
			Draw.drawOutline(box, outlineSize + edgeSize, outlineSize + edgeSize, 
							 borderWidth, borderHeight, borderSize, 1, borderColor, 1);
			// box fill
			Draw.drawFilledRectangle(box, outlineSize + edgeSize + borderSize,
										  outlineSize + edgeSize + borderSize,
										  bodyWidth,
										  bodyHeight, 1, boxColor, 1);
			// glow
			if (height > titleBarHeight + 2) {
				Draw.drawOutline(box, edgeOffset, edgeOffset + titleBarHeight,
								 	  bodyWidth, bodyHeight - titleBarHeight, 
								 	  1, 1, glowColor1, 1);
				
				Draw.drawOutline(box, edgeOffset + 1, edgeOffset + titleBarHeight + 1,
								 	  bodyWidth - 2, bodyHeight - titleBarHeight - 2, 
								 	  1, 1, glowColor2, 1);
			}
			
			
			var boxBitmap:Bitmap = new Bitmap(box);
			boxBitmap.x = -edgeOffset;
			boxBitmap.y = -edgeOffset;
			
			var windowBox:Sprite = new Sprite();
			windowBox.addChild(boxBitmap);
			return windowBox;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawTitleBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawTitleBar(width:int, 
									  height:int,
									  boxColor:Number,
									  borderColor:Number,
									  glowColor1:Number,
									  glowColor2:Number,
									  alpha:Number,
									  borderSize:uint):Sprite {

			var boxWidth:uint = width + (borderSize << 1);
			
			var box:BitmapData = new BitmapData(boxWidth, height, true, 0x00000000);
			
			// border
			Draw.drawOutline(box, 0, 0, boxWidth, height, borderSize, 1, borderColor, 1);
			// box fill
			Draw.drawFilledRectangle(box, borderSize, borderSize, width, height - (borderSize << 1), 1, boxColor, 1);
			// glow
			Draw.drawOutline(box, borderSize, borderSize, width, height - (borderSize << 1), 1, 1, glowColor1, 1);
			Draw.drawOutline(box, borderSize + 1, borderSize + 1, width - 2, height - (borderSize << 1) - 2, 1, 1, glowColor2, 1);
			
			var boxBitmap:Bitmap = new Bitmap(box);
			boxBitmap.x = -borderSize;
			boxBitmap.y = -borderSize;
			
			var titleBar:Sprite = new Sprite();
			titleBar.addChild(boxBitmap);
			
			// title bar mouse events
			titleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarMouseDownHandler, false, 0, true);
			titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, titleBarMouseDoubleClickHandler, false, 0, true);
			
			return titleBar;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawResizeHitZones - draw resize mouse hit areas for extending window to the right and bottom
		 * @param width - new width
		 * @param height - new height
		 * @param hitSize - size of hit area
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawResizeHitZones(width:int, height:int, hitSize:uint):Sprite {
			
			var resizeAreas:Sprite = new Sprite();
			
			// increase hitSize by PAD AMOUNT
			hitSize = hitSize + HIT_SIZE_PAD;
			
			// right hit stripe
			rightHitArea = new Sprite();
			rightHitArea.name = "resizeRight";
			rightHitArea.graphics.beginFill(0x000000, 0);
			rightHitArea.graphics.drawRect(0, 0, hitSize, height);
			rightHitArea.graphics.endFill();
			rightHitArea.x = width;
			
			// bottom hit stripe
			bottomHitArea = new Sprite();
			bottomHitArea.name = "resizeBottom";
			bottomHitArea.graphics.beginFill(0x000000, 0);
			bottomHitArea.graphics.drawRect(0, 0, width, hitSize);
			bottomHitArea.graphics.endFill();
			bottomHitArea.y = height;
			
			// corner hit area
			cornerHitArea = new Sprite();
			cornerHitArea.name = "resizeCorner";
			cornerHitArea.graphics.beginFill(0x000000, 0);
			cornerHitArea.graphics.drawRect(0, 0, hitSize, hitSize);
			cornerHitArea.graphics.endFill();
			cornerHitArea.x = width;
			cornerHitArea.y = height;
			
			// add to resizeAreas
			resizeAreas.addChild(rightHitArea);
			resizeAreas.addChild(bottomHitArea);
			resizeAreas.addChild(cornerHitArea);
			
			// mouse events
			resizeAreas.addEventListener(MouseEvent.MOUSE_OVER, resizeMouseOverHandler);	// resize over
			resizeAreas.addEventListener(MouseEvent.MOUSE_DOWN, resizeMouseDownHandler);	// resize down
			resizeAreas.addEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler);		// resize up
			
			return resizeAreas;
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawWindowButtons - draw window button icons and add mouse events
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawWindowButtons():Sprite {
		
			// create sprites
			windowButtons = new Sprite();		
			closeIcon = new Sprite();
			maximizeIcon = new Sprite();
			minimizeIcon = new Sprite();
						
			// draw minimize button
			var minimizeImage:Bitmap = Draw.getBitmap("minimizeIcon");
			minimizeImageOver = Draw.getBitmap("minimizeIconOver");
			minimizeImageOver.alpha = 0;
			minimizeIcon.addChild(minimizeImage);
			minimizeIcon.addChild(minimizeImageOver);
			
			// draw maximize button
			var maximizeImage:Bitmap = Draw.getBitmap("maximizeIcon");
			maximizeImageOver = Draw.getBitmap("maximizeIconOver");
			maximizeImageOver.alpha = 0;
			maximizeIcon.x = minimizeIcon.width + ICON_PAD;
			maximizeIcon.addChild(maximizeImage);
			maximizeIcon.addChild(maximizeImageOver);
			
			// draw close button
			var closeImage:Bitmap = Draw.getBitmap("closeIcon");
			closeImageFocus = Draw.getBitmap("closeIconFocus");
			closeImageOver = Draw.getBitmap("closeIconOver");
			closeImageFocus.alpha = 0;
			closeImageOver.alpha = 0;
			closeIcon.x = minimizeIcon.width + maximizeIcon.width + (ICON_PAD << 1);
			closeIcon.addChild(closeImage);
			closeIcon.addChild(closeImageFocus);
			closeIcon.addChild(closeImageOver);
			
			// add to windowButtons
			windowButtons.addChild(closeIcon);
			windowButtons.addChild(maximizeIcon);
			windowButtons.addChild(minimizeIcon);

			// position windowButtons			
			windowButtons.y = int((titleBarHeight >> 1) - (windowButtons.height >> 1)) - 1;
			windowButtons.x = baseRect.width - windowButtons.width - WINDOW_BUTTONS_PAD;
			windowButtons.mouseEnabled = true;
			
			// close mouse events
			closeIcon.addEventListener(MouseEvent.MOUSE_OVER, closeButtonMouseOverHandler, false, 0, true);
			closeIcon.addEventListener(MouseEvent.MOUSE_OUT, closeButtonMouseOutHandler, false, 0, true);
			closeIcon.addEventListener(MouseEvent.CLICK, closeButtonMouseClickHandler, false, 0, true);
			// maximize mouse events
			maximizeIcon.addEventListener(MouseEvent.MOUSE_OVER, maximizeButtonMouseOverHandler, false, 0, true);
			maximizeIcon.addEventListener(MouseEvent.MOUSE_OUT, maximizeButtonMouseOutHandler, false, 0, true);
			maximizeIcon.addEventListener(MouseEvent.CLICK, maximizeButtonMouseClickHandler, false, 0, true);
			// minimize mouse events
			minimizeIcon.addEventListener(MouseEvent.MOUSE_OVER, minimizeButtonMouseOverHandler, false, 0, true);
			minimizeIcon.addEventListener(MouseEvent.MOUSE_OUT, minimizeButtonMouseOutHandler, false, 0, true);
			minimizeIcon.addEventListener(MouseEvent.CLICK, minimizeButtonMouseClickHandler, false, 0, true);
			
			return windowButtons;
		}
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * resizeScrollRect - resizes scrollContainer scrollRect property adjusting for scrollBar visibility
		 * @param width - new scrollRect width
		 * @param height - new scrollRect height
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function resizeScrollRect(width:int, height:int):void {
			
			// resize content scrollRect
			var viewArea:Rectangle = contentContainer.scrollRect;
			viewArea.width = width;
			viewArea.height = height;
			contentContainer.scrollRect = viewArea;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * restrictWidth - restricts width to minimum or maxium values as defined
		 * @param width - new window width
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function restrictWidth(width:int, verticalScrollReservedWidth:int = 0):int {
			
			// restrict width
			if (width < Styles.WINDOW_MIN_WIDTH || width < windowTitleReservedWidth) {
				width = (Styles.WINDOW_MIN_WIDTH > windowTitleReservedWidth) ? Styles.WINDOW_MIN_WIDTH : windowTitleReservedWidth;
			} else if (width > getContentWidth() + verticalScrollReservedWidth) {
				width = getContentWidth() + verticalScrollReservedWidth;
			} else if (width + (windowWidth - baseRect.width) > MAX_BITMAP_SIZE) {
				width = MAX_BITMAP_SIZE - (windowWidth - baseRect.width);
			}
			
			return width;
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * restrictHeight - restricts height to minimum or maxium values as defined
		 * @param height - new window height
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function restrictHeight(height:int, horizontalScrollReservedHeight:int = 0):int {
			
			// restrict height
			if (height < Styles.WINDOW_MIN_HEIGHT) {
				height = Styles.WINDOW_MIN_HEIGHT;
			} else if (height > getContentHeight() + horizontalScrollReservedHeight) {
				height = getContentHeight() + horizontalScrollReservedHeight;
			} else if (height + (windowHeight - baseRect.height) > MAX_BITMAP_SIZE) {
				height = MAX_BITMAP_SIZE - (windowHeight - baseRect.height);
			}
			
			return height;
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getContentWidth - returns width of content
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getContentWidth():Number {
			return (contentPadding << 1) + content.width;
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getContentHeight - returns height of content
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getContentHeight():Number {
			return (contentPadding << 1) + content.height;
		}


		/*=====================================================================================
			EVENT HANDLERS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * windowMouseOverHandler - handles MOUSE_OVER event for windowContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function windowMouseOverHandler(event:MouseEvent):void {
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * windowMouseOutHandler - handles MOUSE_OUT event for windowContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function windowMouseOutHandler(event:MouseEvent):void {
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * windowMouseDownHandler - handles MOUSE_DOWN event for windowContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function windowMouseDownHandler(event:MouseEvent):void {
			
			// set new focus 
			WindowGroup.setFocusWindow(this);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * titleBarMouseDownHandler - handles MOUSE_DOWN event for titleBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function titleBarMouseDownHandler(event:MouseEvent):void {

			// save click coordinates on titleBar
			titleBarMouseClickPoint.x = event.localX;
			titleBarMouseClickPoint.y = event.localY;
			
			// set new window to drag
			WindowGroup.setDragWindow(this, event.localX, event.localY);		
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * titleBarMouseDoubleClickHandler - handles DOUBLE_CLICK event for titleBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function titleBarMouseDoubleClickHandler(event:MouseEvent):void {
			// minimize window
			minimizeWindow();
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * resizeMouseOverHandler - handles MOUSE_OVER event for window resize outline
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function resizeMouseOverHandler(event:MouseEvent):void {
			
			// custom cursor
			if (!event.buttonDown) {
				switch(event.target.name) {
					case "resizeRight":
						Mouse.setCursor(Mouse.resizeHorizontalCursor);
						break;
					case "resizeBottom":
						Mouse.setCursor(Mouse.resizeVericalCursor);
						break;
					case "resizeCorner":
						Mouse.setCursor(Mouse.resizeCornerCursor);
						break;		
				}
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * resizeMouseDownHandler - handles MOUSE_DOWN event for window resize outline
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function resizeMouseDownHandler(event:MouseEvent):void {
			// resize type
			WindowGroup.setResizeWindow(this, event.target.name, event.localX, event.localY);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * resizeMouseUpHandler - handles MOUSE_UP event for window resize outline
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function resizeMouseUpHandler(event:MouseEvent):void {
			
			// custom cursor
			switch(event.target.name) {
				case "resizeRight":
					Mouse.setCursor(Mouse.resizeHorizontalCursor);
					break;
				case "resizeBottom":
					Mouse.setCursor(Mouse.resizeVericalCursor);
					break;
				case "resizeCorner":
					Mouse.setCursor(Mouse.resizeCornerCursor);
					break;		
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * scrollerVisibilityChangeHandler - handles SCROLLER_VISIBLE event for scroller
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function scrollerVisibilityChangeHandler(event:ScrollerEvent):void {
			
			if (event.referenceObject != content) return;

			/* // set reserved scroller sizes - used to adjust content scrollRect area
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// vertical
			if (event.verticalVisible || event.verticalArrowsVisible) {
				verticalScrollReservedWidth = event.reservedScrollerSize;
			} else {
				verticalScrollReservedWidth = 0; }
				
			// horizontal
			if (event.horizontalVisible || event.horizontalArrowsVisible) {
				horizontalScrollReservedHeight = event.reservedScrollerSize;
			} else {
				horizontalScrollReservedHeight = 0; }
			
			// resize content container scrollMask
			resizeScrollRect(baseRect.width - verticalScrollReservedWidth, baseRect.height - horizontalScrollReservedHeight);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * resizeAnimationUpdateHandler - handles ANIMATION_UPDATES for resizeWindow animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function resizeAnimationUpdateHandler(event:AnimationEvent):void {
			// animate window resize
			resizeWindow(event.a, event.b, false);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * closeButtonMouseOverHandler - handles MOUSE_OVER event for closeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function closeButtonMouseOverHandler(event:MouseEvent):void {
			Animate.animateAlpha(closeImageOver, 1);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * closeButtonMouseOutHandler - handles MOUSE_OUT event for closeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function closeButtonMouseOutHandler(event:MouseEvent):void {
			Animate.animateAlpha(closeImageOver, 0);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * closeButtonMouseClickHandler - handles CLICK event for closeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function closeButtonMouseClickHandler(event:MouseEvent):void {
			closeWindow();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * maximizeButtonMouseOverHandler - handles MOUSE_OVER event for maximizeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function maximizeButtonMouseOverHandler(event:MouseEvent):void {
			Animate.animateAlpha(maximizeImageOver, 1);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * maximizeButtonMouseOutHandler - handles MOUSE_OUT event for maximizeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function maximizeButtonMouseOutHandler(event:MouseEvent):void {
			Animate.animateAlpha(maximizeImageOver, 0);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * maximizeButtonMouseClickHandler - handles CLICK event for maximizeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function maximizeButtonMouseClickHandler(event:MouseEvent):void {
			maximizeWindow(windowAnimations);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * minimizeButtonMouseOverHandler - handles MOUSE_OVER event for minimizeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function minimizeButtonMouseOverHandler(event:MouseEvent):void {
			Animate.animateAlpha(minimizeImageOver, 1);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * minimizeButtonMouseOutHandler - handles MOUSE_OUT event for minimizeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function minimizeButtonMouseOutHandler(event:MouseEvent):void {
			Animate.animateAlpha(minimizeImageOver, 0);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * minimizeButtonMouseClickHandler - handles CLICK event for minimizeIcon
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function minimizeButtonMouseClickHandler(event:MouseEvent):void {
			minimizeWindow(windowAnimations);
		}
	}
}