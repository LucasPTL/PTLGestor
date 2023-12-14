unit ptlgestor.model.tarefas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ptlgestor.dm, ZDataset;
type

  { TModelTarefa }

  TModelTarefa = class
    private
      FDataConclusao: TDateTime;
      FDescTarefa: String;
      FIdLista: String;
      FIdTarefa: String;
      FRetorno: String;
      FTituloTarefa: String;
    public
      property Retorno:String read FRetorno write FRetorno;
      property IdLista:String read FIdLista write FIdLista;
      property IdTarefa:String read FIdTarefa write FIdTarefa;
      property TituloTarefa:String read FTituloTarefa write FTituloTarefa;
      property DescTarefa:String read FDescTarefa write FDescTarefa;
      property DataConclusao:TDateTime read FDataConclusao write FDataConclusao;
      procedure Gravar;
      procedure Excluir;
  end;

implementation

{ TModelTarefa }

procedure TModelTarefa.Gravar;
var
  LQuery: TZQuery;
begin
   try
    LQuery := TZQuery.Create(Nil);
    LQuery.Connection := DM.Conexao;
    DM.Conexao.StartTransaction;
    if FIdTarefa = '' then
    begin
       LQuery.SQL.Add('INSERT INTO TAREFAS_ITENS (ID, ID_LISTA, TITULO, DESCRICAO, DATA_CONCLUSAO, DATA_EXCLUSAO) VALUES(GEN_ID(GEN_IDTAREFA, 1), :pidlista, :ptitulo, :pdesc, :pdataconclusao, NULL)');
       LQuery.ParamByName('pidlista').AsString := FIdLista;
    end
    else
    begin
       LQuery.SQL.Add('UPDATE TAREFAS_ITENS SET TITULO = :ptitulo, DESCRICAO = :pdesc, DATA_CONCLUSAO = :pdataconclusao where ID = :pidtarefa');
       LQuery.ParamByName('pidtarefa').AsString := FIdTarefa;
    end;
    LQuery.ParamByName('ptitulo').AsString := FTituloTarefa;
    LQuery.ParamByName('pdesc').AsString := FDescTarefa;
    LQuery.ParamByName('pdataconclusao').AsDate := FDataConclusao;
    LQuery.ExecSQL;
    LQuery.Free;
    DM.Conexao.Commit;
  except
    on E: Exception do
    begin
      Retorno := 'Erro ao gravar tarefa: ' +  E.ClassName +  '/' +  E.Message;
      DM.Conexao.Rollback;
    end;
  end;
end;

procedure TModelTarefa.Excluir;
var
  LQuery: TZQuery;
begin
  try
    LQuery := TZQuery.Create(Nil);
    LQuery.Connection := DM.Conexao;
    DM.Conexao.StartTransaction;
    try
      LQuery.SQL.Add('UPDATE TAREFAS_ITENS SET DATA_EXCLUSAO = CURRENT_TIMESTAMP WHERE ID = :pidtarefa');
      LQuery.ParamByName('pidtarefa').AsString := FIdTarefa;
      LQuery.ExecSQL;
      DM.Conexao.Commit;
    except
      on E: Exception do
      begin
        Retorno := 'Erro ao excluir tarefa: ' +  E.ClassName +  '/' +  E.Message;
        DM.Conexao.Rollback;
      end;
    end;
  finally
    LQuery.Free;
  end;
end;

end.

