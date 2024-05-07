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
#include <EMS.FileResource.hpp>
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)
class TDataResource1 : public TDataModule
{
__published:
	TEMSFileResource *EMSFileResource1;
private:
public:
	__fastcall TDataResource1(TComponent* Owner);
	void PostUpload(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
};
#endif
