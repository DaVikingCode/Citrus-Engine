package dragonBones.errors
{
	/**
	 * Thrown when encounter an unknow error.
	 */
	public final class UnknownDataError extends Error
	{
		public function UnknownDataError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}