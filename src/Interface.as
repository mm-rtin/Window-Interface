 /*
     File:	Interface.as
  Purpose:	
   Author:	
  Created:	June 26, 2008
   Edited:
    Notes: 
    
*/

package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Stage;
	import flash.text.TextField;
	
	// custom
	import data.ContentLoader;
	import window.WindowGroup;
	import window.Window;
	
	import system.*;
	import graphics.*;
	import flash.geom.Rectangle;


    // metadata
    [SWF(width="1024", height="768", backgroundColor="#244249", frameRate="32")]
    
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 * class Interface
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Interface extends Sprite {
		
		// classes
		
		// containers
		private var interfaceContainer:Sprite;
		private var groupContainer:Sprite;
		private var mouseContainer:Sprite;
		
		// static 
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 * Interface constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Interface() {
			
			/** site properties
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.showDefaultContextMenu = true;
			stage.align = StageAlign.TOP;
			stage.quality = "high";

			/** create sprites
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// container sprites
			interfaceContainer = new Sprite();
			groupContainer = new Sprite();
			mouseContainer = new Sprite();
			
			/** initialize static classes
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			Styles.initialize();
			Draw.initialize();
			Animate.initialize(20);
			
			/** initialize classes
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			KeyInput.initialize(this.stage);								// KeyInput static class
			mouseContainer = Mouse.initialize(this.stage);					// Mouse static class
			// create window group
			var boundry:Rectangle = new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			
			groupContainer = WindowGroup.initialize(this.stage, boundry);
			
			/** add interface elements to display list
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			this.addChild(groupContainer);		// child 0
			this.addChild(mouseContainer);		// keep at last child
			
			/** TEMP WINDOW 1
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var temp:String = "<body>" 
			+ "<p>An ActionScript 3.0 interactive window system with asynchronous content loading built in Flash Builder. This window interface project contains most of the features standard in most operating system windows.</p>"
			+	"\n\nFeatures: \n"
			+	"<ul>"
			+	"<li>Window movement, </li>"
			+	"<li>3-way resizing, </li>"
			+	"<li>Z-depth ordering, </li>"
			+	"<li>Close, minimize and maximize, </li>"
			+	"<li>scroll-bar and content easing</li>"
			+	"</ul>"
			+	"\n\nScrolling inputs supported: \n"
			+	"<ul>"
			+	"<li>Keyboard, </li>"
			+	"<li>Arrow button, </li>"
			+	"<li>Track scrolling, </li>"
			+	"<li>Mouse wheel</li>"
			+	"</ul>"
			+	"\n\nAdditionally, the windows may be snapped to nearby window edges and the windows support displaying any object inheriting from DisplayObject.</body>";
			
			// test content
			var testText:TextField = Text.drawMultiLineTextField(temp, "content", false, false, 250); 
			// create test window 1
			WindowGroup.newWindow(testText, "Window Interface", 46, 64, 297, 130, 15, false);
			
			// content loader
			var contentLoader:ContentLoader = new ContentLoader("content/large_image.jpg", "regular");
			
			// create test window 2
			WindowGroup.newWindow(contentLoader, "large fantasy picture", 508, 64, 364, 274, 0, true);
			
			// content loader
			var contentLoader2:ContentLoader = new ContentLoader("content/medium_image.jpg", "regular");
			// create test window 3
			WindowGroup.newWindow(contentLoader2, "x", 362, 64, 111, 439, 0, true);
			
			// content loader
			var contentLoader3:ContentLoader = new ContentLoader("content/wide_image.jpg", "regular");
			// create test window 3
			WindowGroup.newWindow(contentLoader3, "city", 110, 237, 216, 216, 0, true);
			
			// content loader
			var contentLoader4:ContentLoader = new ContentLoader("content/ref_image.gif", "regular");
			// create test window 4
			WindowGroup.newWindow(contentLoader4, "reference", 40, 381, 220, 221, 0, true);
			
			// content loader
			var contentLoader5:ContentLoader = new ContentLoader("content/test_image.jpg", "regular");
			// create test window 4
			WindowGroup.newWindow(contentLoader5, "wallpaper", 509, 422, 488, 186, 0, true);
		}
	}
}