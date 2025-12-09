from ete3 import Tree
from ete3.treeview import TreeStyle
import sys

mitogex_path = sys.argv[1]
contree_path = sys.argv[2]

t = Tree(contree_path)

t.render(mitogex_path + '/Results/Phylogenetic/tree.png')
