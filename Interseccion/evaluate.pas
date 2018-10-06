unit Evaluate;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ParseMath;

type
  TEvaluate = class
    constructor Create();
    destructor Destroy(); override;

    public
      MP: TParseMath;
      function Func(x: real; fn: string): real;
  end;

implementation

constructor TEvaluate.Create();
begin
  MP:= TParseMath.Create();
  MP.AddVariable('x',0);
end;

destructor TEvaluate.Destroy();
begin
  MP.Destroy();
end;

function TEvaluate.Func(x: real; fn: string): real;
begin
  MP.NewValue('x',x);
  MP.Expression:= fn;
  Result:= MP.Evaluate();
end;

end.
