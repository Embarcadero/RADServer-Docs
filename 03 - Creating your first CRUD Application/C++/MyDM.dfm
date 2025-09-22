object TestResource1: TTestResource1
  Height = 300
  Width = 600
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=EMPLOYEE')
    LoginPrompt = False
    Left = 30
    Top = 16
  end
  object qryCUSTOMER: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from CUSTOMER'
      '{if !SORT}order by !SORT{fi}')
    Left = 130
    Top = 16
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrCUSTOMER: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qryCUSTOMER
    Left = 130
    Top = 64
  end
  object qrySALES: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from SALES'
      '{if !SORT}order by !SORT{fi}')
    Left = 230
    Top = 16
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrSALES: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qrySALES
    Left = 230
    Top = 64
  end
end
