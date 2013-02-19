package citrus.objects.platformer.box2d{
	
	import flash.display.BitmapData;
	
	import Box2D.Dynamics.b2Body;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.objects.CitrusSprite;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.rad2deg;
	
	public class BridgeDisplay extends CitrusSprite
	{
		private var _numChain:uint;
		private var _vecSprites:Vector.<CitrusSprite>;
		private var _width:uint;
		private var _height:uint;
		
		public function BridgeDisplay(name:String = "l", params:Object = null)
		{
			_ce = CitrusEngine.getInstance() as StarlingCitrusEngine;
			
			super(name, params);
		}
		
		public function init(numChain:uint, width:uint, height:uint, b:BitmapData = null):void 
		{
			_numChain = numChain;
			_width = width;// + 5;
			_height = height;
			var texture:Texture
			
			if (b == null) texture = Texture.empty(_width*2, _height*2, 0xff000000 + Math.random()*0xffffff);
			else {
				
				texture = Texture.fromBitmapData(b, true, false, b.width/((_width)*2));
			}
			
			_vecSprites = new Vector.<CitrusSprite>();
			
			for (var i:uint = 0; i < _numChain; ++i) {
				
				var image:CitrusSprite = new CitrusSprite(i.toString(), {group:2, width:_width*2, height:_height*2, view:new Image(texture), registration:"center"});
								
				_ce.state.add(image);
				_vecSprites.push(image);
			}
		}
		
		public function updateSegmentDisplay(vecBodyChain:Vector.<b2Body>, box2DScale:Number, rope:Boolean=false):void {
			
			var i:uint = 0;
			
			for each (var body:b2Body in vecBodyChain) {
				
				_vecSprites[i].x = body.GetPosition().x * box2DScale;
				_vecSprites[i].y = body.GetPosition().y * box2DScale;
				if (rope)_vecSprites[i].rotation = rad2deg(body.GetAngle())+90;
				else _vecSprites[i].rotation = rad2deg(body.GetAngle());
				++i;
			}
		}
	}
}