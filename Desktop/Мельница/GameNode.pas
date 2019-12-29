unit GameNode;

{-------------------------------}

interface

uses GamePoint;

type
  Node = class
  
  public
    placement: Point;
    linkedNodes: array of Integer;
    team: Integer = 0;
    
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