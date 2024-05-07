unit MyDM;

// EMS Resource Module

interface

{$REGION 'uses'}
uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.IB,
  FireDAC.Phys.IBDef,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  EMS.DataSetResource,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  ApiDocSpecs,
  Common;
{$ENDREGION}

type
  [ResourceName('test')]
  [EndPointObjectsYAMLDefinitions(cYamlDefinitions)]
  [EndPointObjectsJSONDefinitions(cJSONDefinitions)]
  TTestResource1 = class(TDataModule)
    FDConnection1: TFDConnection;
    qryCUSTOMER: TFDQuery;
    {$REGION 'Customers OpenAPI specs'}
    [EndPointRequestSummary(
      'Customers', // Tags
      'Customers', // Summary
      'Description of the Customers endpoint', // Description
      'application/json', // Produces
    '')] // Consumes
    [EndPointRequestParameter(
       TMethods.Get,
       TSpecs.ParamIn.Path, // equivalent to TAPIDocParameter.TParameterIn.Path
       'CUST_NO', // Param name
       'Customer number', //desc
       true, // required
       TSpecs.Types.spInteger, // equivalent to TAPIDoc.TPrimitiveType.spInteger
       TSpecs.Formats.Int64, // equivalent to TAPIDoc.TPrimitiveFormat.Int64
       TSpecs.Types.spInteger,
       '', // Schema
       '')] // Reference
    [EndPointRequestParameter(
       TMethods.Post,
       TSpecs.ParamIn.Body,
       'Name', // Param name
       'Description', //desc
       true, // required
       TSpecs.Types.spObject,
       TSpecs.Formats.None,
       TSpecs.Types.spObject,
       '#/definitions/customer', // Schema
       '#/definitions/customer')] // Reference
    [EndPointRequestParameter(
       TMethods.Delete,
       TSpecs.ParamIn.Path,
       'CUST_NO', // Param name
       'Customer number', //desc
       true, // required
       TSpecs.Types.spInteger,
       TSpecs.Formats.Int64,
       TSpecs.Types.spInteger,
       '', // Schema
       '')] // Reference
    [EndPointResponseDetails(TMethods.List, TStatus.Ok.Code, TStatus.Ok.Reason, TSpecs.Types.spArray, TSpecs.Formats.None, '', '#/definitions/customer')]
    [EndPointResponseDetails(TMethods.Get, TStatus.Ok.Code, TStatus.Ok.Reason, TSpecs.Types.spObject, TSpecs.Formats.None, '', '#/definitions/customer')]
    [EndPointResponseDetails(TMethods.Post, TStatus.Created.Code, TStatus.Created.Reason, TSpecs.Types.spObject, TSpecs.Formats.None, '', '#/definitions/customer')]
    [EndPointResponseDetails(TMethods.Put, TStatus.Ok.Code, TStatus.Ok.Reason, TSpecs.Types.spObject, TSpecs.Formats.None, '', '#/definitions/customer')]
    [EndPointResponseDetails(TMethods.Post, TStatus.BadRequest.Code, TStatus.BadRequest.Reason, TSpecs.Types.spNull, TSpecs.Formats.None, '', '')]
    [EndPointResponseDetails(TMethods.Get, TStatus.NotFound.Code, TStatus.NotFound.Reason, TSpecs.Types.spNull, TSpecs.Formats.None, '', '')]
    [ResourceSuffix('customers')]
    [ResourceSuffix(TMethods.List, './')]
    [ResourceSuffix(TMethods.Get, './{CUST_NO}')]
    [ResourceSuffix(TMethods.Post, './')]
    [ResourceSuffix(TMethods.Put, './{CUST_NO}')]
    [ResourceSuffix(TMethods.Delete, './{CUST_NO}')]
    {$ENDREGION}
    dsrCUSTOMER: TEMSDataSetResource;
    qrySALES: TFDQuery;
    {$REGION 'Sales OpenAPI specs'}
    [EndPointRequestSummary('Sales', 'Sales', 'Description of the Sales endpoint', 'application/json', '')]
    [EndPointRequestParameter(TMethods.Get, TSpecs.ParamIn.Path, 'PO_NUMBER', 'Sale number', true, TSpecs.Types.spString, TSpecs.Formats.None, TSpecs.Types.spString, '', '')]
    [EndPointRequestParameter(TMethods.Post, TSpecs.ParamIn.Body, 'Name', 'Description', true, TSpecs.Types.spObject, TSpecs.Formats.None, TSpecs.Types.spObject, '#/definitions/sale', '#/definitions/sale')]
    [EndPointRequestParameter(TMethods.Delete, TSpecs.ParamIn.Path, 'PO_NUMBER', 'Sale number', true, TSpecs.Types.spString, TSpecs.Formats.None, TSpecs.Types.spString, '', '')]
    [EndPointResponseDetails(TMethods.List, TStatus.Ok.Code, TStatus.Ok.Reason, TSpecs.Types.spArray, TSpecs.Formats.None, '', '#/definitions/sale')]
    [EndPointResponseDetails(TMethods.Get, TStatus.Ok.Code, TStatus.Ok.Reason, TSpecs.Types.spObject, TSpecs.Formats.None, '', '#/definitions/sale')]
    [EndPointResponseDetails(TMethods.Post, TStatus.Created.Code, TStatus.Created.Reason, TSpecs.Types.spObject, TSpecs.Formats.None, '', '#/definitions/sale')]
    [EndPointResponseDetails(TMethods.Put, TStatus.Ok.Code, TStatus.Ok.Reason, TSpecs.Types.spObject, TSpecs.Formats.None, '', '#/definitions/sale')]
    [EndPointResponseDetails(TMethods.Post, TStatus.BadRequest.Code, TStatus.BadRequest.Reason, TSpecs.Types.spNull, TSpecs.Formats.None, '', '')]
    [EndPointResponseDetails(TMethods.Get, TStatus.NotFound.Code, TStatus.NotFound.Reason, TSpecs.Types.spNull, TSpecs.Formats.None, '', '')]
    [ResourceSuffix('sales')]
    [ResourceSuffix('List', './')]
    [ResourceSuffix('Get', './{PO_NUMBER}')]
    [ResourceSuffix('Post', './')]
    [ResourceSuffix('Put', './{PO_NUMBER}')]
    [ResourceSuffix('Delete', './{PO_NUMBER}')]
    {$ENDREGION}
    dsrSALES: TEMSDataSetResource;

  published
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

procedure Register;
begin
  RegisterResource(TypeInfo(TTestResource1));
end;

initialization

Register;

end.
