/*
     File:	Sounds.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	June 02, 2008
   Edited:	
    Notes:	
Functions:

*/

package system {
	
	// import classes
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Sound
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Sounds {
		
		// sound
		//[Embed(source="..\\sound.mp3")]
		//private static var sound:Class;
		//private static var sound:Sound = new tek() as Sound;
		//private static var sound:SoundChannel;
		
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		playSound
		@param sound - sound class to play
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function playSound(sound:String):void {
			
			// cut-off sound from existing soundChannel if any
			try {
				Sounds[sound + "Channel"].stop();	
			} catch (error:Error) {
			}
			
			Sounds[sound + "Channel"] = Sounds[sound + "Sound"].play();
		}
		
	}
}