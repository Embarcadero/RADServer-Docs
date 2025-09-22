// EMS Resource Modules
//---------------------------------------------------------------------------

#ifndef EdgeModuleUH
#define EdgeModuleUH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <EMS.Services.hpp>
#include <EMS.ResourceAPI.hpp>
#include <EMS.ResourceTypes.hpp>
#include <System.JSON.hpp>
#include <System.DateUtils.hpp>
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)

namespace EdgeModuleU {
    struct TFormValues
    {
        bool CheckBox;
        UnicodeString Edit;
        double TrackBar;

        TJSONObject* ToJSON();
    };

    // Global variable
	extern TFormValues FormValues;
}

class TProcessorResource1 : public TDataModule
{
__published:
private:
public:
	__fastcall TProcessorResource1(TComponent* Owner);
	void GetCalculate(TEndpointContext* AContext,
					  TEndpointRequest* ARequest,
					  TEndpointResponse* AResponse);

	void GetFormValues(TEndpointContext* AContext,
					   TEndpointRequest* ARequest,
					   TEndpointResponse* AResponse);
};

#endif
