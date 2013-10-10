package dragonBones.utils
{
	import flash.utils.ByteArray;
	
	public function checkBytesTailisXML(bytes:ByteArray):Boolean
	{
		var offset:int = bytes.length;
		
		var count1:int = 20;
		while(count1 --)
		{
			if(offset --)
			{
				switch(bytes[offset])
				{
					case charCodes[" "]:
					case charCodes["\t"]:
					case charCodes["\r"]:
					case charCodes["\n"]:
						//
					break;
					case charCodes[">"]:
						var count2:int = 20;
						while(count2 --)
						{
							if(offset --)
							{
								if(bytes[offset] == charCodes["<"])
								{
									return true;
								}
							}
							else
							{
								break;
							}
						}
						return false;
					break;
				}
			}
		}
		return false;
	}
}

const charCodes:Object = new Object();
for each(var c:String in " \t\r\n<>".split(""))
{
	charCodes[c] = c.charCodeAt(0);
}