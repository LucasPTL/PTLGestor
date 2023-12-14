unit ptlgestor.controllers.tarefas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Buttons, ZDataset, Graphics, Controls,
  ptlgestor.dm, ptlgestor.alterartarefa, ptlgestor.model.tarefas,
  ptlgestor.janelacustom, Forms, Dialogs;
type

  { TControllerTarefas }

  TControllerTarefas =  class
    private
      FIdLista: String;
      FscrollMainTarefas: TWinControl;
      procedure LimparTarefas;
    public
      property IdLista: String read FIdLista write FIdLista;
      property scrollMainTarefas: TWinControl read FscrollMainTarefas write FscrollMainTarefas;
      procedure AlterarTarefas(Sender: TObject);
      function CarregaTarefas: TPanel;
      procedure ExcluirTarefas(Sender: TObject);
      function Gravar(IdTarefa:String;TituloTarefa:String;DescTarefa:String;DataConclusao:TDateTime): String;
  end;

implementation

{ TControllerTarefas }

function TControllerTarefas.CarregaTarefas: TPanel;
var
  LPanelTarefa, LPanelBotoes: TPanel;
  LQuery: TZQuery;
begin
  LimparTarefas;
  LQuery := TZQuery.Create(Nil);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Add('select * from TAREFAS_ITENS where DATA_EXCLUSAO is null and ID_LISTA = :pidlista');
  LQuery.ParamByName('pidlista').AsString:=FIdLista;
  LQuery.Open;
  while not LQuery.EOF do
  begin
    LPanelTarefa := TPanel.Create(Nil);
    LPanelTarefa.Name := 'tarefa' + LQuery.FieldByName('id').AsString;
    LPanelTarefa.Hint := LQuery.FieldByName('id').AsString;
    LPanelTarefa.Parent := FscrollMainTarefas;
    LPanelTarefa.Align := alTop;
    LPanelTarefa.BorderSpacing.Top := 10;
    LPanelTarefa.Caption := LQuery.FieldByName('titulo').AsString + ': ' + LQuery.FieldByName('descricao').AsString;
    if (LQuery.FieldByName('data_conclusao').AsString = '') or (LQuery.FieldByName('data_conclusao').AsString = '30/12/1899') then
       LPanelTarefa.Color := clWhite
    else
       LPanelTarefa.Color := clGreen;
    LPanelTarefa.Font.Name := 'Inter';
    LPanelTarefa.Font.Size := Round(LPanelTarefa.Width*0.028);
    LPanelTarefa.Height := 100;
    LPanelTarefa.BevelOuter := bvNone;
    LPanelTarefa.Top:=9999;
    LPanelBotoes := TPanel.Create(Nil);
    LPanelBotoes.BevelOuter := bvNone;
    LPanelBotoes.Parent := LPanelTarefa;
    LPanelBotoes.Align := alRight;
    LPanelBotoes.Width := 70;
    LPanelBotoes.Hint := LQuery.FieldByName('id').AsString;

    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'pen';
      OnClick:=@AlterarTarefas;
      Flat:=True;
      Transparent:=False;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
      end;
      Height:=Round(LPanelBotoes.Height/2);
    end;

    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'trash';
      Flat:=True;
      Transparent:=False;
      OnClick:=@ExcluirTarefas;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
        Color := clRed;
      end;
      Height:=Round(LPanelBotoes.Height/2);
      Top := 9999;
    end;
    LQuery.Next;
  end;
  LQuery.Free;

end;

procedure TControllerTarefas.AlterarTarefas(Sender: TObject);
var
  LTarefa: TModelTarefa;
  LRetorno: String;
  Form: TFormAlterarTarefa;
  LIdTarefa: String;
begin
 LIdTarefa := TControl(Sender).Parent.Hint;
 try
   Form := TFormAlterarTarefa.Create(Nil);
   Form.IdTarefa := LIdTarefa;
   Form.ShowModal;
 finally
   try
    LTarefa := TModelTarefa.Create;
    LTarefa.IdLista := FIdLista;
    LTarefa.IdTarefa := LIdTarefa;
    LTarefa.TituloTarefa := Form.TituloTarefa;
    LTarefa.DescTarefa := Form.DescTarefa;
    LTarefa.DataConclusao := Form.DataConclusao;
    LTarefa.Gravar;
    LRetorno := LTarefa.Retorno;
   except
    on E: Exception do
    LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
   end;
   Form.Free;
   if LRetorno = '' then
      CarregaTarefas
   else
      ShowMessage(LRetorno);
   LTarefa.Free;
 end;
end;

procedure TControllerTarefas.ExcluirTarefas(Sender: TObject);
var
 LTarefa: TModelTarefa;
 Form: TJanelaCustom;
 Excluir: Boolean;
 LIdTarefa,LRetorno : String;
begin
 LIdTarefa := TControl(Sender).Parent.Hint;
 try
   Form:= TJanelaCustom.Create(Nil);
   Form.BorderStyle := bsNone;
   Form.Position := poMainFormCenter;
   Form.labelTitulo.Caption := 'Deseja realmente excluir a tarefa?';
   with TZQuery.Create(Nil) do
   begin
     Connection := DM.Conexao;
     SQL.Add('SELECT TITULO FROM TAREFAS_ITENS WHERE ID = :pidtarefa');
     ParamByName('pidtarefa').AsString:=LIdTarefa;
     Open;
     Form.labelTexto.Caption:='A Tarefa '+ FieldByName('titulo').AsString + ' será excluida.';
     Free;
   end;
   Form.AddBotao('Cancelar',False);
   Form.AddBotao('Excluir',True);
   Form.ShowModal;
 finally
   Form.Free;
   Excluir := Form.Retorno;
 end;
 if Excluir then
 begin
   try
     LTarefa := TModelTarefa.Create;
     LTarefa.IdTarefa := LIdTarefa;
     LTarefa.Excluir;
   except
       on E: Exception do
       LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
   end;
   if LRetorno = '' then
      CarregaTarefas
   else
      ShowMessage(LRetorno);
 end;
end;

function TControllerTarefas.Gravar(IdTarefa: String; TituloTarefa: String;
  DescTarefa: String; DataConclusao: TDateTime): String;
var
  LTarefa: TModelTarefa;
  LRetorno: String;
begin
  LTarefa := TModelTarefa.Create;
  try
    try
      LTarefa.IdLista := FIdLista;

      LTarefa.IdTarefa := IdTarefa;
      LTarefa.TituloTarefa := TituloTarefa;
      LTarefa.DescTarefa := DescTarefa;
      LTarefa.DataConclusao := DataConclusao;
      LTarefa.Gravar;
      LRetorno := LTarefa.Retorno;
    except
      on E: Exception do
      LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
    end;
  finally
    LTarefa.Free;
    Result := LRetorno;
  end;
end;

procedure TControllerTarefas.LimparTarefas;
var
 i: Integer;
begin
 for i := scrollMainTarefas.ControlCount -1 downto 0 do
   scrollMainTarefas.Controls[i].Free;
end;
end.

