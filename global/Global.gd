extends Node

const cellsize := 64

func cell2p(cell : Vector2) -> Vector2:
	return (cell+Vector2(0.5,0.5))*cellsize
	
func p2cell(p: Vector2) -> Vector2:
	return Vector2(floor(p.x/cellsize), floor(p.y/cellsize))
	
