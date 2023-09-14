//---------------------------------------------------------------------------

#include <fmx.h>
#pragma hdrstop

#include "MyForm01.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.fmx"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ActSendRequestExecute(TObject *Sender)
{
    RESTRequest1->Execute();
}
//---------------------------------------------------------------------------

