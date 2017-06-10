object frmDownloadFile: TfrmDownloadFile
  Left = 0
  Top = 0
  Width = 283
  Height = 49
  TabOrder = 0
  DesignSize = (
    283
    49)
  object imgPreview: TImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  object lblFileName: TLabel
    Left = 52
    Top = 6
    Width = 182
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblFileName'
    ExplicitWidth = 169
  end
  object btnStatus: TSpeedButton
    Left = 251
    Top = 12
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    ExplicitLeft = 203
  end
  object pbFile: TProgressBar
    Left = 46
    Top = 25
    Width = 185
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Position = 75
    TabOrder = 0
  end
  object stDuration: TStaticText
    Left = 80
    Top = 25
    Width = 54
    Height = 17
    BevelInner = bvNone
    BevelOuter = bvNone
    Caption = 'stDuration'
    TabOrder = 1
    StyleElements = [seFont]
  end
end
