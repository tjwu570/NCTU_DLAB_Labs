#include <iostream>
#include <math.h>
using namespace std;

#define BLACK 1
#define RED 0

// Red-black tree node
struct Node
{
    int val;
    bool color;
    Node *left, *right, *parent;

    // Constructor
    Node(int val) : val(val), color(RED), left(NULL), right(NULL), parent(NULL) {}
};

// Red-black tree
class RedBlackTree
{
private:
    // Root of the tree
    Node *root;

    // Left Rotate
    void leftRotate(Node *&, Node *&);

    // Right Rotate
    void rightRotate(Node *&, Node *&);

    // Fix violation of Red-Black Tree properties
    void fixViolation(Node *&, Node *&);

public:
    // Constructor
    RedBlackTree() : root(NULL) {}

    // Inserts a new node in the tree
    void insert(const int &);

    // Deletes a node from the tree
    void remove(const int &);

    // Returns the inorder traversal of the tree
    vector<int> inorder() const;
};

// Left Rotate
void RedBlackTree::leftRotate(Node *&root, Node *&pt)
{
    Node *pt_right = pt->right;

    pt->right = pt_right->left;

    if (pt->right != NULL)
        pt->right->parent = pt;

    pt_right->parent = pt->parent;

    if (pt->parent == NULL)
        root = pt_right;

    else if (pt == pt->parent->left)
        pt->parent->left = pt_right;

    else
        pt->parent->right = pt_right;

    pt_right->left = pt;
    pt->parent = pt_right;
}

// Right Rotate
void RedBlackTree::rightRotate(Node *&root, Node *&pt)
{
    Node *pt_left = pt->left;

    pt->left = pt_left->right;

    if (pt->left != NULL)
        pt->left->parent = pt;

    pt_left->parent = pt->parent;

    if (pt->parent == NULL)
        root = pt_left;

    else if (pt == pt->parent->left)
        pt->parent->left = pt_left;

    else
        pt->parent->right = pt_left;

    pt_left->right = pt;
    pt->parent = pt_left;
}

// Fix violation of Red-Black Tree properties
void RedBlackTree::fixViolation(Node *&root, Node *&pt)
{
    Node *parent_pt = NULL;
    Node *grand_parent_pt = NULL;

    while ((pt != root) && (pt->color != BLACK) &&
           (pt->parent->color == RED))
    {

        parent_pt = pt->parent;
        grand_parent_pt = pt->parent->parent;

        // Case : A
        // Parent of pt is left child of Grand-parent of pt
        if (parent_pt == grand_parent_pt->left)
        {

            Node *uncle_pt = grand_parent_pt->right;

            // Case : A
            // Parent of pt is left child of Grand-parent of pt
            if (parent_pt == grand_parent_pt->left)
            {
                // Only if uncle is not NULL and uncle is red
                // Perform rotation and change colors
                if ((uncle_pt != NULL) && (uncle_pt->color == RED))
                {
                    grand_parent_pt->color = RED;
                    parent_pt->color = BLACK;
                    uncle_pt->color = BLACK;
                    pt = grand_parent_pt;
                }

                else
                {
                    // Case : B
                    // Current node is right child of its parent
                    // Left-rotation required
                    if (pt == parent_pt->right)
                    {
                        leftRotate(root, parent_pt);
                        pt = parent_pt;
                        parent_pt = pt->parent;
                    }

                    // Case : C
                    // Current node is left child of its parent
                    // Right-rotation required
                    rightRotate(root, grand_parent_pt);
                    swap(parent_pt->color, grand_parent_pt->color);
                    pt = parent_pt;
                }
            }

            // Case : B
            // Parent of pt is right child of Grand-parent of pt
            else
            {
                Node *uncle_pt = grand_parent_pt->left;

                // Only if uncle is not NULL and uncle is red
                // Perform rotation and change colors
                if ((uncle_pt != NULL) && (uncle_pt->color == RED))
                {
                    grand_parent_pt->color = RED;
                    parent_pt->color = BLACK;
                    uncle_pt->color = BLACK;
                    pt = grand_parent_pt;
                }
                else
                {
                    // Case : B
                    // Current node is left child of its parent
                    // Right-rotation required
                    if (pt == parent_pt->left)
                    {
                        rightRotate(root, parent_pt);
                        pt = parent_pt;
                        parent_pt = pt->parent;
                    }

                    // Case : C
                    // Current node is right child of its parent
                    // Left-rotation required
                    leftRotate(root, grand_parent_pt);
                    swap(parent_pt->color, grand_parent_pt->color);
                    pt = parent_pt;
                }
            }
        }
    }

    root->color = BLACK;
}

// Returns the inorder traversal of the tree





// Inserts a new node in the tree
void RedBlackTree::insert(const int &val)
{
    Node *pt = new Node(val);

    // Do a normal BST insert
    Node *y = NULL;
    Node *x = root;

    while (x != NULL)
    {
        y = x;
        if (pt->val < x->val)
            x = x->left;
        else
            x = x->right;
    }

    pt->parent = y;
    if (y == NULL)
        root = pt;
    else if (pt->val < y->val)
        y->left = pt;
    else
        y->right = pt;

    // Fix violation of Red-Black Tree properties
    fixViolation(root, pt);
}

// Deletes a node from the tree
void RedBlackTree::remove(const int &val)
{
    // Search for the node to be deleted
    Node *pt = root;
    while (pt != NULL && pt->val != val)
    {
        if (val < pt->val)
            pt = pt->left;
        else
            pt = pt->right;
    }

    if (pt == NULL)
        return;

    // If the node to be deleted has both children
    if (pt->left != NULL && pt->right != NULL)
    {
        Node *y = pt->right;
        while (y->left != NULL)
            y = y->left;

        pt->val = y->val;
        pt = y;
    }

    // If the node to be deleted has only one child or no children
    Node *child = (pt->left != NULL) ? pt->left : pt->right;
    if (child != NULL)
        child->parent = pt->parent;

    if (pt->parent == NULL)
        root = child;
    else if (pt == pt->parent->left)
        pt->parent->left = child;
    else
        pt->parent->right = child;

    // If the node to be deleted is black, fix violations
    if (pt->color == BLACK)
        fixViolation(root, child);

    delete pt;
}
