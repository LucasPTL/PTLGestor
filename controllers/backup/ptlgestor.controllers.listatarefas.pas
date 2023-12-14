unit ptlgestor.controllers.listatarefas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ptlgestor.model.listatarefas;
type
  { TControllerListaTarefas }
  TControllerListaTarefas = class
    private
    public
      function Excluir(IdLista: String): String;
      function Gravar(IdLista:String;DescLista:String):String;
  end;

implementation

{ TControllerListaTarefas }

function TControllerListaTarefas.Gravar(IdLista: String; DescLista: String): String;
var
  LListaTarefas: TModelListaTarefas;
  LRetorno: String;
begin
  LListaTarefas := TModelListaTarefas.Create;
  try
    try
      LListaTarefas.IdLista := IdLista;
      LListaTarefas.DescLista := IdLista;
      LListaTarefas.Gravar;
      LRetorno := LListaTarefas.Retorno;
    except
      on E: Exception do
      LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
    end;
  finally
    LListaTarefas.Free;
    Result := LRetorno;
  end;
end;

function TControllerListaTarefas.Excluir(IdLista: String): String;
var
  LListaTarefas: TModelListaTarefas;
  LRetorno: String;
begin
  LListaTarefas := TModelListaTarefas.Create;
  try
    try
      LListaTarefas.IdLista := IdLista;
      LListaTarefas.Excluir;
      LRetorno := LListaTarefas.Retorno;
    except
      on E: Exception do
      LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
    end;
  finally
    LListaTarefas.Free;
    Result := LRetorno;
  end;
end;
end.

