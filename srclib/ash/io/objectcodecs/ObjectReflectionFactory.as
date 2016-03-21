package ash.io.objectcodecs
{
	import flash.utils.Dictionary;

	internal class ObjectReflectionFactory
	{
		private static var reflections : Dictionary = new Dictionary();

		public static function reflection( component : Object ) : ObjectReflection
		{
			var type : Class = component.constructor as Class;
			if( !reflections[ type ] )
			{
				reflections[ type ] = new ObjectReflection( component );
			}
			return reflections[ type ];
		}
	}
}
