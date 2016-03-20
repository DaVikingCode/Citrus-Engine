// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.extensions.particles
{
    public class ColorArgb
    {
        public var red:Number;
        public var green:Number;
        public var blue:Number;
        public var alpha:Number;
        
        public static function fromRgb(color:uint):ColorArgb
        {
            var rgb:ColorArgb = new ColorArgb();
            rgb.fromRgb(color);
            return rgb;
        }
        
        public static function fromArgb(color:uint):ColorArgb
        {
            var argb:ColorArgb = new ColorArgb();
            argb.fromArgb(color);
            return argb;
        }
        
        public function ColorArgb(red:Number=0, green:Number=0, blue:Number=0, alpha:Number=0)
        {
            this.red = red;
            this.green = green;
            this.blue = blue;
            this.alpha = alpha;
        }
        
        public function toRgb():uint
        {
            var r:Number = red;   if (r < 0.0) r = 0.0; else if (r > 1.0) r = 1.0;
            var g:Number = green; if (g < 0.0) g = 0.0; else if (g > 1.0) g = 1.0;
            var b:Number = blue;  if (b < 0.0) b = 0.0; else if (b > 1.0) b = 1.0;
            
            return int(r * 255) << 16 | int(g * 255) << 8 | int(b * 255);
        }
        
        public function toArgb():uint
        {
            var a:Number = alpha; if (a < 0.0) a = 0.0; else if (a > 1.0) a = 1.0;
            var r:Number = red;   if (r < 0.0) r = 0.0; else if (r > 1.0) r = 1.0;
            var g:Number = green; if (g < 0.0) g = 0.0; else if (g > 1.0) g = 1.0;
            var b:Number = blue;  if (b < 0.0) b = 0.0; else if (b > 1.0) b = 1.0;
            
            return int(a * 255) << 24 | int(r * 255) << 16 | int(g * 255) << 8 | int(b * 255);
        }
        
        public function fromRgb(color:uint):void
        {
            red = (color >> 16 & 0xFF) / 255.0;
            green = (color >> 8 & 0xFF) / 255.0;
            blue = (color & 0xFF) / 255.0;
        }
        
        public function fromArgb(color:uint):void
        {
            red = (color >> 16 & 0xFF) / 255.0;
            green = (color >> 8 & 0xFF) / 255.0;
            blue = (color & 0xFF) / 255.0;
            alpha = (color >> 24 & 0xFF) / 255.0;
        }
        
        public function copyFrom(argb:ColorArgb):void
        {
            red = argb.red;
            green = argb.green;
            blue = argb.blue;
            alpha = argb.alpha;
        }
    }
}