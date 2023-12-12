unit ptlgestor.dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection;

type

  { TDM }

  TDM = class(TDataModule)
    ZConnection: TZConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
     procedure CarregarConexao;
  public

  end;

var
  DM: TDM;

implementation

{$R *.lfm}

{ TDM }

procedure TDM.DataModuleCreate(Sender: TObject);
begin

end;

procedure TDM.CarregarConexao;
var
  LocalSistema,LocalIni: String;
begin
  LocalSistema := ExtractFilePath(ParamStr(0));
  LocalIni := LocalSistema+'\Configuracoes.ini';
  if not FileExists(LocalIni) then
  begin

  end;
end;

end.

