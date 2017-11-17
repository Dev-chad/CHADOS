#include "Types.h"

void kPrintString(int iX, int iY, BYTE attribute, const char *pcString);

void Main(void)
{
	kPrintString(45, 3, 0x0A, "PASS");

	while(1);
}

void kPrintString(int iX, int iY, BYTE attribute, const char *pcString)
{
	CHARACTER* pstScreen = (CHARACTER *) 0xB8000;
	int i;

	pstScreen += (iY * 80) + iX;
	
	for(i=0; pcString[i] != 0; i++)
	{
		pstScreen[i].bCharacter = pcString[i];
		pstScreen[i].bAttribute = attribute;
	}
}
