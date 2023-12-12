unit PTLGestor.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ptlgestor.janelacustom, ptlgestor.configConexao, ptlgestor.dm;

type

  { TFormMain }

  TFormMain = class(TForm)
    labelAvisoConexao: TLabel;
    panelBotoesBarra1: TPanel;
    panelConteudo: TPanel;
    panelBotoesBarra: TPanel;
    panelTop: TPanel;
    btnMinimizar: TSpeedButton;
    btnMaximizar: TSpeedButton;
    btnFechar: TSpeedButton;
    panelBottom: TPanel;
    btnConfigBanco: TSpeedButton;
    timerVerificaConexao: TTimer;
    procedure btnConfigBancoClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnMaximizarClick(Sender: TObject);
    procedure btnMinimizarClick(Sender: TObject);
    procedure panelTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure panelTopMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure panelTopMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure timerVerificaConexaoStartTimer(Sender: TObject);
    procedure timerVerificaConexaoTimer(Sender: TObject);
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

procedure TFormMain.panelTopMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 FMouseDown := False;
end;

procedure TFormMain.timerVerificaConexaoTimer(Sender: TObject);
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

end.

