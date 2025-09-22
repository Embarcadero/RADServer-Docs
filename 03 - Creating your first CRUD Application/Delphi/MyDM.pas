unit MyDM;

// EMS Resource Module

interface

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
  FireDAC.Comp.Client;

type

  [ResourceName('test')]
  TTestResource1 = class(TDataModule)
    FDConnection1: TFDConnection;
    qryCUSTOMER: TFDQuery;
    [ResourceSuffix('customers')]
    [ResourceSuffix('Get', './{CUST_NO}')]
    [ResourceSuffix('Post', './')]
    [ResourceSuffix('Put', './{CUST_NO}')]
    [ResourceSuffix('Delete', './{CUST_NO}')]
    dsrCUSTOMER: TEMSDataSetResource;
    qrySALES: TFDQuery;
    [ResourceSuffix('sales')]
    [ResourceSuffix('Get', './{PO_NUMBER}')]
    [ResourceSuffix('Post', './')]
    [ResourceSuffix('Put', './{PO_NUMBER}')]
    [ResourceSuffix('Delete', './{PO_NUMBER}')]
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
