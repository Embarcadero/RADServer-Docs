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
	attributes->ResourceSuffix["dsrCUSTOMER.get"] = "./{CUST_NO}";
	attributes->ResourceSuffix["dsrCUSTOMER.post"] = "./";
	attributes->ResourceSuffix["dsrCUSTOMER.put"] = "./{CUST_NO}";
	attributes->ResourceSuffix["dsrCUSTOMER.delete"] = "./{CUST_NO}";
	attributes->ResourceSuffix["dsrSALES"] = "sales";
	attributes->ResourceSuffix["dsrSALES.get"] = "./{PO_NUMBER}";
	attributes->ResourceSuffix["dsrSALES.post"] = "./";
	attributes->ResourceSuffix["dsrSALES.put"] = "./{PO_NUMBER}";
	attributes->ResourceSuffix["dsrSALES.delete"] = "./{PO_NUMBER}";

	RegisterResource(__typeinfo(TTestResource1), attributes.release());
}

#pragma startup Register 32

