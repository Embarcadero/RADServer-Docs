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

void TTestResource1::Get(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	AResponse->Body->SetValue(new TJSONString("Hello World"), true);
}

void TTestResource1::GetItem(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	String item;
	item = ARequest->Params->Values["item"];
	AResponse->Body->SetValue(new TJSONString("Hello World " +  item), true);
}

static void Register()
{
    std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
    attributes->ResourceName = "test";
    attributes->ResourceSuffix["GetItem"] = "{item}";
    RegisterResource(__typeinfo(TTestResource1), attributes.release());
}

#pragma startup Register 32
