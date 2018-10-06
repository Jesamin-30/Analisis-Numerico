unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TATools, TASeries, TAFuncSeries, Forms,
  Controls, Graphics, Dialogs, TAChartUtils, ComCtrls, ExtCtrls, StdCtrls,
  Grids, ColorBox, Types, ParseMath, Evaluate, Intersection, Math, Func,
  TACustomSeries;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnOk: TButton;
    charFunction: TChart;
    charFunctionFuncSeries1: TFuncSeries;
    char1LineSeries1: TLineSeries;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    EFunction2: TEdit;
    LFunction2: TLabel;
    LineColorBox: TColorBox;
    LPoints: TLineSeries;
    CMethod: TComboBox;
    EA: TEdit;
    EB: TEdit;
    EFunction1: TEdit;
    EError: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    LA: TLabel;
    LB: TLabel;
    LError: TLabel;
    LFuncion1: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    SGData: TStringGrid;
    TabInterseccion: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure BtnLimpiarClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure charFunctionFuncSeries1Calculate(const AX: Double; out AY: Double
      );
    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure PutSG(TB: TBox);
    procedure PutPoint(ML: TList);
    function Func(x: real; Fn: string): real;
    procedure GraphicPoint(MP: TList);
    procedure MNewFunction(fn: string);
    procedure Plotear(fn: string; xmin,xmax: real);
    procedure ClearPlot();

  private
    MParse: TParseMath;
    MInter: TMethIntersection;
  public
    cont:integer;
    MP: TEvaluate;
    idxcolor: integer;
    FuncSelected: boolean;
  end;

var
  Form1: TForm1;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ClearPlot();
var
  i: integer;
begin
  for i:=0 to TLSFunct.Count-1 do
    TLineSeries(TLSFunct.Items[i]).Destroy;

  MFunct.Clear;
  TLSFunct.Clear;
  charFunction.ClearSeries;
  LPoints := TLineSeries.Create(charFunction);
  charFunction.AddSeries(LPoints);
  idxcolor:= 9;
end;

procedure TForm1.BtnOkClick(Sender: TObject);
var
  Fn,Fp,Ft: string;
  RT,RA,A,B,Er: real;
  MTRB: TRB;
begin
  Fn:= EFunction1.Text;
  Fp:= EFunction2.Text;
  Er:= StrToFloat(EError.Text);
  A:= StrToFloat(EA.Text);
  B:= StrToFloat(EB.Text);

  if(CMethod.ItemIndex=5) then begin
      PutPoint(MInter.MBoth(A,B,Er,Fn,Fn))
  end

  else if (CMethod.ItemIndex=7)then begin
      Plotear(fn,a,b);
  end
  else if(CMethod.ItemIndex=8)then begin
      Ft:= '('+F1+')-('+F2+')';
      GraphicPoint(MInter.MBoth(A,B,Er,FT,Fn));
      //Plotear(fn,a,b);
  end
  else if (CMethod.ItemIndex=9) then begin
      ClearPlot();
  end
  else if(CMethod.ItemIndex=6) then begin
      Mtrb:= MInter.MPuntoFijo(A,Er,Fn); //PUNTO FIJO
      PutSG(MTRB.MBox);
  end
  else begin
    //intervalos cercanos [a,b], una sola raiz
    RA:= Func(A,Fn); RT:= RA*Func(B,Fn);
    if(RT<0) then begin
      case CMethod.ItemIndex of
        0: MTRB:= MInter.MBisect(A,B,Er,Fn);  //Bisección
        1: MTRB:= MInter.MFalPos(A,B,Er,Fn);  //Falsa Posición
        2: MTRB:= MInter.MNewton(A,Er,Fn,Fp); //Newton
        3: MTRB:= MInter.MSecant(A,Er,Fn);    //Secante
        4: MTRB:= MInter.MBothIn(A,B,Er,Fn);  //Bisección-Secante para solo una raiz.
        //6: Mtrb:= MInter.MPuntoFijo(A,Er,Fn); //PUNTO FIJO

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

procedure TForm1.BtnLimpiarClick(Sender: TObject);
begin

end;

procedure TForm1.charFunctionFuncSeries1Calculate(const AX: Double; out
  AY: Double);
var
  Fn: String;
begin
    //Fn:= EFunction1.Text;
//    AY:=Func(AX,Fn);
end;

procedure TForm1.ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
  APoint: TPoint);
begin
  with ATool as TDatapointClickTool do begin
    if (Series is TLineSeries) then begin
      with TLineSeries(Series) do begin
        if(FuncSelected) then begin
          F1:= MFunct[Tag];
          ShowMessage('f(x): '+F1);
          FuncSelected:= False;
        end
        else begin
          if(F1 <> MFunct[Tag]) then begin
            F2:= MFunct[Tag];
            ShowMessage('g(x): '+F2);
            FuncSelected:= True;
          end
          else
            ShowMessage('Seleccione otra función, no la misma!!');
        end;
      end;
    end;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  MParse:= TParseMath.Create();
  MInter:= TMethIntersection.Create();
  MFunct:= TStringList.Create;
  TLSFunct:= TList.Create;
  MP:= TEvaluate.Create();
  FuncSelected:= True;
  F1:=' ';
  F2:=' ';
  idxcolor:= 9;
  MParse.AddVariable('x',0);
  cont:=0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  MParse.Destroy;
  MInter.Destroy;
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;

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


function TForm1.Func(x: real; Fn: string): real;
begin
  MParse.NewValue('x',x);
  MParse.Expression:= Fn;
  Result:= MParse.Evaluate();
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

procedure TForm1.MNewFunction(fn: string);
begin
  MFunct.Add(fn);
  TLSFunct.Add(TLineSeries.Create(charFunction));
  with TLineSeries(TLSFunct[TLSFunct.Count-1]) do begin
    Name:= 'FunctionName'+IntToStr(TLSFunct.Count);
    Tag:= MFunct.Count-1;
    LinePen.Color:= LineColorBox.Colors[idxcolor];  ;
  end;
  idxcolor:= idxcolor+1;
  charFunction.AddSeries(TLineSeries(TLSFunct[TLSFunct.Count-1]));
end;

procedure TForm1.Plotear(fn: string; xmin,xmax: real);
var
  x,y,h: Real;
begin
  x:= xmin;
  h:= 0.001;

  MNewFunction(fn);
  with TLineSeries(TLSFunct[TLSFunct.Count-1]) do repeat
    y:= MP.Func(x,fn);
    AddXY(x,y);
    x:= x+h
  until(x>=xmax);
end;

end.

