package citrus.input.controllers 
{
	import citrus.input.controllers.gamepad.GenericGamepad;
	/**
	 * This is the Freebox gamepad controller.
	 * It will work only in analog mode though (axes are weird when its not)
	 * http://www.lowcostmobile.com/img/operateurs/free/gamepad_free.jpg
	 */
	public class FreeboxGamepad extends GenericGamepad
	{
		
		public function FreeboxGamepad(name:String) 
		{
			super(name);
			
			addMultiAxis("Lpad", ["AXIS_1", "AXIS_0"]);
			addMultiAxis("Rpad", ["AXIS_4", "AXIS_2"]);
			
			addButton("L1","BUTTON_13");
			addButton("R1", "BUTTON_14");
			addButton("L2", "BUTTON_15");
			addButton("R2", "BUTTON_16");
			
			addButton("select", "BUTTON_17");
			addButton("start", "BUTTON_18");
			
			addButton("up","BUTTON_5");
			addButton("down","BUTTON_6");
			addButton("right","BUTTON_8");
			addButton("left","BUTTON_7");
			
			addButton("1", "BUTTON_9");
			addButton("2", "BUTTON_10");
			addButton("3", "BUTTON_11");
			addButton("4", "BUTTON_12");
		}
		
	}

}