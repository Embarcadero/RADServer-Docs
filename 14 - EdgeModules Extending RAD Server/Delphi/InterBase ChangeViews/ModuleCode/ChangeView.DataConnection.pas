unit ChangeView.DataConnection;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.IB,
  FireDAC.Phys.IBDef, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TChangeViewConnection = class(TDataModule)
    FDConnection: TFDConnection;
    qryData: TFDQuery;
    qryActivateChangeView: TFDQuery;
    FDTransaction1: TFDTransaction;
  private
    FLastCalled : TDateTime;
    function GetDeviceID: string;
    function GetSubscriptionName: string;

    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner : TComponent; Const ADeviceID, ASubscription : String);
    destructor Destroy; override;

    procedure Activate;

    procedure CommitChangeView;
    procedure RollBackChangeView;
    // Updates the date time for a last made change
    procedure MarkAsActive;

    property DeviceID : string read GetDeviceID;
    property SubscriptionName : string read GetSubscriptionName;
    property LatestActivity : TDateTime read FLastCalled;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


procedure TChangeViewConnection.Activate;
begin
  if not FDConnection.Connected then
    FDConnection.Connected := True;

  if not FDConnection.Transaction.Active then
    FDConnection.StartTransaction;

  qryActivateChangeView.ExecSQL;

  MarkAsActive;
end;

procedure TChangeViewConnection.CommitChangeView;
begin
  if FDConnection.Transaction.Active then
    FDConnection.Commit;

  MarkAsActive;
end;

{ TdataHighScoreConnection }

constructor TChangeViewConnection.Create(AOwner: TComponent; const ADeviceID, ASubscription: String);
begin
  Assert(ADeviceID > '','Invalid DeviceID');
  Assert(ASubscription > '','Invalid Subscription');

  inherited Create(AOwner);

  qryActivateChangeView.MacroByName('SubscriptionName').AsString := ASubscription; //'sub_highscore';
  qryActivateChangeView.MacroByName('DeviceID').AsString := ADeviceID;

  MarkAsActive;
end;

destructor TChangeViewConnection.Destroy;
begin
  if FDConnection.Transaction.Active then
    RollBackChangeView;
  inherited;
end;

function TChangeViewConnection.GetDeviceID: string;
begin
  Result := qryActivateChangeView.MacroByName('DeviceID').AsString;
end;

procedure TChangeViewConnection.MarkAsActive;
begin
  FLastCalled := Now;
end;

procedure TChangeViewConnection.RollBackChangeView;
begin
  if FDConnection.Transaction.Active then
    FDConnection.Rollback;

  MarkAsActive;
end;

function TChangeViewConnection.GetSubscriptionName : string;
begin
  Result := qryActivateChangeView.MacroByName('SubscriptionName').AsString;
end;

end.
