unit ptlgestor.dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, DB, IniFiles, ZDataset;

type

  { TDM }

  TDM = class(TDataModule)
    ZConnection: TZConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
     procedure CarregarConexao;
     procedure ConfigurarBanco;

  public
    Conexao:TZConnection;
    function criptografar(const key, texto: String): String;
    function descriptografar(const key, texto: String): String;
  end;

var
  DM: TDM;
 const key:string = '061004';

implementation

{$R *.lfm}

{ TDM }

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  CarregarConexao;
end;

procedure TDM.CarregarConexao;
var
  LocalSistema,LocalIni: String;
  IniConfig: TIniFile;
begin
  LocalSistema := ExtractFilePath(ParamStr(0));
  LocalIni := LocalSistema+'configuracoes.ini';
  Conexao:=TZConnection.Create(Self);
  if FileExists(LocalIni) then
  begin
    IniConfig := TIniFile.Create(LocalIni);
    try
      with Conexao do
      begin
       Database:=IniConfig.ReadString('Banco de dados', 'Database', '');
       LibraryLocation:=IniConfig.ReadString('Banco de dados', 'LibraryLocation', '');
       User:=descriptografar(key,IniConfig.ReadString('Banco de dados', 'User', ''));
       Password:=descriptografar(key,IniConfig.ReadString('Banco de dados', 'Password', ''));
       Port:=StrToInt(IniConfig.ReadString('Banco de dados', 'Port', ''));
       Protocol:='firebird-2.5';
      end;
    finally
      Conexao.Connected:=True;
      ConfigurarBanco;
    end;
  end;
end;
procedure TDM.ConfigurarBanco;
var
  LSql:String;
begin
  with TZQuery.Create(Self) do
  begin
    Connection:=Conexao;
    try
       try
         Connection.StartTransaction;

         LSql := 'EXECUTE BLOCK AS ';
         LSql := LSql + 'DECLARE VARIABLE gerador_existente INTEGER; ';
         LSql := LSql + 'BEGIN ';
           LSql := LSql + 'SELECT COUNT(*) FROM RDB$GENERATORS WHERE RDB$GENERATOR_NAME = ''gen_id'' INTO ::gerador_existente; ';
           LSql := LSql + ' IF (gerador_existente = 0) THEN EXECUTE STATEMENT ''CREATE GENERATOR gen_id''; ';
         LSql := LSql + ' END';
         SQL.Add(LSql);
         ExecSQL;
         SQL.Clear;

         LSql := 'EXECUTE BLOCK AS ';
         LSql := LSql + 'DECLARE VARIABLE tabela_existente INTEGER; ';
         LSql := LSql + 'DECLARE VARIABLE indice_existente INTEGER; ';
         LSql := LSql + 'BEGIN ';
           LSql := LSql + 'SELECT COUNT(*) FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''tarefas'' INTO ::tabela_existente; ';
           LSql := LSql + 'SELECT COUNT(*) FROM RDB$INDICES WHERE RDB$INDEX_NAME = ''ind_id'' INTO ::indice_existente; ';
           LSql := LSql + ' IF (tabela_existente = 0) THEN EXECUTE STATEMENT ''';
             LSql := LSql + 'CREATE TABLE tarefas ( ';
               LSql := LSql + ' id INTEGER NOT NULL, ';
               LSql := LSql + ' descricao VARCHAR(255), ';
               LSql := LSql + ' data_exclusao TIMESTAMP, ';
             LSql := LSql + ' PRIMARY KEY (id) ';
             LSql := LSql + ')''; ';
           LSql := LSql + ' IF (indice_existente = 0) THEN EXECUTE STATEMENT ''CREATE INDEX ind_id ON tarefas (id)''; ';
         LSql := LSql + ' END ';
         SQL.Add(LSql);
         ExecSQL;
         SQL.Clear;

         LSql := 'EXECUTE BLOCK AS ';
         LSql := LSql + 'DECLARE VARIABLE trigger_existente INTEGER; ';
         LSql := LSql + 'BEGIN ';
         LSql := LSql + 'SELECT COUNT(*) FROM RDB$TRIGGERS WHERE RDB$TRIGGER_NAME = ''tr_id'' INTO ::trigger_existente;';
         LSql := LSql + ' IF (trigger_existente = 0) THEN EXECUTE STATEMENT ''CREATE TRIGGER tr_id FOR tarefas ACTIVE BEFORE INSERT POSITION 0 AS BEGIN new.id = gen_id(gen_id, 1); END'';';
         LSql := LSql + ' END ';
         SQL.Add(LSql);
         ExecSQL;

         Connection.Commit;
       except
         Connection.Rollback;
       end;
    finally
      Free;
    end;
  end;
end;

function TDM.criptografar(const key, texto: String): String;
var
  I: Integer;
  C: Byte;
begin
  Result := '';
  for I := 1 to Length(texto) do
  begin
    if Length(Key) > 0 then
      C := Byte(Key[1 + ((I - 1) mod Length(Key))]) xor Byte(texto[I])
    else
    C := Byte(texto[I]);
    Result := Result + AnsiLowerCase(IntToHex(C, 2));
  end;
end;

function TDM.descriptografar(const key, texto: String): String;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 0 to Length(texto) div 2 - 1 do
  begin
    C := Chr(StrToIntDef('$' + Copy(texto, (I * 2) + 1, 2), Ord(' ')));
    if Length(Key) > 0 then
      C := Chr(Byte(Key[1 + (I mod Length(Key))]) xor Byte(C));
    Result := Result + C;

  end;
end;

end.

