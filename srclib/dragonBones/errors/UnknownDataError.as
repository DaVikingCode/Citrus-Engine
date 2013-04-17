package dragonBones.errors
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	
	/**
	 * Thrown when dragonBones encounters an unknow error.
	 */
	public final class UnknownDataError extends Error
	{
		public function UnknownDataError(message:* = "", id:* = 0)
		{
			super(message, id);
		}
	}
}