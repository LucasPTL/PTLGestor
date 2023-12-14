unit ptlgestor.model.listatarefas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ptlgestor.dm, ZDataset;
type

  { TModelListaTarefas }

  TModelListaTarefas = class
    private
      FDescLista: String;
      FIdLista: String;
      FRetorno: String;
    public
      property IdLista:String read FIdLista write FIdLista;
      property DescLista:String read FDescLista write FDescLista;
      property Retorno:String read FRetorno write FRetorno;
      procedure Gravar;
      procedure Excluir;
  end;

implementation

{ TModelListaTarefas }

procedure TModelListaTarefas.Gravar;
var
  LQuery: TZQuery;
begin
  try
    LQuery := TZQuery.Create(Nil);
    LQuery.Connection := DM.Conexao;
    LQuery.SQL.Add('SELECT * FROM TAREFAS WHERE Lower(DESCRICAO) = :pdesc and ID <> :pidlista and DATA_EXCLUSAO is null');
    LQuery.ParamByName('pidlista').AsString := FIdLista;
    LQuery.ParamByName('pdesc').AsString := FDescLista;
    LQuery.Open;
    if not LQuery.eof then
    begin
      Retorno :='Nome de lista já em uso.';
      LQuery.Free;
    end
    else
    begin
      LQuery.SQL.Clear;
      DM.Conexao.StartTransaction;
      if FIdLista = '' then
         LQuery.SQL.Add('INSERT INTO TAREFAS (ID, DESCRICAO, DATA_EXCLUSAO) VALUES(GEN_ID(GEN_ID, 1), :pdesc, NULL)')
      else
      begin
         LQuery.SQL.Add('UPDATE TAREFAS SET DESCRICAO = :pdesc where ID = :pidlista');
         LQuery.ParamByName('pidlista').AsString := FIdLista;
      end;
      LQuery.ParamByName('pdesc').AsString := FDescLista;
      LQuery.ExecSQL;
      LQuery.Free;
      DM.Conexao.Commit;
    end;
  except
    on E: Exception do
    begin
      Retorno := 'Erro ao criar lista: ' +  E.ClassName +  '/' +  E.Message;
      DM.Conexao.Rollback;
    end;
  end;
end;

procedure TModelListaTarefas.Excluir;
var
  LQuery: TZQuery;
begin
  Retorno := '';
  LQuery := TZQuery.Create(Nil);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Clear;
  try
    try
      DM.Conexao.StartTransaction;
      LQuery.SQL.Add('update TAREFAS set DATA_EXCLUSAO = CURRENT_TIMESTAMP WHERE ID = :pidlista');
      LQuery.ParamByName('pidlista').AsString:=FIdLista;
      LQuery.ExecSQL;
      DM.Conexao.Commit;
    except
      on E: Exception do
      begin
        Retorno :='Erro ao excluir lista: ' +  E.ClassName +  '/' +  E.Message;
        DM.Conexao.Rollback;
      end;
    end;
  finally
    LQuery.Free;
  end;
end;

end.

