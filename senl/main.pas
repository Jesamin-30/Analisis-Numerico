unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, ComCtrls, Intersection, ParseMath, Func,
  Math, TAChartUtils, Matrices, Result, Lagrange;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnPuntos: TButton;
    BtnLagrange: TButton;
    EPolinomio: TEdit;
    Enum_puntos: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    LPolinomio: TLabel;
    Lpuntos: TLabel;
    Panel1: TPanel;
    RPMA: TButton;
    RPMB: TButton;
    EMAm: TEdit;
    EMAn: TEdit;
    EMBm: TEdit;
    EMBn: TEdit;
    OkM: TButton;
    OpeMatr: TComboBox;
    DataChart: TChart;
    EValueM: TEdit;
    EFunction2: TEdit;
    LME: TLabel;
    MatA: TGroupBox;
    MatB: TGroupBox;
    MxBox: TGroupBox;
    LFunction2: TLabel;
    LPoints: TLineSeries;
    Func1: TLineSeries;
    Func2: TLineSeries;
    OK: TButton;
    CMethod: TComboBox;
    Data: TGroupBox;
    EA: TEdit;
    EB: TEdit;
    EFunction1: TEdit;
    EError: TEdit;
    LFunction1: TLabel;
    LA: TLabel;
    LB: TLabel;
    MPanel: TPanel;
    PageControl1: TPageControl;
    MxMenu: TPanel;
    PMA: TPanel;
    PMB: TPanel;
    SGData: TStringGrid;
    SGMA: TStringGrid;
    SGMB: TStringGrid;
    StringPuntos: TStringGrid;
    TabIntersection: TTabSheet;
    TabMatrices: TTabSheet;
    TabSheet1: TTabSheet;
    TabLagrange: TTabSheet;
    procedure BtnLagrangeClick(Sender: TObject);
    procedure BtnPuntosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure OKClick(Sender: TObject);
    procedure OkMClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PutSG(TB: TBox);
    procedure PutPoint(ML: TList);
    procedure RPMAClick(Sender: TObject);
    procedure RPMBClick(Sender: TObject);
    procedure SelectData(a: integer);
    procedure DataVisible(a: integer);
    procedure GraphicFunc(Fn: string; a,b: real; id: integer);
    procedure GraphicPoint(MP: TList);
    procedure PutResult(a: TMatriz);
    procedure MatrizRandom();

    function Func(x: real; Fn: string): real;
    function CreateA(): TMatriz;
    function CreateB(): TMatriz;
  private
    PointInter: TMPoint;
    MParse: TParseMath;
    MInter: TMethIntersection;
    MLagrange: TLagrange;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  MParse:= TParseMath.Create();
  MInter:= TMethIntersection.Create();
  MParse.AddVariable('x',0);
  MLagrange:= TLagrange.Create();
end;

procedure TForm1.BtnLagrangeClick(Sender: TObject);
var
  i: integer;
  MP: TList;
begin
  MP:= TList.Create;
  for i:=1 to StringPuntos.RowCount-1 do
    MP.Add(TMPoint.Create(StrToFloat(StringPuntos.Cells[0,i]),StrToFloat(StringPuntos.Cells[1,i])));
  PointInter:= XIntervalo(MP);

  case TButton(Sender).Tag of
    0: EPolinomio.Text:= MLagrange.funcLagrange(MP);
  end;
  MP.Clear;
end;


procedure TForm1.BtnPuntosClick(Sender: TObject);
var
  nt: integer;
begin
  nt:= StrToInt(Enum_puntos.Text);
  StringPuntos.RowCount:= nt+1;
  StringPuntos.Cells[0,0]:= 'X';
  StringPuntos.Cells[1,0]:= 'Y';
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  MParse.Destroy;
  MInter.Destroy;
end;

procedure TForm1.GroupBox1Click(Sender: TObject);
begin

end;

procedure TForm1.OKClick(Sender: TObject);
var
  Fn,Fp,Ft: string;
  RT,RA,A,B,Er: real;
  MTRB: TRB;
