unit ChangeView.Cache;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  ChangeView.DataConnection, System.SyncObjs, System.Threading;

type

  // A list of Sessions for a ChangeView based on the DeviceID as the key
  TChangeViewSessions = class(TComponent)
  type
    TChangeViewSessionItems = TDictionary<String, TChangeViewConnection>;
  strict private
    FChangeViewName: string;
    FCriticalSection : TCriticalSection;
    FSessions : TChangeViewSessionItems;
    procedure EnterCriticalSection;
    procedure LeaveCriticalSection;
    function GetCount: Integer;
  public
    constructor Create(AOwner : TComponent; AChangeViewName : String); reintroduce;
    destructor Destroy; override;

    function FindSession(ADeviceID : string):TChangeViewConnection;
    function NewSession(ADeviceID : string):TChangeViewConnection;
    procedure CloseSession(ADeviceID : string);
    procedure CloseInactiveSession(InactiveTimeInSeconds : Integer);
    procedure GetStats(AOutput: TStrings);

    property Count : Integer read GetCount;
    property ChangeViewName : string read FChangeViewName;
  end;


   // ChangeView Name and a List of Sessions for that ChangeView
  TChangeViewSessionList = TDictionary<String, TChangeViewSessions>;

  TChangeViewSessionManager = class(TComponent)
  strict private
    FChangeViewSessionList : TChangeViewSessionList;
    FCriticalSectionManager : TCriticalSection;

    procedure EnterCriticalSection;
    procedure LeaveCriticalSection;
  public
    constructor Create(AOwner : TComponent); Reintroduce;
    destructor Destroy; override;

    function FindDeviceSession(const ChangeViewName : string; const DeviceID : string; AutoCreate : Boolean = False):  TChangeViewConnection;
    function FindChangeViewSessions(const ChangeViewName : string; AutoCreate : Boolean = False): TChangeViewSessions;

    procedure Sweep(SecondsInactive : Integer);

    procedure GetStats(AOutput: TStrings; const QuickStats : Boolean = False);
  end;

var
  FChangeViewSessionManager : TChangeViewSessionManager;

  function ChangeViewSessions : TChangeViewSessionManager;


implementation

uses System.DateUtils;


function ChangeViewSessions : TChangeViewSessionManager;
begin
  Result := FChangeViewSessionManager;
end;


constructor TChangeViewSessionManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCriticalSectionManager := TCriticalSection.Create;
  FChangeViewSessionList := TChangeViewSessionList.Create;
end;

destructor TChangeViewSessionManager.Destroy;
begin
  FChangeViewSessionList.Free;
  FCriticalSectionManager.Free;
  inherited Destroy;
end;

procedure TChangeViewSessionManager.EnterCriticalSection;
begin
  FCriticalSectionManager.Enter;
end;

function TChangeViewSessionManager.FindChangeViewSessions(
  const ChangeViewName: string; AutoCreate : Boolean = False): TChangeViewSessions;
var
  FChangeViewSessions : TChangeViewSessions;
begin
  FChangeViewSessionList.TryGetValue(ChangeViewName, FChangeViewSessions);

  if (FChangeViewSessions = nil) and AutoCreate then
  begin
    FCriticalSectionManager.Enter;
    try
      FChangeViewSessions := TChangeViewSessions.Create(Self, ChangeViewName);
      if not FChangeViewSessionList.TryAdd(ChangeViewName,FChangeViewSessions) then
      begin
        FChangeViewSessions.Free;
        Exit(nil);
      end;
    finally
      FCriticalSectionManager.Leave;
    end;
  end;

  Result := FChangeViewSessions;

end;

function TChangeViewSessionManager.FindDeviceSession(const ChangeViewName : string; const DeviceID : string; AutoCreate : Boolean = False):  TChangeViewConnection;
var
  FChangeViewSessions : TChangeViewSessions;

begin
  FChangeViewSessions := FindChangeViewSessions(ChangeViewName, AutoCreate);

  if FChangeViewSessions <> nil then begin

    var FCurrSession := FChangeViewSessions.FindSession(DeviceID);

    if (FCurrSession = nil) and AutoCreate then
    begin
      FCurrSession := FChangeViewSessions.NewSession(DeviceID);
    end;

    Result := FCurrSession;
    Result.MarkAsActive;

  end else
    Result := nil;

end;

procedure TChangeViewSessionManager.GetStats(AOutput: TStrings; const QuickStats : Boolean);

  procedure Log(s : string);
  begin
    AOutput.Add(s);
  end;

