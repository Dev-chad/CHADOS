#include "Types.h"

void kPrintString(int iX, int iY, BYTE attribute, const char *pcString);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);

void Main(void)
{
	DWORD i;

	kPrintString(45, 3, 0x0A, "PASS");

	kPrintString(0, 4, 0x07, "Minimum Memory Size Check...................[    ]");
	
	if(kIsMemoryEnough() == TRUE)
	{
		kPrintString(45, 4, 0x0A, "PASS");
	}
	else
	{
		kPrintString(45, 4, 0x04, "FAIL");
		kPrintString(0, 5, 0x07, "      - [                 ] OS Requires Over 64Mbyte Memory.");
		kPrintString(9, 5, 0x04, "Not Enough Memory");

		while(1);
	}
	
	kPrintString(0, 5, 0x07, "IA-32e Kernel Area Initializing.............[    ]");

	if(kInitializeKernel64Area() == TRUE)
	{
		kPrintString(45, 5, 0x0A, "PASS");
	}
	else
	{
		kPrintString(45, 5, 0x04, "FAIL");
	}

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

BOOL kInitializeKernel64Area(void)
{
	DWORD *pdwCurrentAddress;

	pdwCurrentAddress = (DWORD *) 0x100000;
	
	while((DWORD *)pdwCurrentAddress < 0x600000)
	{
		*pdwCurrentAddress = 0x00;

		if(*pdwCurrentAddress != 0)
		{
			return FALSE;
		}

		pdwCurrentAddress++;
	}

	return TRUE;
}

BOOL kIsMemoryEnough(void)
{
	DWORD * pdwCurrentAddress;

	pdwCurrentAddress = (DWORD *) 0x100000;

	while((DWORD)pdwCurrentAddress < 0x4000000)
	{
		*pdwCurrentAddress = 0x12345678;

		if(*pdwCurrentAddress != 0x12345678)
		{
			return FALSE;
		}

		pdwCurrentAddress += (0x100000 / 4);
	}

	return TRUE;
}
