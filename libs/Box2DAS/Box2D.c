/*

To compile the SWC:

alc-on; g++ Box2D.c -I.. -O3 -Wall -swc -DOSX -o Box2D.swc; alc-off

To see the temporary AS files:

export ACHACKS_TMPS=1


*/
#include "Box2DAS/Box2D.h";

int main() {
	AS3_LibInit(b2Core());
	return 0; 
}