begin
  AOutput.BeginUpdate;
  try
    AOutput.Clear;

    Log( Format('Total ChangeViews : %d',[FChangeViewSessionList.Count] ));
    Log( '' );
    for var CVS in FChangeViewSessionList do begin

      if QuickStats then
        Log( Format('-- ChangeView : %s [%d Sessions] --',[CVS.Value.ChangeViewName, CVS.Value.Count] ))
      else
        CVS.Value.GetStats(AOutput);

      Log( '' );

    end;


  finally
    AOutput.EndUpdate;
  end;
end;


procedure TChangeViewSessionManager.LeaveCriticalSection;
begin
  FCriticalSectionManager.Leave;
end;

procedure TChangeViewSessionManager.Sweep(SecondsInactive: Integer);
begin
  var FCloseList := TStringList.Create;
  try
    EnterCriticalSection;
    try
      for var FChangeViewList in FChangeViewSessionList do
      begin
        FChangeViewList.Value.CloseInactiveSession(SecondsInactive);
        if FChangeViewList.Value.Count = 0 then
        begin
          FCloseList.Add(FChangeViewList.Key);
        end;
      end;

      for var S in FCloseList do
        FChangeViewSessionList.Remove(S);

    finally
      LeaveCriticalSection;
    end;

  finally
    FCloseList.Free;
  end;

end;

{ TChangeViewSessions }

procedure TChangeViewSessions.CloseInactiveSession(
  InactiveTimeInSeconds: Integer);
begin
  var CloseList := TStringList.Create;
  try
    EnterCriticalSection;
    try
      for var FCurrSession in FSessions do
      begin
        if FCurrSession.Value.LatestActivity.IncSecond(InactiveTimeInSeconds) < Now then
        begin
           CloseList.Add(FCurrSession.Key);
        end;
      end;
    finally
      LeaveCriticalSection;
    end;

    for var FDeviceID in CloseList do
      CloseSession(FDeviceID);

  finally
    CloseList.Free;
  end;
end;

procedure TChangeViewSessions.CloseSession(ADeviceID: string);
begin
  EnterCriticalSection;
  try
    var FCurrSession := FindSession(ADeviceID);
    if FCurrSession <> nil then
    begin
      FSessions.Remove(ADeviceID);
      FCurrSession.Free;
    end;
  finally
    LeaveCriticalSection;
  end;
end;

constructor TChangeViewSessions.Create(AOwner: TComponent;
  AChangeViewName: String);
begin
  inherited Create(AOwner);
  FCriticalSection := TCriticalSection.Create;
  FChangeViewName := AChangeViewName;
  FSessions := TChangeViewSessionItems.Create;
end;

destructor TChangeViewSessions.Destroy;
begin
  FSessions.Free;
  FCriticalSection.Free;
  inherited;
end;

procedure TChangeViewSessions.EnterCriticalSection;
begin
  FCriticalSection.Enter;
end;

function TChangeViewSessions.FindSession(
  ADeviceID: string): TChangeViewConnection;
var
  FFoundSession : TChangeViewConnection;
begin
  FSessions.TryGetValue(ADeviceID, FFoundSession);
  Result := FFoundSession;
end;

function TChangeViewSessions.GetCount: Integer;
begin
  Result := FSessions.Count;
end;

procedure TChangeViewSessions.GetStats(AOutput: TStrings);

  procedure Log(s : string);
  begin
    AOutput.Add(s);
  end;

begin
  AOutput.BeginUpdate;
  try
    Log( Format('-- ChangeView : %s [%d Sessions] --',[ChangeViewName, FSessions.Count] ));
    for var CurrSession in FSessions do begin
      Log( Format('Device : %s  [Active %s]',[CurrSession.Value.DeviceID, DateTimeToStr(CurrSession.Value.LatestActivity)]) );
      Log('');
    end;
  finally
    AOutput.EndUpdate;
  end;
end;

procedure TChangeViewSessions.LeaveCriticalSection;
begin
  FCriticalSection.Leave;
end;

function TChangeViewSessions.NewSession(
  ADeviceID: string): TChangeViewConnection;
begin
  if FindSession(ADeviceID) <> nil then
    CloseSession(ADeviceID);

  var FNewSession := TChangeViewConnection.Create(Self,aDeviceID,ChangeViewName);

  EnterCriticalSection;
  try
    if not FSessions.TryAdd(ADeviceID, FNewSession) then
      FNewSession.Free;
  finally
    LeaveCriticalSection;
  end;

  // Get from list incase of issue adding
  Result := FindSession(ADeviceID);

end;

initialization
  FChangeViewSessionManager := TChangeViewSessionManager.Create(nil);

finalization
  try
    FreeAndNil(FChangeViewSessionManager);
  except
  end;



end.
