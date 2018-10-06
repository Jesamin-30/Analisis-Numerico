unit Func;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, math, fpexprpars;

type
  VectString = array of string;

type
  VectReal = array of real;

//para retornar los valores del sucesión
type
  TBox = class
    public
      x,y: integer;
      M: array of array of String;
      procedure Print;
      constructor Create(a: TList; size: integer);
      constructor Create(a,b: integer);
      destructor Destroy(); override;
  end;

//clase punto
type
  TMPoint = class
    public
      x,y: real;
      constructor Create(_x,_y: real);
      destructor Destroy(); override;
  end;

type
  TRB = record
    MBox: TBox;
    Value: Real;//valor que converge
  end;

var
  TLSFunct: TList;
  MFunct: TStringList;
  F1,F2: string;

implementation

constructor TMPoint.Create(_x, _y: real);
begin
  Self.x:= _x;
  Self.y:= _y;
end;

destructor TMPoint.Destroy();
begin
end;

function XIntervalo(MP: TList): TMPoint;
var
  i: integer;
  xmin,xmax,xtmp: real;
begin
  xmin:= TMPoint(MP.Items[0]).x;
  xmax:= TMPoint(MP.Items[0]).x;
  for i:=1 to MP.Count-1 do begin
    xtmp:= TMPoint(MP.Items[i]).x;
    if(xtmp < xmin) then xmin:= xtmp;
    if(xtmp > xmax) then xmax:= xtmp;
  end;
  Result:= TMPoint.Create(xmin,xmax);
end;
{TList: Almacena cualquier tipo de dato
se crea a partir de un TList de reales}

constructor TBox.Create(a: TList; size: integer);
var
  r,i,j: integer;
begin
  r:= (a.Count div size);//matriz en una lista
  i:= 0;  j:=1;
  y:= size+1;
  x:= r+1;

  //Metodo Abiertos [idx,xn,error]
  SetLength(M,x,y);
  if(size=2) then begin
    M[0,0]:= 'n'; M[0,1]:= 'xn'; M[0,2]:= 'e';
    while(i<a.Count) do begin
      M[j,0]:= IntToStr(j-1);
      M[j,1]:= FloatToStr(Real(a.Items[i]));
      M[j,2]:= FloatToStr(Real(a.Items[i+1]));
      i:= i+size;
      j:= j+1;
    end;
  end
  //Metodos Cerrados [idx,an,bn,xn,error]
  else if(size=4) then begin
    M[0,0]:= 'n'; M[0,1]:= 'a'; M[0,2]:= 'b'; M[0,3]:= 'xn'; M[0,4]:= 'e';
    while(i<a.Count) do begin
      M[j,0]:= IntToStr(j-1);
      M[j,1]:= FloatToStr(Real(a.Items[i]));
      M[j,2]:= FloatToStr(Real(a.Items[i+1]));
      M[j,3]:= FloatToStr(Real(a.Items[i+2]));
      M[j,4]:= FloatToStr(Real(a.Items[i+3]));

      i:= i+size;
      j:= j+1;
    end;
  end;
end;

constructor TBox.Create(a,b: integer);
begin
  x:= a;
  y:= b;
  SetLength(M,x,y);
end;

destructor TBox.Destroy();
begin
end;

//ver en consola
procedure TBox.Print;
var
  i,j: integer;
begin
  for i:=0 to x-1 do begin
    for j:=0 to y-1 do
      Write(M[i,j]+' ');
    WriteLn()
  end;
end;

function IsNumber(AValue: TExprFloat): Boolean;
begin
  result := not (IsNaN(AValue) or IsInfinite(AValue) or IsInfinite(-AValue));
end;

end.

