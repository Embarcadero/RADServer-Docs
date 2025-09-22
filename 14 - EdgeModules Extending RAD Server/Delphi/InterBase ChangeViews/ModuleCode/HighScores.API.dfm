object dataHighscoresResource: TdataHighscoresResource
  Height = 300
  Width = 600
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=sub')
    LoginPrompt = False
    Left = 46
    Top = 20
  end
  object qryHIGHSCORES: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from HIGHSCORES'
      '{if !SORT}order by !SORT{fi}')
    Left = 130
    Top = 56
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrHIGHSCORES: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qryHIGHSCORES
    Left = 186
    Top = 124
  end
end
