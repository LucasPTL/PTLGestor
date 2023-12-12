unit ptlgestor.janelacustom;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Buttons, Graphics;
type

   { TButtonRetorno }

   TButtonRetorno = class(TSpeedButton)
   private
     FRetorno: Variant;
   published
     property Retorno: Variant read FRetorno write FRetorno;
   end;
type

  { TJanelaCustom }

  TJanelaCustom = class(TForm)
    labelTitulo: TLabel;
    labelTexto: TLabel;
    panelMid: TPanel;
    panelBottom: TPanel;
    panelTop: TPanel;
    panelConteudo: TPanel;
    panelFundo: TPanel;
  private
    FRetorno: Boolean;
    procedure ReturnValor(Sender: TObject);
    procedure CalculaTamanho;
  public
    property Retorno:Boolean read FRetorno write FRetorno;
    procedure AddBotao(ANome:String;ARetorno: Boolean);
  end;

implementation

{$R *.lfm}

{ TJanelaCustom }

procedure TJanelaCustom.ReturnValor(Sender: TObject);
begin
  Retorno:=TButtonRetorno(Sender).Retorno;
  Self.Close;
end;

procedure TJanelaCustom.AddBotao(ANome: String; ARetorno: Boolean);
begin
  with TButtonRetorno.Create(Self) do
  begin
    Align:=alLeft;
    Font.Color:=clBlack;
    Flat:=True;
    Caption:=ANome;
    Height:=panelBottom.Height;
    Parent:=panelBottom;
    Retorno:=ARetorno;
    OnClick:=@ReturnValor;
  end;
  CalculaTamanho;
end;

procedure TJanelaCustom.CalculaTamanho;
var
 LarguraLivre: Integer;
 i: Integer;
begin

 LarguraLivre := panelBottom.ClientWidth;
 for i := 0 to panelBottom.ControlCount - 1 do
 begin
      panelBottom.Controls[i].Width := Round(panelBottom.Width / panelBottom.ControlCount) - panelBottom.Controls[i].Left;
 end;

end;

end.

