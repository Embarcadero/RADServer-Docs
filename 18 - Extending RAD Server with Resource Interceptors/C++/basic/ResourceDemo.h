// EMS Resource Modules
//---------------------------------------------------------------------------

#ifndef ResourceDemoH
#define ResourceDemoH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <System.JSON.hpp>
#include <System.DateUtils.hpp>
#include <EMS.Services.hpp>
#include <EMS.ResourceAPI.hpp>
#include <EMS.ResourceTypes.hpp>
#include <EMSHosting.Helpers.hpp>
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)
class TDemoResource1 : public TDataModule, public IEMSResourceInterceptor
{
INTFOBJECT_IMPL_IUNKNOWN(TDataModule)
__published:
private:
	System::String FRequestID;
	TDateTime FStartTime;
	// FOriginalResponse field removed - no longer needed

	// Helper method
	System::String GenerateRequestID();
	bool ShouldIncludeMetadata(TEndpointRequest* ARequest);

	// Interceptor methods (called by RAD Server framework)
	void __fastcall BeforeRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse, bool& AHandled);
	void __fastcall AfterRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);

public:
	__fastcall TDemoResource1(TComponent* Owner);
	__fastcall ~TDemoResource1();

	// Resource endpoints
	void GetHello(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	void PostEcho(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
};
#endif
