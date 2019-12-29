unit GamePoint;

{-------------------------------}

interface

uses GraphABC;

const
  thingSize = 10;//Размер фишки

type
  Point = class
  
  public
    x, y: Integer;
    
    {$region Constructors}
    
    constructor create(newX, newY: Integer);
    begin
      x := newX;
      y := newY;    
    end;
    
    constructor create(other: Point);
    begin
      x := other.x;
      y := other.y;    
    end;
    
    {$endRegion Constructors}
    
    procedure print; reintroduce;//Переопределение вывода координат
    begin
      write('(', x, ', ', y, ')');
    end;
  
  public
    procedure line(other, offset, toResize: Point; scale: Double);//Проводит линию между точками с учетом ремасштабирования
    procedure markOccupied(offset, toResize: Point; scale: Double; c: Integer);//Отмечает точку как занятую
    procedure subscribeIdx(idx: Integer; offset, toResize: Point; scale: Double);//Подписывает точку
  
  private
    procedure line(other: Point);//Проводит линию между двумя точками
    function getNewCoord(offset, toResize: Point; scale: Double): Point;//Пересчет координат в новом масштабе
  
  end;

{-------------------------------}

implementation

{$region Drawing}

//public
procedure Point.markOccupied(offset, toResize: Point; scale: Double; c: Integer);
var
  newPoint: Point := getNewCoord(offset, toResize, scale);
begin
  Brush.Color := (c = 1 ? Color.Blue : Color.Red);
  Circle(newPoint.x, newPoint.y, thingSize);
  Brush.Color := color.Empty;
end;

//public
procedure Point.subscribeIdx(idx: Integer; offset, toResize: Point; scale: Double);
var
  newPoint: Point;
begin
  newPoint := getNewCoord(offset, toResize, scale);
  textOut(newPoint.x + thingSize{Чуть сместили, чтобы не закрасить индекс}, newPoint.y, idx);
end;

//public
procedure Point.line(other, offset, toResize: Point; scale: Double);
var
  place1, place2: Point;
begin
  place1 := getNewCoord(offset, toResize, scale);
  place2 := other.getNewCoord(offset, toResize, scale);
  place1.line(place2);
end;

//private
procedure Point.line(other: Point);//Проводит линию между двумя точками
begin
  GraphABC.Line(x, window.Height - y, other.x, window.Height - other.y);
end;

{$endRegion Drawing}

//private
function Point.getNewCoord(offset, toResize: Point; scale: Double): Point;//Пересчет координат в новом масштабе
var
  newX, newY: Integer;
begin
  newX := floor((x - toResize.x) * scale) + offset.x;
  newY := floor((y - toResize.y) * scale) + offset.y;
  result := new Point(newX, newY);
end;

{---------------------------------}

begin
end . 