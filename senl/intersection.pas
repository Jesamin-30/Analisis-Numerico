unit Intersection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ParseMath, Dialogs, Func;

type
  TMethIntersection = class
    private
      MSP: TList;
      nv: integer;
    public
      MParse: TParseMath;
      constructor Create();
      destructor Destroy(); override;

      procedure SizeH(a,b: real);
      function Func(x: real; f: string): real;
      function Bolzano(fn,f: string; xmin,xmax: real): TList;
      function MBisIni(a,b,e: real; fn: string):       real;
      function MSecIni(a,e: real; fn: string):         real;
      function MBisect(a,b,e: real; fn: string):       TRB;
      function MFalPos(a,b,e: real; fn: string):       TRB;
      function MNewton(a,e: real; fn,fp: string):      TRB;
      function MSecant(a,e: real; fn: string):         TRB;
      function MBothIn(a,b,e: real; fn: string):       TRB;   //raiz en entre [a,b]
      function MBoth(xmin,xmax,e: real; fn,f: string): TList; //todas las raices en [xmin,xmax]
end;

implementation

constructor TMethIntersection.Create();
begin
  MParse:= TParseMath.create();
  MParse.AddVariable('x',0);
  MSP:= TList.Create;
end;

destructor TMethIntersection.Destroy();
begin
end;

function TMethIntersection.Func(x: real; f: string): real;
begin
  MParse.NewValue('x',x);
  MParse.Expression:= f;
  Result:= MParse.Evaluate();
end;

procedure TMethIntersection.SizeH(a,b: real);
begin
  nv:= Round((b-a)/0.1);
end;

function TMethIntersection.MBisect(a,b,e: real; fn: string): TRB;
var
  et,vt,v,s: real;
  MT: TList;
begin
  et:= e+1; v:= 0;
  MT:= TList.Create;
  while(e<et) do begin
    vt:= v;
    v:= (a+b)/2;
    et:= abs(vt-v);
    s:= Func(a,fn)*Func(v,fn);

    MT.Add(Pointer(a));  MT.Add(Pointer(b));
    MT.Add(Pointer(v));  MT.Add(Pointer(et));

    if(s=0) then et:= e
    else if(s<0) then b:= v
    else a:= v;
  end;
  Result.Value:= v;
  Result.MBox:= TBox.Create(MT,4);
  MT.Clear;
end;

function TMethIntersection.MFalPos(a,b,e: real; fn: string): TRB;
var
  et,vt,v,s: real;
  MT: TList;
begin
  et:= e+1; v:= 0;
  MT:= TList.Create;
  while(e<et) do begin
    vt:= v;
    v:= b-((Func(b,fn)*(a-b))/(Func(a,fn)-Func(b,fn)));
    et:= abs(vt-v);
    s:= Func(a,fn)*Func(v,fn);

    MT.Add(Pointer(a));  MT.Add(Pointer(b));
    MT.Add(Pointer(v));  MT.Add(Pointer(et));

    if(s<0) then b:= v
    else a:= v;
  end;
  Result.Value:= v;
  Result.MBox:= TBox.Create(MT,4);
  MT.Clear;
end;

function TMethIntersection.MNewton(a,e: real; fn,fp: string): TRB;
var
  v,vt,et: real;
  MT: TList;
begin
  v:= a; et:= e+1;
  MT:= TList.Create;
  while(e<et) do begin
    vt:= v;
    if(Func(v,fp) = 0.0) then
      v:= v-(Func(v,fn)/(Func(v,fp)+0.0001))
    else
      v:= v-(Func(v,fn)/Func(v,fp));
    et:= abs(vt-v);

    MT.Add(Pointer(v));  MT.Add(Pointer(et));
  end;
  Result.Value:= v;
  Result.MBox:= TBox.Create(MT,2);
  MT.Clear;
end;

function TMethIntersection.MSecant(a,e: real; fn: string): TRB;
var
  v,vt,et,h: real;
  MT: TList;
begin
  h:= e/10; v:= a; et:= e+1;
  MT:= TList.Create;
  while(e<et) do begin
    vt:= v;
    if((Func(v+h,fn)-Func(v-h,fn)) = 0.0) then
      v:= v-((2*h*Func(v,fn))/(Func(v+h,fn)-Func(v-h,fn)+0.0001))
    else
      v:= v-((2*h*Func(v,fn))/(Func(v+h,fn)-Func(v-h,fn)));
    et:= abs(vt-v);

    MT.Add(Pointer(v));  MT.Add(Pointer(et));
  end;
  Result.Value:= v;
  Result.MBox:= TBox.Create(MT,2);
  MT.Clear;
end;

function TMethIntersection.MBisIni(a,b,e: real; fn: string): real;
var
  et,vt,v,s: real;
begin
  et:= e+1; v:= 0;
  while(e<et) do begin
    vt:= v;
    v:= (a+b)/2;
    et:= abs(vt-v);
    s:= Func(a,fn)*Func(v,fn);

    if(s<0) then b:= v
    else a:= v;
  end;
  Result:= v;
end;

function TMethIntersection.MSecIni(a,e: real; fn: string): real;
var
  v,vt,et,h: real;
begin
  h:= e/10; v:= a; et:= e+1;
  while(e<et) do begin
    vt:= v;
    if((Func(v+h,fn)-Func(v-h,fn)) = 0.0) then
      v:= v-((2*h*Func(v,fn))/(Func(v+h,fn)-Func(v-h,fn)+0.0001))
    else
      v:= v-((2*h*Func(v,fn))/(Func(v+h,fn)-Func(v-h,fn)));
    et:= abs(vt-v);
  end;
  Result:= v;
end;


function TMethIntersection.Bolzano(fn,f: string; xmin,xmax: real): TList;
var
  xmint,a,b,step: real;
  i: integer;
  t: boolean;
begin
  SizeH(xmin,xmax);
  step:= (xmax-xmin)/nv;
  Result:= TList.Create;
  t:= False;
  for i:=0 to nv-1 do begin
    xmint:= xmin;
    if(t) then begin
      xmint:= xmint+0.001;
      t:= False;
    end;

    a:= Func(xmint,fn);
    b:= Func(xmin+step,fn);
    if IsNumber(a) and IsNumber(b) and ((a*b)<0) then begin
      Result.Add(TMPoint.Create(xmint,xmin+step));
    end
    else if a=0 then
      MSP.Add(TMPoint.Create(xmint,Func(xmint,f)))
    else if b=0 then begin
      MSP.Add(TMPoint.Create(xmint,Func(xmin+step,f)));
      t:= True;
    end;
    xmin:= xmin+step;
  end;
end;

function TMethIntersection.MBothIn(a,b,e: real; fn: string): TRB;
var
  xtmp: real;
begin
  xtmp:= MBisIni(a,b,0.01,fn);
  Result:= MSecant(xtmp,e,fn);
end;

function TMethIntersection.MBoth(xmin,xmax,e: real; fn,f: string): TList;
var
  MBZ: TList;
  i: integer;
  xtmp,xtm1: real;
begin
  MBZ:= TList.Create;
  MSP.Clear;
  MBZ:= Bolzano(fn,f,xmin,xmax);
  for i:=0 to MBZ.Count-1 do begin
    xtmp:= MBisIni(TMPoint(MBZ.Items[i]).x,TMPoint(MBZ.Items[i]).y,0.01,fn);
    xtm1:= MSecIni(xtmp,e,fn);
    if (xtm1>=xmin) and (xtm1<=xmax) then
       MSP.Add(TMPoint.Create(xtm1,Func(xtm1,f)));
  end;
  Result:= MSP;
end;

end.

