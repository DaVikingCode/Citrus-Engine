// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.extensions.particles
{
    import starling.textures.Texture;
    
    /** This class is only available for backwards-compatibility. 
     *  This was the old name of the 'PDParticleSystem' class. */
    public class ParticleDesignerPS extends PDParticleSystem
    {
        private static var sDeprecationNotified:Boolean = false;
        
        public function ParticleDesignerPS(config:XML, texture:Texture)
        {
            if (!sDeprecationNotified)
            {
                sDeprecationNotified = true;
                trace("[Starling] The class 'ParticleDesignerPS' is deprecated. " + 
                      "Please use 'PDParticleSystem' instead.");
            }
            super(config, texture);
        }
    }
}