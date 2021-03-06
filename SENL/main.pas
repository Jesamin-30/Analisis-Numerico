unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLType, ExtCtrls, ComCtrls, Grids, ParseMath, TASeries,
  TAFuncSeries, Intersection, Func, Matrices, Result, Senl, Interpolacion;

type

  { TForm1 }

  TForm1 = class(TForm)
    BInterpolar: TButton;
    InterX: TEdit;
    InterY: TEdit;
    InterpSol: TEdit;
    ISGNE: TButton;
    ILagrange: TButton;
    INewton: TButton;
    DatoSenl: TButton;
    INE: TEdit;
    IData: TGroupBox;
    Label5: TLabel;
    OkSenl: TButton;
    DatosOpe: TButton;
    BoxPanel: TGroupBox;
    EcuationSenl: TEdit;
    HSenl: TEdit;
    GroupBox1: TGroupBox;
    MData: TEdit;
    Label4: TLabel;
    OKA: TButton;
    OKB: TButton;
    Panel2: TPanel;
    IPM: TPanel;
    IEVAL: TPanel;
    SGA: TStringGrid;
    SGB: TStringGrid;
    FSENL: TTabSheet;
    PointInitialSenl: TStringGrid;
    SGEcuationSenl: TStringGrid;
    FInter: TTabSheet;
    SGPI: TStringGrid;
    XA: TEdit;
    YA: TEdit;
    XB: TEdit;
    YB: TEdit;
    MenuA: TPanel;
    MenuB: TPanel;
    SolOper: TButton;
    OperMatriz: TComboBox;
    DB: TButton;
    Derivada: TEdit;
    BoxTM: TGroupBox;
    BMA: TGroupBox;
    BMB: TGroupBox;
    MenuPanel: TPanel;
    Sol: TEdit;
    ErrorH: TEdit;
    PanelLeft: TGroupBox;
    Inter: TButton;
    Chart1: TChart;
    colorbtnFunction: TColorButton;
    comb: TComboBox;
    ediMin: TEdit;
    ediMax: TEdit;
    ediStep: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Solution: TPanel;
    Sarah: TPageControl;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    ENL: TTabSheet;
    Matrix: TTabSheet;
    Datos: TTabSheet;
    SGPoints: TStringGrid;
    TableData: TStringGrid;
    TrackBar1: TTrackBar;

    procedure BInterpolarClick(Sender: TObject);
    procedure DatoSenlClick(Sender: TObject);
    procedure DBClick(Sender: TObject);
    procedure ILagrangeClick(Sender: TObject);
    procedure InterClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FunctionSeriesCalculate(const AX: Double; out AY: Double);
    procedure FormShow(Sender: TObject);
    procedure FunctionsEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure ISGNEClick(Sender: TObject);
    procedure OKAClick(Sender: TObject);
    procedure OKBClick(Sender: TObject);
    procedure OkSenlClick(Sender: TObject);
    procedure SolOperClick(Sender: TObject);
    procedure PutResult(a: TMatriz);
    procedure MatrizRandom();
    procedure PointSol(xn: integer);
    procedure SGResultado(TB: TBox);

    function CreateA(): TMatriz;
    function CreateB(): TMatriz;
  private
    FunctionList,
    EditList: TList;
    ActiveFunction: Integer;
    min, max: Real;
    Parse: TparseMath;
    MInter: TMethIntersection;
    GList: TList;
    MSenl: TSENL;
    PointInter: TPoint;
    MInterpolacion: TInterpolacion;

    function f(x: Real): Real;
    function Func(x: real; s: string): real;
    procedure CreateNewFunction;
    procedure Graphic2D;

  public

  end;

var
  Form1: TForm1;

implementation

const
  FunctionEditName = 'FunctionEdit';
  FunctionSeriesName = 'FunctionLines';

