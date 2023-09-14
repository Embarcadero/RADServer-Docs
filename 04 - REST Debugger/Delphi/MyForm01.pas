unit MyForm01;

interface

uses
	System.SysUtils,
	System.Types,
	System.UITypes,
	System.Classes,
	System.Variants,
	FMX.Types,
	FMX.Controls,
	FMX.Forms,
	FMX.Graphics,
	FMX.Dialogs,
	System.Rtti,
	FMX.Grid.Style,
	System.Actions,
	FMX.ActnList,
	FMX.StdCtrls,
	FMX.Controls.Presentation,
	FMX.ScrollBox,
	FMX.Grid,
	FMX.Layouts,
	REST.Types,
	FireDAC.Stan.Intf,
	FireDAC.Stan.Option,
	FireDAC.Stan.Param,
	FireDAC.Stan.Error,
	FireDAC.DatS,
	FireDAC.Phys.Intf,
	FireDAC.DApt.Intf,
	Data.Bind.EngExt,
	FMX.Bind.DBEngExt,
	FMX.Bind.Grid,
	System.Bindings.Outputs,
	FMX.Bind.Editors,
	Data.Bind.Components,
	Data.Bind.Grid,
	Data.Bind.DBScope,
	Data.DB,
	FireDAC.Comp.DataSet,
	FireDAC.Comp.Client,
	REST.Response.Adapter,
	REST.Client,
	Data.Bind.ObjectScope;

type
	TForm1 = class(TForm)
		Layout1: TLayout;
		Grid1: TGrid;
		ActionList1: TActionList;
		ActSendGETRequest: TAction;
		Button1: TButton;
		RESTClient1: TRESTClient;
		RESTRequest1: TRESTRequest;
		RESTResponse1: TRESTResponse;
		RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
		FDMemTable1: TFDMemTable;
		BindSourceDB1: TBindSourceDB;
		BindingsList1: TBindingsList;
		LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
		procedure ActSendGETRequestExecute(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.ActSendGETRequestExecute(Sender: TObject);
begin
	RESTRequest1.Execute;
end;

end.