begin
  Fn:= EFunction1.Text;
  Fp:= 'cos(x)';
  Er:= StrToFloat(EError.Text);
  A:= StrToFloat(EA.Text);
  B:= StrToFloat(EB.Text);

  {5 es para Hallar Todas las Raices entre un dominio, por ejemplo [-10,10]
  estas raices son halladas con Bisection-Secant, Primero bisection hasta un
  error 0.01, luego secante. Primero se divide en pqueñas partes y luego
  bolzano para cada parte, y el metodo, y te dara las todas las raices
  Ejemplo
  Fn= sin(x)
  Er= 0.000001
  Dm= [-10,10]
  Resultado son 7 raices
  }
  if(CMethod.ItemIndex=5) then begin
    SelectData(0);
    PutPoint(MInter.MBoth(A,B,Er,Fn,Fn))
  end
  else if(CMethod.ItemIndex=6) then begin
    SelectData(1);
    GraphicFunc(Fn,A,B,0);
    GraphicFunc(EFunction2.Text,A,B,1);
    Ft:= '('+Fn+')-('+EFunction2.Text+')';
    GraphicPoint(MInter.MBoth(A,B,Er,FT,Fn));
  end
  else begin
    //intervalos cercanos [a,b], una sola raiz
    RA:= Func(A,Fn); RT:= RA*Func(B,Fn);
    if(RT<0) then begin
      SelectData(0);
      case CMethod.ItemIndex of
        0: MTRB:= MInter.MBisect(A,B,Er,Fn);  //Bisección
        1: MTRB:= MInter.MFalPos(A,B,Er,Fn);  //Falsa Posición
        2: MTRB:= MInter.MNewton(A,Er,Fn,Fp); //Newton (Solo falta un TEdit para ingresar la derivada, esta constante con "cos(x)", que es la derivada de sin(x))
        3: MTRB:= MInter.MSecant(A,Er,Fn);    //Secante
        4: MTRB:= MInter.MBothIn(A,B,Er,Fn);  //Bisección-Secante para solo una raiz.
      end;
      PutSG(MTRB.MBox);
    end
    else if(RT=0) then begin
      {Raiz es uno de los valores iniciales}
      if(RA=0) then  ShowMessage('Raiz: '+FloatToStr(A))
      else  ShowMessage('Raiz: '+FloatToStr(B));
    end
    else
      ShowMessage('No Cumple Bolzano');
  end;
end;

function TForm1.Func(x: real; Fn: string): real;
begin
  MParse.NewValue('x',x);
  MParse.Expression:= Fn;
  Result:= MParse.Evaluate();
end;

//Imprime las raices en el StringGrid
procedure TForm1.PutPoint(ML: TList);
var
  TP: TMPoint;
  i: integer;
begin
  SGData.Clear();
  SGData.RowCount:= ML.Count+1; SGData.ColCount:= 2;
  SGData.Cells[0,0]:= 'X'; SGData.Cells[1,0]:= 'Y';

  for i:=0 to ML.Count-1 do begin
    TP:= TMPoint(ML.Items[i]);
    SGData.Cells[0,i+1]:= FloatToStr(TP.x);
    SGData.Cells[1,i+1]:= FloatToStr(TP.y);
  end;
end;

procedure TForm1.DataVisible(a: integer);
begin
  case a of
    0: begin
      SGData.Visible:= True;
      DataChart.Visible:= False;
    end;
    1: begin
      SGData.Visible:= False;
      DataChart.Visible:= True;
    end;
  end;
end;

procedure TForm1.SelectData(a: integer);
begin
  case a of
     0: SGData.Parent:= Data;
     1: DataChart.Parent:= Data;
  end;
  DataVisible(a);
end;

//Imprime la Sucesión de cada metodo en el StringGrid
procedure TForm1.PutSG(TB: TBox);
var
  i,j: integer;
begin
  SGData.Clear();
  SGData.RowCount:= TB.x;
  SGData.ColCount:= TB.y;
  for i:=0 to TB.x-1 do
    for j:=0 to TB.y-1 do
      SGData.Cells[j,i]:= TB.M[i,j];
end;

procedure TForm1.GraphicFunc(Fn: string; a,b: real; id: integer);
var
  x,h: real;
begin
  x:= a;
  h:= 0.1;
  case id of
    0: begin
      Func1.Clear;
      with Func1 do repeat
        AddXY(x,Func(x,Fn));
        x:= x+h
      until(x>=b);
    end;
    1: begin
      Func2.Clear;
      with Func2 do repeat
        AddXY(x,Func(x,Fn));
        x:= x+h
      until(x>=b);
    end
  end;
