package ash.fsm
{
	import ash.core.System;

	public interface ISystemProvider
	{
		function getSystem() : System;

		function get identifier() : *;

		function get priority() : int;

		function set priority( value : int ) : void;
	}
}
