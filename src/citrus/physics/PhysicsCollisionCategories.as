package citrus.physics {
	/**
	 * Physics Engine uses bits to represent collision categories.
	 * 
	 * <p>If you don't understand binary and bit shifting, then it may get kind of confusing trying to work 
	 * with physics engine categories, so I've created this class that those bits can be accessed by 
	 * creating and referring to String representations.</p>
	 * 
	 * <p>The bit system is actually really great because any combination of categories can actually be
	 * represented by a single integer value. However, using bitwise operations is not always readable
	 * for everyone, so this call is meant to be as light of a wrapper as possible for managing collision
	 * categories with the Citrus Engine.</p>
	 * 
	 * <p>The constructors of the Physics Engine classes create a couple of initial categories for you to use:
	 * GoodGuys, BadGuys, Items, Level. If you need more, you can always add more categories, but don't complicate
	 * it just for the sake of adding fun category names. The categories created by the Physics Engine classes are used by the
	 * platformer kit that comes with Citrus Engine.</p>
	 */
	public class PhysicsCollisionCategories {
		
		private static var _categoryIndexes : Array = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384];
		
		private static var _categoryNames : Array = new Array(15);
		private static var _allCategories : uint = 0;
		
		private static function getEmptySlotIndex():int {
			for(var i:int = 0; i < _categoryNames.length; i++)
				if(_categoryNames[i] == null)
					return i;
					
			return -1;
		}
		
		/**
		 * Get all valid category names
		 */
		public static function GetAllNames():Array {
			var names:Array = [];
			for each(var n:String in _categoryNames)
				if(n != null)
					names.push(n);
			return names;
		}

		/**
		 * Returns true if the categories in the first parameter contain the category(s) in the second parameter.
		 * @param	categories The categories to check against.
		 * @param	theCategory The category you want to know exists in the categories of the first parameter.
		 */
		public static function Has(categories : uint, theCategory : uint) : Boolean {
			return Boolean(categories & theCategory);
		}

		/**
		 * Add a category to the collision categories list.
		 * @param	categoryName The name of the category.
		 */
		public static function Add(categoryName : String) : void {
			
			var lastEmptySlot:int = getEmptySlotIndex();
			
			if (lastEmptySlot < 0)
				throw new Error("You can only have 15 categories.");

			if (_categoryNames.indexOf(categoryName) > -1)
				return;

			_categoryNames[lastEmptySlot] = categoryName;
			_allCategories |= _categoryIndexes[lastEmptySlot];
		}

		/**
		 * Gets the category(s) integer by name. You can pass in multiple category names, and it will return the appropriate integer.
		 * @param	...args The categories that you want the integer for.
		 * @return A single integer representing the category(s) you passed in.
		 */
		public static function Get(...args) : uint {
			var categories : uint = 0;
			for each (var name : String in args) {
				var catIndex:int = _categoryNames.indexOf(name);
				var category : uint = _categoryIndexes[catIndex];
				
				if (catIndex < 0) {
					trace("Warning: " + name + " category does not exist.");
					continue;
				}
				
				categories |= category;
			}
			return categories;
		}
		
		/**
		 * Remove a single category
		 */
		public static function Remove(categoryName:String):void {
			var catIndex:int = _categoryNames.indexOf(categoryName);
			if(catIndex > -1) {
				_categoryNames[catIndex] = null;
				_allCategories &= (~_categoryIndexes[catIndex]);
			}
		}
		
		/**
		 * Clear all categories
		 */
		public static function Clear():void {
			_categoryNames = new Array(15);
			_allCategories = 0;
		}

		/**
		 * Returns an integer representing all categories.
		 */
		public static function GetAll() : uint {
			return _allCategories;
		}

		/**
		 * Returns an integer representing all categories except the ones whose names you pass in.
		 * @param	...args The names of the categories you want excluded from the result.
		 */
		public static function GetAllExcept(...args) : uint {
			var categories : uint = _allCategories;
			for each (var name : String in args) {
				var catIndex:int = _categoryNames.indexOf(name);
				if (catIndex < 0) {
					trace("Warning: " + name + " category does not exist.");
					continue;
				}
				categories &= (~_categoryIndexes[catIndex]);
			}
			return categories;
		}

		/**
		 * Returns the number zero, which means no categories. You can also just use the number zero instead of this function (but this reads better).
		 */
		public static function GetNone() : uint {
			return 0;
		}
	}
}