end;

procedure TForm1.GraphicPoint(MP: TList);
var
  i: integer;
  TM: TMPoint;
begin
  LPoints.Clear;
  LPoints.ShowPoints:= True;
  LPoints.Marks.Style:= smsValue;
  for i:=0 to MP.Count-1 do begin
    TM:= TMPoint(MP[i]);
    LPoints.AddXY(TM.x,TM.y);
    LPoints.AddXY(NaN,NaN);
  end;
end;

//Matrices

procedure TForm1.PutResult(a: TMatriz);
var
  i,j: integer;
begin
  Form2.SGResult.RowCount:= a.GetX;
  Form2.SGResult.ColCount:= a.GetY;
  for i:=0 to a.GetY-1 do
    for j:=0 to a.GetX-1 do
      Form2.SGResult.Cells[i,j]:= FloatToStr(a.M[j,i]);
end;

procedure TForm1.MatrizRandom();
var
  i,j,ra1,ca1,rb1,cb1: integer;
begin
  ra1:= SGMA.RowCount; ca1:= SGMA.ColCount;
  for i:=0 to ra1-1 do
   for j:=0 to ca1-1 do
     SGMA.Cells[j,i]:= IntToStr(random(10));

  rb1:= SGMB.RowCount; cb1:= SGMB.ColCount;
  for i:=0 to rb1-1 do
   for j:=0 to cb1-1  do
     SGMB.Cells[j,i]:= IntToStr(random(10));
end;

function TForm1.CreateA(): TMatriz;
var
  i,j: integer;
begin
  Result:= TMatriz.Create(SGMA.RowCount,SGMA.ColCount);
  for i:=0 to SGMA.RowCount-1 do
    for j:=0 to SGMA.ColCount-1 do
      Result.M[i,j]:= StrToFloat(SGMA.Cells[j,i]);
end;

function TForm1.CreateB(): TMatriz;
var
  i,j: integer;
begin
  Result:= TMatriz.Create(SGMB.RowCount,SGMB.ColCount);
  for i:=0 to SGMB.RowCount-1 do
    for j:=0 to SGMB.ColCount-1 do
      Result.M[i,j]:= StrToFloat(SGMB.Cells[j,i]);
end;

procedure TForm1.OkMClick(Sender: TObject);
var
  A,B: TMatriz;
  det: TRD;
begin
  if(OpeMatr.ItemIndex=9) then
    MatrizRandom()
  else begin
    A:= CreateA;  B:= CreateB;
    Form2.Show;
    if(OpeMatr.ItemIndex=0) then
      PutResult(A+B)
    else if(OpeMatr.ItemIndex=1) then
      PutResult(A-B)
    else if(OpeMatr.ItemIndex=2) then
      PutResult(A*B)
    else if(OpeMatr.ItemIndex=3) then
      PutResult(A/B)
    else if(OpeMatr.ItemIndex=4) then begin
      det:= A.Determinante();
      if(det.State and (det.Value<>0)) then
        PutResult(A.Inversa(det.Value))
      else
        ShowMessage('No Tiene Inversa');
    end
    else if(OpeMatr.ItemIndex=5) then begin
      det:= B.Determinante();
      if(det.State and (det.Value<>0)) then
        PutResult(B.Inversa(det.Value))
      else
        ShowMessage('No Tiene Inversa');
    end
    else if(OpeMatr.ItemIndex=6) then
      PutResult(A.Escalar(StrToFloat(EValueM.Text)))
    else if(OpeMatr.ItemIndex=7) then
      PutResult(A.MPower(StrToInt(EValueM.Text)))
    else if(OpeMatr.ItemIndex=8) then
      PutResult(A.Transpuesta)
  end;
end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin

end;

procedure TForm1.RPMAClick(Sender: TObject);
begin
  SGMA.Clear;
  SGMA.RowCount:= StrToInt(EMAm.Text);
  SGMA.ColCount:= StrToInt(EMAn.Text);
end;

procedure TForm1.RPMBClick(Sender: TObject);
begin
  SGMB.Clear;
  SGMB.RowCount:= StrToInt(EMBm.Text);
  SGMB.ColCount:= StrToInt(EMBn.Text);
end;

end.

