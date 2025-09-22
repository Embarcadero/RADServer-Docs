unit HighScores.API;

// EMS Resource Module

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  EMS.Services, EMS.ResourceAPI, EMS.ResourceTypes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.IB, FireDAC.Phys.IBDef, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  EMS.DataSetResource, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  ChangeView.Cache, HighScores.Params;

type
  [ResourceName('highscores')]
  TdataHighscoresResource = class(TDataModule)
    FDConnection1: TFDConnection;
    qryHIGHSCORES: TFDQuery;

    [ResourceSuffix('./')]
    dsrHIGHSCORES: TEMSDataSetResource;
  published

    [ResourceSuffix('./CHANGEVIEW/ACTIVATE')]
    procedure GetActivateChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

    [ResourceSuffix('./CHANGEVIEW/QUERY')]
    procedure GetQueryChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

    [ResourceSuffix('./CHANGEVIEW/COMMIT')]
    procedure GetCommitChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

    [ResourceSuffix('./CHANGEVIEW/ROLLBACK')]
    procedure GetRollBackChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses Data.DBJson;

{$R *.dfm}

procedure TdataHighscoresResource.GetActivateChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  // Get the ChangeView Name and the Device ID
  // Return the Internal Session ID where the DataModule with the active transaction is stored.
  var Params := TChangeViewParams.Create(AContext, ARequest, AResponse);

  var CVS := ChangeViewSessions.FindDeviceSession(Params.ChangeViewName, Params.DeviceID, True);
  CVS.Activate;

  if CVS <> nil then
    AResponse.Body.SetValue(TJSONString.Create(CVS.SubscriptionName+' Active for '+CVS.DeviceID), True)
  else
    AResponse.Body.SetValue(TJSONString.Create('Active failed'), True);

end;

procedure TdataHighscoresResource.GetQueryChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  // AResponse.Body.SetValue(TJSONString.Create('Query ChangeView'), True);
  var Params := TChangeViewParams.Create(AContext, ARequest, AResponse);

  var CVS := ChangeViewSessions.FindDeviceSession(Params.ChangeViewName, Params.DeviceID, True);

  if CVS.FDConnection.Transaction.Active = False then
    CVS.Activate;

  var QueryOption : string := ARequest.Params.Values['query'];

  if LowerCase(QueryOption) = 'count'  then
  begin
    CVS.qryData.Open('SELECT COUNT(*) as "COUNT" FROM HIGHSCORES')
  end else
  begin
    CVS.qryData.Open('SELECT * FROM HIGHSCORES');
  end;

  var lBridge := TDataSetToJSONBridge.Create;
  // takes the current record of the master query and converts it to a JSON object
  lBridge.Dataset := CVS.qryData;
  lBridge.IncludeNulls := True;
  // specifies that the we only require to process the current record
  lBridge.Area := TJSONDataSetArea.All;
  // adds the master record as an object in the JSON result
  lBridge.Produce(AResponse.Body.JSONWriter);

end;

procedure TdataHighscoresResource.GetCommitChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  var Params := TChangeViewParams.Create(AContext, ARequest, AResponse);
  var CVC := ChangeViewSessions.FindDeviceSession(Params.ChangeViewName, Params.DeviceID, True);
  CVC.CommitChangeView;

  // Remove from Cache... all done!!
  var CVS := ChangeViewSessions.FindChangeViewSessions(Params.ChangeViewName);
  if Assigned(CVS) then
    CVS.CloseSession(Params.DeviceID);
  AResponse.Body.SetValue(TJSONString.Create(Format('ChangeView %s for %s Commited', [Params.ChangeViewName, Params.DeviceID])), True);
end;

procedure TdataHighscoresResource.GetRollBackChangeView(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  var Params := TChangeViewParams.Create(AContext, ARequest, AResponse);
  var CVC := ChangeViewSessions.FindDeviceSession(Params.ChangeViewName, Params.DeviceID, True);
  CVC.RollBackChangeView;

  // Remove from Cache... all done!!
  var CVS := ChangeViewSessions.FindChangeViewSessions(Params.ChangeViewName);
  if Assigned(CVS) then
    CVS.CloseSession(Params.DeviceID);
  AResponse.Body.SetValue(TJSONString.Create(Format('ChangeView %s for %s Rolledback', [Params.ChangeViewName, Params.DeviceID])), True);

end;


procedure Register;
begin
  RegisterResource(TypeInfo(TdataHighscoresResource));
end;

initialization
  Register;
end.


