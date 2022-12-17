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
    Node(int);
};

class RBTree
{
    public:
        void  left_rotate(Node *&);
        void  right_rotate(Node *&);
        void  fix_after_insert(Node *&);
        void  fix_after_delete(Node *&);

        Node* minValueNode(Node *&);
        Node* insertBST(Node *root, Node *ptr);
        Node* deleteBST(Node *&, int);

        //Constructor
        RBTree();

        void insert(int);
        void deleteValue(int);

        //Printing the output 
        void inorder(Node *node);

        Node *root;
};





Node::Node(int data) {
    this->data = data;
    color = RED;
    left = right = parent = nullptr;
}

RBTree::RBTree() {
    root = nullptr;
}

void RBTree::insert(int n) {
    Node *node = new Node(n);
    root = insertBST(root, node);
    fix_after_insert(node);
}
Node* RBTree::insertBST(Node *root, Node *ptr) {
    if (root == nullptr)
        return ptr;

    if (ptr->data < root->data) {
        root->left = insertBST(root->left, ptr);
        root->left->parent = root;
    } else if (ptr->data > root->data) {
        root->right = insertBST(root->right, ptr);
        root->right->parent = root;
    }

    return root;
}



void RBTree::left_rotate(Node *&ptr) {
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

void RBTree::right_rotate(Node *&ptr) {
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

void RBTree::fix_after_insert(Node *&ptr) {
    Node *parent = nullptr;
    Node *grandparent = nullptr;
    while ((ptr != root && ptr->color == RED ) && ( ptr->parent != nullptr && ptr->parent->color == RED) ){
        parent = ptr->parent;
        grandparent = parent->parent;
        if (parent == grandparent->left) {
            Node *uncle = grandparent->right;
            if (uncle != nullptr && uncle->color == RED) {
                uncle->color = BLACK;
                if (parent != nullptr) parent->color = BLACK;
                if (grandparent != nullptr) grandparent->color = RED;
                ptr = grandparent;
            } else {
                if (ptr == parent->right) {
                    left_rotate(parent);
                    ptr = parent;
                    parent = ptr->parent;
                }
                right_rotate(grandparent);
                swap(parent->color, grandparent->color);
                ptr = parent;
            }
        } else {
            Node *uncle = grandparent->left;
            if (uncle != nullptr && uncle->color == RED) {
                uncle->color = BLACK;
                if (parent != nullptr) parent->color = BLACK;
                if (grandparent != nullptr) grandparent->color = RED;
                ptr = grandparent;
            } else {
                if (ptr == parent->left) {
                    right_rotate(parent);
                    ptr = parent;
                    parent = ptr->parent;
                }
                left_rotate(grandparent);
                swap(parent->color, grandparent->color);
                ptr = parent;
            }
        }
    }
    if (root!= nullptr) root->color = BLACK;
}

void RBTree::fix_after_delete(Node *&node) {
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
        Node *sibling = nullptr;
        Node *parent = nullptr;
        Node *ptr = node;
        ptr->color = BLACK;
        while (ptr != root && ptr->color == BLACK) {
            parent = ptr->parent;
            if (ptr == parent->left) {
                sibling = parent->right;
                if (sibling!=nullptr && sibling == RED) {
                    sibling->color = BLACK;
                    parent->color = RED;
                    left_rotate(parent);
                } else {
                    if ( (sibling->left != nullptr && sibling->left->color == BLACK ) && (sibling->right != nullptr && sibling->right->color == BLACK )) {
                        sibling->color = RED;
                        parent->color = BLACK;
                        ptr = parent;
                    } else {
                        if (sibling->right != nullptr && sibling->right->color == BLACK ) {
                            if (sibling->left != nullptr) sibling->left->color = BLACK;
                            sibling->color = RED;
                            right_rotate(sibling);
                            sibling = parent->right;
                        }
                        if (sibling != nullptr) sibling->color = parent->color;
                        parent->color = BLACK;
                        if (sibling->right != nullptr) sibling->right->color = BLACK;
                        left_rotate(parent);
                        break;
                    }
                }
            } else {
                sibling = parent->left;
                if (sibling!=nullptr && sibling == RED) {
                    sibling->color = BLACK;
                    parent->color = RED;
                    right_rotate(parent);
                    //***check***//
                } else {

                    if ( (sibling->left != nullptr && sibling->left->color == BLACK ) && (sibling->right != nullptr && sibling->right->color == BLACK )) {
                        sibling->color = RED;
                        parent->color = BLACK;
                        ptr = parent;
                    } else {
                        if (sibling->left != nullptr && sibling->left->color == BLACK ) {
                            if (sibling->right != nullptr) sibling->right->color = BLACK;
                            sibling->color = RED;
                            left_rotate(sibling);
                            sibling = parent->left;
                        }

                        if (sibling != nullptr) sibling->color = parent->color;
                        parent->color = BLACK;
                        if (sibling->left != nullptr) sibling->left->color = BLACK;
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
}

Node* RBTree::deleteBST(Node *&root, int data) {
    if (root == nullptr)
        return root;

    if (data < root->data)
        return deleteBST(root->left, data);

    if (data > root->data)
        return deleteBST(root->right, data);

    if (root->left == nullptr || root->right == nullptr)
        return root;

    Node *temp = minValueNode(root->right);
    root->data = temp->data;
    return deleteBST(root->right, temp->data);
}

void RBTree::deleteValue(int data) {
    Node *node = deleteBST(root, data);
    fix_after_delete(node);
}

Node *RBTree::minValueNode(Node *&node) {

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