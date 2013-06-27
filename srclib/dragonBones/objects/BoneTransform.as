package dragonBones.objects
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/

	/**
	 * The BoneTransform class provides transformation properties and methods for Bone instances.
	 * @example
	 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
	 * <p>This example gets the BoneTransform of the head bone and adjust the x and y registration by 60 pixels.</p>
	 * <listing>	
	 *	package  
	 *	{
	 *		import dragonBones.Armature;
	 *		import dragonBones.factorys.BaseFactory;
	 *  	import flash.display.Sprite;
	 *		import flash.events.Event;	
     *
	 *		public class DragonAnimation extends Sprite 
	 *		{		
	 *			[Embed(source = "Dragon1.swf", mimeType = "application/octet-stream")]  
	 *			private static const ResourcesData:Class;
	 *			
	 *			private var factory:BaseFactory;
	 *			private var armature:Armature;		
	 *			
	 *			public function DragonAnimation() 
	 *			{				
	 *				factory = new BaseFactory();
	 *				factory.addEventListener(Event.COMPLETE, handleParseData);
	 *				factory.parseData(new ResourcesData(), 'Dragon');
	 *			}
	 *			
	 *			private function handleParseData(e:Event):void 
	 *			{			
	 *				armature = factory.buildArmature('Dragon');
	 *				addChild(armature.display as Sprite); 			
	 *				armature.animation.play();
	 * 				var bone:Bone = armature.getBone("head");
	 * 				bone.origin.pivotX = 60;//origin BoneTransform
	 *				bone.origin.pivotY = 60;//origin BoneTransform
	 *				addEventListener(Event.ENTER_FRAME, updateAnimation);			
	 *			}
	 *			
	 *			private function updateAnimation(e:Event):void 
	 *			{
	 *				armature.advanceTime(1 / stage.frameRate);
	 *			}		
	 *		}
	 *	}
	 * </listing>
	 * @see dragonBones.Bone
	 * @see dragonBones.animation.Animation
	 */
	public class BoneTransform
	{
		/**
		 * Position on the x axis.
		 */
		public var x:Number;
		/**
		 * Position on the y axis.
		 */
		public var y:Number;
		/**
		 * Scale on the x axis.
		 */
		public var scaleX:Number;
		/**
		 * Scale on the y axis.
		 */
		public var scaleY:Number;
		/**
		 * Skew on the x axis.
		 */
		public var skewX:Number;
		/**
		 * skew on the y axis.
		 */
		public var skewY:Number;
		/**
		 * pivot point on the x axis (registration)
		 */
		public var pivotX:Number;
		/**
		 * pivot point on the y axis (registration)
		 */
		public var pivotY:Number;
		/**
		 * Z order.
		 */
		public var z:Number;
		
		/**
		 * The rotation of that BoneTransform instance.
		 */
		public function get rotation():Number
		{
			return skewX;
		}
		/**
		 * @private
		 */
		public function set rotation(value:Number):void
		{
			skewX = skewY = value;
		}
		/**
		 * Creat a new BoneTransform instance.
		 */
		public function BoneTransform()
		{
			setValues();
		}
		/**
		 * Sets all properties at once.
		 * @param	x The x position.
		 * @param	y The y position.
		 * @param	skewX The skew value on x axis.
		 * @param	skewY The skew value on y axis.
		 * @param	scaleX The scale on x axis.
		 * @param	scaleY The scale on y axis.
		 * @param	pivotX The pivot value on x axis (registration)
		 * @param	pivotY The pivot valule on y axis (registration)
		 * @param	z The z order.
		 */
		public function setValues(x:Number = 0, y:Number = 0, skewX:Number = 0, skewY:Number = 0, scaleX:Number = 0, scaleY:Number = 0, pivotX:Number = 0, pivotY:Number = 0, z:int = 0):void
		{
			this.x = x || 0;
			this.y = y || 0;
			this.skewX = skewX || 0;
			this.skewY = skewY || 0;
			this.scaleX = scaleX || 0;
			this.scaleY = scaleY || 0;
			this.pivotX = pivotX || 0;
			this.pivotY = pivotY || 0;
			this.z = z;
		}
		/**
		 * Copy all properties from this BoneTransform instance to the passed BoneTransform instance.
		 * @param	node
		 */
		public function copy(node:BoneTransform):void
		{
			x = node.x;
			y = node.y;
			scaleX = node.scaleX;
			scaleY = node.scaleY;
			skewX = node.skewX;
			skewY = node.skewY;
			pivotX = node.pivotX;
			pivotY = node.pivotY;
			z = node.z;
		}
		/**
		 * Get a string representing all BoneTransform property values.
		 * @return String All property values in a formatted string.
		 */
		public function toString():String
		{
			var string:String = "x:" + x + " y:" + y + " skewX:" + skewX + " skewY:" + skewY + " scaleX:" + scaleX + " scaleY:" + scaleY;
			return string;
		}
	}
}