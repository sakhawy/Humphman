#!/usr/bin/env python3

class BinaryTree:
    def __init__(self, root_obj):
        self.key = root_obj
        self.left_child = None
        self.right_child = None

    def insert_left(self, new_node):
        if self.left_child == None:
            self.left_child = new_node
        else:
            t = new_node
            t.left_child = self.left_child
            self.left_child = t

    def insert_right(self, new_node):
        if self.right_child == None:
            self.right_child = new_node
        else:
            t = new_node
            t.right_child = self.right_child
            self.right_child = t

    def get_right_child(self):
        return self.right_child

    def get_left_child(self):
        return self.left_child

    def set_root_val(self, obj):
        self.key = obj

    def get_root_val(self):
        return self.key

    def search(self, key):
        if self.key == key:
            return self
        else:
            if self.left_child:
                self.left_child.search(key)
            if self.right_child:
                self.right_child.search(key)

    def print_tree(self, level=0):
        if self:
            right = self.get_right_child()
            if right:
                right.print_tree(level+1)
            print('--' * level + str(self.get_root_val()))
            left = self.get_left_child()
            if left:
                left.print_tree(level+1)

    def __str__(self):
        return str(self.key)

    def __repr__(self):
        return str(self.key)

def build_huffman_tree(s):
    freq_list = []
    for i in s:
        if i not in [x[0] for x in freq_list]:
            freq_list.append((i, s.count(i)))

    ordered_nodes = []
    for i in freq_list:
        node = BinaryTree(i)
        ordered_nodes.append(node)

    ordered_nodes = sorted(ordered_nodes, key=lambda x: x.get_root_val()[1])

    while len(ordered_nodes) > 1:
        item1 = ordered_nodes.pop(0)
        item2 = ordered_nodes.pop(0)

        combined_node = BinaryTree(
            (
                item1.get_root_val()[0] + item2.get_root_val()[0], 
                item1.get_root_val()[1] + item2.get_root_val()[1]
            )
        )

        combined_node.insert_left(item1)
        combined_node.insert_right(item2)

        for i in range(len(ordered_nodes)):
            if combined_node.get_root_val()[1] <= ordered_nodes[i].get_root_val()[1]:
                ordered_nodes.insert(i, combined_node)
                break
            elif i == len(ordered_nodes) - 1:
                ordered_nodes.append(combined_node)
        
        if not ordered_nodes:
            ordered_nodes.append(combined_node)

    result = ordered_nodes[0]

    return result

if __name__ == '__main__':
    build_huffman_tree("I LOVE ABBA").print_tree()