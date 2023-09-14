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
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)
class TTestResource1 : public TDataModule
{
__published:
private:
public:
	__fastcall TTestResource1(TComponent* Owner);
	void Get(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	void GetItem(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
};
#endif
