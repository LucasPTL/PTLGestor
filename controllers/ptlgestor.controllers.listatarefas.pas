unit ptlgestor.controllers.listatarefas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Buttons, ZDataset, Graphics, Controls,
  ptlgestor.dm, ptlgestor.alterarlista,
  ptlgestor.controllers.tarefas, ptlgestor.model.listatarefas,
  ptlgestor.janelacustom, Forms, Dialogs, ComCtrls;
type
  { TControllerListaTarefas }
  TControllerListaTarefas = class
    private
      FPageControlMain: TPageControl;
      FscrollMain: TWinControl;
      FscrollMainTarefas: TWinControl;
      FTabListaTarefas: TTabSheet;
    public
      procedure AlterarListaTarefas(Sender: TObject);
      procedure AtualizarListasTarefas;
      procedure CarregaTarefas(Sender: TObject);
      procedure ExcluirLista(Sender: TObject);
      procedure LimparListasTarefas;
      function Gravar(IdLista:String;DescLista:String):String;

      property pageControlMain: TPageControl read FPageControlMain write FPageControlMain;
      property tabListaTarefas: TTabSheet read FTabListaTarefas write FTabListaTarefas;
      property scrollMain: TWinControl read FscrollMain write FscrollMain;
      property scrollMainTarefas: TWinControl read FscrollMainTarefas write FscrollMainTarefas;


  end;

implementation

{ TControllerListaTarefas }

procedure TControllerListaTarefas.AtualizarListasTarefas;
var
  LQuery: TZQuery;
  LPanelLista,LPanelBotoes: TPanel;
begin
  LimparListasTarefas;
  FPageControlMain.ActivePage := FTabListaTarefas;
  LQuery := TZQuery.Create(Nil);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Add('select * from TAREFAS where data_exclusao is null');
  LQuery.Open;
  while not LQuery.EOF do
  begin
    LPanelLista := TPanel.Create(Nil);
    LPanelLista.Name := 'lista'+LQuery.FieldByName('id').AsString;
    LPanelLista.Hint := LQuery.FieldByName('id').AsString;
    LPanelLista.Parent := FscrollMain;
    LPanelLista.Align := alTop;
    LPanelLista.BorderSpacing.Top := 10;
    LPanelLista.Height := 100;
    LPanelLista.BevelOuter := bvNone;
    LPanelLista.Top:=9999;
    LPanelBotoes := TPanel.Create(Nil);
    LPanelBotoes.BevelOuter := bvNone;
    LPanelBotoes.Parent := LPanelLista;
    LPanelBotoes.Align := alRight;
    LPanelBotoes.Width := 150;
    LPanelBotoes.Hint := LQuery.FieldByName('id').AsString;

    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'pen';
      OnClick:=@AlterarListaTarefas;
      Flat:=True;
      Transparent:=False;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
      end;
      Height:=Round(LPanelBotoes.Height/3);
    end;
    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'print';
      Flat:=True;
      Transparent:=False;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
        Color := clBlue;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;
    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'trash';
      OnClick := @ExcluirLista;
      Flat:=True;
      Transparent:=False;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
        Color := clRed;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;

    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelLista;
      Align := alClient;
      OnClick := @CarregaTarefas;
      Caption := LQuery.FieldByName('descricao').AsString;
      with Font do
      begin
        Name := 'Inter';
        Size := Round(LPanelLista.Height/6);
      end;
    end;
    LQuery.Next;
  end;
  LQuery.Free;
end;

procedure TControllerListaTarefas.CarregaTarefas(Sender: TObject);
var
  LTarefa: TControllerTarefas;
  LIdLista:String;
begin
  LIdLista := TControl(Sender).Parent.Hint;
  try
    LTarefa := TControllerTarefas.Create;
    LTarefa.IdLista := LIdLista;
    LTarefa.scrollMainTarefas := FscrollMainTarefas;
    LTarefa.CarregaTarefas;
  finally

  end;
end;
procedure TControllerListaTarefas.ExcluirLista(Sender: TObject);
var
 LListaTarefa: TModelListaTarefas;
 Form: TJanelaCustom;
 Confirma: Boolean;
 LIdLista,LRetorno : String;
begin
 LIdLista := TControl(Sender).Parent.Hint;
 try
   Form:= TJanelaCustom.Create(Nil);
   Form.BorderStyle := bsNone;
   Form.Position := poMainFormCenter;
   Form.labelTitulo.Caption := 'Deseja realmente excluir a lista?';
   with TZQuery.Create(Nil) do
   begin
     Connection := DM.Conexao;
     SQL.Add('SELECT DESCRICAO FROM TAREFAS WHERE ID = :pidlista');
     ParamByName('pidlista').AsString:= LIdLista;
     Open;
     Form.labelTexto.Caption:='A Lista '+ FieldByName('descricao').AsString + ' será excluida.';
     Free;
   end;
   Form.AddBotao('Cancelar',False);
   Form.AddBotao('Excluir',True);
   Form.ShowModal;
 finally
   Form.Free;
   Confirma := Form.Retorno;
 end;
 if Confirma then
 begin
   try
     try
       LListaTarefa := TModelListaTarefas.Create;
       LListaTarefa.IdLista := LIdLista;
       LListaTarefa.Excluir;
     except
         on E: Exception do
         LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
     end;
   finally
     LListaTarefa.Free;
   end;
   if LRetorno = '' then
      AtualizarListasTarefas
   else
      ShowMessage(LRetorno);
 end;
end;

procedure TControllerListaTarefas.AlterarListaTarefas(Sender: TObject);
var
  LIdLista, Desc, LRetorno:String;
  Form: TFormAlterarLista;
  LListaTarefa: TModelListaTarefas;
begin
  LIdLista := TControl(Sender).Parent.Hint;
  try
    Form := TFormAlterarLista.Create(Nil);
    Form.IdLista:=LIdLista;
    Form.ShowModal;
  finally
    Desc := Form.DescLista;
    Form.Free;
    try
      try
        LListaTarefa := TModelListaTarefas.Create;
        LListaTarefa.IdLista := LIdLista;
        LListaTarefa.DescLista := Desc;
        LListaTarefa.Gravar;
        LRetorno := LListaTarefa.Retorno;
      except
         on E: Exception do
         LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
      end;
    finally
      Form.Free;
      if LRetorno = '' then
         AtualizarListasTarefas
      else
         ShowMessage(LRetorno);
      LListaTarefa.Free;
    end;
  end;
end;

procedure TControllerListaTarefas.LimparListasTarefas;
var
 i: Integer;
begin
 for i := FscrollMainTarefas.ControlCount -1 downto 0 do
   FscrollMainTarefas.Controls[i].Free;
end;

function TControllerListaTarefas.Gravar(IdLista: String; DescLista: String): String;
var
  LListaTarefas: TModelListaTarefas;
  LRetorno: String;
begin
  LListaTarefas := TModelListaTarefas.Create;
  try
    try
      LListaTarefas.IdLista := IdLista;
      LListaTarefas.DescLista := DescLista;
      LListaTarefas.Gravar;
      LRetorno := LListaTarefas.Retorno;
    except
      on E: Exception do
      LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
    end;
  finally
    LListaTarefas.Free;
    Result := LRetorno;
    AtualizarListasTarefas;
  end;
end;

end.

