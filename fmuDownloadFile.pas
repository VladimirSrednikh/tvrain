unit fmuDownloadFile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ComCtrls,
  untM3U;

type
  TFrmDownloadFile = class(TFrame)
    imgPreview: TImage;
    lblFileName: TLabel;
    btnStatus: TSpeedButton;
    pbFile: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
    EagleId: Integer;
    constructor CreateFrame(APlayList: TM3UPlayList; AOwner: TControl);
  end;

implementation

{$R *.dfm}

{ TFrmDownloadFile }

constructor TFrmDownloadFile.CreateFrame(APlayList: TM3UPlayList; AOwner: TControl);
begin
  inherited Create(AOwner);
  Name := '';
  EagleId := APlayList.FPlayerId;
  if AOwner is TWinControl then
    Parent := AOwner as TWinControl;
  lblFileName.Caption := APlayList.Title;
  pbFile.Max := APlayList.TrackCount;
  pbFile.Position := 0;
  pbFile.Visible := True;
  Self.Align := alTop;
  if (Self.Top + Self.Height) > AOwner.Height then
    AOwner.Height := Self.Top + Self.Height;
end;

end.
