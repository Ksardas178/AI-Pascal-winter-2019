unit GameBorders;

{-------------------------------}

interface

uses 
  GamePoint,
  GraphABC;

const
  margin = 120;//Поля экрана

type
  //Границы поля
  Borders = class
  
  public
    maxPoint, minPoint, centerAlignOffset: GamePoint.Point;
    scale: double;
    
    constructor create();
    begin
      scale := 1;
    end;
  
  public
    procedure checkPoint(place: GamePoint.Point);//Подстройка границ окна под новую точку
    procedure setScale(newScale: double);//Ручное ремасштабирование
    procedure setScale();//Автоматическое ремасштабирование
  
  private
    procedure setOffset;//Переопределение точки привязки  
  end;

{-------------------------------}

implementation

//public
procedure Borders.setScale();//Автоматическое ремасштабирование
var
  h, w: integer;
begin
  w := maxPoint.x - minPoint.x;
  h := maxPoint.y - minPoint.y;
  scale := min((Window.Width - 2 * margin) / w, (Window.Height - 2 * margin) / h);
  setOffset;
end;

//private
procedure Borders.setOffset;
var
  h, w, newX, newY: integer;
begin
  w := maxPoint.x - minPoint.x;
  h := maxPoint.y - minPoint.y;
  newX := floor((Window.Width - w * scale) / 2);
  newY := floor((Window.Height - h * scale) / 2);
  centerAlignOffset := new GamePoint.Point(newX, newY);
  writeln(centerAlignOffset);
end;

//public
procedure Borders.setScale(newScale: double);//Ручное ремасштабирование
begin
  scale := newScale;
  setOffset;
end;

//public
procedure Borders.checkPoint(place: GamePoint.Point);//Подстройка границ окна под новую точку
begin
  if (maxPoint = nil) then//Если еще нет точек привязки
  begin
    maxPoint := new GamePoint.Point(place);
    minPoint := new GamePoint.Point(place);
  end 
      else
  begin
    if (place.x > maxPoint.x) then maxPoint.x := place.x;
    if (place.y > maxPoint.y) then maxPoint.y := place.y;
    if (place.x < minPoint.x) then minPoint.x := place.x;
    if (place.y < minPoint.y) then minPoint.y := place.y;
  end;
end;

{---------------------------------}

begin
end. 