procedure TForm1.FormCreate(Sender: TObject);
begin
  FunctionList:= TList.Create;
  EditList:= TList.Create;
  min:= -10.0;
  max:= 10.0;
  Parse:= TParseMath.create();
  Parse.AddVariable('x', min);
  MInter:= TMethIntersection.Create();
  GList:= TList.Create;
  MSenl:= TSENL.Create();
  MInterpolacion:= TInterpolacion.Create();
end;

function TForm1.f( x: Real ): Real;
begin
  Parse.Expression:= TEdit( EditList[ ActiveFunction ]).Text;
  Parse.NewValue('x', x);
  Result:= Parse.Evaluate();
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Parse.destroy;
  FunctionList.Destroy;
  EditList.Destroy;
end;

procedure TForm1.FunctionSeriesCalculate(const AX: Double; out AY: Double);
begin
   // AY:= f( AX )
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  CreateNewFunction;
end;

procedure TForm1.FunctionsEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  if not (key = VK_RETURN) then
     exit;

   with TEdit( Sender ) do begin
       ActiveFunction:= Tag;
       Graphic2D;
       if tag = EditList.Count - 1 then
          CreateNewFunction;
   end;

end;

procedure TForm1.Graphic2D;
var x, h: Real;

begin
  h:= StrToFloat( ediStep.Text );
  min:= StrToFloat( ediMin.Text );
  max:= StrToFloat( ediMax.Text );

  with TLineSeries( FunctionList[ ActiveFunction ] ) do begin
       LinePen.Color:= colorbtnFunction.ButtonColor;
       LinePen.Width:= TrackBar1.Position;

  end;

  x:= min;
  TLineSeries( FunctionList[ ActiveFunction ] ).Clear;
  with TLineSeries( FunctionList[ ActiveFunction ] ) do
  repeat
      AddXY(x,f(x));
      x:= x+h
  until ( x>= max );


end;

procedure TForm1.CreateNewFunction;
begin
   EditList.Add( TEdit.Create(ScrollBox1) );
   //We OKA Edits with functions
   with Tedit( EditList.Items[ EditList.Count - 1 ] ) do begin
        Parent:= ScrollBox1;
        Align:= alTop;
        name:= FunctionEditName + IntToStr( EditList.Count );
        OnKeyUp:= @FunctionsEditKeyUp;
        Font.Size:= 10;
        Text:= EmptyStr;
        Tag:= EditList.Count - 1;
        SetFocus;

   end;
   //We OKA serial functions
   FunctionList.Add( TLineSeries.Create( Chart1 ) );
   with TLineSeries( FunctionList[ FunctionList.Count - 1 ] ) do begin
        Name:= FunctionSeriesName + IntToStr( FunctionList.Count );
        Tag:= EditList.Count - 1; // Edit Asossiated

   end;
   Chart1.AddSeries( TLineSeries( FunctionList[ FunctionList.Count - 1 ] ) );
end;

procedure TForm1.PointSol(xn: integer);
var
  i: integer;
begin
  SGPoints.RowCount:= GList.Count+1;
  SGPoints.Cells[0,0]:= 'x'; SGPoints.Cells[1,0]:= 'y';
  for i:=0 to GList.Count-1 do begin
    SGPoints.Cells[0,i+1]:= TBox(GList.Items[i]).M[TBox(GList.Items[i]).x-1,xn];
    SGPoints.Cells[1,i+1]:= '0';
  end;
end;

procedure TForm1.InterClick(Sender: TObject);
var
  PList: TList;
  sl,slp: string;
  i: integer;
  e: real;
