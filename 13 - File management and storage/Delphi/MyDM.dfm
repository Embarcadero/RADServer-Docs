object DataResource1: TDataResource1
  Height = 136
  Width = 145
  object EMSFileResource1: TEMSFileResource
    AllowedActions = [List, Get, Post, Put, Delete]
    PathTemplate = 'c:\uploads\{id}'
    DefaultFile = 'index.html'
    Left = 48
    Top = 32
  end
end
