package com.genome2d.fbx;

import com.genome2d.fbx.GFbxTools;
import com.genome2d.fbx.GFbxParserNode;

class GFbxGeometry extends GFbxNode {

    public var vertices:Array<Float>;
    public var indices:Array<UInt>;
    public var uvs:Array<Float>;
    //public var importedNormals:Array<Float>;
    public var vertexNormals:Array<Float>;
    public var faceNormals:Array<Float>;

    public function new(p_fbxNode:GFbxParserNode) {
        super(p_fbxNode);

        var vertexNode:GFbxParserNode = GFbxTools.getAll(p_fbxNode,"Vertices")[0];
        var vertexIndexNode:GFbxParserNode = GFbxTools.getAll(p_fbxNode,"PolygonVertexIndex")[0];

        var normalsNode:GFbxParserNode = GFbxTools.getAll(p_fbxNode, "LayerElementNormal.Normals")[0];

        var uvNode:GFbxParserNode = GFbxTools.getAll(p_fbxNode,"LayerElementUV.UV")[0];
        var uvIndexNode:GFbxParserNode = GFbxTools.getAll(p_fbxNode,"LayerElementUV.UVIndex")[0];

        var importedVertices:Array<Float> = GFbxTools.getFloats(vertexNode);
        vertexNormals = GFbxTools.getFloats(normalsNode);
        var currentVertexIndices:Array<Int> = cast GFbxTools.getInts(vertexIndexNode);
        var currentUVs:Array<Float> = GFbxTools.getFloats(uvNode);
        var currentUVIndices:Array<Int> = GFbxTools.getInts(uvIndexNode);
        if (currentUVIndices.length != currentVertexIndices.length) throw "Not same number of vertex and UV indices!";
        // Create array for our reindexed UVs
        uvs = new Array<Float>();
        for (j in 0...currentUVs.length) {
            uvs.push(0);
        }

        // Reindex stuff
        vertices = new Array<Float>();
        indices = new Array<UInt>();
        for (j in 0...currentVertexIndices.length) {
            var vertexIndex:Int = currentVertexIndices[j];
            if (vertexIndex < 0) vertexIndex = -vertexIndex-1;
            vertices.push(importedVertices[vertexIndex*3]);
            vertices.push(importedVertices[vertexIndex*3+1]);
            vertices.push(importedVertices[vertexIndex*3+2]);
            indices.push(j);
            //mergedVertexIndices.push(vertexIndex+indexOffset);

            var uvIndex:Int = currentUVIndices[j];
            uvs[j*2] = currentUVs[uvIndex*2];
            uvs[j*2+1] = 1-currentUVs[uvIndex*2+1];
        }

        //calculateFaceNormals();
        //calculateVertexNormals();
    }

    private function calculateFaceNormals():Void {
        faceNormals = new Array<Float>();
        var i:Int = 0;
        while (i<indices.length) {
            var p1x:Float = vertices[indices[i]*3];
            var p1y:Float = vertices[indices[i]*3+1];
            var p1z:Float = vertices[indices[i]*3+2];
            var p2x:Float = vertices[indices[i+1]*3];
            var p2y:Float = vertices[indices[i+1]*3+1];
            var p2z:Float = vertices[indices[i+1]*3+2];
            var p3x:Float = vertices[indices[i+2]*3];
            var p3y:Float = vertices[indices[i+2]*3+1];
            var p3z:Float = vertices[indices[i+2]*3+2];
            var e1x:Float = p1x-p2x;
            var e1y:Float = p1y-p2y;
            var e1z:Float = p1z-p2z;
            var e2x:Float = p3x-p2x;
            var e2y:Float = p3y-p2y;
            var e2z:Float = p3z-p2z;
            var nx:Float = e1y*e2z - e1z*e2y;
            var ny:Float = e1z*e2x - e1x*e2z;
            var nz:Float = e1x*e2y - e1y*e2x;
            var nl:Float = Math.sqrt(nx*nx+ny*ny+nz*nz);
            nx /= nl;
            ny /= nl;
            nz /= nl;
            faceNormals.push(nx);
            faceNormals.push(ny);
            faceNormals.push(nz);
            i+=3;
        }
    }

    private function getVertexFaces(p_vertexIndex:UInt):Array<UInt> {
        var faces:Array<UInt> = new Array<UInt>();
        for (i in 0...indices.length) {
            if (indices[i] == p_vertexIndex) {
                var face:UInt = Std.int(i/3);
                if (faces.indexOf(face) == -1) faces.push(face);
            }
        }
        return faces;
    }

    private function calculateVertexNormals():Void {
        vertexNormals = new Array<Float>();
        var vertexCount:Int = Std.int(vertices.length/3);
        for (i in 0...vertexCount) {
            var sharedFaces:Array<UInt> = getVertexFaces(i);
            var nx:Float = 0;
            var ny:Float = 0;
            var nz:Float = 0;
            for (faceIndex in sharedFaces) {
                nx += faceNormals[faceIndex*3];
                ny += faceNormals[faceIndex*3+1];
                nz += faceNormals[faceIndex*3+2];
            }
            var nl:Float = Math.sqrt(nx*nx+ny*ny+nz*nz);
            vertexNormals.push(nx/nl);
            vertexNormals.push(ny/nl);
            vertexNormals.push(nz/nl);
        }
    }
}
