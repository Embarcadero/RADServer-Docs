unit formMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.JSON, REST.Backend.EMSServices,
  EMSHosting.ExtensionsServices, EMSHosting.EdgeHTTPListener,
  REST.Backend.EMSProvider, REST.Backend.Providers, EMSHosting.EdgeService,
  Vcl.StdCtrls, ChangeView.Cache, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TForm1 = class(TForm)
    Button1: TButton;
    EMSEdgeService1: TEMSEdgeService;
    EMSProvider1: TEMSProvider;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    MemoStatus: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    TimerStatsUpdate: TTimer;
    TimerSweep: TTimer;
    btnSweep: TButton;
    seLifeSpanSeconds: TSpinEdit;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSweepClick(Sender: TObject);
    procedure TimerSweepTimer(Sender: TObject);
    procedure TimerStatsUpdateTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnSweepClick(Sender: TObject);
begin
  TimerSweep.Enabled := not TimerSweep.Enabled;
  btnSweep.Caption := 'Sweep Active = '+ BoolToStr(TimerSweep.Enabled, True);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  EMSEdgeService1.Active := not EMSEdgeService1.Active;
  Button1.Caption := 'Active = '+ BoolToStr(EMSEdgeService1.Active, True);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if EMSEdgeService1.Active then
    EMSEdgeService1.Active := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Button1.Caption := 'Active = '+ BoolToStr(EMSEdgeService1.Active, True);
end;

procedure TForm1.TimerStatsUpdateTimer(Sender: TObject);
begin
  ChangeViewSessions.GetStats(MemoStatus.Lines);
end;

procedure TForm1.TimerSweepTimer(Sender: TObject);
begin
  TimerSweep.Enabled := False;
  try
    // Removes Sessions that have passed their allowed inactive time.
    ChangeViewSessions.Sweep(seLifeSpanSeconds.Value);
  finally
    TimerSweep.Enabled := True;
  end;
end;

end.
