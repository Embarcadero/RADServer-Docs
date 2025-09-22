//---------------------------------------------------------------------------

#ifndef FormMainH
#define FormMainH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <FMX.Controls.hpp>
#include <FMX.Forms.hpp>
#include <FMX.Controls.Presentation.hpp>
#include <FMX.StdCtrls.hpp>
#include <FMX.Types.hpp>
#include <FMX.Edit.hpp>
#include <EMSHosting.EdgeHTTPListener.hpp>
#include <EMSHosting.EdgeService.hpp>
#include <EMSHosting.ExtensionsServices.hpp>
#include <FMX.ActnList.hpp>
#include <REST.Backend.EMSProvider.hpp>
#include <REST.Backend.EMSServices.hpp>
#include <REST.Backend.Providers.hpp>
#include <System.Actions.hpp>
#include <System.JSON.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:
    TPanel *Panel1;
    TLabel *Label1;
    TButton *BtnActive;
    TGroupBox *GroupBox1;
    TEdit *Edit1;
    TTrackBar *TrackBar1;
    TLabel *lblTrackValue;
    TCheckBox *CheckBox1;
    TEMSProvider *EMSProvider1;
    TEMSEdgeService *EMSEdgeService1;
    TActionList *ActionList1;
    TAction *ActivateEdgeModule;
    void __fastcall EMSEdgeService1Registered(TObject *Sender);
    void __fastcall EMSEdgeService1Unregistered(TObject *Sender);
    void __fastcall FormDestroy(TObject *Sender);
    void __fastcall ActivateEdgeModuleExecute(TObject *Sender);
    void __fastcall ActivateEdgeModuleUpdate(TObject *Sender);
private:
    bool FEdgeRegistered;
public:
    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
