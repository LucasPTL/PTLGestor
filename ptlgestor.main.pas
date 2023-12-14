unit PTLGestor.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ComCtrls, ptlgestor.janelacustom, ptlgestor.configConexao,
  ptlgestor.criarlista, ptlgestor.criartarefa, ptlgestor.dm,
  ptlgestor.controllers.listatarefas, ptlgestor.controllers.tarefas, ZDataset;

type

  { TFormMain }

  TFormMain = class(TForm)
    btnAddLista: TSpeedButton;
    btnAddTarefa: TSpeedButton;
    textCodigoTarefa: TEdit;
    labelNomeTarefa: TLabel;
    labelAvisoConexao: TLabel;
    pageControlMain: TPageControl;
    panelConteudoTopTarefas: TPanel;
    panelListaTarefasMain: TPanel;
    panelConteudo: TPanel;
    panelBotoesBarra: TPanel;
    panelConteudoTopListaTarefas: TPanel;
    panelTarefasMain: TPanel;
    panelTop: TPanel;
    btnMinimizar: TSpeedButton;
    btnMaximizar: TSpeedButton;
    btnFechar: TSpeedButton;
    panelBottom: TPanel;
    btnConfigBanco: TSpeedButton;
    scrollMain: TScrollBox;
    scrollMainTarefas: TScrollBox;
    btnVoltar: TSpeedButton;
    tabTarefas: TTabSheet;
    tabListaTarefas: TTabSheet;
    timerVerificaConexao: TTimer;
    procedure btnAddTarefaClick(Sender: TObject);
    procedure btnConfigBancoClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnMaximizarClick(Sender: TObject);
    procedure btnMinimizarClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure panelTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure panelTopMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure panelTopMouseUp;
    procedure btnAddListaClick;
    procedure btnVoltarClick(Sender: TObject);
    procedure timerVerificaConexaoTimer;

    procedure AtualizarListasTarefas;
    procedure LimparListasTarefas;
    procedure AlterarListaTarefas(Sender: TObject);
    procedure ExcluirLista(Sender: TObject);

    procedure CarregaTarefas(Sender: TObject);
  private
    FMouseDown: Boolean;
    FMousePos: TPoint;

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.panelTopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FMouseDown := True;
    FMousePos := Point(X, Y);
  end;
end;

procedure TFormMain.btnFecharClick(Sender: TObject);
var
  Form: TJanelaCustom;
  Fechar: Boolean;
begin
  try
    Form:= TJanelaCustom.Create(Self);
    Form.BorderStyle:=bsNone;
    Form.Position:=poMainFormCenter;
    Form.labelTitulo.Caption:='Deseja realmente fechar o sistema?';
    Form.labelTexto.Caption:='';
    Form.AddBotao('Cancelar',False);
    Form.AddBotao('Fechar',True);
    Form.ShowModal;
  finally
    Form.Free;
    Fechar:=Form.Retorno;
    if Fechar then Application.Terminate;
  end;

end;

procedure TFormMain.btnConfigBancoClick(Sender: TObject);
var
  Form: TFormConfigConexao;
begin
  try
    Form := TFormConfigConexao.Create(Self);
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFormMain.btnAddTarefaClick(Sender: TObject);
var
  Form: TFormCriarTarefa;
begin
 if btnConfigBanco.Color <> clRed then
 begin
   try
     Form := TFormCriarTarefa.Create(Self);
     Form.IdLista := textCodigoTarefa.Text;
     Form.Ok := False;
     Form.ShowModal;
   finally
     Form.Free;
     if Form.Ok then CarregaTarefas(Self);
   end;
 end;
end;

procedure TFormMain.btnMaximizarClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
     WindowState := wsNormal
  else
     WindowState := wsMaximized;
end;

procedure TFormMain.btnMinimizarClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
 scrollMain.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMain.BorderSpacing.Right:=Round(Self.Width*0.20);

 scrollMainTarefas.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMainTarefas.BorderSpacing.Right:=Round(Self.Width*0.20);
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
 AtualizarListasTarefas;
 scrollMain.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMain.BorderSpacing.Right:=Round(Self.Width*0.20);

 scrollMainTarefas.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMainTarefas.BorderSpacing.Right:=Round(Self.Width*0.20);
end;

procedure TFormMain.panelTopMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 NewPos: TPoint;
begin
 if FMouseDown then
 begin
   NewPos := Point(X + Self.Left, Y + Self.Top);

   Self.Left := NewPos.X;
   Self.Top := NewPos.Y;
 end;
end;

procedure TFormMain.panelTopMouseUp;
begin
 FMouseDown := False;
end;

procedure TFormMain.btnAddListaClick;
var
  Form: TFormCriarLista;
begin
 if btnConfigBanco.Color <> clRed then
 begin
   try
     Form := TFormCriarLista.Create(Self);
     Form.labelTitulo.Caption:='Criação de lista';
     Form.ShowModal;
   finally
     Form.Free;
     AtualizarListasTarefas;
   end;
 end;
end;

procedure TFormMain.btnVoltarClick(Sender: TObject);
begin
  pageControlMain.ActivePage := tabListaTarefas;
