package awayphysics {
	import cmodule.AwayPhysics.*;

	import flash.utils.ByteArray;

	public class AWPBase {
		protected static var loader : CLibInit;
		protected static var bullet : Object;
		protected static var memUser : MemUser;
		protected static var alchemyMemory : ByteArray;
		private static var initialized : Boolean = false;

		/**
		 * Initialize the Alchemy Memory and get the pointer of the buffer
		 */
		public static function initialize() : void {
			if (initialized) {
				return;
			}
			initialized = true;

			loader = new CLibInit();
			bullet = loader.init();

			memUser = new MemUser();

			var ns : Namespace = new Namespace("cmodule.AwayPhysics");
			alchemyMemory = (ns::gstate).ds;
		}

		/**
		 * 1 visual units equal to 0.01 bullet meters by default, this value is inversely with physics world scaling
		 * refer to http://www.bulletphysics.org/mediawiki-1.5.8/index.php?title=Scaling_The_World
		 */
		protected static var _scaling : Number = 100;
		public var pointer : uint;
		
		protected var cleanup:Boolean = false;
	}
}