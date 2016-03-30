//
//  CanvasView.m
//  Colors
//
//  Created by Abid Rana on 03/03/2014.
//  Copyright (c) 2014 Stuff. All rights reserved.
//

#import "CanvasView.h"
#import <vector>


//#define GRID_COLS 9
//#define GRID_ROWS 9

#define GRID_COLS (320/10)
#define GRID_ROWS (480/20)


#define TILE_WIDTH 8
#define TILE_HEIGHT 8

#define DIR_UP      0
#define DIR_DOWN    1
#define DIR_LEFT    2
#define DIR_RIGHT   3

#define WALL 0 
#define MAZE 1

struct Node
{
    int row;
    int col;
    int maxRow;
    int maxCol;
    int type;
    int dir;
    bool visited;
};

enum NodeType
{
    eClear = 0,
    eSolid = 1
};

class NodeStack
{
public:
    
    Node **stack;
    int stackPointer;
    std::vector<Node*> stackNodesV;
    
    NodeStack(int size)
    {
        stack = new Node*[size];
        stackPointer = 0;
        
    }
    void push(Node *node)
    {
        
        //printf("pushing node row %d col%d \n",node->row, node->col);
        
        stack[stackPointer] = node;
        stackPointer += 1;
        
        stackNodesV.push_back(node);
        
    }
    Node* pop()
    {
        Node *node = NULL;
        
        stackPointer -= 1;
        
        if( stackPointer < 0 )
        {
            printf("ALL DONE stack empty!!!\n");
            node = stack[0];
            return node;
        }
        
        node = stack[stackPointer];
        
        int index =rand()%stackNodesV.size();
        
        node = stackNodesV.at(index);
        
        stackNodesV.erase (stackNodesV.begin()+index);
        
        
        return node;
    }
    bool isEmpty()
    {
        
        if( stackPointer >= 0 )
        {
            return false;
        }
        
        return true;
    }
};

class Grid2dD
{
public:
    int width;
    int height;
    
    Node **grid;
    
    Grid2dD(int _width, int _height)
    {
        
        width = _width;
        height = _height;
        
        grid = new Node*[height];
        
        for ( int row = 0; row < height; row ++ )
        {
            grid[row] = new Node[width];
        }
    }
    
    void clearGrid(int _type)
    {
        for ( int row = 0; row < height; row ++ )
        {
            for ( int col = 0; col < width; col ++ )
            {
                Node *n = &grid[row][col];
                
                n->row = row;
                n->col = col;
                n->maxRow = height;
                n->maxCol = width;
                
                if( row == 0 || row == height-1 || col == 0 ||col == width-1)
                {
                        // close border
                    n->type = 1;
                }
                else
                {
                    n->type = _type;
                }
                
                n->visited = false;
            }
        }
    }
    void clearBorder()
    {
        for ( int row = 0; row < height; row ++ )
        {
            for ( int col = 0; col < width; col ++ )
            {
                Node *n = &grid[row][col];
                
                if( row == 0 || row == height-1 || col == 0 ||col == width-1)
                {
                    // close border
                    n->type = 0;
                }
            }
        }
    }
    void print()
    {
        printf("\n");
        for ( int row = 0; row < height; row ++ )
        {
            for ( int col = 0; col < width; col ++ )
            {
                printf("%d ",grid[row][col].type);
            }
            printf("\n");
        }
    }
    
};

@implementation CanvasView

//Grid2dD *grid = NULL;
Grid2dD *trackGrid = NULL;
NodeStack *nodeStack;

