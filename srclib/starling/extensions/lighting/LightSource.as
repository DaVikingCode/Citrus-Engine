// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2015 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.extensions.lighting
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display3D.Context3DTextureFormat;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import starling.display.Image;
    import starling.display.Sprite3D;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.textures.Texture;

    public class LightSource extends Sprite3D
    {
        private var _color:uint;
        private var _brightness:Number;
        private var _ambientColor:uint;
        private var _ambientBrightness:Number;
        private var _lightBulb:Image;

        // helpers
        private var sMovement:Point = new Point();

        public function LightSource(color:uint=0xffffff, brightness:Number=1.0)
        {
            _color = color;
            _brightness = brightness;
            _ambientColor = 0xffffff;
            _ambientBrightness = 0.0;
        }

        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.MOVED);
            if (touch)
            {
                touch.getMovement(this, sMovement);
                this.x += sMovement.x;
                this.y += sMovement.y;
            }
        }

        private function createBulbTexture():Texture
        {
            var radius:Number = 12;
            var offset:int = 20;
            var shape:Shape = new Shape();
            shape.graphics.beginFill(0x0);
            shape.graphics.drawCircle(0, 0, radius);
            shape.graphics.endFill();
            shape.graphics.beginFill(0xffffff);
            shape.graphics.drawCircle(0, 0, radius - 2);
            shape.graphics.endFill();

            var matrix:Matrix = new Matrix();
            matrix.translate(radius + offset, radius + offset);

            var size:int = (radius + offset) * 2;
            var bitmapData:BitmapData = new BitmapData(size, size, true, 0x0);
            bitmapData.draw(shape, matrix);

            return Texture.fromBitmapData(bitmapData, false, false, 2.0,
                    Context3DTextureFormat.BGRA_PACKED);
        }

        public function get color():uint { return _color; }
        public function set color(value:uint):void
        {
            _color = value;
            if (_lightBulb) _lightBulb.color = _color;
        }

        public function get brightness():Number { return _brightness; }
        public function set brightness(value:Number):void
        {
            _brightness = value;
            if (_lightBulb) _lightBulb.alpha = value;
        }

        public function get ambientColor():uint { return _ambientColor; }
        public function set ambientColor(value:uint):void { _ambientColor = value; }

        public function get ambientBrightness():Number { return _ambientBrightness; }
        public function set ambientBrightness(value:Number):void { _ambientBrightness = value; }

        public function get showLightBulb():Boolean { return _lightBulb ? _lightBulb.visible : false; }
        public function set showLightBulb(value:Boolean):void
        {
            if (value == showLightBulb) return;
            if (_lightBulb == null)
            {
                _lightBulb = new Image(createBulbTexture());
                _lightBulb.alignPivot();
                _lightBulb.color = _color;
                _lightBulb.alpha = _brightness;
                _lightBulb.useHandCursor = true;

                addChild(_lightBulb);
                addEventListener(TouchEvent.TOUCH, onTouch);
            }
            _lightBulb.visible = value;
        }
    }
}
