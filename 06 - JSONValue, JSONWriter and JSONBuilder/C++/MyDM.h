// EMS Resource Modules
//---------------------------------------------------------------------------

#ifndef MyDMH
#define MyDMH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <EMS.Services.hpp>
#include <EMS.ResourceAPI.hpp>
#include <EMS.ResourceTypes.hpp>
#include <System.JSON.Types.hpp>
#include <System.JSON.Writers.hpp>
#include <System.JSON.Builders.hpp>
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)
class TTestResource1 : public TDataModule
{
__published:
private:
public:
	__fastcall TTestResource1(TComponent* Owner);
	void GetJSON(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	void GetJSONWriter(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	void GetJSONBuilder(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
};
#endif
