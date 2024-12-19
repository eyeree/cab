#The following license ONLY applies to this file. Other files might have different licenses.

#MIT License

#Copyright (c) 2024 Tacure Dev

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.


extends Node

static func snap_pos_to_hex_grid_flat_top(i_globalPosition: Vector2, i_gridOffset: Vector2, i_hexCellRadius: float):
	i_globalPosition += i_gridOffset
	
	var recWidth = 3.0 * i_hexCellRadius
	var recHeight = sqrt(3.0) * i_hexCellRadius
	
	var idxXA = floor(i_globalPosition.x / recWidth)
	var idxYA = floor(i_globalPosition.y / recHeight)
	var posXA = idxXA * recWidth
	var posYA = idxYA * recHeight
	posXA -= i_gridOffset.x
	posYA -= i_gridOffset.y
	posXA += recWidth / 2
	posYA += recHeight / 2
	
	var idxXB = floor((i_globalPosition.x + recWidth / 2) / recWidth)
	var idxYB = floor((i_globalPosition.y + recHeight / 2) / recHeight)
	var posXB = idxXB * recWidth
	var posYB = idxYB * recHeight
	posXB -= i_gridOffset.x
	posYB -= i_gridOffset.y
	
	var posA = Vector2(posXA, posYA)
	var posB = Vector2(posXB, posYB)
	i_globalPosition -= i_gridOffset
	var distA = i_globalPosition.distance_to(posA)
	var distB = i_globalPosition.distance_to(posB)
	
	var resultPos: Vector2i
	var resultIdx: Vector2i
	var selectedRect: int
	if (distA < distB):
		resultPos = Vector2i(posXA, posYA)
		resultIdx = Vector2i(idxXA * 2, idxYA)
		selectedRect = 0
	else:
		resultPos = Vector2i(posXB, posYB)
		resultIdx = Vector2i(idxXB * 2 - 1, idxYB)
		selectedRect = 1
		
	var result = {
		"position": resultPos, #Snap position.
		"index": resultIdx, #Hex cell index.
		#Useful for debugging:
		"rect_a_position": posA, #Position of rectangle A.
		"rect_b_position": posB, #Position of rectangle B.
		"distance_a": distA, #Distance to the center of rectangle A.
		"distance_b": distB, #Distance to the center of rectangle B.
		"selected_rect": selectedRect, #Selected rectangle index: 0 == A, 1 == B
		"rect_width": recWidth, #Width of both, A and B, rectangles.
		"rect_height": recHeight #Height of both, A and B, rectangles.
	}
	return result

static func snap_pos_to_hex_grid_pointy_top(i_globalPosition: Vector2, i_gridOffset: Vector2, i_hexCellRadius: float):
	i_globalPosition += i_gridOffset
	
	var recWidth = sqrt(3.0) * i_hexCellRadius
	var recHeight = 3.0 * i_hexCellRadius
	
	var idxXA = floor(i_globalPosition.x / recWidth)
	var idxYA = floor(i_globalPosition.y / recHeight)
	var posXA = idxXA * recWidth
	var posYA = idxYA * recHeight
	posXA -= i_gridOffset.x
	posYA -= i_gridOffset.y
	posXA += recWidth / 2
	posYA += recHeight / 2
	
	var idxXB = floor((i_globalPosition.x + recWidth / 2) / recWidth)
	var idxYB = floor((i_globalPosition.y + recHeight / 2) / recHeight)
	var posXB = idxXB * recWidth
	var posYB = idxYB * recHeight
	posXB -= i_gridOffset.x
	posYB -= i_gridOffset.y
	
	var posA = Vector2(posXA, posYA)
	var posB = Vector2(posXB, posYB)
	i_globalPosition -= i_gridOffset
	var distA = i_globalPosition.distance_to(posA)
	var distB = i_globalPosition.distance_to(posB)
	
	var resultPos: Vector2i
	var resultIdx: Vector2i
	var selectedRect: int
	if (distA < distB):
		resultPos = Vector2i(posXA, posYA)
		resultIdx = Vector2i(idxXA, idxYA * 2)
		selectedRect = 0
	else:
		resultPos = Vector2i(posXB, posYB)
		resultIdx = Vector2i(idxXB, idxYB * 2 - 1)
		selectedRect = 1
		
	var result = {
		"position": resultPos, #Snap position.
		"index": resultIdx, #Hex cell index.
		#Useful for debugging:
		"rect_a_position": posA, #Position of rectangle A.
		"rect_b_position": posB, #Position of rectangle B.
		"distance_a": distA, #Distance to the center of rectangle A.
		"distance_b": distB, #Distance to the center of rectangle B.
		"selected_rect": selectedRect, #Selected rectangle index: 0 == A, 1 == B
		"rect_width": recWidth, #Width of both, A and B, rectangles.
		"rect_height": recHeight #Height of both, A and B, rectangles.
	}
	return result
