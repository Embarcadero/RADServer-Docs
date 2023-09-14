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
	TMemoryStream * mStream = new TMemoryStream;
	AResponse->Body->SetStream(mStream,"application/json", True);
	EmployeeQuery->Open();
	EmployeeQuery->SaveToStream(mStream, sfJSON);
}

void TTestResource1::GetBatchMove(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
   FDBatchMoveJSONWriter1->JsonWriter = AResponse->Body->JSONWriter;
   FDBatchMove1->Execute();
}

static void Register()
{
    std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "FireDAC";
	attributes->ResourceSuffix["GetBatchMove"] = "BatchMove";
    RegisterResource(__typeinfo(TTestResource1), attributes.release());
}

#pragma startup Register 32
