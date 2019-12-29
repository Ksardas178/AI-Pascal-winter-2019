unit GamePoint;
{-------------------------------}
interface

uses GraphABC;

const
  thingSize = 10;//Размер фишки

type
  
  Point = class
    public x, y: integer;
    
    constructor create(newX, newY: integer);
    begin
      x := newX;
      y := newY;    
    end;
    
    constructor create(other: Point);
    begin
      x := other.x;
      y := other.y;    
    end;
    
    private procedure line(other: Point);//Проводит линию между двумя точками
    
    public procedure line(other, offset, toResize: Point; scale: double);//Проводит линию между точками с учетом ремасштабирования
    
    public procedure markOccupied(offset, toResize: Point; scale: double; c: byte);//Отмечает точку как занятую
    
    private function getNewCoord(offset, toResize: Point; scale: double): Point;//Пересчет координат в новом масштабе
    
    public procedure subscribeIdx(idx: integer; offset, toResize: Point; scale: double);//Подписывает точку
    
    procedure print; reintroduce;//Переопределение вывода координат
    begin
      write('(', x, ', ', y, ')');
    end;
  end;
{-------------------------------}
implementation

{public} procedure Point.markOccupied(offset, toResize: Point; scale: double; c: byte);
var
  newPoint: Point := getNewCoord(offset, toResize, scale);
begin
  Brush.Color := (c = 1 ? Color.Blue : Color.Red);
  Circle(newPoint.x, newPoint.y, thingSize);
  Brush.Color := color.Empty;
end;

{public} procedure Point.subscribeIdx(idx: integer; offset, toResize: Point; scale: double);
var
  newPoint: Point;
begin
  newPoint := getNewCoord(offset, toResize, scale);
  textOut(newPoint.x + thingSize{Чуть сместили, чтобы не закрасить индекс}, newPoint.y, idx);
end;

{public} procedure Point.line(other, offset, toResize: Point; scale: double);
var
  place1, place2: Point;
begin
  place1 := getNewCoord(offset, toResize, scale);
  place2 := other.getNewCoord(offset, toResize, scale);
  place1.line(place2);
end;

{private} procedure Point.line(other: Point);
begin
  GraphABC.Line(x, window.Height - y, other.x, window.Height - other.y);
end;

{private} function Point.getNewCoord(offset, toResize: Point; scale: double): Point;//Пересчет координат в новом масштабе
var
  newX, newY: integer;
begin
  newX := floor((x - toResize.x) * scale) + offset.x;
  newY := floor((y - toResize.y) * scale) + offset.y;
  result := new Point(newX, newY);
end;
{---------------------------------}
begin
end . 