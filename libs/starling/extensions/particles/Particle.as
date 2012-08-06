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
    public class Particle
    {
        public var x:Number;
        public var y:Number;
        public var scale:Number;
        public var rotation:Number;
        public var color:uint;
        public var alpha:Number;
        public var currentTime:Number;
        public var totalTime:Number;

        public function Particle()
        {
            x = y = rotation = currentTime = 0.0;
            totalTime = alpha = scale = 1.0;
            color = 0xffffff;
        }
    }
}