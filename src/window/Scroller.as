 /*
     File:	Scroller.as
  Purpose:	
   Author:	
  Created:	July 12, 2008
   Edited:	Aug 1, 2008
    Notes:	
    
*/

package window {
	
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	// custom
	import system.*;
	import system.events.*;
	import graphics.*;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 * class Scroller
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Scroller {
		
		// scroller containers
		private var scrollerContainer:Sprite;		// contains all scroller objects
		
		// objects
		private var scrollRectContainer:Sprite;		// content container containing scrollRect property
		private var content:DisplayObject;			// content reference
		private var scrollTimer:Timer;				// timer for continuous scrolling
		
		// scroller properties
		private var windowWidth:int;				// width of content containing window
		private var windowHeight:int;				// height of content containing window
		private var yAdjust:int;					// amount to adjust y coordinate of scroller
		private var focus:Boolean;					// true - scroller has focus
		private var easing:Boolean;					// true - ease animations
		private var scrollTrackSize:uint;			// size of scroll track, used to mask scrollBar area
		private var contentScrollAmount:Point;		// amount to scroll content to a x,y point (scrollRect)
		private var activeScrollType:String;		// name of scrolling mechanism which is currently active
		
		// vertical scroller objects
		private var verticalScroller:Sprite;		// container for entire vertical scroll system
		private var verticalScrollBar:Sprite;		// vertical scroll graphic/button
		private var verticalBarOut:Bitmap;			// scrollBar bitmap (mouse out)
		private var verticalBarOver:Bitmap;			// scrollBar bitmap (mouse over)
		private var verticalBarDown:Bitmap;			// scrollBar bitmap (mouse down)
		
		private var verticalArrows:Sprite;			// contains up and down vertical arrow buttons
		private var verticalArrowUp:Sprite;			// up scroll arrow (mouse out)
		private var verticalArrowUpOver:Sprite;		// up scroll arrow (mouse over)
		private var verticalArrowUpDown:Sprite;		// up scroll arrow (mouse down)
		private var verticalArrowDown:Sprite;		// down scroll arrow (mouse out)
		private var verticalArrowDownOver:Sprite;	// down scroll arrow (mouse over)
		private var verticalArrowDownDown:Sprite;	// down scroll arrow (mouse down)
		private var verticalTrack:Sprite;			// track for scroll bar
		private var verticalTrackGraphic:Sprite;	// track graphic for verticalTrack
		
		// horizontal scroller objects
		private var horizontalScroller:Sprite;		// container for entire horizontal scroll system
		private var horizontalScrollBar:Sprite;		// horizontal scroll graphic/button
		private var horizontalBarOut:Bitmap;		// scrollBar bitmap (mouse out)
		private var horizontalBarOver:Bitmap;		// scrollBar bitmap (mouse over)
		private var horizontalBarDown:Bitmap;		// scrollBar bitmap (mouse down)
		
		private var horizontalArrows:Sprite;		// contains left and right horizontal arrow buttons
		private var horizontalArrowLeft:Sprite;		// left scroll arrow (mouse out)
		private var horizontalArrowLeftOver:Sprite;	// left scroll arrow (mouse over)
		private var horizontalArrowLeftDown:Sprite;	// left scroll arrow (mouse right)
		private var horizontalArrowRight:Sprite;	// right scroll arrow (mouse out)
		private var horizontalArrowRightOver:Sprite;// right scroll arrow (mouse over)
		private var horizontalArrowRightDown:Sprite;// right scroll arrow (mouse right)
		private var horizontalTrack:Sprite;			// track for scroll bar
		private var horizontalTrackGraphic:Sprite;	// track graphic for horizontalTrack
		
		// vertical scroller properties
		private var verticalVisible:Boolean;		// true - vertical scroller visible
		private var verticalArrowsVisible:Boolean;	// true - vertical arrows visible
		private var verticalActive:Boolean;			// true = user scrolling vertical bar
		private var verticalClick:int;				// y coordinate of mouse down on vertical scrollBar
		private var verticalScrollSize:int;			// height of vertical scrollBar
		private var verticalPosition:Number;		// current y coordinate of vertical scrollBar
		private var verticalRange:int;				// scroll range for vertical scroll
		private var verticalScrollRemaining:int;	// amount of content left to scroll (below window)
		private var verticalTrackSize:int;			// height of verticalTrack
		private var verticalScrollAdjust:uint;		// amount to adjust vertical scrollRange and scrollSizes
		private var verticalArrowAdjust:uint;
		
		// horizontal scroller properties
		private var horizontalVisible:Boolean;		// true - horizontal scroller visible
		private var horizontalArrowsVisible:Boolean;// true - horizontal arrows visible
		private var horizontalActive:Boolean;		// true = scrolling horizontal bar
		private var horizontalClick:int;			// x coordinate of mouse down on horizontal scrollBar
		private var horizontalScrollSize:int;		// width of horizontal scrollBar
		private var horizontalPosition:Number;		// current x coordinate of horizontal scrollBar
		private var horizontalRange:int;			// scroll range for horizontal scroll
		private var horizontalScrollRemaining:int;	// amount of content left to scroll (right of window)
		private var horizontalTrackSize:int;		// width of horizontalTrack
		private var horizontalScrollAdjust:uint;	// amount to adjust horizontal scrollRange and scrollSizes
		private var horizontalArrowAdjust:uint;
		
		// const properties
		private static const WHEEL_MULT:uint = 8;		// amount to multiply mouse wheel delta for moving scrollBar
		private static const TRACK_SCROLL:uint = 120;	// amount to scroll content using scroll track	
		private static const ARROW_SCROLL:uint = 20;	// amount to scroll content using arrow buttons
		private static const KEY_ARROW_SCROLL:uint = 20;// amount to scroll content using arrow keys
		private static const KEY_PAGE_SCROLL:uint = 120;// amount to scroll content using pgUp/pgDown keys
		private static const EASE_DUR:uint = 10;		// duration of easing animations
		private static const SCROLL_INTERVAL:uint = 100;// timer delay between continuous scrolling 'pulses'
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * Scroller constructor
		 * @param content - displayObject reference to content scroller controls
		 * @param windowWidth - width of window holding content
		 * @param windowHeight - height of window holding content
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Scroller(	content:DisplayObject, 
									scrollRectContainer:Sprite, 
									windowWidth:int, 
									windowHeight:int, 
									focus:Boolean = false,
									easing:Boolean = true) {
			
			// init sprites
			scrollerContainer = new Sprite();
			
			// init objects
			this.content = content;
			this.scrollRectContainer = scrollRectContainer;
			this.windowWidth = windowWidth;
			this.windowHeight = windowHeight;
			this.focus = focus;
			this.easing = easing;
			
			this.scrollTrackSize = Styles.SCROLL_SIZE + (Styles.SCROLL_PAD << 1);
			this.contentScrollAmount = new Point(0, 0);
			
			// added to stage event > initialize scrollers
			scrollerContainer.addEventListener(Event.ADDED_TO_STAGE, initializeScrollers);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getScrollerContainer - returns scrollerContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getScrollerContainer():Sprite {
			return scrollerContainer;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * initializeScrollers - creates scrollers, at this point this.stage is available
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function initializeScrollers(event:Event):void {

			// remove initialization event
			scrollerContainer.removeEventListener(Event.ADDED_TO_STAGE, initializeScrollers);
			
			// calculate scroll properties
			calculateScrollProperties(windowWidth, windowHeight);				
			calculateScrollerVisibility(true);
			// recalcuate due to cyclical dependancy on visibility properties
			calculateScrollProperties(windowWidth, windowHeight);
			
			// create vertical/horizontal scrollers
			verticalScroller = createVerticalScroller(verticalScrollSize);		
			horizontalScroller = createHorizontalScroller(horizontalScrollSize);
			
			// set scroller visibility, update properties
			updateScrollerVisibility();							
			updateScrollerProperties(windowWidth, windowHeight);				
			
			// create scroll timer
			scrollTimer = new Timer(SCROLL_INTERVAL);
			scrollTimer.addEventListener(TimerEvent.TIMER, scrollTimerHandler);
			
			// stage mouse events
			scrollerContainer.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			scrollerContainer.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			scrollerContainer.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			// stage keyboard events
			GlobalEventDispatcher.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			
			// window resized event
			GlobalEventDispatcher.addEventListener(ResizeEvent.WINDOW_RESIZED, windowResizedHandler);
			// animation update event (for scrollRect content scroll)
			scrollRectContainer.addEventListener(AnimationEvent.ANIMATION_UPDATE, animationUpdateHandler);
			
			// add to scroller
			scrollerContainer.addChild(horizontalScroller);
			scrollerContainer.addChild(verticalScroller);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * changeFocus
		 * @param focus - true/false change focus property
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function changeFocus(focus:Boolean):void{	
			this.focus = focus;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * deleteScroller - delete all scroller objects and remove event listeners
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function deleteScroller():void{	

			/* delete event listeners
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			GlobalEventDispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			GlobalEventDispatcher.removeEventListener(ResizeEvent.WINDOW_RESIZED, windowResizedHandler);

			scrollRectContainer.removeEventListener(AnimationEvent.ANIMATION_UPDATE, animationUpdateHandler);
			scrollTimer.removeEventListener(TimerEvent.TIMER, scrollTimerHandler);

			scrollerContainer.removeEventListener(Event.ADDED_TO_STAGE, initializeScrollers);
			scrollerContainer.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			scrollerContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			scrollerContainer.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			
			verticalScrollBar.removeEventListener(MouseEvent.MOUSE_OVER, verticalBarMouseOverHandler);
			verticalScrollBar.removeEventListener(MouseEvent.MOUSE_OUT, verticalBarMouseOutHandler);
			verticalScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, verticalBarMouseDownHandler);
			
			horizontalScrollBar.removeEventListener(MouseEvent.MOUSE_OVER, horizontalBarMouseOverHandler);
			horizontalScrollBar.removeEventListener(MouseEvent.MOUSE_OUT, horizontalBarMouseOutHandler);
			horizontalScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, horizontalBarMouseDownHandler);
			
			verticalArrowUp.removeEventListener(MouseEvent.MOUSE_OVER, arrowUpMouseOverHandler);
			verticalArrowUp.removeEventListener(MouseEvent.MOUSE_OUT, arrowUpMouseOutHandler);
			verticalArrowUp.removeEventListener(MouseEvent.MOUSE_DOWN, arrowUpMouseDownHandler);
			verticalArrowUp.removeEventListener(MouseEvent.MOUSE_UP, arrowUpMouseUpHandler);
			
			verticalArrowDown.removeEventListener(MouseEvent.MOUSE_OVER, arrowDownMouseOverHandler);
			verticalArrowDown.removeEventListener(MouseEvent.MOUSE_OUT, arrowDownMouseOutHandler);
			verticalArrowDown.removeEventListener(MouseEvent.MOUSE_DOWN, arrowDownMouseDownHandler);
			verticalArrowDown.removeEventListener(MouseEvent.MOUSE_UP, arrowDownMouseUpHandler);
			
			horizontalArrowLeft.removeEventListener(MouseEvent.MOUSE_OVER, arrowLeftMouseOverHandler);
			horizontalArrowLeft.removeEventListener(MouseEvent.MOUSE_OUT, arrowLeftMouseOutHandler);
			horizontalArrowLeft.removeEventListener(MouseEvent.MOUSE_DOWN, arrowLeftMouseDownHandler);
			horizontalArrowLeft.removeEventListener(MouseEvent.MOUSE_UP, arrowLeftMouseUpHandler);
			
			horizontalArrowRight.removeEventListener(MouseEvent.MOUSE_OVER, arrowRightMouseOverHandler);
			horizontalArrowRight.removeEventListener(MouseEvent.MOUSE_OUT, arrowRightMouseOutHandler);
			horizontalArrowRight.removeEventListener(MouseEvent.MOUSE_DOWN, arrowRightMouseDownHandler);
			horizontalArrowRight.removeEventListener(MouseEvent.MOUSE_UP, arrowRightMouseUpHandler);
			
			verticalTrack.removeEventListener(MouseEvent.MOUSE_OVER, verticalTrackMouseOverHandler);
			verticalTrack.removeEventListener(MouseEvent.MOUSE_OUT, verticalTrackMouseOutHandler);
			verticalTrack.removeEventListener(MouseEvent.MOUSE_DOWN, verticalTrackMouseDownHandler);
			
			horizontalTrack.removeEventListener(MouseEvent.MOUSE_OVER, horizontalTrackMouseOverHandler);
			horizontalTrack.removeEventListener(MouseEvent.MOUSE_OUT, horizontalTrackMouseOutHandler);
			horizontalTrack.removeEventListener(MouseEvent.MOUSE_DOWN, horizontalTrackMouseDownHandler);

			/* delete objects
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
			scrollerContainer = null;
			
			scrollRectContainer = null;
			content = null;
			scrollTimer = null;
			
			verticalScroller = null;
			verticalScrollBar = null;
			verticalBarOut = null;
			verticalBarOver = null;
			verticalBarDown = null;
			
			verticalArrows = null;
			verticalArrowUp = null;
			verticalArrowUpOver = null;
			verticalArrowUpDown = null;
			verticalArrowDown = null;
			verticalArrowDownOver = null;
			verticalArrowDownDown = null;
			verticalTrack = null;
			verticalTrackGraphic = null;
			
			horizontalScroller = null;
			horizontalScrollBar = null;
			horizontalBarOut = null;
			horizontalBarOver = null;
			horizontalBarDown = null;
			
			horizontalArrows = null;
			horizontalArrowLeft = null;
			horizontalArrowLeftOver = null;
			horizontalArrowLeftDown = null;
			horizontalArrowRight = null;
			horizontalArrowRightOver = null;
			horizontalArrowRightDown = null;
			horizontalTrack = null;	
			horizontalTrackGraphic = null;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * createVerticalScroller
		 * @param scrollBarHeight - height of vertical scroll bar
		 * @return verticalScroller - entire vertical scroll bar system
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function createVerticalScroller(scrollBarHeight:int):Sprite {
			
			verticalScrollBar = drawVerticalScrollBar(scrollBarHeight);		// draw vertical scroller
			verticalArrows = drawVerticalScrollArrows();					// draw vertical scroll arrows
			verticalTrack = drawVerticalTrack(verticalTrackSize);			// draw verticalTrack
				
			// add to verticalScroller
			verticalScroller = new Sprite();
			verticalScroller.addChild(verticalTrack);
			verticalScroller.addChild(verticalScrollBar);
			verticalScroller.addChild(verticalArrows);
			
			// set properties
			verticalScroller.y = Styles.SCROLL_PAD + Styles.SCROLL_SIZE + Styles.SCROLL_ARROW_PAD;
			verticalTrack.y = -Styles.SCROLL_SIZE - Styles.SCROLL_ARROW_PAD - Styles.SCROLL_PAD;
			verticalArrows.y = -Styles.SCROLL_SIZE - Styles.SCROLL_ARROW_PAD;
										
			return verticalScroller;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * createHorizontalScroller
		 * @param scrollBarWidth - width of horizontal scroll bar
		 * @return horizontalScroller - entire horizontal scroll bar system
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function createHorizontalScroller(scrollBarWidth:int):Sprite {
			
			horizontalScrollBar = drawHorizontalScrollBar(scrollBarWidth);		// draw horizontal scroller
			horizontalArrows = drawHorizontalScrollArrows();					// draw horizontal scroll arrows
			horizontalTrack = drawHorizontalTrack(horizontalTrackSize);			// draw horizontalTrack
												
			// add to horizontalScroller
			horizontalScroller = new Sprite();
			horizontalScroller.addChild(horizontalTrack);					
			horizontalScroller.addChild(horizontalScrollBar);
			horizontalScroller.addChild(horizontalArrows);
			
			// set properties
			horizontalScroller.x = Styles.SCROLL_PAD + Styles.SCROLL_SIZE + Styles.SCROLL_ARROW_PAD;
			horizontalTrack.y = -2;
			horizontalArrows.x = -Styles.SCROLL_SIZE - Styles.SCROLL_ARROW_PAD;
										
			return horizontalScroller;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawVerticalScrollBar
		 * @param scrollBarHeight - height of vertical scroll bar
		 * @return verticalScrollBar - vertical scroll bar sprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawVerticalScrollBar(scrollBarHeight:int):Sprite {
			
			// draw scroll bar (out state)
			verticalBarOut = drawScrollBar(Styles.SCROLL_SIZE, scrollBarHeight, Styles.SCROLL_BG, Styles.SCROLL_HIGHLIGHT);
			verticalBarOver = drawScrollBar(Styles.SCROLL_SIZE, scrollBarHeight, Styles.SCROLL_BG_OVER, Styles.SCROLL_HIGHLIGHT_OVER);
			verticalBarDown = drawScrollBar(Styles.SCROLL_SIZE, scrollBarHeight, Styles.SCROLL_BG_DOWN, Styles.SCROLL_HIGHLIGHT_DOWN);
			
			// set properties
			verticalBarOver.alpha = 0;
			verticalBarDown.alpha = 0;
			
			// add to scrollBar sprite
			var verticalScrollBar:Sprite = new Sprite();
			verticalScrollBar.addChild(verticalBarOut);			// child 0
			verticalScrollBar.addChild(verticalBarOver);		// child 1
			verticalScrollBar.addChild(verticalBarDown);		// child 2
			
			// verticalScrollBar mouse events
			verticalScrollBar.addEventListener(MouseEvent.MOUSE_OVER, verticalBarMouseOverHandler);		// over
			verticalScrollBar.addEventListener(MouseEvent.MOUSE_OUT, verticalBarMouseOutHandler);		// out
			verticalScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, verticalBarMouseDownHandler);		// down	
		
			return verticalScrollBar;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawHorizontalScrollBar
		 * @param scrollBarWidth - width of horizontal scroll bar
		 * @return horizontalScrollBar - horizontal scroll bar sprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawHorizontalScrollBar(scrollBarWidth:int):Sprite {
			
			// draw scroll bar (out state)
			horizontalBarOut = drawScrollBar(scrollBarWidth, Styles.SCROLL_SIZE, Styles.SCROLL_BG, Styles.SCROLL_HIGHLIGHT);
			horizontalBarOver = drawScrollBar(scrollBarWidth, Styles.SCROLL_SIZE, Styles.SCROLL_BG_OVER, Styles.SCROLL_HIGHLIGHT_OVER);
			horizontalBarDown = drawScrollBar(scrollBarWidth, Styles.SCROLL_SIZE, Styles.SCROLL_BG_DOWN, Styles.SCROLL_HIGHLIGHT_DOWN);
			
			// set properties
			horizontalBarOver.alpha = 0;
			horizontalBarDown.alpha = 0;
			
			// add to scrollBar sprite
			var horizontalScrollBar:Sprite = new Sprite();
			horizontalScrollBar.addChild(horizontalBarOut);			// child 0
			horizontalScrollBar.addChild(horizontalBarOver);		// child 1
			horizontalScrollBar.addChild(horizontalBarDown);		// child 2
			
			// horizontalScrollBar mouse events
			horizontalScrollBar.addEventListener(MouseEvent.MOUSE_OVER, horizontalBarMouseOverHandler);		// over
			horizontalScrollBar.addEventListener(MouseEvent.MOUSE_OUT, horizontalBarMouseOutHandler);		// out
			horizontalScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, horizontalBarMouseDownHandler);		// down	
		
			return horizontalScrollBar;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawVerticalScrollArrows
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawVerticalScrollArrows():Sprite {

			// create sprites			
			verticalArrows = new Sprite();
			verticalArrowUp = new Sprite();
			verticalArrowUpOver = new Sprite();
			verticalArrowUpDown = new Sprite();
			
			verticalArrowDown = new Sprite();
			verticalArrowDownOver = new Sprite();
			verticalArrowDownDown = new Sprite();
			
			// calculate arrow centering
			var centerWidth:int = Math.ceil((Styles.SCROLL_SIZE - Styles.SCROLL_ARROW_WIDTH) / 2);
			var centerHeight:int = Math.ceil((Styles.SCROLL_SIZE - Styles.SCROLL_ARROW_HEIGHT) / 2);
			
			/* draw bitmaps (out)
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var upArrowBitmap:Bitmap = Draw.drawSmallArrow("up", Styles.SCROLL_ARROW);
			var downArrowBitmap:Bitmap = Draw.drawSmallArrow("down", Styles.SCROLL_ARROW);
			
			/* draw bitmaps (over)
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var upBoxOverBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG, 1, 1, true, Styles.SCROLL_HIGHLIGHT);
			var upArrowOverBitmap:Bitmap = Draw.drawSmallArrow("up", Styles.SCROLL_ARROW_OVER);

			var downBoxOverBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG, 1, 1, true, Styles.SCROLL_HIGHLIGHT);
			var downArrowOverBitmap:Bitmap = Draw.drawSmallArrow("down", Styles.SCROLL_ARROW_OVER);

			/* draw bitmaps (down)
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var upBoxDownBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG_OVER, 1, 1, true, Styles.SCROLL_HIGHLIGHT_OVER);
			var upArrowDownBitmap:Bitmap = Draw.drawSmallArrow("up", Styles.SCROLL_ARROW_OVER);

			var downBoxDownBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG_OVER, 1, 1, true, Styles.SCROLL_HIGHLIGHT_OVER);
			var downArrowDownBitmap:Bitmap = Draw.drawSmallArrow("down", Styles.SCROLL_ARROW_OVER);

			/* set bitmap position, alpha property
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// out
			upArrowBitmap.x = centerWidth;
			upArrowBitmap.y = centerHeight;
			downArrowBitmap.x = centerWidth;
			downArrowBitmap.y = centerHeight;
			// over
			upArrowOverBitmap.x = centerWidth;
			upArrowOverBitmap.y = centerHeight;
			downArrowOverBitmap.x = centerWidth;
			downArrowOverBitmap.y = centerHeight;
			// down
			upArrowDownBitmap.x = centerWidth;
			upArrowDownBitmap.y = centerHeight;
			downArrowDownBitmap.x = centerWidth;
			downArrowDownBitmap.y = centerHeight;
			
			verticalArrowUpOver.alpha = 0;
			verticalArrowUpDown.alpha = 0;
			
			verticalArrowDownOver.alpha = 0;
			verticalArrowDownDown.alpha = 0;
			
			/* update arrow position
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			updateArrowPositions();
			
			// add assets to up arrow (out)
			verticalArrowUp.addChild(upArrowBitmap);
			verticalArrowDown.addChild(downArrowBitmap);
			
			// add assets to up arrow (over)
			verticalArrowUpOver.addChild(upBoxOverBitmap);
			verticalArrowUpOver.addChild(upArrowOverBitmap);
			verticalArrowDownOver.addChild(downBoxOverBitmap);
			verticalArrowDownOver.addChild(downArrowOverBitmap);
			
			// add assets to up arrow (down)
			verticalArrowUpDown.addChild(upBoxDownBitmap);
			verticalArrowUpDown.addChild(upArrowDownBitmap);
			verticalArrowDownDown.addChild(downBoxDownBitmap);
			verticalArrowDownDown.addChild(downArrowDownBitmap);
			
			// add to vertical arrows
			verticalArrowUp.addChild(verticalArrowUpOver);
			verticalArrowUp.addChild(verticalArrowUpDown);
			verticalArrowDown.addChild(verticalArrowDownOver);
			verticalArrowDown.addChild(verticalArrowDownDown);
			
			verticalArrows.addChild(verticalArrowUp);
			verticalArrows.addChild(verticalArrowDown);
			
			// mouse events
			verticalArrowUp.addEventListener(MouseEvent.MOUSE_OVER, arrowUpMouseOverHandler);			// over
			verticalArrowUp.addEventListener(MouseEvent.MOUSE_OUT, arrowUpMouseOutHandler);				// out
			verticalArrowUp.addEventListener(MouseEvent.MOUSE_DOWN, arrowUpMouseDownHandler);			// down
			verticalArrowUp.addEventListener(MouseEvent.MOUSE_UP, arrowUpMouseUpHandler);				// up
			
			verticalArrowDown.addEventListener(MouseEvent.MOUSE_OVER, arrowDownMouseOverHandler);		// over
			verticalArrowDown.addEventListener(MouseEvent.MOUSE_OUT, arrowDownMouseOutHandler);			// out
			verticalArrowDown.addEventListener(MouseEvent.MOUSE_DOWN, arrowDownMouseDownHandler);		// down
			verticalArrowDown.addEventListener(MouseEvent.MOUSE_UP, arrowDownMouseUpHandler);			// up
			
			return verticalArrows;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawHorizontalScrollArrows
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawHorizontalScrollArrows():Sprite {

			// create sprites			
			horizontalArrows = new Sprite();
			horizontalArrowLeft = new Sprite();
			horizontalArrowLeftOver = new Sprite();
			horizontalArrowLeftDown = new Sprite();
			
			horizontalArrowRight = new Sprite();
			horizontalArrowRightOver = new Sprite();
			horizontalArrowRightDown = new Sprite();
			
			// calculate arrow centering
			var centerWidth:int = Math.floor((Styles.SCROLL_SIZE - Styles.SCROLL_ARROW_WIDTH) / 2) + 1;
			var centerHeight:int = Math.floor((Styles.SCROLL_SIZE - Styles.SCROLL_ARROW_HEIGHT) / 2);
			
			/* draw bitmaps (out)
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var leftArrowBitmap:Bitmap = Draw.drawSmallArrow("left", Styles.SCROLL_ARROW);
			var rightArrowBitmap:Bitmap = Draw.drawSmallArrow("right", Styles.SCROLL_ARROW);
			
			/* draw bitmaps (over)
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var leftBoxOverBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG, 1, 1, true, Styles.SCROLL_HIGHLIGHT);
			var leftArrowOverBitmap:Bitmap = Draw.drawSmallArrow("left", Styles.SCROLL_ARROW_OVER);

			var rightBoxOverBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG, 1, 1, true, Styles.SCROLL_HIGHLIGHT);
			var rightArrowOverBitmap:Bitmap = Draw.drawSmallArrow("right", Styles.SCROLL_ARROW_OVER);

			/* draw bitmaps (right)
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var leftBoxRightBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG_OVER, 1, 1, true, Styles.SCROLL_HIGHLIGHT_OVER);
			var leftArrowRightBitmap:Bitmap = Draw.drawSmallArrow("left", Styles.SCROLL_ARROW_OVER);

			var rightBoxRightBitmap:Bitmap = Draw.drawRoundedBox(Styles.SCROLL_SIZE, Styles.SCROLL_SIZE, Styles.SCROLL_BG_OVER, 1, 1, true, Styles.SCROLL_HIGHLIGHT_OVER);
			var rightArrowRightBitmap:Bitmap = Draw.drawSmallArrow("right", Styles.SCROLL_ARROW_OVER);

			/* set bitmap position, alpha property
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// out
			leftArrowBitmap.x = centerWidth;
			leftArrowBitmap.y = centerHeight;
			rightArrowBitmap.x = centerWidth;
			rightArrowBitmap.y = centerHeight;
			// over
			leftArrowOverBitmap.x = centerWidth;
			leftArrowOverBitmap.y = centerHeight;
			rightArrowOverBitmap.x = centerWidth;
			rightArrowOverBitmap.y = centerHeight;
			// right
			leftArrowRightBitmap.x = centerWidth;
			leftArrowRightBitmap.y = centerHeight;
			rightArrowRightBitmap.x = centerWidth;
			rightArrowRightBitmap.y = centerHeight;
			
			horizontalArrowLeftOver.alpha = 0;
			horizontalArrowLeftDown.alpha = 0;
			
			horizontalArrowRightOver.alpha = 0;
			horizontalArrowRightDown.alpha = 0;
			
			/* leftdate arrow position
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			updateArrowPositions();
			
			// add assets to left arrow (out)
			horizontalArrowLeft.addChild(leftArrowBitmap);
			horizontalArrowRight.addChild(rightArrowBitmap);
			
			// add assets to left arrow (over)
			horizontalArrowLeftOver.addChild(leftBoxOverBitmap);
			horizontalArrowLeftOver.addChild(leftArrowOverBitmap);
			horizontalArrowRightOver.addChild(rightBoxOverBitmap);
			horizontalArrowRightOver.addChild(rightArrowOverBitmap);
			
			// add assets to left arrow (right)
			horizontalArrowLeftDown.addChild(leftBoxRightBitmap);
			horizontalArrowLeftDown.addChild(leftArrowRightBitmap);
			horizontalArrowRightDown.addChild(rightBoxRightBitmap);
			horizontalArrowRightDown.addChild(rightArrowRightBitmap);
			
			// add to horizontal arrows
			horizontalArrowLeft.addChild(horizontalArrowLeftOver);
			horizontalArrowLeft.addChild(horizontalArrowLeftDown);
			horizontalArrowRight.addChild(horizontalArrowRightOver);
			horizontalArrowRight.addChild(horizontalArrowRightDown);
			
			horizontalArrows.addChild(horizontalArrowLeft);
			horizontalArrows.addChild(horizontalArrowRight);
			
			// mouse events
			horizontalArrowLeft.addEventListener(MouseEvent.MOUSE_OVER, arrowLeftMouseOverHandler);			// over
			horizontalArrowLeft.addEventListener(MouseEvent.MOUSE_OUT, arrowLeftMouseOutHandler);				// out
			horizontalArrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, arrowLeftMouseDownHandler);			// right
			horizontalArrowLeft.addEventListener(MouseEvent.MOUSE_UP, arrowLeftMouseUpHandler);				// left
			
			horizontalArrowRight.addEventListener(MouseEvent.MOUSE_OVER, arrowRightMouseOverHandler);		// over
			horizontalArrowRight.addEventListener(MouseEvent.MOUSE_OUT, arrowRightMouseOutHandler);			// out
			horizontalArrowRight.addEventListener(MouseEvent.MOUSE_DOWN, arrowRightMouseDownHandler);		// right
			horizontalArrowRight.addEventListener(MouseEvent.MOUSE_UP, arrowRightMouseUpHandler);			// left
			
			return horizontalArrows;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawVerticalTrack
		 * @param trackHeight - height of horizontal track
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawVerticalTrack(trackHeight:uint):Sprite {
			
			// draw track
			verticalTrackGraphic = drawTrack(scrollTrackSize, trackHeight, Styles.SCROLL_TRACK);
			
			// add to vertical track
			var verticalTrack:Sprite = new Sprite();
			verticalTrack.addChild(verticalTrackGraphic);
			
			// track mouse events
			verticalTrack.addEventListener(MouseEvent.MOUSE_OVER, verticalTrackMouseOverHandler);
			verticalTrack.addEventListener(MouseEvent.MOUSE_OUT, verticalTrackMouseOutHandler);
			verticalTrack.addEventListener(MouseEvent.MOUSE_DOWN, verticalTrackMouseDownHandler);
			
			return verticalTrack;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawHorizontalTrack
		 * @param trackWidth - width of horizontal track
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawHorizontalTrack(trackWidth:uint):Sprite {
			
			// draw track
			horizontalTrackGraphic = drawTrack(trackWidth, scrollTrackSize, Styles.SCROLL_TRACK);
			
			// add to vertical track
			var horizontalTrack:Sprite = new Sprite();
			horizontalTrack.addChild(horizontalTrackGraphic);
			
			// track mouse events
			horizontalTrack.addEventListener(MouseEvent.MOUSE_OVER, horizontalTrackMouseOverHandler);
			horizontalTrack.addEventListener(MouseEvent.MOUSE_OUT, horizontalTrackMouseOutHandler);
			horizontalTrack.addEventListener(MouseEvent.MOUSE_DOWN, horizontalTrackMouseDownHandler);
			
			return horizontalTrack;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawScrollBar - draw rounded scroll bar bitmap
		 * @param width - width of scrollbar
		 * @param height - height of scrollbar
		 * @param color - scroll bar base color
		 * @param highlightColor - scroll bar highlight color
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawScrollBar(width:uint, height:uint, color:Number, highlightColor:Number):Bitmap {
			
			// draw scrollBar bitmap
			var scrollBarBitmap:Bitmap = Draw.drawRoundedBox(width, height, color, 1, 1, true, highlightColor);
			return scrollBarBitmap;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawTrack - draw rounded track bitmap
		 * @param trackWidth - width of track
		 * @param trackHeight - height of track
		 * @param color - scroll bar base color
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawTrack(width:uint, height:uint, color:Number):Sprite {
			
			// draw track bitmap
			var trackBitmap:Bitmap = Draw.drawRoundedBox(width, height, color, 1, 1);
			trackBitmap.x = -Styles.SCROLL_PAD;
			
			// add to track sprite
			var track:Sprite = new Sprite();
			track.addChild(trackBitmap);
			track.alpha = 0;
			
			return track;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * scrollVertical - scroll to position and save new verticalPosition
		 * @param scrollAmount - amount to move verticalScrollBar and corresponding content
		 * @param ease - set easing property for scrolLBar and content
		 * @param scrollByContent - calculate scroll amount by how much content to scroll
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function scrollVertical(scrollAmount:Number, ease:Boolean = false, scrollByContent:Boolean = false):void {

			// if scrolling by content amount - calculate new scrollAmount
			if (scrollByContent) {
				scrollAmount = scrollAmount / ((getContentHeight() - windowHeight) / verticalRange) + verticalPosition;
			}
			
			// restrict scroll
			if (scrollAmount > verticalRange) {
				scrollAmount = verticalRange;
			} else if (scrollAmount < 0) {
				scrollAmount = 0;
			}
			
			// calculate content scroll amount
			var scrollRatio:Number = (getContentHeight() - windowHeight) / verticalRange;
			contentScrollAmount.y = int(scrollAmount * scrollRatio);
			// scroll content
			scrollContent(scrollRectContainer, contentScrollAmount, ease);		
			
			// move scrollBar
			if (ease) {
				Animate.animatePosition(verticalScrollBar, verticalScrollBar.x, scrollAmount, false, false, EASE_DUR);
			} else {
				verticalScrollBar.y = scrollAmount;							
			}
			
			// save vertical position
			verticalPosition = scrollAmount;
		}		
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * scrollHorizontal - scroll to position and save new horizontalPosition
		 * @param scrollAmount - amount to move horizontalScrollBar and corresponding content
		 * @return scrollAmount - return corrected, final scrollAmount
		 * @param scrollByContent - calculate scroll amount by how much content to scroll
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function scrollHorizontal(scrollAmount:Number, ease:Boolean = false, scrollByContent:Boolean = false):void {

			// if scrolling by content amount - calculate new scrollAmount
			if (scrollByContent) {
				scrollAmount = scrollAmount / ((getContentWidth() - windowWidth) / horizontalRange) + horizontalPosition;
			}
			
			// restrict scroll
			if (scrollAmount > horizontalRange) {
				scrollAmount = horizontalRange;
			} else if (scrollAmount < 0) {
				scrollAmount = 0;
			}
			
			// calculate content scroll amount
			var scrollRatio:Number = (getContentWidth() - windowWidth) / horizontalRange;
			contentScrollAmount.x = int(scrollAmount * scrollRatio);
			
			scrollContent(scrollRectContainer, contentScrollAmount, ease);	// scroll content
			
			// move scrollBar
			if (ease) {
				Animate.animatePosition(horizontalScrollBar, scrollAmount, horizontalScrollBar.y, false, false, EASE_DUR);
			} else {
				horizontalScrollBar.x = scrollAmount;							
			}
			
			horizontalPosition = scrollAmount;
		}		
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * scrollContent - scroll using scrollRect property and current contentScrollAmount point object values
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function scrollContent(contentContainer:Sprite, scrollAmount:Point, ease:Boolean = false):void {	

			// restrict scrollAmount
			if (scrollAmount.x < 0) scrollAmount.x = 0;
			if (scrollAmount.y < 0) scrollAmount.y = 0;

			// scroll content
			if (ease) {
				Animate.animateGeneric(	contentContainer, 
										contentContainer.scrollRect.x,
										contentContainer.scrollRect.y,
										scrollAmount.x,
										scrollAmount.y,
										false, EASE_DUR);
			} else {
				var scrollArea:Rectangle = contentContainer.scrollRect;
				scrollArea.x = scrollAmount.x;
				scrollArea.y = scrollAmount.y;
				scrollRectContainer.scrollRect = scrollArea;
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * calculateScrollProperties
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function calculateScrollProperties(windowWidth:int, windowHeight:int):void {		

			// calculate arrow position adjustments based on arrow visibility
			if (horizontalArrowsVisible) {
				verticalArrowAdjust = (Styles.SCROLL_SIZE << 1) + (Styles.SCROLL_ARROW_PAD << 1);
			} else {
				verticalArrowAdjust = Styles.SCROLL_SIZE + (Styles.SCROLL_ARROW_PAD << 1);
			}
			
			if (verticalArrowsVisible) {
				horizontalArrowAdjust = (Styles.SCROLL_SIZE << 1) + (Styles.SCROLL_ARROW_PAD << 1);
			} else {
				horizontalArrowAdjust = Styles.SCROLL_SIZE + (Styles.SCROLL_ARROW_PAD << 1);
			}
			
			// calculate adjustment amount for scrollSize and scrollRange 
			verticalScrollAdjust = scrollTrackSize + verticalArrowAdjust;
			horizontalScrollAdjust = scrollTrackSize + horizontalArrowAdjust;

			// set scrollBar sizes
			verticalScrollSize = int((windowHeight / getContentHeight()) * windowHeight) - verticalScrollAdjust;
			horizontalScrollSize = int((windowWidth / getContentWidth()) * windowWidth) - horizontalScrollAdjust;
				// restrict scrollBar sizes
				if (verticalScrollSize < Styles.SCROLL_MINSIZE) {
					verticalScrollSize = Styles.SCROLL_MINSIZE;
				} else if (verticalScrollSize > windowHeight) {
					verticalScrollSize = windowHeight
				}
				if (horizontalScrollSize < Styles.SCROLL_MINSIZE) {
					horizontalScrollSize = Styles.SCROLL_MINSIZE;
				} else if (horizontalScrollSize > windowWidth) {
					horizontalScrollSize = windowWidth
				}
			
			// set scroll
			verticalRange = int(windowHeight - verticalScrollSize) - verticalScrollAdjust;
			horizontalRange = int(windowWidth - horizontalScrollSize) - horizontalScrollAdjust;
				// restrict scroll range, allow at least 1 pixel range to allow arrow scrolling
				verticalRange = (verticalRange <= 0) ? 1 : verticalRange;
				horizontalRange = (horizontalRange <= 0) ? 1 : horizontalRange;
			
			// set track sizes
			verticalTrackSize = windowHeight;
			horizontalTrackSize = windowWidth;
			
			// set scrollBar position based on new content view range
			verticalPosition = scrollRectContainer.scrollRect.y / ((getContentHeight() - windowHeight) / verticalRange);
			horizontalPosition = scrollRectContainer.scrollRect.x / ((getContentWidth() - windowWidth) / horizontalRange);

			// set amount of content left to scroll
			verticalScrollRemaining = getContentHeight() - windowHeight - scrollRectContainer.scrollRect.y;
			horizontalScrollRemaining = getContentWidth() - windowWidth - scrollRectContainer.scrollRect.x;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * calculateScrollerVisibility - calculate scroller visibility properties
		 * @return boolean - true = update scroller graphics visibility
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function calculateScrollerVisibility(initialize:Boolean = false):Boolean {
			
			/* scrollBar visibility calculations
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var tempVerticalVisible:Boolean = (verticalRange > 1) ? true : false;
			var tempVerticalArrowsVisible:Boolean = ((Styles.SCROLL_SIZE << 1) + scrollTrackSize < windowHeight 
													&& getContentHeight() > windowHeight
													&& scrollTrackSize < windowWidth) ? true : false;
			
			var tempHorizontalVisible:Boolean = (horizontalRange > 1 && windowHeight > scrollTrackSize) ? true : false;
			var tempHorizontalArrowsVisible:Boolean = (Styles.SCROLL_SIZE << 1 < windowWidth 
													  && getContentWidth() > windowWidth
													  && windowHeight > scrollTrackSize) ? true : false;
			
			// if both width and height is maximized override visibility status
			if (windowWidth >= getContentWidth(true) && windowHeight >= getContentHeight(true)) {
				tempVerticalVisible = false;
				tempVerticalArrowsVisible = false;
				tempHorizontalVisible = false;
				tempHorizontalArrowsVisible = false;
			}
			
			if (tempVerticalArrowsVisible != verticalArrowsVisible || 
				tempHorizontalArrowsVisible != horizontalArrowsVisible || 
				tempVerticalVisible != verticalVisible ||
				tempHorizontalVisible != horizontalVisible || initialize) {
				
				// set class properties
				verticalVisible = tempVerticalVisible;
				horizontalVisible = tempHorizontalVisible;
				verticalArrowsVisible = tempVerticalArrowsVisible;
				horizontalArrowsVisible = tempHorizontalArrowsVisible;
				
				return true;
			}
			
			return false;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateScrollerVisibility - update scroller visibility property, show/hide scrollers and dispatch event
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateScrollerVisibility():void {

			/* vertical scrollBar visibility
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// set verticalRange if visibility status is changing
			if (verticalVisible) {
				if (easing) { 
					Animate.animateAlpha(verticalScrollBar, 1, EASE_DUR); 
				} else {
					verticalScrollBar.alpha = 1;
					verticalScrollBar.visible = true; 
				}
			} else {
				Animate.stopAnimation(verticalScrollBar, "alpha");		// stop existing animation
				verticalScrollBar.alpha = 0;
				verticalScrollBar.visible = false; 
			}
			
			/* horizontal scrollBar visibility
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// set horizontalRange if visibility status is changing
			if (horizontalVisible) {
				if (easing) { 
					Animate.animateAlpha(horizontalScrollBar, 1, EASE_DUR); 
				} else { 
					horizontalScrollBar.alpha = 1;
					horizontalScrollBar.visible = true; 
					horizontalTrack.visible = true;
				}
			} else {
				Animate.stopAnimation(horizontalScrollBar, "alpha");	// stop existing animation
				horizontalScrollBar.alpha = 0;
				horizontalScrollBar.visible = false; 
				horizontalTrack.visible = false;
			}
			
			/* vertical scroll arrows visibility
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			if (verticalArrowsVisible) {
				verticalArrows.visible = true;
				verticalTrack.visible = true;
			} else {
				verticalArrows.visible = false;
				verticalTrack.visible = false;
			}
			
			/* horizontal scroll arrows visibility
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			if (horizontalArrowsVisible) {
				horizontalArrows.visible = true;
				horizontalTrack.visible = true;
			} else {
				horizontalArrows.visible = false;
				horizontalTrack.visible = false;
			}
			
			/* dispatch ScrollEvent
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			GlobalEventDispatcher.dispatchEvent(new ScrollerEvent(	ScrollerEvent.SCROLLER_VISIBLE, 
																	false, false, 
																	verticalVisible, 
																	verticalArrowsVisible,
																	horizontalVisible,
																	horizontalArrowsVisible,
																	scrollTrackSize,
																	content));
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateScrollBars - redraw scroll bar bitmaps with new scrollSize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateScrollBars():void {
			
			updateVerticalScrollBar(verticalScrollSize);		// update verticalScrollBar
			updateHorizontalScrollBar(horizontalScrollSize);	// update horizontalScrollBar
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateVerticalScrollBar
		 * @param scrollBarHeight - height of vertical scroll bar
		 * @param updateEventBitmaps - true = update mouse event scrollBar graphics
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateVerticalScrollBar(scrollBarHeight:int, updateEventBitmaps:Boolean = false):void {
			
			/* remove verticalScrollBar bitmaps
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			try {
				verticalScrollBar.removeChild(verticalBarOut);			// remove out
				
				if (updateEventBitmaps) {
					verticalScrollBar.removeChild(verticalBarOver);		// remove over
					verticalScrollBar.removeChild(verticalBarDown);		// remove down
				}
			} catch (error:Error) {}
			
			/* update bitmaps
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			verticalBarOut = drawScrollBar(Styles.SCROLL_SIZE, scrollBarHeight, Styles.SCROLL_BG, Styles.SCROLL_HIGHLIGHT);
			if (updateEventBitmaps) {
				verticalBarOver = drawScrollBar(Styles.SCROLL_SIZE, scrollBarHeight, Styles.SCROLL_BG_OVER, Styles.SCROLL_HIGHLIGHT_OVER);
				verticalBarDown = drawScrollBar(Styles.SCROLL_SIZE, scrollBarHeight, Styles.SCROLL_BG_DOWN, Styles.SCROLL_HIGHLIGHT_DOWN);
			}

			/* add verticalScrollBar bitmaps
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			verticalScrollBar.addChild(verticalBarOut);				// add out (child 0)
			
			if (updateEventBitmaps) {
				// set properties
				verticalBarOver.alpha = 0;
				verticalBarDown.alpha = 0;
				
				verticalScrollBar.addChild(verticalBarOver);		// add over (child 1)
				verticalScrollBar.addChild(verticalBarDown);		// add down (child 2)
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateHorizontalScrollBar
		 * @param scrollBarWidth - width of horizontal scroll bar
		 * @param updateEventBitmaps - true = update mouse event scrollBar graphics
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateHorizontalScrollBar(scrollBarWidth:int, updateEventBitmaps:Boolean = false):void {
			
			/* remove horizontalScrollBar bitmaps
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			try {
				horizontalScrollBar.removeChild(horizontalBarOut);			// remove out
				
				if (updateEventBitmaps) {
					horizontalScrollBar.removeChild(horizontalBarOver);		// remove over
					horizontalScrollBar.removeChild(horizontalBarDown);		// remove down
				}
			} catch (error:Error) {}
			
			/* update bitmaps
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			horizontalBarOut = drawScrollBar(scrollBarWidth, Styles.SCROLL_SIZE, Styles.SCROLL_BG, Styles.SCROLL_HIGHLIGHT);
			if (updateEventBitmaps) {
				horizontalBarOver = drawScrollBar(scrollBarWidth, Styles.SCROLL_SIZE, Styles.SCROLL_BG_OVER, Styles.SCROLL_HIGHLIGHT_OVER);
				horizontalBarDown = drawScrollBar(scrollBarWidth, Styles.SCROLL_SIZE, Styles.SCROLL_BG_DOWN, Styles.SCROLL_HIGHLIGHT_DOWN);
			}

			/* add horizontalScrollBar bitmaps
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			horizontalScrollBar.addChild(horizontalBarOut);				// add out (child 0)
			
			if (updateEventBitmaps) {
				// set properties
				horizontalBarOver.alpha = 0;
				horizontalBarDown.alpha = 0;
				
				horizontalScrollBar.addChild(horizontalBarOver);		// add over (child 1)
				horizontalScrollBar.addChild(horizontalBarDown);		// add down (child 2)
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateScrollTracks - redraw scroll track bitmaps
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateScrollTracks():void {
			
			/* update vertical track
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			if (verticalArrowsVisible) {
				try {
					verticalTrack.removeChild(verticalTrackGraphic);
				} catch (error:Error) {}
				
				verticalTrackGraphic = drawTrack(scrollTrackSize, verticalTrackSize, Styles.SCROLL_TRACK);
				verticalTrack.addChild(verticalTrackGraphic);
			}
			
			/* update horizontal track
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			if (horizontalVisible) {
				try {
					horizontalTrack.removeChild(horizontalTrackGraphic);
				} catch (error:Error) {}
				
				horizontalTrackGraphic = drawTrack(horizontalTrackSize, scrollTrackSize, Styles.SCROLL_TRACK);
				horizontalTrack.addChild(horizontalTrackGraphic);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateScrollerProperties - updates scroller position, scroll arrow buttons, and other properties
		 * @param windowWidth - new windowWidth
		 * @param windowHeight - new windowHeight
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateScrollerProperties(windowWidth:int, windowHeight:int):void {
			
			/* reposition vertical scrollBar
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			verticalScroller.x = windowWidth - Styles.SCROLL_SIZE - Styles.SCROLL_PAD;
			verticalScrollBar.y = verticalPosition;
			// pull content down if nothing left to scroll
			if (verticalScrollRemaining < 0 && scrollRectContainer.scrollRect.y > 0) {
				scrollVertical(verticalPosition);
			}
			
			/* reposition horizontal scrollBar
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			horizontalScroller.y = windowHeight - Styles.SCROLL_SIZE - Styles.SCROLL_PAD;
			horizontalScrollBar.x = horizontalPosition;
			// pull content right if nothing left to scroll
			if (horizontalScrollRemaining < 0 && scrollRectContainer.scrollRect.x > 0) {
				scrollHorizontal(horizontalPosition);
			}
			
			/* reposition scroller arrows
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			updateArrowPositions();
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * updateArrowPositions - updates scroller arrow positions
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateArrowPositions():void {

			// update right arrow
			try {
				verticalArrowDown.y = windowHeight - verticalArrowAdjust;
			} catch (error:Error) {}
			
			// update left arrow
			try {
				horizontalArrowRight.x = windowWidth - horizontalArrowAdjust;
			} catch (error:Error) {}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getContentWidth - returns width of content
		 * @param unmodified - get content width unmodified by scrollTrackSize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getContentWidth(unmodified:Boolean = false):Number {
			var contentWidth:int = (content.x << 1) + content.width;
			return ((verticalVisible || verticalArrowsVisible)  && !unmodified) ? contentWidth + scrollTrackSize : contentWidth;
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * getContentHeight - returns height of content
		 * @param unmodified - get content height unmodified by scrollTrackSize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getContentHeight(unmodified:Boolean = false):Number {
			var contentHeight:int = (content.y << 1) + content.height;
			return (horizontalVisible && !unmodified) ? contentHeight + scrollTrackSize : contentHeight;
		}
		
		
		/*=====================================================================================
			EVENT HANDLERS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * animationUpdateHandler - handles ANIMATION_UPDATES from content scroll animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function animationUpdateHandler(event:AnimationEvent):void {

			// scroll content
			var scrollArea:Rectangle = scrollRectContainer.scrollRect;
			scrollArea.x = event.a;
			scrollArea.y = event.b;
			scrollRectContainer.scrollRect = scrollArea;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * windowResizedHandler
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function windowResizedHandler(event:ResizeEvent):void {
			
			if (event.referenceObject != this.content) return;
			
			// update window width/height
			this.windowWidth = event.windowWidth;
			this.windowHeight = event.windowHeight;
			
			/* update scrollers
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			calculateScrollProperties(windowWidth, windowHeight);	// update scroll properties
			var update:Boolean = calculateScrollerVisibility();		// calculate visibility 
			if (update) updateScrollerVisibility();					// change scroller visibility 
			updateScrollBars();										// redraw scrollBars
			updateScrollTracks();									// redraw scrollTrack
			updateScrollerProperties(windowWidth, windowHeight);	// reposition scroll bars
		}	
		
		/*	MOUSE STAGE EVENTS
		======================================================================================= */		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseMoveHandler - handles MOUSE_MOVE on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function mouseMoveHandler(event:MouseEvent):void {

			// scroll vertical
			if (verticalActive) {
				
				// convert global mouse position to relative position of verticalScroller
				var localVertical:Point = verticalScroller.globalToLocal(new Point(event.stageX, event.stageY));
				// scroll vertical
				scrollVertical(localVertical.y - verticalClick, easing);
			
			// scroll horizontal
			} else if (horizontalActive) {

				// convert global mouse position to relative position of horizontalScroller
				var localHorizontal:Point = horizontalScroller.globalToLocal(new Point(event.stageX, event.stageY));
				// scroll horizontal
				scrollHorizontal(localHorizontal.x - horizontalClick, easing);
			}
		}	
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseWheelHandler - handles MOUSE_WHEEL on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function mouseWheelHandler(event:MouseEvent):void {
			
			// calculate scroll amount (check LeftMousePress, prevents mouse scroll while resizing)
			if (!event.buttonDown && focus) {
				scrollVertical((-event.delta * WHEEL_MULT), easing, true);	// scroll vertical
			}
		}	
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * mouseUpHandler - handles MOUSE_UP on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function mouseUpHandler(event:MouseEvent):void {
			
			// hide scrollBar mouse over/down graphics
			if (event.target != verticalScrollBar) 
				Animate.animateAlpha(verticalBarOver, 0, 10);	// hide over bar (vertical)
			if (event.target != horizontalScrollBar) 
				Animate.animateAlpha(horizontalBarOver, 0, 10);	// hide over bar (horizontal)

			// hide scrollBar MOUSE_DOWN
			if (verticalActive)	Animate.animateAlpha(verticalBarDown, 0, 10);		// hide down bar (vertical)
			if (horizontalActive) Animate.animateAlpha(horizontalBarDown, 0, 10);	// hide down bar (horizontal)

			// stop all scrolling
			verticalActive = false;
			horizontalActive = false;
			activeScrollType = null;
			
			// stop and reset scrollTimer
			scrollTimer.stop();
			scrollTimer.reset();
		}	
		
		/*	KEYBOARD STAGE EVENTS
		======================================================================================= */		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * keyDownHandler - handles KEY_DOWN on stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function keyDownHandler(event:KeyboardEvent):void {
				
				if (!focus) return;
				
				// scrolling keys
				switch (event.keyCode) {
					case Keyboard.UP:
						scrollVertical(-KEY_ARROW_SCROLL, easing, true); break;
					
					case Keyboard.DOWN:
						scrollVertical(KEY_ARROW_SCROLL, easing, true); break;
					 
					case Keyboard.LEFT:
						scrollHorizontal(-KEY_ARROW_SCROLL, easing, true); break;
					
					case Keyboard.RIGHT:
						scrollHorizontal(KEY_ARROW_SCROLL, easing, true); break;

					case Keyboard.PAGE_UP:
						scrollVertical(-KEY_PAGE_SCROLL, easing, true); break;
					
					case Keyboard.PAGE_DOWN:
						scrollVertical(KEY_PAGE_SCROLL, easing, true); break;
					
					case Keyboard.HOME:
						scrollVertical(-20, easing); 
						break;
					
					case Keyboard.END:
						scrollVertical(verticalRange, easing); 
						break;
				}
		}
		
		
		/*	VERTICAL BAR EVENTS
		======================================================================================= */		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * verticalBarMouseOverHandler - handles MOUSE_OVER on verticalScrollBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function verticalBarMouseOverHandler(event:MouseEvent):void {
			
			if (!event.buttonDown) {
				updateVerticalScrollBar(verticalScrollSize, true);	// update mouse event scrollBar graphics
				Animate.animateAlpha(verticalBarOver, 1, 10);		// show over bar
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * verticalBarMouseOutHandler - handles MOUSE_OUT on verticalScrollBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function verticalBarMouseOutHandler(event:MouseEvent):void {
			
			if (!event.buttonDown) {
				Animate.animateAlpha(verticalBarOver, 0, 10);	// hide over bar
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * verticalBarMouseDownHandler - handles MOUSE_DOWN on verticalScrollBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function verticalBarMouseDownHandler(event:MouseEvent):void {
			
			activeScrollType = "bar_vertical";
			verticalActive = true;							// activate vertical scrolling
			verticalClick = event.localY;					// set y click position
			Animate.animateAlpha(verticalBarDown, 1, 10);	// show down bar
		}
		
		/*	HORIZONTAL BAR EVENTS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * horizontalBarMouseOverHandler - handles MOUSE_OVER on horizontalScrollBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function horizontalBarMouseOverHandler(event:MouseEvent):void {
			
			if (!event.buttonDown) {
				updateHorizontalScrollBar(horizontalScrollSize, true);	// update mouse event scrollBar graphics
				Animate.animateAlpha(horizontalBarOver, 1, 10);			// show over bar
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * horizontalBarMouseOutHandler - handles MOUSE_OUT on horizontalScrollBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function horizontalBarMouseOutHandler(event:MouseEvent):void {
			
			if (!event.buttonDown) {
				Animate.animateAlpha(horizontalBarOver, 0, 10);	// hide over bar
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * horizontalBarMouseDownHandler - handles MOUSE_DOWN on horizontalScrollBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function horizontalBarMouseDownHandler(event:MouseEvent):void {
			
			activeScrollType = "bar_horizontal";
			horizontalActive = true;							// activate horizontal scrolling
			horizontalClick = event.localX;						// set x click position
			Animate.animateAlpha(horizontalBarDown, 1, 10);		// show down bar
		}


		/*	VERTICAL ARROW UP EVENTS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowUpMouseOverHandler - handles MOUSE_OVER on verticalArrowUp
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowUpMouseOverHandler(event:MouseEvent):void {
			
			if (!verticalActive && !horizontalActive) {
				if (activeScrollType == "arrow_up") scrollTimer.start();
				Animate.animateAlpha(verticalArrowUpOver, 1, EASE_DUR);
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowUpMouseOutHandler - handles MOUSE_OUT on verticalArrowUp
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowUpMouseOutHandler(event:MouseEvent):void {
			
			// pause continuous scroll timer
			scrollTimer.stop();
			
			Animate.animateAlpha(verticalArrowUpOver, 0, EASE_DUR, "easeOut", 0, null, null, false, false);
			verticalArrowUpDown.alpha = 0;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowUpMouseDownHandler - handles MOUSE_DOWN on verticalArrowUp
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowUpMouseDownHandler(event:MouseEvent):void {
			
			// start continuous scroll timer, set scrollType
			activeScrollType = "arrow_up";
			scrollTimer.start();
			
			// scroll vertical
			scrollVertical(-ARROW_SCROLL, easing, true);
			verticalArrowUpDown.alpha = 1;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowUpMouseUpHandler - handles MOUSE_UP on verticalArrowUp
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowUpMouseUpHandler(event:MouseEvent):void {
			
			verticalArrowUpDown.alpha = 0;
		}

		/*	VERTICAL ARROW DOWN EVENTS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowDownMouseOverHandler - handles MOUSE_OVER on verticalArrowDown
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowDownMouseOverHandler(event:MouseEvent):void {
			
			if (!verticalActive && !horizontalActive) {
				if (activeScrollType == "arrow_down") scrollTimer.start();
				Animate.animateAlpha(verticalArrowDownOver, 1, EASE_DUR);
			}
			
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowDownMouseOutHandler - handles MOUSE_OUT on verticalArrowDown
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowDownMouseOutHandler(event:MouseEvent):void {
			
			// pause continuous scroll timer
			scrollTimer.stop();
			
			Animate.animateAlpha(verticalArrowDownOver, 0, EASE_DUR, "easeOut", 0, null, null, false, false);
			verticalArrowDownDown.alpha = 0;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowDownMouseDownHandler - handles MOUSE_DOWN on verticalArrowDown
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowDownMouseDownHandler(event:MouseEvent):void {
			
			// start continuous scroll timer, set scrollType
			activeScrollType = "arrow_down";
			scrollTimer.start();
			
			// scroll vertical
			scrollVertical(ARROW_SCROLL, easing, true);
			verticalArrowDownDown.alpha = 1;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowDownMouseUpHandler - handles MOUSE_UP on verticalArrowUp
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowDownMouseUpHandler(event:MouseEvent):void {
			
			verticalArrowDownDown.alpha = 0;
		}


		/*	HORIZONTAL ARROW LEFT EVENTS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowLeftMouseOverHandler - handles MOUSE_OVER on horizontalArrowLeft
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowLeftMouseOverHandler(event:MouseEvent):void {
			
			if (!verticalActive && !horizontalActive) {
				if (activeScrollType == "arrow_left") scrollTimer.start();
				Animate.animateAlpha(horizontalArrowLeftOver, 1, EASE_DUR);
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowLeftMouseOutHandler - handles MOUSE_OUT on horizontalArrowLeft
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowLeftMouseOutHandler(event:MouseEvent):void {
			
			// pause continuous scroll timer
			scrollTimer.stop();
			
			Animate.animateAlpha(horizontalArrowLeftOver, 0, EASE_DUR, "easeOut", 0, null, null, false, false);
			horizontalArrowLeftDown.alpha = 0;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowLeftMouseRightHandler - handles MOUSE_DOWN on horizontalArrowLeft
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowLeftMouseDownHandler(event:MouseEvent):void {
			
			// start continuous scroll timer, set scrollType
			activeScrollType = "arrow_left";
			scrollTimer.start();
			
			// scroll horizontal
			scrollHorizontal(-ARROW_SCROLL, easing, true);
			horizontalArrowLeftDown.alpha = 1;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowLeftMouseLeftHandler - handles MOUSE_UP on horizontalArrowLeft
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowLeftMouseUpHandler(event:MouseEvent):void {
			
			horizontalArrowLeftDown.alpha = 0;
		}

		/*	HORIZONTAL ARROW RIGHT EVENTS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowRightMouseOverHandler - handles MOUSE_OVER on horizontalArrowRight
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowRightMouseOverHandler(event:MouseEvent):void {
			
			if (!verticalActive && !horizontalActive) {
				if (activeScrollType == "arrow_right") scrollTimer.start();
				Animate.animateAlpha(horizontalArrowRightOver, 1, EASE_DUR);
			}
			
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowRightMouseOutHandler - handles MOUSE_OUT on horizontalArrowRight
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowRightMouseOutHandler(event:MouseEvent):void {
			
			// pause continuous scroll timer
			scrollTimer.stop();
			
			Animate.animateAlpha(horizontalArrowRightOver, 0, EASE_DUR, "easeOut", 0, null, null, false, false);
			horizontalArrowRightDown.alpha = 0;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowRightMouseRightHandler - handles MOUSE_DOWN on horizontalArrowRight
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowRightMouseDownHandler(event:MouseEvent):void {
			
			// start continuous scroll timer, set scrollType
			activeScrollType = "arrow_right";
			scrollTimer.start();
			
			// scroll horizontal
			scrollHorizontal(ARROW_SCROLL, easing, true);
			horizontalArrowRightDown.alpha = 1;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * arrowRightMouseLeftHandler - handles MOUSE_UP on horizontalArrowLeft
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function arrowRightMouseUpHandler(event:MouseEvent):void {
			
			horizontalArrowRightDown.alpha = 0;
		}

		/*	VERTICAL TRACK EVENTS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * verticalTrackMouseOverHandler - handles MOUSE_OVER on verticalTrack
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function verticalTrackMouseOverHandler(event:MouseEvent):void {

		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * verticalTrackMouseOutHandler - handles MOUSE_OVER on verticalTrack
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function verticalTrackMouseOutHandler(event:MouseEvent):void {
			
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * verticalTrackMouseDownHandler - handles MOUSE_DOWN on verticalTrack
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function verticalTrackMouseDownHandler(event:MouseEvent):void {
			
			var hitAdjust:uint = Styles.SCROLL_SIZE + Styles.SCROLL_PAD;
			var click:uint = event.localY - hitAdjust;
			
			// abort track scrolling if click found above/below arrow scroll area
			if (event.localY <= hitAdjust || event.localY >= verticalTrackSize - hitAdjust) return;

			// scroll up (above scrollBar)
			if (click < verticalPosition) {
				scrollVertical(-TRACK_SCROLL, easing, true);
			
			// scroll down (below scrollBar)
			} else if (click > verticalPosition + verticalScrollSize) {
				scrollVertical(TRACK_SCROLL, easing, true);
			}
		}
		
		/*	HORIZONTAL TRACK EVENTS
		======================================================================================= */
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * horizontalTrackMouseOverHandler - handles MOUSE_OVER on horizontalTrack
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function horizontalTrackMouseOverHandler(event:MouseEvent):void {
			
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * horizontalTrackMouseOutHandler - handles MOUSE_OVER on horizontalTrack
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function horizontalTrackMouseOutHandler(event:MouseEvent):void {
			
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * horizontalTrackMouseDownHandler - handles MOUSE_DOWN on horizontalTrack
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function horizontalTrackMouseDownHandler(event:MouseEvent):void {
			
			var hitAdjust:uint = 0;
			var click:uint = event.localX - hitAdjust;
			
			// abort track scrolling if click found above/below arrow scroll area
			if (event.localX <= hitAdjust || event.localX >= horizontalTrackSize - hitAdjust) return;

			// scroll up (above scrollBar)
			if (click < horizontalPosition) {
				scrollHorizontal(-TRACK_SCROLL, easing, true);
			
			// scroll down (below scrollBar)
			} else if (click > horizontalPosition + horizontalScrollSize) {
				scrollHorizontal(TRACK_SCROLL, easing, true);
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * scrollTimerHandler - handles TIMER events for scrollTimer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function scrollTimerHandler(event:TimerEvent):void {
			
			if (scrollTimer.currentCount < 3) return;
			
			switch(activeScrollType) {
				case "arrow_up": 
					scrollVertical(-ARROW_SCROLL, easing, true); break;
				case "arrow_down":
					scrollVertical(ARROW_SCROLL, easing, true); break;
				case "arrow_left": 
					scrollHorizontal(-ARROW_SCROLL, easing, true); break;
				case "arrow_right":
					scrollHorizontal(ARROW_SCROLL, easing, true); break;
				case "track_up":
				
				case "track_down":
				
			}
			
		}
	}
}