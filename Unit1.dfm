object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 600
  ClientWidth = 810
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pgcPages: TPageControl
    Left = 0
    Top = 0
    Width = 810
    Height = 560
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'tsMain'
      object ewbMain: TEmbeddedWB
        Left = 0
        Top = 0
        Width = 802
        Height = 532
        Align = alClient
        TabOrder = 0
        OnBeforeNavigate2 = ewbMainBeforeNavigate2
        OnNavigateComplete2 = ewbMainNavigateComplete2
        DisableCtrlShortcuts = 'N'
        UserInterfaceOptions = [EnablesFormsAutoComplete, EnableThemes]
        About = ' EmbeddedWB http://bsalsa.com/'
        PrintOptions.HTMLHeader.Strings = (
          '<HTML></HTML>')
        PrintOptions.Orientation = poPortrait
        ExplicitTop = 264
        ExplicitWidth = 675
        ExplicitHeight = 436
        ControlData = {
          4C000000021F0000810F00000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 560
    Width = 810
    Height = 40
    Align = alBottom
    Caption = 'pnl1'
    TabOrder = 1
    object cbxLog: TComboBox
      Left = 1
      Top = 1
      Width = 623
      Height = 21
      Align = alClient
      Style = csDropDownList
      TabOrder = 0
    end
    object pnl2: TPanel
      Left = 624
      Top = 1
      Width = 185
      Height = 38
      Align = alRight
      Caption = 'pnl2'
      TabOrder = 1
      object pbProgressCurrent: TProgressBar
        Left = 1
        Top = 21
        Width = 183
        Height = 20
        Align = alTop
        TabOrder = 0
      end
      object pbCount: TProgressBar
        Left = 1
        Top = 1
        Width = 183
        Height = 20
        Align = alTop
        TabOrder = 1
      end
    end
  end
  object mmMain: TMainMenu
    Left = 364
    Top = 36
    object gototvrain1: TMenuItem
      Caption = 'go to tvrain'
    end
    object mniDownload: TMenuItem
      Caption = 'Download and Close'
      OnClick = mniDownloadClick
    end
    object mniLog: TMenuItem
      Caption = 'Log'
    end
    object mniWowMp3: TMenuItem
      Caption = 'Get '#1054#1089#1090#1088#1086#1074' '#1075#1088#1086#1084#1072
      OnClick = mniWowMp3Click
    end
    object mniFastMM1: TMenuItem
      Caption = 'FastMM'
      OnClick = mniFastMM1Click
    end
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 552
  end
  object tmr1: TTimer
    Interval = 500
    OnTimer = tmr1Timer
    Left = 592
    Top = 8
  end
end