begin
  sl:= 'sin(x)-cos(x*2)';
  slp:= Derivada.Text;
  PList:= TList.Create;
  PList:= MInter.Points(min,max,sl);
  GList.Clear;
  TableData.Clear;
  SGPoints.Clear;
  e:= StrToFloat(ErrorH.Text);
  if(comb.ItemIndex = 0) then begin
    for i:=0 to PList.Count-1 do
      GList.Add(MInter.MBisect(TPoint(PList.Items[i]).x,TPoint(PList.Items[i]).y,e,sl));
    PointSol(3);
  end
  else if(comb.ItemIndex = 1) then begin
    for i:=0 to PList.Count-1 do
      GList.Add(MInter.MFalPos(TPoint(PList.Items[i]).x,TPoint(PList.Items[i]).y,e,sl));
    PointSol(3);
  end
  else if(comb.ItemIndex = 2) then begin
    for i:=0 to PList.Count-1 do
      GList.Add(MInter.MNewton(TPoint(PList.Items[i]).x,e,sl,slp));
    PointSol(1);
  end
  else if(comb.ItemIndex = 3) then begin
    for i:=0 to PList.Count-1 do
      GList.Add(MInter.MSecant(TPoint(PList.Items[i]).x,e,sl));
    PointSol(1);
  end;
end;

procedure TForm1.DBClick(Sender: TObject);
var
  BT: TBox;
  i,j: integer;
begin
  BT:= TBox(GList.Items[StrToInt(Sol.Text)-1]);
  TableData.Clear;
  TableData.RowCount:= BT.x;
  TableData.ColCount:= BT.y;
  for i:=0 to BT.x-1 do begin
    for j:=0 to BT.y-1 do
      TableData.Cells[j,i]:= BT.M[i,j];
  end
end;

procedure TForm1.OKAClick(Sender: TObject);
begin
  SGA.Clear;
  SGA.RowCount:= StrToInt(XA.Text);
  SGA.ColCount:= StrToInt(YA.Text);
end;

procedure TForm1.OKBClick(Sender: TObject);
begin
  SGB.Clear;
  SGB.RowCount:= StrToInt(XB.Text);
  SGB.ColCount:= StrToInt(YB.Text);
end;

function TForm1.CreateA(): TMatriz;
var
  i,j: integer;
begin
  Result:= TMatriz.Create(SGA.ColCount,SGA.RowCount);
  for i:=0 to SGA.ColCount-1 do
    for j:=0 to SGA.RowCount-1 do
      Result.M[i,j]:= StrToFloat(SGA.Cells[i,j]);
end;

function TForm1.CreateB(): TMatriz;
var
  i,j: integer;
begin
  Result:= TMatriz.Create(SGB.ColCount,SGB.RowCount);
  for i:=0 to SGB.ColCount-1 do
    for j:=0 to SGB.RowCount-1 do
      Result.M[i,j]:= StrToFloat(SGB.Cells[i,j]);
end;

procedure TForm1.PutResult(a: TMatriz);
var
  i,j: integer;
begin
  MResult.SGFResult.RowCount:= a.GetY;
  MResult.SGFResult.ColCount:= a.GetX;
  for i:=0 to a.GetX-1 do
    for j:=0 to a.GetY-1 do
      MResult.SGFResult.Cells[i,j]:= FloatToStr(a.M[i,j]);
end;

procedure TForm1.MatrizRandom();
var
  i,j,ra1,ca1,rb1,cb1: integer;
begin
  ra1:= SGA.RowCount; ca1:= SGA.ColCount;
  for i:=0 to ra1-1 do
   for j:=0 to ca1-1 do
     SGA.Cells[j,i]:= IntToStr(random(10));

  rb1:= SGB.RowCount; cb1:= SGB.ColCount;
  for i:=0 to rb1-1 do
   for j:=0 to cb1-1  do
     SGB.Cells[j,i]:= IntToStr(random(10));
end;

procedure TForm1.SolOperClick(Sender: TObject);
var
  A,B: TMatriz;
  det: TRD;