void initMaze()
{
    nodeStack = new NodeStack(200);
    
    trackGrid = new Grid2dD(GRID_COLS,GRID_ROWS);
    trackGrid->clearGrid(0);
    
}
void pushNodeFrontiers(Node *node)
{
    
    int row = 0;
    int col = 0;

    node->type = 1;
    
    // check top
    if( node->row > 0 )
    {
        row = node->row-1;
        col = node->col;
        
        if( trackGrid->grid[row][col].type == WALL )
        {
            trackGrid->grid[row][col].type = 2;
            trackGrid->grid[row][col].dir = DIR_UP;
            nodeStack->push(&trackGrid->grid[row][col]);
        }
    }
    // left
    if( node->col > 0 )
    {
        row = node->row;
        col = node->col-1;
        
        if( trackGrid->grid[row][col].type == WALL )
        {
            
            trackGrid->grid[row][col].type = 2;
            trackGrid->grid[row][col].dir = DIR_LEFT;
            nodeStack->push(&trackGrid->grid[row][col]);
        }
    }
    // check right
    if( node->col < (node->maxCol-1) )
    {
        row = node->row;
        col = node->col+1;
        
        if( trackGrid->grid[row][col].type == WALL )
        {
            
            trackGrid->grid[row][col].type = 2;
            trackGrid->grid[row][col].dir = DIR_RIGHT;
            nodeStack->push(&trackGrid->grid[row][col]);
        }
    }
    // bottom
    if( node->row < (node->maxRow-1) )
    {
        row = node->row+1;
        col = node->col;
        
        if( trackGrid->grid[row][col].type == WALL )
        {
            
            trackGrid->grid[row][col].type = 2;
            trackGrid->grid[row][col].dir = DIR_DOWN;
            nodeStack->push(&trackGrid->grid[row][col]);
        }
    }
    
    
}
void checkNodePrims(Node *node)
{
    
    int row = 0;
    int col = 0;
    
    switch (node->dir) {
        case DIR_UP:
            row = node->row-1;
            col = node->col;
            
            if( trackGrid->grid[row][col].type != MAZE )
            {
                trackGrid->grid[row][col].type = MAZE;
                node->type = 1;
                pushNodeFrontiers(&trackGrid->grid[row][col]);
            }
            break;
        case DIR_DOWN:
            
            row = node->row+1;
            col = node->col;
            
            if( trackGrid->grid[row][col].type != MAZE )
            {
                trackGrid->grid[row][col].type = MAZE;
                node->type = 1;
                pushNodeFrontiers(&trackGrid->grid[row][col]);
            }
            
            break;
        case DIR_LEFT:
            
            row = node->row;
            col = node->col-1;
            
            if( trackGrid->grid[row][col].type != MAZE )
            {
                trackGrid->grid[row][col].type = MAZE;
                node->type = 1;
                pushNodeFrontiers(&trackGrid->grid[row][col]);
            }
            
            break;
        case DIR_RIGHT:
            
            row = node->row;
            col = node->col+1;
            
            if( trackGrid->grid[row][col].type != MAZE )
            {
                trackGrid->grid[row][col].type = MAZE;
                node->type = 1;
                pushNodeFrontiers(&trackGrid->grid[row][col]);
            }
            
            break;
            
        default:
            break;
    }

}

// MAZE WHITE
// WALL BLACK

/*
1. Start with a grid full of walls.

2. Pick a node, mark it as part of the maze.

3. Add the adjacent nodes of the current node to the wall list.

4. While there are walls in the list:

    Pick a random wall from the list. If the cell on the opposite side isn't in the maze yet:
    Make the wall a passage and mark the cell on the opposite side as part of the maze.
    Add the neighboring walls of the cell to the wall list.
    If the cell on the opposite side already was in the maze, remove the wall from the list.

*/
void createMaze()
{
    
    Node *currNode;
    
    // 1. Start with a grid full of walls.
    trackGrid->clearGrid(WALL);
    
    
    //pushNodeFrontiers(&trackGrid->grid[rand()%GRID_ROWS][rand()%GRID_COLS]);
    
    //pushNodeFrontiers(&trackGrid->grid[1][1]);
    
    //pushNodeFrontiers(&trackGrid->grid[3][3]);
    
   // pushNodeFrontiers(&trackGrid->grid[5][5]);
    
    for ( int row = 1; row < trackGrid->height; row += 8 )
    {
        for ( int col = 1; col < trackGrid->width; col += 8 )
        {
            pushNodeFrontiers(&trackGrid->grid[row][col]);
        }
    }
    
    // do the bulk of the work
    int numIterations = 0;
    
    while(!nodeStack->isEmpty())
    {
        // process current node
       // trackGrid->print();
        
        currNode = nodeStack->pop();
        
       checkNodePrims(currNode);
        
        //checkNodePrims(currNode);
        
        // push new nodes on stack
        
        numIterations += 1;
    }
    
    trackGrid->clearBorder();
    
    printf("track grid:::\n");
    
    //trackGrid->print();
    
    printf("numIterations %d:::\n",numIterations);
    
    printf("ALL DONE WITH MAZE!\n");
    
    
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        

        
    }
    return self;
}

-(void) drawMaze
{
    static bool init =  true;
    
    
    if( init )
    {
        init = false;
        initMaze();
        
        createMaze();
        
    }
        //Get the CGContext from this view
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //Draw a rectangle
        
        //Define a rectangle
        //CGContextAddRect(context, CGRectMake(10.0, 150.0, 60.0, 120.0));     //X, Y, Width, Height
        
        
        //CGContextAddRect(context, CGRectMake(100.0, 350.0, 60.0, 120.0));     //X, Y, Width, Height
        
    int xDraw = (self.frame.size.width/2)  - ((TILE_WIDTH * GRID_COLS) / 2 );
    int yDraw = (self.frame.size.height/2) - ((TILE_HEIGHT * GRID_ROWS) / 2 );
    
        for( int row = 0 ; row < trackGrid->height; row++)
        {
            for( int col = 0 ; col < trackGrid->width; col++)
            {
                if( trackGrid->grid[row][col].type == 1 )
                {
                    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
                }
                else
                {
                    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
                }
                
                CGContextAddRect(context, CGRectMake(xDraw+(col*TILE_WIDTH), yDraw+(row*TILE_HEIGHT), TILE_WIDTH, TILE_HEIGHT));
                
                CGContextFillPath(context);
                
            }
        }
        
        
    

}
-(void) drawRect:(CGRect)rect

{
    [self drawMaze];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
