#include "Types.h"
#include "Page.h"
#include "ModeSwitch.h"

void kPrintString(int iX, int iY, BYTE attribute, const char *pcString);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);
void kCopyKernel64ImageTo2Mbyte(void);

void Main(void)
{
	DWORD i;
	DWORD dwEAX, dwEBX, dwECX, dwEDX;
	char vcVendorString[13] = {0, };

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
	
	kPrintString(0, 5, 0x07, "IA-32e Kernel Area Initialize...............[    ]");

	if(kInitializeKernel64Area() == TRUE)
	{
		kPrintString(45, 5, 0x0A, "PASS");
	}
	else
	{
		kPrintString(45, 5, 0x04, "FAIL");
	}

	kPrintString(0, 6, 0x07, "IA-32e Page Tables Initialize...............[    ]");
	kInitializePageTables();
	kPrintString(45, 6, 0x0A, "PASS");

	kReadCPUID(0x00, &dwEAX, &dwEBX, &dwECX, &dwEDX);
	*(DWORD *) vcVendorString = dwEBX;
	*((DWORD *) vcVendorString + 1) = dwEDX;
	*((DWORD *) vcVendorString + 2) = dwECX;
	kPrintString(0, 7, 0x07, "Processor Vendor String.....................[            ]");
	kPrintString(45, 7, 0x0A, vcVendorString);

	kReadCPUID(0x80000001, &dwEAX, &dwEBX, &dwECX, &dwEDX);
	kPrintString(0, 8, 0x07, "64bit Mode Support Check....................[    ]");
	if(dwEDX & (1 << 29))
	{
		kPrintString(45, 8, 0x0A, "PASS");
	}
	else
	{
		kPrintString(45, 8, 0x04, "FAIL");
		kPrintString(0, 9, 0x07, "   - [             ] This processor does not support 64bit mode");
		kPrintString(6, 9, 0x04, "Support Error");

		while(1);
	}

	kPrintString(0, 9, 0x07, "Copy IA-32e Kernel To 2M Address............[    ]");
	kCopyKernel64ImageTo2Mbyte();
	kPrintString(45, 9, 0x0A, "PASS");

	kPrintString(0, 10, 0x07, "Switch To IA-32e Mode.......................[    ]");
	kSwitchAndExcecute64bitKernel();
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

void kCopyKernel64ImageTo2Mbyte(void)
{
	WORD wKernel32SectorCount, wTotalKernelSectorCount;
	DWORD *pdwSourceAddress, *pdwDestinationAddress;
	int i;

	wTotalKernelSectorCount = *((WORD *)0x7C05);
	wKernel32SectorCount = *((WORD *) 0x7C07);

	pdwSourceAddress = (DWORD *)(0x10000 + (wKernel32SectorCount * 512));
	pdwDestinationAddress = (DWORD *)0x200000;

	for(i=0; i<512 * (wTotalKernelSectorCount - wKernel32SectorCount) / 4; i++)
	{
		*pdwDestinationAddress = *pdwSourceAddress;
		pdwDestinationAddress++;
		pdwSourceAddress++;
	}
}
