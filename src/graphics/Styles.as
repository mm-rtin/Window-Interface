/*
     File:	Styles.as
 Revision:	0.2.0
  Purpose:	
  Authors:	
  Created:	June 29, 2008
   Edited:	June 29, 2008
    Notes:	
Functions:

*/

package graphics {

	import flash.text.StyleSheet;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Styles
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Styles {
		
		/* embed font assets
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    	[Embed(source="..\\..\\embed\\fonts\\FFF Hero.ttf", fontName="PixelBody", mimeType="application/x-font-truetype")]
    	private static var PixelBodyFont:Class;
    	
    	[Embed(source="..\\..\\embed\\fonts\\FFF Bionic.ttf", fontName="PixelHeavy", mimeType="application/x-font-truetype")]
    	private static var PixelHeavyFont:Class;
    	
    	[Embed(source="..\\..\\embed\\fonts\\FFF Museum.ttf", fontName="PixelHeavyWide", mimeType="application/x-font-truetype")]
    	private static var PixelHeavyWideFont:Class;

		// styles
		private static var global:StyleSheet;
		private static var content:StyleSheet;
		
		/* graphic styles constants
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		// window
		public static const WINDOW_BG:Number = 0xe7fbf9;
			
		// border
		public static const WINDOW_BORDER_SIZE:uint = 2;
		public static const WINDOW_BORDER:Number = 0x5EA6C1;
		//edge
		public static const WINDOW_EDGE_SIZE:uint = 4;
		public static const WINDOW_EDGE:Number = 0xffffff;
		public static const WINDOW_EDGE_OVER:Number = 0xa8ff00;
		public static const WINDOW_EDGE_FOCUS:Number = 0xd6ff88;
		// outline
		public static const WINDOW_OUTLINE_SIZE:uint = 1;
		public static const WINDOW_OUTLINE:Number = 0x244249;
			
		public static const WINDOW_SHADOW:Number = 0x1d353b;
		public static const WINDOW_SHADOW_ALPHA:Number = .4;
		public static const WINDOW_SHADOW_SIZE:int = -6;				// for proper shadow:
		public static const WINDOW_SHADOW_DISTANCE:uint = 9;			// -SIZE + DISTANCE is > 0
		public static const WINDOW_GLOW1:Number = 0xcbe2e8;
		public static const WINDOW_GLOW2:Number = 0xd9eff1;
		public static const WINDOW_ALPHA:Number = .8;
		public static const WINDOW_MIN_WIDTH:uint = 40;
		public static const WINDOW_MIN_HEIGHT:uint = 0;
		
		// titleBar
		public static const TITLEBAR_BG:Number = 0xD8F0F5;
		public static const TITLEBAR_BORDER:Number = 0x5EA6C1;
		public static const TITLEBAR_GLOW1:Number = 0xeffcff;
		public static const TITLEBAR_GLOW2:Number = 0xdff5fa;
		public static const TITLEBAR_ALPHA:Number = .75;
		public static const TITLEBAR_HEIGHT:uint = 26;
		
		// scrollbar
		public static const SCROLL_BG:Number = 0x5ea6c1;
		public static const SCROLL_BG_OVER:Number = 0x6e9a22;
		public static const SCROLL_BG_DOWN:Number = 0xd58c00;
		public static const	SCROLL_HIGHLIGHT:Number = 0x8fc1d4;
		public static const	SCROLL_HIGHLIGHT_OVER:Number = 0x9ab865;
		public static const	SCROLL_HIGHLIGHT_DOWN:Number = 0xe2c04d;		
		public static const	SCROLL_SIZE:uint = 13;						// width of bar in vertical scroll bar
		public static const	SCROLL_PAD:uint = 2;						// distance from window edge top/bottom
		public static const SCROLL_MINSIZE:uint = 15; 					// minimum height in vertical scroll bar
		public static const SCROLL_TRACK:Number = 0xe7fbf9;
		public static const SCROLL_ARROW:Number = 0x5ea6c1;
		public static const SCROLL_ARROW_OVER:Number = 0xffffff;
		public static const SCROLL_ARROW_WIDTH:uint = 5;
		public static const SCROLL_ARROW_HEIGHT:uint = 4;
		public static const	SCROLL_ARROW_PAD:uint = 2;					// distance from scroll bars and scroll arrows
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initialize - create interface stylesheet and visual style properties
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize():void {
			
			/** global styles
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// body
			var body:Object = new Object();
			body.fontFamily = "PixelBody";
			body.fontSize = "8";
			body.leading = "5";
			body.color = "#000000";
			
			// h1 (window title)
			var h1:Object = new Object();
			h1.fontFamily = "PixelHeavyWide";
			h1.fontSize = "8";
			h1.leading = "0";
			h1.color = "#4a8398";
			
			/* apply global styles
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			Styles.global = new StyleSheet();
			Styles.global.setStyle("body", body);
			Styles.global.setStyle("h1", h1);
			
			
			
			
			/** content styles
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// body
			var body:Object = new Object();
			body.fontFamily = "PixelBody";
			body.fontSize = "8";
			body.leading = "5";
			body.color = "#000000";
			
			// h1 (window title)
			var h1:Object = new Object();
			h1.fontFamily = "PixelHeavyWide";
			h1.fontSize = "8";
			h1.leading = "0";
			h1.color = "#4a8398";
			
			
			/* apply content styles
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			Styles.content = new StyleSheet();
			Styles.content.setStyle("body", body);
			Styles.content.setStyle("h1", h1);

		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getStyle: return stylesheet, default = global
		@param stylesheet - stylesheet to return
		~~~~~~~~~~~~~~~~~~~s~~~~~~~~~~*/
		public static function getStyle(stylesheet:String = "global"):StyleSheet {
			return Styles[stylesheet];
		}
	}
}