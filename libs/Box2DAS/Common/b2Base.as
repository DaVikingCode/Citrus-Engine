package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.utils.*;
	
	public class b2Base {
	
		public static var loader:CLibInit;
		public static var lib:Object; /// The object returned from loader.init().
		public static var bytes:ByteArray; /// A ByteArray that operates on the C++ memory.
		public static var mem:MemUser;
		
		public static var initialized:Boolean = false;
		
		/**
		 * Initialize the C++ module. Pass false as the second parameter if you
		 * don't plan on using the static defs in the b2Def class.
		 */
		public static function initialize(defs:Boolean = true):void {
			if(initialized) {
				return;
			}
			initialized = true;
			loader = new CLibInit();
			lib = loader.init();
			mem = new MemUser();
			bytes = gstate.ds;
			if(defs) {
				b2Def.initialize();
			}
		}
		
		/**
		 * Nullifies everything so the entire Box2D C++ library can be garbage collected. Only use
		 * if your SWF doesn't need the Box2D library at all anymore (opposite of "initialize").
		 */
		public static function goodbyeBox2D():void {
			b2Def.destroy();
			// bytes.clear(); // Throws "RangeError" ?
			// gstate.ds = null;
			// gdomainClass.currentDomain.domainMemory = null;
			bytes.length = 0;
			initialized = false;
			loader = null;
			lib = null;
			bytes = null;
			mem = null;
		}
		
		public static function getArr():Array {
			return arr;
		}
				
		/// The address of the Box2d object in C++ memory.
		public var _ptr:Number;
		
		/**
		 * dereference a C++ pointer or AS3_Val that is pointing to an AS3 object.
		 */
		public static function deref(adr:int):* {
			return vt.get(adr);
		}
		
		/**
		 * Destroy base function just sets _ptr = 0. This should be overridden
		 * to actually destroy the object.
		 */
		public function destroy():void {
			_ptr = 0;
		}
		
		/**
		 * Does the object point to a C++ equivalent (i.e. is it created and not destroyed)? NOTE: When a C++
		 * instance is automatically destroyed (like when a b2World automatically destroys all physics entities)
		 * this function will still indicate it is valid, when it is in fact not valid.
		 */
		public function get valid():Boolean {
			return _ptr != 0;
		}
		
		/**
		 * Write a vertex array of the format [new V2(x,y), new V2(x,y), ...] to C++ memory.
		 */
		public function writeVertices(adr:int, v:Vector.<V2>):void {
			bytes.position = adr;
			var l:uint = v.length;
			for(var i:uint = 0; i < l; ++i) {
				bytes.writeFloat(v[i].x);
				bytes.writeFloat(v[i].y);
			}
		}
		
		/**
		 * Read C++ memory and convert it into a vertex array.
		 */
		public function readVertices(adr:int, num:int):Vector.<V2> {
			var v:Vector.<V2> = new Vector.<V2>();
			bytes.position = adr;
			for(var i:int = 0; i < num; ++i) {
				v[i] = new V2(bytes.readFloat(), bytes.readFloat());
			}
			return v;
		}	
	}
}