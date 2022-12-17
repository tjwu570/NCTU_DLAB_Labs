#include <iostream>
#include <vector>
using namespace std;

#define RED 0
#define BLACK 1

#define _INSERT 1
#define _DELETE 2

struct Node
{
    int data;
    bool color;
    Node *left, *right, *parent;

    //Constructor
    Node(int data){
        this->data = data;
        color = RED;
        left = nullptr;
        right = nullptr;
        parent = nullptr;
    };
};

class RBTree
{
public:
        void  left_rotate(Node *ptr);
        void  right_rotate(Node *ptr);

        Node* find_min(Node *node);
        Node* BST_insert(Node *root, Node *ptr);
        Node* BST_delete(Node *root, int data);

        //Constructor
        RBTree() {root = nullptr;};

        void insert(int);
        void deleteValue(int);

        //Printing the output 
        void inorder(Node *node);

        Node *root;
};


void RBTree::insert(int n) {
    Node *node = new Node(n);

    root = BST_insert(root, node);

    // Fixing violation after inserting
    Node *parent = nullptr;
    Node *grandma = nullptr;
    while ((node != root && node->color == RED ) && ( node->parent != nullptr && node->parent->color == RED) ){
        parent = node->parent;
        grandma = parent->parent;
        if (parent == grandma->left) {
            Node *aunt = grandma->right;
            if (aunt != nullptr && aunt->color == RED) {
                aunt->color = BLACK;
                if (parent != nullptr) parent->color = BLACK;
                if (grandma != nullptr) grandma->color = RED;
                node = grandma;
            } else {
                if (node == parent->right) {
                    left_rotate(parent);
                    node = parent;
                    parent = node->parent;
                }
                right_rotate(grandma);
                swap(parent->color, grandma->color);
                node = parent;
            }
        } else {
            Node *aunt = grandma->left;
            if (aunt != nullptr && aunt->color == RED) {
                aunt->color = BLACK;
                if (parent != nullptr) parent->color = BLACK;
                if (grandma != nullptr) grandma->color = RED;
                node = grandma;
            } else {
                if (node == parent->left) {
                    right_rotate(parent);
                    node = parent;
                    parent = node->parent;
                }
                left_rotate(grandma);
                swap(parent->color, grandma->color);
                node = parent;
            }
        }
    }
    if (root!= nullptr) root->color = BLACK;
    //Done fixing violation
}

// A recursive function that find the right place and insert the node into the tree
Node* RBTree::BST_insert(Node *root, Node *ptr) {
    if (root == nullptr)
        return ptr;

    if (ptr->data < root->data) {
        root->left = BST_insert(root->left, ptr);
        root->left->parent = root;
    } else if (ptr->data > root->data) {
        root->right = BST_insert(root->right, ptr);
        root->right->parent = root;
    }
    return root;
}


void RBTree::deleteValue(int data) {
    Node *node = BST_delete(root, data);

    // Fixing violation after deletion
    if (node == nullptr)
        return;

    if (node == root) {
        root = nullptr;
        return;
    }

    if (node->color == RED || (node->left!=nullptr && node->left->color == RED) || (node->right!=nullptr && node->right->color == RED)) {
        Node *child = node->left != nullptr ? node->left : node->right;

        if (node == node->parent->left) {
            node->parent->left = child;
            if (child != nullptr){
                child->parent = node->parent;
                child->color = BLACK;
            }
            delete (node);
        } else {
            node->parent->right = child;
            if (child != nullptr){
                child->parent = node->parent;
                child->color = BLACK;
            }
            delete (node);
        }
    } else {
        Node *sister = nullptr;
        Node *parent = nullptr;
        Node *ptr = node;
        ptr->color = BLACK;
        while (ptr != root && ptr->color == BLACK) {
            parent = ptr->parent;
            if (ptr == parent->left) {
                sister = parent->right;
                if (sister!=nullptr && sister == RED) {
                    sister->color = BLACK;
                    parent->color = RED;
                    left_rotate(parent);
                } else {
                    if ( (sister->left != nullptr && sister->left->color == BLACK ) && (sister->right != nullptr && sister->right->color == BLACK )) {
                        sister->color = RED;
                        parent->color = BLACK;
                        ptr = parent;
                    } else {
                        if (sister->right != nullptr && sister->right->color == BLACK ) {
                            if (sister->left != nullptr) sister->left->color = BLACK;
                            sister->color = RED;
                            right_rotate(sister);
                            sister = parent->right;
                        }
                        if (sister != nullptr) sister->color = parent->color;
                        parent->color = BLACK;
                        if (sister->right != nullptr) sister->right->color = BLACK;
                        left_rotate(parent);
                        break;
                    }
                }
            } else {
                sister = parent->left;
                if (sister!=nullptr && sister == RED) {
                    sister->color = BLACK;
                    parent->color = RED;
                    right_rotate(parent);
                    //***check***//
                } else {

                    if ( (sister->left != nullptr && sister->left->color == BLACK ) && (sister->right != nullptr && sister->right->color == BLACK )) {
                        sister->color = RED;
                        parent->color = BLACK;
                        ptr = parent;
                    } else {
                        if (sister->left != nullptr && sister->left->color == BLACK ) {
                            if (sister->right != nullptr) sister->right->color = BLACK;
                            sister->color = RED;
                            left_rotate(sister);
                            sister = parent->left;
                        }

                        if (sister != nullptr) sister->color = parent->color;
                        parent->color = BLACK;
                        if (sister->left != nullptr) sister->left->color = BLACK;
                        right_rotate(parent);
                        break;
                    }
                }
            }
        }
        if (node == node->parent->left)
            node->parent->left = nullptr;
        else
            node->parent->right = nullptr;
        delete(node);
        if (root!=nullptr) root->color = BLACK;
    }
    //Done fixing violation
}

