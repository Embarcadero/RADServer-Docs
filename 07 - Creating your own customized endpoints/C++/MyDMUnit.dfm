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
      '&MacroWhere'
      '{if !SORT}order by !SORT{fi}')
    Left = 163
    Top = 20
    MacroData = <
      item
        Value = Null
        Name = 'MACROWHERE'
        DataType = mdIdentifier
      end
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrCUSTOMER: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qryCUSTOMER
    Left = 163
    Top = 96
  end
  object qrySALES: TFDQuery
    MasterSource = dsCUSTOMER
    MasterFields = 'CUST_NO'
    Connection = FDConnection1
    SQL.Strings = (
      'select * from SALES'
      'WHERE CUST_NO = :CUST_NO'
      '{if !SORT}order by !SORT{fi}')
    Left = 288
    Top = 20
    ParamData = <
      item
        Name = 'CUST_NO'
        ParamType = ptInput
      end>
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
    Top = 96
  end
  object dsCUSTOMER: TDataSource
    DataSet = qryCUSTOMER
    Left = 160
    Top = 176
  end
end
