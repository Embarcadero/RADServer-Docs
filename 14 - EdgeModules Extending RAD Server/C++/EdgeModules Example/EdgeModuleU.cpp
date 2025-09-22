//---------------------------------------------------------------------------
#pragma hdrstop

#include "EdgeModuleU.h"
#include <memory>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "FMX.Controls.TControl"
#pragma resource "*.dfm"
//---------------------------------------------------------------------------

// Initialize global variable
EdgeModuleU::TFormValues EdgeModuleU::FormValues = { false, L"", 0.0 };

__fastcall TProcessorResource1::TProcessorResource1(TComponent* Owner)
	: TDataModule(Owner)
{
}

void TProcessorResource1::GetCalculate(TEndpointContext* AContext,
	TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
    UnicodeString LParam1, LParam2;
    TJSONObject* LResponse;

	// Read the input params
	if (!ARequest->Params->TryGetValue("param1", LParam1) ||
		!ARequest->Params->TryGetValue("param2", LParam2))
	{
		AResponse->RaiseBadRequest("Bad request", "Missing data");
    }

    LResponse = new TJSONObject();
    try
    {
        // Calculate the result
        double calculation = StrToFloat(LParam1) + StrToFloat(LParam2);

        // Add your processing logic here
        LResponse->AddPair("status", "processed");
        LResponse->AddPair("timestamp", DateToISO8601(Now()));
        LResponse->AddPair("result", calculation);

        // Send the response
		AResponse->Body->SetValue(LResponse, false);
    }
    __finally
    {
        LResponse->Free();
    }
}

void TProcessorResource1::GetFormValues(TEndpointContext* AContext,
    TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	AResponse->Body->SetValue(EdgeModuleU::FormValues.ToJSON(), true);
}

// TFormValues implementation
TJSONObject* EdgeModuleU::TFormValues::ToJSON()
{
    TJSONObject* Result = new TJSONObject();
    Result->AddPair("CheckBox", this->CheckBox);
    Result->AddPair("Edit", this->Edit);
    Result->AddPair("TrackBar", this->TrackBar);
    return Result;
}

static void Register()
{
    std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "processor";
	attributes->ResourceSuffix["GetCalculate"] = "calculate";
	attributes->ResourceSuffix["GetFormValues"] = "formValues";
	RegisterResource(__typeinfo(TProcessorResource1), attributes.release());
}

#pragma startup Register 64
