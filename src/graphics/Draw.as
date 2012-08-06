/*
     File:	Draw.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	June 29, 2008
   Edited:	June 29, 2008
    Notes:	
Functions:

*/

package graphics {
	
	import flash.geom.*;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Draw
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Draw {

		// embed media assets
		[Embed(source="..\\..\\embed\\graphics\\close_icon.gif", mimeType="image/gif")]
    	private static var closeImage:Class;
   		[Embed(source="..\\..\\embed\\graphics\\close_icon_focus.gif", mimeType="image/gif")]
    	private static var closeImageFocus:Class;
   		[Embed(source="..\\..\\embed\\graphics\\close_icon_over.gif", mimeType="image/gif")]
    	private static var closeImageOver:Class;
    	 	
		[Embed(source="..\\..\\embed\\graphics\\maximize_icon.gif", mimeType="image/gif")]
    	private static var maximizeImage:Class;
   		[Embed(source="..\\..\\embed\\graphics\\maximize_icon_over.gif", mimeType="image/gif")]
    	private static var maximizeImageOver:Class;
    	
		[Embed(source="..\\..\\embed\\graphics\\minimize_icon.gif", mimeType="image/gif")]
		private static var minimizeImage:Class;
   		[Embed(source="..\\..\\embed\\graphics\\minimize_icon_over.gif", mimeType="image/gif")]
    	private static var minimizeImageOver:Class;
    	
  		[Embed(source="..\\..\\embed\\graphics\\resize_horizontal.png", mimeType="image/png")]
    	private static var resizeHorizontalImage:Class;
    	
  		[Embed(source="..\\..\\embed\\graphics\\resize_vertical.png", mimeType="image/png")]
    	private static var resizeVerticalImage:Class;
    	
  		[Embed(source="..\\..\\embed\\graphics\\resize_corner.png", mimeType="image/png")]
    	private static var resizeCornerImage:Class;
    	
    	// embed media bitmaps
    	private static var closeIcon:Bitmap;
    	private static var closeIconFocus:Bitmap;
    	private static var closeIconOver:Bitmap;
    	
    	private static var maximizeIcon:Bitmap;
    	private static var maximizeIconOver:Bitmap;
    	
    	private static var minimizeIcon:Bitmap;
    	private static var minimizeIconOver:Bitmap;
    	
    	private static var resizeHorizontal:Bitmap;
    	private static var resizeVertical:Bitmap;
    	private static var resizeCorner:Bitmap;
    	
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initialize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize():void {
			
			/* create bitmaps
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// icons
			closeIcon = new Draw.closeImage();
			closeIconOver = new Draw.closeImageOver();
			closeIconFocus = new Draw.closeImageFocus();
			
			maximizeIcon = new Draw.maximizeImage();
			maximizeIconOver = new Draw.maximizeImageOver();
			
			minimizeIcon = new Draw.minimizeImage();
			minimizeIconOver = new Draw.minimizeImageOver();
			
			// resize cursors
			resizeHorizontal = new Draw.resizeHorizontalImage();
			resizeVertical = new Draw.resizeVerticalImage();
			resizeCorner = new Draw.resizeCornerImage();
			
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getBitmap: create and return new bitmap from bitmapData source
		@param bitmap - embedded bitmap to return
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function getBitmap(bitmap:String):Bitmap {
			
			return new Bitmap(Draw[bitmap].bitmapData);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawFilledRectangle: draws a filled bitmap pixel rectangle on target bitmapdata
		 * @param target - target BitmapData to draw rectangle on
		 * @param x - amount to offset on x axis
		 * @param y - amount to offset on y axis
		 * @param width - outline width
		 * @param height - outline height
		 * @param bgColor - outline color
		 * @param rounding - level of rounding, 0 for none
		 * @return bitmapRect - bitmap display object of pixel rectangle
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawFilledRectangle(	target:BitmapData,
													x:uint,
													y:uint,
													width:uint, 
													height:uint, 
													corners:uint = 1,
													color:Number = 0xffffff,
													alpha:Number = 1):void {
			
			var offset:uint = corners;
			var offWidth:uint = width - (corners << 1);
			var offHeight:uint = height - (corners << 1);	
			var alphaInt:uint = 255 * alpha;					// convert alpha to 0-255 range
			var alphaColor:Number = color | (alphaInt << 24);	// add alpha channel to color
			
			target.fillRect(new Rectangle(x + offset, y, offWidth, 1), alphaColor);					// top (1)
			target.fillRect(new Rectangle(x, y + offset, width, offHeight), alphaColor);			// fill	
			target.fillRect(new Rectangle(x + offset, y + height - 1, offWidth, 1), alphaColor);	// bottom (1)
			
			if (corners == 2) {
				target.fillRect(new Rectangle(x + offset - 1, y + 1, offWidth + 2, 1), alphaColor);				// top (2)
				target.fillRect(new Rectangle(x + offset - 1, y + height - 2, offWidth + 2, 1), alphaColor);	// bottom (2)			
			}
		}
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawOutline: draws variable width pixel outline on target bitmapdata
		 * @param target - bitmapData to draw on
		 * @param x - amount to offset on x axis
		 * @param y - amount to offset on y axis
		 * @param width - outline width
		 * @param height - outline height
		 * @param size - thickness of outline
		 * @param corners - 1 or 2 levels of pixel rounding
		 * @param color - outline color
		 * @param alpha - outline transparency
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawOutline(	target:BitmapData,
											x:uint,
											y:uint,
											width:uint, 
											height:uint, 
											size:uint = 1, 
											corners:uint = 1,
											color:Number = 0xffffff,
											alpha:Number = 1):void {
			var offset:uint = corners;
			var offWidth:uint = width - (corners << 1);
			var offHeight:uint = height - (corners << 1);		
			var alphaInt:uint = 255 * alpha;					// convert alpha to 0-255 range
			var alphaColor:Number = color | (alphaInt << 24);	// add alpha channel to color
			
			// draw sides
			target.fillRect(new Rectangle(x + offset, y, offWidth, size), alphaColor);					// top
			target.fillRect(new Rectangle(x + offset, y + height - size, offWidth, size), alphaColor);	// bottom
			target.fillRect(new Rectangle(x, y + offset, size, offHeight), alphaColor);					// left
			target.fillRect(new Rectangle(x + width - size, y + offset, size, offHeight), alphaColor);	// right
			
			// outer corners (size = 2)  inner corners (size = 1)
			target.setPixel32(x + 1, y + 1, alphaColor);
			target.setPixel32(x + width - 2, y + 1, alphaColor);		
			target.setPixel32(x + 1, y + height - 2, alphaColor);
			target.setPixel32(x + width - 2, y + height - 2, alphaColor);		
			
			// inner corner for size 1+ or level 2 corners
			if (corners == 2 || size > 1) {
				target.setPixel32(x + size, y + size, alphaColor);
				target.setPixel32(x + width - size - 1, y + size, alphaColor);	
				target.setPixel32(x + size, y + height - size - 1, alphaColor);
				target.setPixel32(x + width - size - 1, y + height - size - 1, alphaColor);	
			}
			
			// inner corners (2 levels)
			if (corners == 2) {
				// top left
				target.setPixel32(x + size + 1, y + size, alphaColor);
				target.setPixel32(x + size, y + size + 1, alphaColor);
				// top right
				target.setPixel32(x + width - size - 2, y + size, alphaColor);	
				target.setPixel32(x + width - size - 1, y + size + 1, alphaColor);	
				// bottom left
				target.setPixel32(x + size + 1, y + height - size - 1, alphaColor);
				target.setPixel32(x + size, y + height - size - 2, alphaColor);						
				// bottom right
				target.setPixel32(x + width - size - 2, y + height - size - 1, alphaColor);	
				target.setPixel32(x + width - size - 1, y + height - size - 2, alphaColor);	
			}
		}													
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawRoundedBorderBox: draws 1 pixel rounded bitmap rectangle with border
		 * @param width - box width
		 * @param height - box height
		 * @param borderSize - thickness of box border
		 * @return bitmapBox - bitmap display object of box
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawRoundedBorderBox(width:uint, 
													height:uint,
													bgColor:Number,
													borderColor:Number,
													borderSize:Number = 1):Bitmap {
			
			
			var innerWidth:int = width - (borderSize);
			var innerHeight:int = height - (borderSize);
			
			var boxBitmapData:BitmapData = new BitmapData(width, height, true, 0);
			// fill inner square (minus border area)
			var innerRect:Rectangle = new Rectangle(borderSize, borderSize, width - (borderSize << 1), height - (borderSize << 1));
			boxBitmapData.fillRect(innerRect, bgColor | 0xff000000);
			
			// remove inner corners
			boxBitmapData.setPixel32(borderSize, borderSize, 0);			// top left
			boxBitmapData.setPixel32(innerWidth - 1, borderSize, 0);		// top right
			boxBitmapData.setPixel32(borderSize, innerHeight - 1, 0);		// bottom left
			boxBitmapData.setPixel32(innerWidth - 1, innerHeight - 1, 0);	// bottom right
			// flood fill edge (creates outline)
			boxBitmapData.floodFill(0, 0, borderColor | 0xff000000);
			// remove outer corners
			boxBitmapData.setPixel32(0, 0, 0);								// top left
			boxBitmapData.setPixel32(width - 1, 0, 0);						// top right
			boxBitmapData.setPixel32(0, height - 1, 0);						// bottom left
			boxBitmapData.setPixel32(width - 1, height - 1, 0);				// bottom right
			
			var bitmapBox:Bitmap = new Bitmap(boxBitmapData);
			return bitmapBox;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawRoundedPixelGlow: draws 1 pixel rounded bitmap multi-level glow rectangle
		 * @param width - box width
		 * @param height - box height
		 * @param glowColor - color of glow base
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawRoundedPixelGlow(width:uint,
													height:uint,
													glowColor:Number,
													levels:uint = 4):Bitmap {
			
			var glowBitmapData:BitmapData = new BitmapData(width, height, true, 0);
			
			// add glow levels
			var i:uint = 0;
			var alpha:int = 255;
			for (i; i < levels; i ++) {
				// add glow 
				var glowRect:Rectangle = new Rectangle(i, i, width - (i << 1), height - (i << 1));
				glowBitmapData.fillRect(glowRect, glowColor | (alpha << 24));
				// remove inner fill
				var j:uint = i + 1;
				var removeRect:Rectangle = new Rectangle(j, j, width - (j << 1), height - (j << 1));
				glowBitmapData.fillRect(removeRect, 0);
				
				alpha = alpha >> 1;
			}
			
			// add glow corners
			i = 1;
			alpha = 255;
			for (i; i <= levels; i ++) {
				// add corner 
				glowBitmapData.setPixel32(i, i, glowColor | (alpha << 24));								// top left
				glowBitmapData.setPixel32(width - i - 1, i, glowColor | (alpha << 24));					// top right
				glowBitmapData.setPixel32(i, height - i - 1, glowColor | (alpha << 24));				// bottom left
				glowBitmapData.setPixel32(width - i - 1, height - i - 1, glowColor | (alpha << 24));	// bottom right
				
				alpha = alpha >> 1;
			}
			
			// remove outer corners
			glowBitmapData.setPixel32(0, 0, 0);						// top left
			glowBitmapData.setPixel32(width - 1, 0, 0);				// top right
			glowBitmapData.setPixel32(0, height - 1, 0);			// bottom left
			glowBitmapData.setPixel32(width - 1, height - 1, 0);	// bottom right
			
			// add highlight
			var highlightRect:Rectangle = new Rectangle(1, 0, width - 2, 1);
			glowBitmapData.fillRect(highlightRect, 0xc8ffffff);
			
			var bitmapGlow:Bitmap = new Bitmap(glowBitmapData);
			return bitmapGlow;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawRoundedBox: draws x pixel solid rounded rectangle
		 * @param width - outline width
		 * @param height - outline height
		 * @param color - outline color
		 * @param rounding - level of rounding to use on corners
		 * @param alpha - alpha of box
		 * @param highlight - true = apply highlight effect
		 * @param highlightColor - color of highlight effect
		 * @return bitmapBox - bitmap display object of box
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawRoundedBox(	width:uint, 
												height:uint,
												color:Number,
												rounding:uint = 1,
												alpha:Number = 1,
												highlight:Boolean = false,
												hightlightColor:Number = 0xffffff):Bitmap {
			
			var roundBoxBitmapData:BitmapData = new BitmapData(width, height, true, 0);
			
			// draw box
			Draw.drawPixelRectangle(roundBoxBitmapData, width, height, color, alpha, rounding);
			// draw highlight			
			if (highlight) Draw.drawPixelHighlight(roundBoxBitmapData, width, height, hightlightColor);
			
			var roundBoxBitmap:Bitmap = new Bitmap(roundBoxBitmapData);
			return roundBoxBitmap;										
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawPixelRectangle: draws bitmap pixel rectangle with or without 1 pixel rounding
		 * @param target - target BitmapData to draw rectangle on
		 * @param width - outline width
		 * @param height - outline height
		 * @param bgColor - outline color
		 * @param rounding - level of rounding, 0 for none
		 * @return bitmapRect - bitmap display object of pixel rectangle
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawPixelRectangle(	target:BitmapData,
													width:uint, 
													height:uint,
													bgColor:Number,
													alpha:Number,
													rounding:uint = 0):void {
			
			var alphaInt:uint = 255 * alpha;	// convert alpha to 0-255 range
			
			// flood fill rectangle
			target.floodFill(0, 0, bgColor | (alphaInt << 24));
			
			// level 1 rounding
			if (rounding >= 1) {
				target.setPixel32(0, 0, 0);						// top left
				target.setPixel32(width - 1, 0, 0);				// top right
				target.setPixel32(0, height - 1, 0);			// bottom left
				target.setPixel32(width - 1, height - 1, 0);	// bottom right
			}
			
			// level 2 rounding
			if (rounding >= 2) {
				// top left
				target.setPixel32(1, 0, 0);
				target.setPixel32(0, 1, 0);
				// top right
				target.setPixel32(width - 2, 0, 0);
				target.setPixel32(width - 1, 1, 0);
				// bottom left
				target.setPixel32(0, height - 2, 0);
				target.setPixel32(1, height - 1, 0);
				// bottom right
				target.setPixel32(width - 1, height - 2, 0);
				target.setPixel32(width - 2, height - 1, 0);
				
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawHighlight: draws highlight on bitmapData target
		 * @param target - target BitmapData to draw highlight on
		 * @param width - target width
		 * @param height - target height
		 * @param color - color of highlight
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawPixelHighlight(target:BitmapData, width:uint, height:uint, color:Number = 0xffffff):void {
			
			target.fillRect(new Rectangle(2, 1, width - 4, 1), color | 0xff000000);		// top highlight
			target.fillRect(new Rectangle(1, 2, 1, height - 4), color | 0xff000000);	// left highlight
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * drawSmallArrow: draws small fixed size arrow on new bitmap
		 * @param orientation - facing direction of arrow
		 * @param color - color of highlight
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawSmallArrow(orientation:String, color:Number = 0xffffff, alpha:Number = 1):Bitmap {
			
			var arrow:BitmapData;
			var alphaInt:uint = 255 * alpha;					// convert alpha to 0-255 range
			var alphaColor:Number = color | (alphaInt << 24);	// add alpha channel to color
			
			// up orientation
			switch (orientation) {
				case "up": 
					arrow = new BitmapData(5, 4, true, 0);
					arrow.fillRect(new Rectangle(0, 2, 5, 2), alphaColor);	// base  (1,2)
					arrow.fillRect(new Rectangle(1, 1, 3, 1), alphaColor);	// tier  (3)
					arrow.setPixel32(2, 0, alphaColor);						// point (4)
					break;
					
				case "down":
					arrow = new BitmapData(5, 4, true, 0);
					arrow.fillRect(new Rectangle(0, 0, 5, 2), alphaColor);	// base  (1,2)
					arrow.fillRect(new Rectangle(1, 2, 3, 1), alphaColor);	// tier  (3)
					arrow.setPixel32(2, 3, alphaColor);						// point (4)
					break;
				
				case "right":
					arrow = new BitmapData(4, 5, true, 0);
					arrow.fillRect(new Rectangle(0, 0, 2, 5), alphaColor);	// base  (1,2)
					arrow.fillRect(new Rectangle(2, 1, 1, 3), alphaColor);	// tier  (3)
					arrow.setPixel32(3, 2, alphaColor);						// point (4)
					break;
					
				case "left":
					arrow = new BitmapData(4, 5, true, 0);
					arrow.fillRect(new Rectangle(2, 0, 2, 5), alphaColor);	// base  (1,2)
					arrow.fillRect(new Rectangle(1, 1, 1, 3), alphaColor);	// tier  (3)
					arrow.setPixel32(0, 2, alphaColor);						// point (4)
					break;
			}
			
			var arrowBitmap:Bitmap = new Bitmap(arrow);
			return arrowBitmap;			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawGradientFill: draw gradientFill on target sprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawGradientVectorFill(	target:Sprite,
														width:Number, 
														height:Number,
														gradientStart:Number,
														gradientEnd:Number,
														alphaStart:Number = 1,
														alphaEnd:Number = 1,
														angle:int = 90):void {
															
			// gradient properties		
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [gradientStart, gradientEnd];
			var alphas:Array = [alphaStart, alphaEnd];
			var ratios:Array = [0x00, 0xFF];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, 90 * Math.PI / 180, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			target.graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod);  
 		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawMessageBox: draws message box with visual effects
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawMessageBox(width:Number, height:Number, x:Number = 0, y:Number = 0, clear:Boolean = false, messageBox:Sprite = null):Sprite {
			
			if (!messageBox) var messageBox:Sprite = new Sprite();
			
			// message box
			messageBox.graphics.lineStyle(2, 0x6b3e3e, 1);
			messageBox.graphics.beginFill(0x452828, 1);
			drawRoundVectorBox(messageBox, width, height, x, y, 1, clear);
			messageBox.graphics.endFill();
			
			// add glow
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.quality = 10;
			glowFilter.color = 0xff5a00;
			glowFilter.blurX = 3;
			glowFilter.blurY = 3;
			glowFilter.alpha = .2;
			
			messageBox.filters = [glowFilter];
			
			return messageBox;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawRoundVectorBox: draws round vector box directly to target objects graphics
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawRoundVectorBox(	target:Sprite,
													width:Number,
													height:Number,
													x:Number = 0,
													y:Number = 0,
													c:Number = 1,
													clear:Boolean = false):void {
			
			if (clear) target.graphics.clear();
			
			// adjust indent values for x,y position
			var cx:Number = c + x;
			var cy:Number = c + y;
			// width and height of box offset by x,y position
			var w:Number = width + x;
			var h:Number = height + y;
			
			target.graphics.moveTo(x, cy);
			target.graphics.lineTo(cx,cy); 			// top left corner
			target.graphics.lineTo(cx,y);
			target.graphics.lineTo(w - c, y); 		// top line
			target.graphics.lineTo(w - c, cy); 		// top right corner
			target.graphics.lineTo(w, cy);
			target.graphics.lineTo(w, h - c); 		// right line
			
			target.graphics.lineTo(w - c, h - c); 	// bottom right corner
			target.graphics.lineTo(w - c, h)
			target.graphics.lineTo(cx, h); 			// bottom line
			target.graphics.lineTo(cx, h - c); 		// bottom left corner
			target.graphics.lineTo(x, h - c);
			target.graphics.lineTo(x, cy); 			// left line
		}
        
	}
}