#include "Types.h"
#include "Keyboard.h"
#include "Descriptor.h"
#include "PIC.h"

void kPrintString(int iX, int iY, BYTE attribute, const char *pcString);

void Main(void)
{
	char vcTemp[2] = {0, };
	BYTE bFlags;
	BYTE bTemp;
	int i = 0;

	kPrintString(45, 9, 0x0A, "PASS");

	kPrintString(0, 10, 0x07, "IA-32e C Kernel Start.......................[    ]");
	kPrintString(45, 10, 0x0A, "PASS");
	
	kPrintString(0, 11, 0x07, "GDT Initialize And Switch For IA-32e Mode...[    ]");
	kInitializeGDTTableAndTSS();
	kLoadGDTR(GDTR_STARTADDRESS);
	kPrintString(45, 11, 0x0A, "PASS");

	kPrintString(0, 12, 0x07, "TSS Segment Load............................[    ]");
	kLoadTR(GDT_TSSSEGMENT);
	kPrintString(45, 12, 0x0A, "PASS");

	kPrintString(0, 13, 0x07, "IDT Initialize..............................[    ]");
	kInitializeIDTTables();
	kLoadIDTR(IDTR_STARTADDRESS);
	kPrintString(45, 13, 0x0A, "PASS");


	kPrintString(0, 14, 0x07, "Keyboard Activate...........................[    ]");
	
	if(kActivateKeyboard() == TRUE)
	{
		kPrintString(45, 14, 0x0A, "PASS");
		kChangeKeyboardLED(FALSE, FALSE, FALSE);
	}
	else
	{
		kPrintString(45, 14, 0x04, "FAIL");
		while(1);
	}

	kPrintString(0, 15, 0x07, "PIC Controller And Interrupt Initialize.....[    ]");
	kInitializePIC();
	kMaskPICInterrupt(0);
	kEnableInterrupt();
	kPrintString(45, 15, 0x0A, "PASS");

	while(1)
	{
		if(kIsOutputBufferFull() == TRUE)
		{
			bTemp = kGetKeyboardScanCode();

			if(kConvertScanCodeToASCIICode(bTemp, &(vcTemp[0]), &bFlags) == TRUE)
			{
				if(bFlags & KEY_FLAGS_DOWN)
				{				
					kPrintString(i++, 16, 0x07, vcTemp);

					if(vcTemp[0] == '0')
					{
						bTemp = bTemp / 0;
					}
				}
			}
		}
	}
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

