//---------------------------------------------------------------------------
#pragma hdrstop

#include "MyDM.h"
#include <memory>
#include <System.IOUtils.hpp>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "System.Classes.TPersistent"
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
__fastcall TDataResource1::TDataResource1(TComponent* Owner)
	: TDataModule(Owner)
{
}

void TDataResource1::PostUpload(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	const System::UnicodeString UPLOAD_PATH = "c:\\uploads"; // change this with the local path you prefer
	TDirectory::CreateDirectory(UPLOAD_PATH);
	AResponse->Body->JSONWriter->WriteStartArray();
	for (int i = 0; i < ARequest->Body->PartCount; ++i) // check how many files/parts are in the body
	{
		System::UnicodeString lFileName = ARequest->Body->Parts[i]->FileName;  // accessing the original file name
		// In case of multi platform development it is important to verify if the file name complies with the OS standards
		if (!TPath::HasValidFileNameChars(lFileName, false)) {
			AResponse->RaiseError(415, "invalid file name: ", lFileName);
		}
		TStream* lFile = new TStream;
		// The file is created in the local path
		lFile = TFile::Create(TPath::Combine(UPLOAD_PATH, lFileName));
		try {
			// The stream from the body is added to the file
			lFile->CopyFrom(ARequest->Body->Parts[i]->GetStream(), 0);
            // In this example we return a status code of 201 and as extra info the file name and the file size
			AResponse->StatusCode = 201;
			AResponse->Body->JSONWriter->WriteStartObject();
			AResponse->Body->JSONWriter->WritePropertyName("fileName");
			AResponse->Body->JSONWriter->WriteValue(lFileName);
			AResponse->Body->JSONWriter->WritePropertyName("size");
			AResponse->Body->JSONWriter->WriteValue(lFile->Size);
			AResponse->Body->JSONWriter->WriteEndObject();
		} __finally {
			lFile->Free();
		}
	}
	AResponse->Body->JSONWriter->WriteEndArray();
}

static void Register()
{
	std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "test";
	attributes->ResourceSuffix["PostUpload"] = "./upload";
	attributes->ResourceSuffix["EMSFileResource1"] = "./fileResource";
	attributes->ResourceSuffix["EMSFileResource1.List"] = "./";
	attributes->ResourceSuffix["EMSFileResource1.Get"] = "./{id}";
	attributes->ResourceSuffix["EMSFileResource1.Post"] = "./";
	RegisterResource(__typeinfo(TDataResource1), attributes.release());
}

#pragma startup Register 32