begin
  if(OperMatriz.ItemIndex=9) then
    MatrizRandom()
  else begin
    A:= CreateA;  B:= CreateB;
    MResult.Show;
    if(OperMatriz.ItemIndex=0) then
      PutResult(A+B)
    else if(OperMatriz.ItemIndex=1) then
      PutResult(A-B)
    else if(OperMatriz.ItemIndex=2) then
      PutResult(A*B)
    else if(OperMatriz.ItemIndex=3) then
      PutResult(A/B)
    else if(OperMatriz.ItemIndex=4) then begin
      det:= A.Determinante();
      if(det.State and (det.Value<>0)) then
        PutResult(A.Inversa(det.Value))
      else
        ShowMessage('No Tiene Inversa');
    end
    else if(OperMatriz.ItemIndex=5) then begin
      det:= B.Determinante();
      if(det.State and (det.Value<>0)) then
        PutResult(B.Inversa(det.Value))
      else
        ShowMessage('No Tiene Inversa');
    end
    else if(OperMatriz.ItemIndex=6) then
      PutResult(A.Escalar(StrToFloat(MData.Text)))
    else if(OperMatriz.ItemIndex=7) then
      PutResult(A.MPower(StrToInt(MData.Text)))
    else if(OperMatriz.ItemIndex=8) then
      PutResult(A.Transpuesta)

  end;
end;


procedure TForm1.OkSenlClick(Sender: TObject);
var
  VP: array of real;
  VE: array of string;
  i, ne: integer;
  TTB: TBox;
  e: real;
begin
  ne:= StrToInt(EcuationSenl.Text);
  e:= StrToFloat(HSenl.Text);
  SetLength(VP,ne);
  SetLength(VE,ne);
  for i:=0 to ne-1 do begin
    VP[i]:= StrToFloat(PointInitialSenl.Cells[0,i+1]);
    VE[i]:= SGEcuationSenl.Cells[0,i+1];
  end;

  MSenl.SetVariable(ne,VE,VP);
  TTB:= MSenl.NewtonGeneralizado(e);
  SGResultado(TTB);
end;

procedure TForm1.SGResultado(TB: TBox);
var
  i,j: integer;
begin
  MResult.Show;

  MResult.SGFResult.RowCount:= TB.x;
  MResult.SGFResult.ColCount:= TB.y;
  for i:=0 to TB.x-1 do
    for j:=0 to TB.y-1 do
      MResult.SGFResult.Cells[j,i]:= TB.M[i,j];
end;

procedure TForm1.DatoSenlClick(Sender: TObject);
begin
  SGEcuationSenl.Cells[0,0]:= 'Ecuaciones';
  PointInitialSenl.Cells[0,0]:= 'Puntos Iniciales';
  SGEcuationSenl.RowCount:= StrToInt(EcuationSenl.Text)+1;
  PointInitialSenl.RowCount:= StrToInt(EcuationSenl.Text)+1;
end;

procedure TForm1.ISGNEClick(Sender: TObject);
var
  nt: integer;
begin
  nt:= StrToInt(INE.Text);
  SGPI.RowCount:= nt+1;
  SGPI.Cells[0,0]:= 'x';
  SGPI.Cells[1,0]:= 'y';
end;

procedure TForm1.ILagrangeClick(Sender: TObject);
var
  i: integer;
  MP: TList;
begin
  MP:= TList.Create;
  for i:=1 to SGPI.RowCount-1 do
    MP.Add(TPoint.Create(StrToFloat(SGPI.Cells[0,i]),StrToFloat(SGPI.Cells[1,i])));
  PointInter:= XIntervalo(MP);

  case TButton(Sender).Tag of
    0: InterpSol.Text:= MInterpolacion.Lagrange(MP);
    1: InterpSol.Text:= 'Newton';
  end;
  MP.Clear;
end;

function TForm1.Func(x: real; s: string): real;
begin
  Parse.Expression:= s;
  Parse.NewValue('x', x);
  Result:= Parse.Evaluate();
end;

procedure TForm1.BInterpolarClick(Sender: TObject);
var
  xt: real;
begin
  if((InterX.Text <> '') and (InterpSol.Text<>'')) then begin
    xt:= StrToFloat(InterX.Text);
    if((xt<PointInter.x) or (xt>PointInter.y)) then
      ShowMessage('Fuera del Intervalo');
    InterY.Text:= FloatToStr(Func(xt,InterpSol.Text));
  end
  else
    ShowMessage('Aplicar Algún Método de Interpolación!!');
end;

{$R *.lfm}

end.
    s
