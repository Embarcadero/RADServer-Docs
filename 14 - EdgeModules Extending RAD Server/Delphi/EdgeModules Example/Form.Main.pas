unit Form.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.JSON, REST.Backend.EMSServices, EMSHosting.ExtensionsServices,
  EMSHosting.EdgeHTTPListener, REST.Backend.Providers,
  EMSHosting.EdgeService, REST.Backend.EMSProvider, FMX.Controls.Presentation,
  FMX.StdCtrls, System.Actions, FMX.ActnList, FMX.Edit;

type

  TForm1 = class(TForm)
    EMSProvider1: TEMSProvider;
    EMSEdgeService1: TEMSEdgeService;
    BtnActive: TButton;
    ActionList1: TActionList;
    ActivateEdgeModule: TAction;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    TrackBar1: TTrackBar;
    lblTrackValue: TLabel;
    Panel1: TPanel;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    procedure ActivateEdgeModuleUpdate(Sender: TObject);
    procedure ActivateEdgeModuleExecute(Sender: TObject);
    procedure EMSEdgeService1Registered(Sender: TObject);
    procedure EMSEdgeService1Unregistered(Sender: TObject);
  private
    FEdgeRegistered: boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses EdgeModuleU;

{$R *.fmx}

procedure TForm1.ActivateEdgeModuleExecute(Sender: TObject);
begin
  EMSEdgeService1.Active := not(EMSEdgeService1.Active);
end;

procedure TForm1.ActivateEdgeModuleUpdate(Sender: TObject);
begin
  var ButtonText := 'EdgeModule'+#13+'Active: ';
  BtnActive.Text := ButtonText + BoolToStr(FEdgeRegistered, True);
  if FEdgeRegistered then
    BtnActive.TextSettings.FontColor := TAlphaColorRec.Forestgreen
  else
    BtnActive.TextSettings.FontColor := TAlphaColorRec.Crimson;
  GroupBox1.Enabled := FEdgeRegistered;
  EdgeModuleU.FormValues.CheckBox := CheckBox1.IsChecked;
  EdgeModuleU.FormValues.Edit := Edit1.Text;
  EdgeModuleU.FormValues.TrackBar := TrackBar1.Value;
  lblTrackValue.Text := TrackBar1.Value.ToString;

end;

procedure TForm1.EMSEdgeService1Registered(Sender: TObject);
begin
  FEdgeRegistered := True;
end;

procedure TForm1.EMSEdgeService1Unregistered(Sender: TObject);
begin
  FEdgeRegistered := False;
end;

end.

initialization
  FEdgeRegistered := False;

finalization
  EMSEdgeService1.Active := False;
