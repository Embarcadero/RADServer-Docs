//---------------------------------------------------------------------------

#include <fmx.h>
#pragma hdrstop

#include "FormMain.h"
#include "EdgeModuleU.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.fmx"
TForm1 *Form1;

// Initialize the static variable
bool FEdgeRegistered = false;

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
    FEdgeRegistered = false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::EMSEdgeService1Registered(TObject *Sender)
{
    FEdgeRegistered = true;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::EMSEdgeService1Unregistered(TObject *Sender)
{
	FEdgeRegistered = false;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
	EMSEdgeService1->Active = false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ActivateEdgeModuleExecute(TObject *Sender)
{
    EMSEdgeService1->Active = !(EMSEdgeService1->Active);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ActivateEdgeModuleUpdate(TObject *Sender)
{
    UnicodeString ButtonText = L"EdgeModule\r\nActive: ";
    BtnActive->Text = ButtonText + BoolToStr(FEdgeRegistered, true);

    if (FEdgeRegistered)
        BtnActive->TextSettings->FontColor = TAlphaColorRec::Forestgreen;
    else
        BtnActive->TextSettings->FontColor = TAlphaColorRec::Crimson;

	GroupBox1->Enabled = FEdgeRegistered;
	EdgeModuleU::FormValues.CheckBox = CheckBox1->IsChecked;
    EdgeModuleU::FormValues.Edit = Edit1->Text;
    EdgeModuleU::FormValues.TrackBar = TrackBar1->Value;
    lblTrackValue->Text = FloatToStr(TrackBar1->Value);
}
//---------------------------------------------------------------------------
