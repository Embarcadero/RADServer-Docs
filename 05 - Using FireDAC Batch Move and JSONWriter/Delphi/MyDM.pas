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
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.JSON,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Comp.BatchMove.DataSet,
  FireDAC.Stan.StorageJSON;

type

  [ResourceName('FireDAC')]
  TFireDACResource1 = class(TDataModule)
    EmployeeConnection: TFDConnection;
    EmployeeQuery: TFDQuery;
    FDBatchMoveJSONWriter1: TFDBatchMoveJSONWriter;
    FDBatchMove1: TFDBatchMove;
    FDBatchMoveDataSetReader1: TFDBatchMoveDataSetReader;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
  published

    procedure Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);

    [ResourceSuffix('BatchMove')]
    procedure GetBatchMove(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

procedure TFireDACResource1.Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  var mStream := TMemoryStream.Create;
  AResponse.Body.SetStream(mStream, 'application/json', True);
  EmployeeQuery.Open;
  EmployeeQuery.SaveToStream(mStream, sfJSON);
end;

procedure TFireDACResource1.GetBatchMove(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  FDBatchMoveJSONWriter1.JsonWriter := AResponse.Body.JsonWriter;
  FDBatchMove1.Execute;
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TFireDACResource1));
end;

initialization

Register;

end.
