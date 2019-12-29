unit GameNode;
{-------------------------------}
interface

Uses GamePoint;

type
  
  Node = class
  
  public
    placement: Point;
    name: string = 'point';
    linkedNodes: array of integer;
    team: integer = 0;
    
    constructor create(place: Point);
    begin
      placement := place;
    end;
  end;
  
  NodeArr = array of Node;
  
{-------------------------------}

implementation

{---------------------------------}

begin
end. 