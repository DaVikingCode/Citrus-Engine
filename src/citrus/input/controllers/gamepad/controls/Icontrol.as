package citrus.input.controllers.gamepad.controls 
{
	import citrus.input.controllers.gamepad.Gamepad;
	
	/**
	 * defines control wrappers we use in Gamepad.
	 */
	public interface Icontrol 
	{
		function updateControl(control:String,value:Number):void
		function hasControl(id:String):Boolean
		function get gamePad():Gamepad
		function destroy():void	
	}

}