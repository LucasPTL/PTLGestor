unit ptlgestor.controllers.tarefas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Buttons, ZDataset, Graphics, Controls,
  ptlgestor.dm, ptlgestor.alterartarefa, ptlgestor.model.tarefas,
  ptlgestor.janelacustom, Forms, Dialogs, StdCtrls;
type

  { TControllerTarefas }

  TControllerTarefas =  class
    private
      FIdLista: String;
      FscrollMainTarefas: TWinControl;

    public
      property IdLista: String read FIdLista write FIdLista;
      property scrollMainTarefas: TWinControl read FscrollMainTarefas write FscrollMainTarefas;

      procedure AlterarTarefas(Sender: TObject);
      function CarregaTarefas: TPanel;
      procedure LimparTarefas;
      procedure ExcluirTarefas(Sender: TObject);
      function Gravar(IdTarefa:String;TituloTarefa:String;DescTarefa:String;DataConclusao:TDateTime): String;
  end;

implementation

{ TControllerTarefas }

function TControllerTarefas.CarregaTarefas: TPanel;
var
  LPanelTarefa, LPanelBotoes, LPanelTitulo, LPanelRight, LPanelClient: TPanel;
  LQuery: TZQuery;
  Concluido: Boolean;
begin
  LimparTarefas;
  LQuery := TZQuery.Create(Nil);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Add('select * from TAREFAS_ITENS where DATA_EXCLUSAO is null and ID_LISTA = :pidlista ORDER BY ID');
  LQuery.ParamByName('pidlista').AsString:=FIdLista;
  LQuery.Open;
  while not LQuery.EOF do
  begin
    Concluido := (LQuery.FieldByName('data_conclusao').AsString = '') or (LQuery.FieldByName('data_conclusao').AsString = '30/12/1899');

    LPanelTarefa := TPanel.Create(Nil);
    LPanelTarefa.Name := 'tarefa' + LQuery.FieldByName('id').AsString;
    LPanelTarefa.Hint := LQuery.FieldByName('id').AsString;
    LPanelTarefa.Parent := FscrollMainTarefas;
    LPanelTarefa.Align := alTop;
    LPanelTarefa.BorderSpacing.Top := 10;

    if Concluido then
       LPanelTarefa.Color := clGreen
    else
       LPanelTarefa.Color := clWhite;

    LPanelTarefa.Font.Name := 'Inter';
    LPanelTarefa.Font.Size := 21;
    LPanelTarefa.Height := 100;
    LPanelTarefa.BevelOuter := bvNone;
    LPanelTarefa.BorderStyle:= bsNone;
    LPanelTarefa.Top:=9999;

    LPanelRight := TPanel.Create(Nil);
    with LPanelRight do
    begin
      Align:=alRight;
      Width := 150;
      Parent := LPanelTarefa;
      BevelOuter := bvNone;
      BorderStyle := bsNone;

      LPanelBotoes := TPanel.Create(Nil);
      LPanelBotoes.BevelOuter := bvNone;
      LPanelBotoes.Parent := LPanelRight;
      LPanelBotoes.Align := alClient;
      LPanelBotoes.Hint := LQuery.FieldByName('id').AsString;
    end;

    LPanelClient := TPanel.Create(Nil);
    with LPanelClient do
    begin
      Align := alClient;
      Parent := LPanelTarefa;
      BevelOuter := bvNone;
      BorderStyle := bsNone;

      LPanelTitulo := TPanel.Create(Nil);
      LPanelTitulo.BevelOuter := bvNone;
      LPanelTitulo.BorderStyle := bsNone;
      LPanelTitulo.Parent := LPanelClient;
      LPanelTitulo.Align := alTop;
      LPanelTitulo.Caption := LQuery.FieldByName('titulo').AsString;
      with LPanelTitulo.Font do
      begin
        Style:=[fsBold];
        if Concluido then Color := clWhite else Color := clBlack;
      end;

      with TLabel.Create(Nil) do
      begin
        Align := alClient;
        Parent := LPanelClient;
        Alignment := taCenter;
        Layout := tlCenter;
        if Concluido then Font.Color := clWhite else Font.Color := clBlack;
        Caption := LQuery.FieldByName('descricao').AsString;
      end;

    end;

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
        Size := 21;
      end;
      Height:=Round(LPanelTarefa.Height/2);
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
        Size := 21;
        Color := clRed;
      end;
      Height:=Round(LPanelTarefa.Height/2);
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
   if (Form.TituloTarefa <> '') and (Form.DescTarefa <> '') then
   begin
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
    if LRetorno = '' then
       CarregaTarefas
    else
       ShowMessage(LRetorno);
   end;
   Form.Free;
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
    CarregaTarefas;
  end;
end;

procedure TControllerTarefas.LimparTarefas;
var
 i: Integer;
begin
 for i := FscrollMainTarefas.ControlCount -1 downto 0 do
  if FscrollMainTarefas.Controls[i].ClassName = 'TPanel' then FscrollMainTarefas.Controls[i].Free;
end;
end.

