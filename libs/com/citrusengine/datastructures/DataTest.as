package com.citrusengine.datastructures {

	public class DataTest {

		static public function isSubclass(a:Class, b:Class):Boolean {
			
			if (int(!a) | int(!b)) return false;
			//return b.prototype.isPrototypeOf(a.prototype); // works too
			return (a == b || a.prototype instanceof b);
		}
	}
}
