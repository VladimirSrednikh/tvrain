unit untfrmWebTab;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.OleCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  SHDocVw, MSHTML;

type
  TfrmWebTab = class(TFrame)
    ewb1: TWebBrowser;
    pnlTop: TPanel;
    edtURL: TEdit;
    btnGo: TBitBtn;
    pbMain: TProgressBar;
    procedure btnGoClick(Sender: TObject);
    procedure ewb1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Navigate(AURL: string);
  end;

implementation

{$R *.dfm}

procedure TfrmWebTab.btnGoClick(Sender: TObject);
begin
  ewb1.Navigate(edtURL.Text);
end;

procedure TfrmWebTab.ewb1NavigateComplete2(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
begin
//  OutputDebugString(PChar('DocumentComplete: ' + string(URL) + ' ; ewb1.Doc2.location.href = ' + ewb1.Doc2.location.href));
  if SameText(URL, (ewb1.Document as IHTMLDocument2).location.href) then
    if Parent is TTabSheet then
    begin
      (Parent as TTabSheet).Caption := (ewb1.Document as IHTMLDocument2).title;
    end;
end;

procedure TfrmWebTab.Navigate(AURL: string);
begin
  edtURL.Text := AURL;
  ewb1.Navigate(AURL);
end;

end.
