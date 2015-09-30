object frmWebTab: TfrmWebTab
  Left = 0
  Top = 0
  Width = 547
  Height = 351
  TabOrder = 0
  object ewb1: TEmbeddedWB
    Left = 0
    Top = 37
    Width = 547
    Height = 297
    Align = alClient
    TabOrder = 0
    Silent = False
    OnDocumentComplete = ewb1DocumentComplete
    DisableCtrlShortcuts = 'N'
    UserInterfaceOptions = [EnablesFormsAutoComplete, EnableThemes]
    About = ' EmbeddedWB http://bsalsa.com/'
    PrintOptions.HTMLHeader.Strings = (
      '<HTML></HTML>')
    PrintOptions.Orientation = poPortrait
    ExplicitTop = 76
    ExplicitWidth = 545
    ExplicitHeight = 257
    ControlData = {
      4C00000089380000742000000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 547
    Height = 37
    Align = alTop
    TabOrder = 1
    DesignSize = (
      547
      37)
    object edtURL: TEdit
      Left = 8
      Top = 8
      Width = 473
      Height = 21
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
    end
    object btnGo: TBitBtn
      Left = 494
      Top = 7
      Width = 45
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Go!'
      TabOrder = 1
      OnClick = btnGoClick
    end
  end
  object pbMain: TProgressBar
    Left = 0
    Top = 334
    Width = 547
    Height = 17
    Align = alBottom
    TabOrder = 2
    ExplicitLeft = 72
    ExplicitTop = 344
    ExplicitWidth = 150
  end
end
