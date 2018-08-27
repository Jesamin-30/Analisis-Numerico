unit class_taylor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

type
  TTaylor = class
    ErrorAllowed: Real;
    FunctionList: TstringList;
    FunctionType: Integer;
    AngleType: Integer;
    x: Real;
    function Execute(): Real;
    private
      Error,
      Angle: Real;
      function sen(): Real;
      function cos(): Real;
      function exponencial(): Real;
      function ln(): Real;
      function arcsen(): Real;
      function arctan(): Real;
    public

      constructor create;
      destructor Destroy; override;

  end;

const
  IsSin = 0;
  IsCos = 1;
  IsExp = 2;
  IsLn = 3;
  IsArcSin = 4;
  IsArcTan = 5;

  AngleSexagedecimal = 0;
  AngleRadian = 1;

implementation

const
  Top = 100000;

constructor TTaylor.create;
begin

  FunctionList:= TStringList.Create;
  FunctionList.AddObject( 'sen', TObject( IsSin ) );
  FunctionList.AddObject( 'cos', TObject( IsCos ) );
  FunctionList.AddObject( 'exp', TObject( IsExp ) );
  FunctionList.AddObject( 'ln(1+x)', TObject( IsLn ) );
  FunctionList.AddObject( 'arcsin', TObject( IsArcSin ) );
  FunctionList.AddObject( 'arctan', TObject( IsArcTan ) );

  Error:= Top;
  x:= 0;
end;

destructor TTaylor.Destroy;
begin

  FunctionList.Destroy;
end;

function Potencia( b: Double; n: Integer ): Double;
var i: Integer;
begin
   Result:= 1;
   for i:= 1 to n do
      Result:= Result * b;

end;

function Factorial( n: Integer ): Double;
begin
     if n > 1 then
        Result:= n * Factorial( n -1 )
     else if n >= 0 then
        Result:= 1
     else
        Result:= 0;

end;

function Module(a: Real; b: Double): Real;
var x: Real;
    i: Real;
begin
   x:=a;
   i:=0;
   repeat
     x:=x-b;
     i:=i+1;
   until (x<0);
   i:=i-1;
   i:=i*b;
   Result := a-i;
end;

function TTaylor.Execute( ): Real;
begin

   case AngleType of
        AngleRadian: Angle:= x;
        AngleSexagedecimal: Angle:=x * pi/180;
   end;
   Angle := Module(Angle ,(2*pi));
   case FunctionType of
        IsSin: Result:= sen();
        IsCos: Result:= cos();
        IsExp: Result:= exponencial();
        IsLn: Result := ln();
        IsArcSin: Result := ArcSen();
        IsArcTan: Result := ArcTan();
   end;
end;


function TTaylor.sen():Real;
var n:Integer=0;
    xn:Real;
begin
   Result:=0;
   repeat
     xn:=Result;
     Result:=Result+Potencia(-1,n)/factorial(2*n+1)*Potencia(x,2*n+1);

     if n>0 then
        Error:=abs(Result-xn);
     n:=n+1;
   until (Error<=ErrorAllowed) or (n>=Top) ;
end;


function TTaylor.cos():Real;
var n:Integer=0;
    xn:Real;
begin
   Result:=0;
   repeat
     xn:=Result;
     Result:=Result+((Potencia(-1,n)/factorial(2*n)))*Potencia(x,(2*n));

     if n>0 then
        Error:=abs(Result-xn);
     n:=n+1;
   until (Error<=ErrorAllowed) or (n>=Top) ;
end;


function TTaylor.exponencial(): Real;
var xn: Real;
    n: Integer=0;
begin
  Result:= 0;
  repeat
    xn:= Result;
    Result:= Result + (Potencia(x,n) / Factorial(n));

    if n > 0 then
       Error:= abs( Result - xn );

    n:= n + 1;
  until (Error < ErrorAllowed ) or (n >= Top );

end;

function Ttaylor.ln(): Real;
  var xn: Real;
    n: Integer=1;
begin
  Result := 0;
  repeat
    xn := Result;
    Result := Result + (Potencia( -1, n + 1) / n )* Potencia( x , n );

    if n > 0 then
       Error := abs( Result - xn);

    n := n + 1;
  until (Error < ErrorAllowed) or (n >= Top);

end;

function Ttaylor.arcsen(): Real;
var xn: Real;
    n: Integer;
begin
  n := 0;
  Result := 0;
  repeat
    xn := Result;
    Result := Result + Factorial( 2*n )/ ( Potencia( 4 , n)*Potencia( Factorial( n ) , 2)*(2*n + 1))*Potencia( angle, 2*n + 1);

    if n > 0 then
       Error := abs( Result - xn);

    n := n + 1;
  until (Error < ErrorAllowed) or (n >= Top);
end;
function Ttaylor.arctan(): Real;
var xn: Real;
    n: Integer;
begin
  n := 0;
  Result := 0;
  repeat
    xn := Result;
    Result := Result + Potencia( -1 , n ) / (2*n + 1) * Potencia (angle, 2*n + 1);

    if n > 0 then
       Error := abs( Result - xn);

    n := n + 1;
  until (Error < ErrorAllowed) or (n >= Top);
end;

end.

