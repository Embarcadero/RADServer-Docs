object TestResource1: TTestResource1
  Height = 289
  Width = 940
  PixelsPerInch = 120
  object EmployeeConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=EMPLOYEE')
    Connected = True
    Left = 120
    Top = 50
  end
  object EmployeeQuery: TFDQuery
    Connection = EmployeeConnection
    SQL.Strings = (
      'SELECT *'
      'FROM employee')
    Left = 120
    Top = 150
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 340
    Top = 110
  end
  object FDBatchMove1: TFDBatchMove
    Reader = FDBatchMoveDataSetReader1
    Writer = FDBatchMoveJSONWriter1
    Mappings = <>
    LogFileName = 'Data.log'
    Left = 570
    Top = 50
  end
  object FDBatchMoveDataSetReader1: TFDBatchMoveDataSetReader
    DataSet = EmployeeQuery
    Left = 570
    Top = 140
  end
  object FDBatchMoveJSONWriter1: TFDBatchMoveJSONWriter
    DataDef.Fields = <>
    Left = 780
    Top = 110
  end
end