Node* RBTree::BST_delete(Node *root, int data) {
    if (root == nullptr)
        return root;

    if (data < root->data)
        return BST_delete(root->left, data);

    if (data > root->data)
        return BST_delete(root->right, data);

    if (root->left == nullptr || root->right == nullptr)
        return root;

    Node *temp = find_min(root->right);
    root->data = temp->data;
    return BST_delete(root->right, temp->data);
}





void RBTree::left_rotate(Node *ptr) {
    Node *right_child = ptr->right;
    ptr->right = right_child->left;

    if (ptr->right != nullptr)
        ptr->right->parent = ptr;

    right_child->parent = ptr->parent;

    if (ptr->parent == nullptr)
        root = right_child;
    else if (ptr == ptr->parent->left)
        ptr->parent->left = right_child;
    else
        ptr->parent->right = right_child;

    right_child->left = ptr;
    ptr->parent = right_child;
}

void RBTree::right_rotate(Node *ptr) {
    Node *left_child = ptr->left;
    ptr->left = left_child->right;

    if (ptr->left != nullptr)
        ptr->left->parent = ptr;

    left_child->parent = ptr->parent;

    if (ptr->parent == nullptr)
        root = left_child;
    else if (ptr == ptr->parent->left)
        ptr->parent->left = left_child;
    else
        ptr->parent->right = left_child;

    left_child->right = ptr;
    ptr->parent = left_child;
}


Node *RBTree::find_min(Node *node) {

    Node *ptr = node;

    while (ptr->left != nullptr)
        ptr = ptr->left;

    return ptr;
}


void RBTree::inorder(Node *node) {

    if (node == NULL)
        return;
    inorder(node->left);
    if (node->parent != nullptr)
    cout << "key: " << node->data << " parent: " << node->parent->data << " color: " << ((node->color == RED) ? "red" : "black") << endl;
    else 
    cout << "key: " << node->data << " parent:  "  << " color: " << ((node->color == RED) ? "red" : "black") << endl;
    inorder(node->right);

}




int main(int argc, char *argv[])
{
    RBTree RB;

    // number of tasks
    int task_count;
    cin >> task_count;

    // mode and elements and key
    int mode, element_count, key;

    // a vector to store input for correct output
    vector<int> input;

    int input_number, iteration;

    for (int i = 0; i < task_count; i++)
    {
        // First pushback the `mode` number
        cin >> input_number;
        input.push_back(input_number);

        // Then pushback the number of this operation
        cin >> iteration;
        input.push_back(iteration);

        // Lastly pushback all the number followd
        for (int j = 0; j < iteration; j++)
        {
            cin >> input_number;
            input.push_back(input_number);
        }
    }

    int index = 0;


    while (task_count != 0)
    {
        mode = input[index];
        index++;


        if (mode == _INSERT)
        {
            element_count = input[index];
            index++;

            int print_index = index -1;
            cout << "Insert: ";
            for(int i=0; i<element_count-1; i++) cout << input[++print_index] << ", ";
            cout << input[++print_index] << endl;
            
            while (element_count)
            {
                key = input[index];
                index++;
                RB.insert(key);
                element_count -= 1;
            }
        }
        else if (mode == _DELETE)
        {
            element_count = input[index];
            index++;

            int print_index = index -1 ;
            cout << "Delete: ";
            for(int i=0; i<element_count-1; i++) cout << input[++print_index] << ", ";
            cout << input[++print_index] << endl;

            while (element_count)
            {
                key = input[index];
                index++;
                RB.deleteValue(key);
                element_count -= 1;
            }
        }
        else
        {
            cerr << "Error: Mode " << mode << "not defined !" << endl;
            return 1;
        }

        // printing the output
        RB.inorder(RB.root);

        task_count -= 1;
    }
    return 0;
}