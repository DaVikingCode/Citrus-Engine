package com.citrusengine.physics 
{
	/**
	 * Physics Engine uses bits to represent collision categories.
	 * 
	 * <p>If you don't understand binary and bit shifting, then it may get kind of confusing trying to work 
	 * with physics engine categories, so I've created this classso that those bits can be accessed by 
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
	public class PhysicsCollisionCategories 
	{
		private static var _allCategories:uint = 0;
		private static var _numCategories:uint = 0;
		private static var _categoryIndexes:Array = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384];
		private static var _categoryNames:Object = new Object();
		
		/**
		 * Returns true if the categories in the first parameter contain the category(s) in the second parameter.
		 * @param	categories The categories to check against.
		 * @param	theCategory The category you want to know exists in the categories of the first parameter.
		 */
		public static function Has(categories:uint, theCategory:uint):Boolean
		{
			return Boolean(categories & theCategory);
		}
		
		/**
		 * Add a category to the collision categories list.
		 * @param	categoryName The name of the category.
		 */
		public static function Add(categoryName:String):void
		{
			if (_numCategories == 15)
			{
				throw new Error("You can only have 15 categories.");
				return;
			}
			
			if (_categoryNames[categoryName])
				return;
			
			_categoryNames[categoryName] = _categoryIndexes[_numCategories];
			_allCategories |= _categoryIndexes[_numCategories];
			_numCategories++;
		}
		
		/**
		 * Gets the category(s) integer by name. You can pass in multiple category names, and it will return the appropriate integer.
		 * @param	...args The categories that you want the integer for.
		 * @return A signle integer representing the category(s) you passed in.
		 */
		public static function Get(...args):uint
		{
			var categories:uint = 0;
			for each (var name:String in args)
			{
				var category:uint = _categoryNames[name];
				if (category == 0)
				{
					trace("Warning: " + name + " category does not exist.");
					continue;
				}
				categories |= _categoryNames[name];
			}
			return categories;
		}
		
		/**
		 * Returns an integer representing all categories.
		 */
		public static function GetAll():uint
		{
			return _allCategories;
		}
		
		/**
		 * Returns an integer representing all categories except the ones whose names you pass in.
		 * @param	...args The names of the categories you want excluded from the result.
		 */
		public static function GetAllExcept(...args):uint
		{
			var categories:uint = _allCategories;
			for each (var name:String in args)
			{
				var category:uint = _categoryNames[name];
				if (category == 0)
				{
					trace("Warning: " + name + " category does not exist.");
					continue;
				}
				categories &= (~_categoryNames[name]);
			}
			return categories;
		}
		
		/**
		 * Returns the number zero, which means no categories. You can also just use the number zero instead of this function (but this reads better).
		 */
		public static function GetNone():uint
		{
			return 0;
		}
	}

}