end;

procedure TFormMain.timerVerificaConexaoTimer;
begin
 with timerVerificaConexao do
 begin
   Enabled:=False;
   if DM.Conexao.Ping then
   begin
     btnConfigBanco.Color:=clGreen;
     labelAvisoConexao.Caption:='';
   end
   else
   begin
     btnConfigBanco.Color:=clRed;
     labelAvisoConexao.Caption:='Verificar conexão.';
   end;
   Enabled:=True;
 end;
end;

procedure TFormMain.AtualizarListasTarefas;
var
  LQuery: TZQuery;
  LPanelLista,LPanelBotoes: TPanel;
begin
  LimparListasTarefas;
  pageControlMain.ActivePage := tabListaTarefas;
  LQuery := TZQuery.Create(Self);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Add('select * from TAREFAS where data_exclusao is null');
  LQuery.Open;
  while not LQuery.EOF do
  begin
    LPanelLista := TPanel.Create(Self);
    LPanelLista.Name := 'lista'+LQuery.FieldByName('id').AsString;
    LPanelLista.Hint := LQuery.FieldByName('id').AsString;
    LPanelLista.Parent := scrollMain;
    LPanelLista.Align := alTop;
    LPanelLista.BorderSpacing.Top := 10;
    LPanelLista.Height := 100;
    LPanelLista.BevelOuter := bvNone;
    LPanelLista.Top:=9999;
    LPanelBotoes := TPanel.Create(Self);
    LPanelBotoes.BevelOuter := bvNone;
    LPanelBotoes.Parent := LPanelLista;
    LPanelBotoes.Align := alRight;
    LPanelBotoes.Width := Round(panelBotoesBarra.Width);
    LPanelBotoes.Hint := LQuery.FieldByName('id').AsString;

    with TSpeedButton.Create(Self) do
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
    with TSpeedButton.Create(Self) do
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
    with TSpeedButton.Create(Self) do
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

    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelLista;
      Align := alClient;
      OnCLick := @CarregaTarefas;
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

procedure TFormMain.LimparListasTarefas;
var
 i: Integer;
begin
 for i := scrollMain.ControlCount -1 downto 0 do
   scrollMain.Controls[i].Free;
end;

procedure TFormMain.ExcluirLista(Sender: TObject);
var
 Form: TJanelaCustom;
 Excluir: Boolean;
 LIdLista, Retorno: String;
 LLista: TControllerListaTarefas;
begin
 LIdLista := TControl(Sender).Parent.Hint;
 try
   Form:= TJanelaCustom.Create(Self);
   Form.BorderStyle := bsNone;
   Form.Position := poMainFormCenter;
   Form.labelTitulo.Caption := 'Deseja realmente excluir a lista?';
   with TZQuery.Create(Self) do
   begin
     Connection := DM.Conexao;
     SQL.Add('SELECT DESCRICAO FROM TAREFAS WHERE ID = :pidlista');
     ParamByName('pidlista').AsString:=LIdLista;
     Open;
     Form.labelTexto.Caption:='A Lista '+ FieldByName('descricao').AsString + ' será excluida.';
     Free;
   end;
   Form.AddBotao('Cancelar',False);
   Form.AddBotao('Excluir',True);
   Form.ShowModal;
 finally
   Form.Free;
   Fechar:=Form.Retorno;
 end;
 if Excluir then
 begin
   try
     LLista := TControllerListaTarefas.Create;
     Retorno := LLista.Excluir(LIdLista);
     if Retorno <> '' then ShowMessage(Retorno);
   finally
     LLista.Free;
   end;
   AtualizarListasTarefas;
 end;
end;

procedure TFormMain.AlterarListaTarefas(Sender: TObject);
var
  LIdLista:String;
  Form: TFormCriarLista;
begin
  LIdLista := TControl(Sender).Parent.Hint;
  try
    Form := TFormCriarLista.Create(Self);
    Form.Ok := False;
    Form.labelTitulo.Caption:='Alteração de lista: ' + LIdLista;
    Form.IdLista:=LIdLista;
    Form.ShowModal;
  finally
    Form.Free;
    if Form.Ok then AtualizarListasTarefas;
  end;
end;

procedure TFormMain.CarregaTarefas(Sender: TObject);
var
  LIdLista:String;
  LTarefas: TControllerTarefas;
begin
  if Assigned(TControl(Sender).Parent) then LIdLista := TControl(Sender).Parent.Hint;
  if LIdLista = '' then LIdLista := textCodigoTarefa.Text;
  textCodigoTarefa.Text := LIdLista;
  pageControlMain.ActivePage := tabTarefas;
  labelNomeTarefa.Caption := TControl(Sender).Caption;
  try
    LTarefas := TControllerTarefas.Create;
    LTarefas.scrollMainTarefas := scrollMainTarefas;
    LTarefas.IdLista := LIdLista;
    LTarefas.CarregaTarefas;
  except
    on E: Exception do
       ShowMessage('Erro ao exibir tarefas: ' +  E.ClassName +  '/' +  E.Message);
  end;
end;


end.

