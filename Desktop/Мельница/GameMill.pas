unit GameMill;
{-------------------------------}
interface

uses GamePoint;

type
  Mill = class
    elements: list<byte>;//Индексы поля, составляющие мельницу
    
    constructor create(a, b, c: byte);
    begin
      elements:=new List<byte>;
      elements.Add(a);
      elements.Add(b);
      elements.Add(c);
    end;
    
    constructor create(s: string);
    begin
      elements:=new List<byte>;
      var idxs := s.Split(' ');
      for var i := 0 to 2 do
        elements.Add(idxs[i].ToInteger);
    end;
    
    public function hasElement(e: byte):boolean;
    begin
      result:=elements.Contains(e);
    end;
    
    
    
  end;
  
  MillArr = array of Mill;
{-------------------------------}
implementation

{---------------------------------}
begin
end . 