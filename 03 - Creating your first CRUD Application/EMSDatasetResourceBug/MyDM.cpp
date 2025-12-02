//---------------------------------------------------------------------------
#pragma hdrstop

#include "MyDM.h"
#include <memory>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "System.Classes.TPersistent"
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
__fastcall TTestResource1::TTestResource1(TComponent* Owner)
	: TDataModule(Owner)
{
}

static void Register()
{
	std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "test";
	attributes->ResourceSuffix["dsrCUSTOMER"] = "customers";
	RegisterResource(__typeinfo(TTestResource1), attributes.release());
}

#pragma startup Register 32

