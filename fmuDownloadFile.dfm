object frmDownloadFile: TfrmDownloadFile
  Left = 0
  Top = 0
  Width = 270
  Height = 44
  TabOrder = 0
  DesignSize = (
    270
    44)
  object imgPreview: TImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  object lblFileName: TLabel
    Left = 52
    Top = 6
    Width = 169
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblFileName'
  end
  object btnStatus: TSpeedButton
    Left = 238
    Top = 12
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    ExplicitLeft = 203
  end
  object pbFile: TProgressBar
    Left = 52
    Top = 21
    Width = 172
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
  end
end
