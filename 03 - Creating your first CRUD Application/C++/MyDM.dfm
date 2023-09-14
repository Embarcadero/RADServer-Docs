object TestResource1: TTestResource1
  Height = 375
  Width = 750
  PixelsPerInch = 120
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=EMPLOYEE')
    LoginPrompt = False
    Left = 38
    Top = 20
  end
  object qryCUSTOMER: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from CUSTOMER'
      '{if !SORT}order by !SORT{fi}')
    Left = 163
    Top = 20
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrCUSTOMER: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qryCUSTOMER
    Left = 163
    Top = 80
  end
  object qrySALES: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from SALES'
      '{if !SORT}order by !SORT{fi}')
    Left = 288
    Top = 20
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrSALES: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qrySALES
    Left = 288
    Top = 80
  end
end
