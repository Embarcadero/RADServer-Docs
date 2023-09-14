// EMS Resource Modules
//---------------------------------------------------------------------------

#ifndef MyDMUnitH
#define MyDMUnitH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <EMS.Services.hpp>
#include <EMS.ResourceAPI.hpp>
#include <EMS.ResourceTypes.hpp>
#include <Data.DB.hpp>
#include <EMS.DataSetResource.hpp>
#include <FireDAC.Comp.Client.hpp>
#include <FireDAC.Comp.DataSet.hpp>
#include <FireDAC.ConsoleUI.Wait.hpp>
#include <FireDAC.DApt.hpp>
#include <FireDAC.DApt.Intf.hpp>
#include <FireDAC.DatS.hpp>
#include <FireDAC.Phys.hpp>
#include <FireDAC.Phys.IB.hpp>
#include <FireDAC.Phys.IBDef.hpp>
#include <FireDAC.Phys.Intf.hpp>
#include <FireDAC.Stan.Async.hpp>
#include <FireDAC.Stan.Def.hpp>
#include <FireDAC.Stan.Error.hpp>
#include <FireDAC.Stan.Intf.hpp>
#include <FireDAC.Stan.Option.hpp>
#include <FireDAC.Stan.Param.hpp>
#include <FireDAC.Stan.Pool.hpp>
#include <FireDAC.UI.Intf.hpp>
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)
class TTestResource1 : public TDataModule
{
__published:
    TFDConnection *FDConnection1;
    TFDQuery *qryCUSTOMER;
    TEMSDataSetResource *dsrCUSTOMER;
    TFDQuery *qrySALES;
    TEMSDataSetResource *dsrSALES;
	TDataSource *dsCUSTOMER;

private:

public:
	__fastcall TTestResource1(TComponent* Owner);
	// Returns an array with all the customers and a nested array with all the customer's sales
	void GetCustomersDetails(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	// Returns a JSON object with the specified customer number and a nested array with all the customer's sales
	void GetCustomerDetails(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	// Custom mock POST method
	void PostCustomEndPoint(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	// If the query has a masterfield defined, it retuns a StringList of all the fields but the masterfield one
	TStringList* ExcludeMasterFieldFromFields(TFDQuery* ADataset);
// Serializes a Master/Detail relationship into a JSON Object with the detail query nested as a JSON array in the same object
	TJSONObject* SerializeMasterDetail(TFDQuery* AMasterDataset, TFDQuery* ADetailDataset, System::UnicodeString APropertyName, TStringList* AFields = NULL);
};
#endif
